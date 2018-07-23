//
//  JHNetworking.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHNetworking.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
@implementation JHNetworking
    
static BOOL _isOpenLog;   // 是否已开启日志打印
static NSMutableArray *_allSessionTask;
static AFHTTPSessionManager *_sessionManager;
    
+ (JHNetworking *)sharedNetworking{
    static JHNetworking *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[JHNetworking alloc] init];
    });
    return handler;
}
    
#pragma makr - 开始监听网络连接
+ (void)startMonitoring{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
    // 当网络状态改变了, 就会调用这个block
    switch (status){
        case AFNetworkReachabilityStatusUnknown: // 未知网络
            [JHNetworking sharedNetworking].networkStats=StatusUnknown;
            break;
        case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
            [JHNetworking sharedNetworking].networkStats=StatusNotReachable;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
            [JHNetworking sharedNetworking].networkStats=StatusReachableViaWWAN;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
            [JHNetworking sharedNetworking].networkStats=StatusReachableViaWiFi;
            break;
            }
    }];
    [mgr startMonitoring];
}
    
+ (void)openLog {
    _isOpenLog = YES;
}
    
+ (void)closeLog {
    _isOpenLog = NO;
}
    
+ (void)cancelAllRequest {
    // 锁操作
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}
    
+ (void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) { return; }
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}
+ (__kindof NSURLSessionTask *)request:(NSString *)URL
                           requestType:(JHRequestType)requestType
                            parameters:(id)parameters
                               success:(JHHttpRequestSuccess)success
                               failure:(JHHttpRequestFailed)failure{
    switch (requestType) {
        case JHRequestType_Post:
            return [self POST:URL parameters:parameters success:success failure:failure];
            break;
            
        default:
            return [self GET:URL parameters:parameters success:success failure:failure];
            break;
    }
}
#pragma mark - GET请求无缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
                  success:(JHHttpRequestSuccess)success
                  failure:(JHHttpRequestFailed)failure {
    
    NSURLSessionTask *sessionTask = [_sessionManager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            NSLog(@"url = %@, parameters = %@, responseObject = %@", URL, parameters,responseObject);
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (_isOpenLog) {
            NSLog(@"url = %@, parameters = %@, error = %@", URL, parameters, error);
            
        }
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
        
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
    
}
#pragma mark - POST请求无缓存
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
                   success:(JHHttpRequestSuccess)success
                   failure:(JHHttpRequestFailed)failure {
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (_isOpenLog) {
            NSLog(@"url = %@, parameters = %@, responseObject = %@", URL, parameters,responseObject);
            
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (_isOpenLog) {
            NSLog(@"url = %@, parameters = %@, error = %@", URL, parameters, error);
        }
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
        
    }];
    
    // 添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}
    /**
     存储着所有的请求task数组
     */
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}
/**
 *  上传单张图片
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param image     图片
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (NSURLSessionTask *)uploadImageWithURL:(NSString *)URL
                              parameters:(id)parameters
                               withImage:(UIImage *)image
                                 success:(JHHttpRequestSuccess)success
                                 failure:(JHHttpRequestFailed)failure{
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        if ((imageData.length > 0.2*(1024*1024))) {
            //小于200k不缩放   大于1M 0.5比例压缩  小于1M 0.7比例压缩
            double scale =imageData.length>(1024*1024)?.5:.7;
            UIImage *image =[UIImage imageWithData:imageData];
            imageData = UIImageJPEGRepresentation(image, scale);
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString  stringWithFormat:@"%@_%i.%@", dateString,arc4random(),[self contentTypeWithImageData:imageData]];
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:[NSString stringWithFormat:@"image/%@",[self contentTypeWithImageData:imageData]]]; //
        (failure && error) ? failure(error) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //        QQLog(@"上传进度:%.2f%%",100.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            NSLog(@"url = %@, parameters = %@, responseObject = %@", URL, parameters,responseObject);
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            NSLog(@"url = %@, parameters = %@, error = %@", URL, parameters, error);
        }
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}

+ (NSURLSessionTask *)uploadImageDataWithURL:(NSString *)URL
                                  parameters:(id)parameters
                                   ImageData:(NSData *)ImageData
                                     success:(JHHttpRequestSuccess)success
                                     failure:(JHHttpRequestFailed)failure{
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data =nil;
        NSData *tempData = ImageData;
        if ([self isGifWithImageData:tempData]||(tempData.length < 0.2*(1024*1024))) {
            data=ImageData;
        }else{
            //小于200k不缩放   大于1M 0.5比例压缩  小于1M 0.7比例压缩
            double scale =tempData.length>(1024*1024)?.5:.7;
            UIImage *image =[UIImage imageWithData:tempData];
            data = UIImageJPEGRepresentation(image, scale);
        }
        //        NSLog(@"tempData%lu--data%lu",(unsigned long)ImageData.length,(unsigned long)data.length);
        //            UIImageJPEGRepresentation(image, 0.3);
        // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
        // 要解决此问题，
        // 可以在上传时使用当前的系统事件作为文件名
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString  stringWithFormat:@"%@_%i.%@", dateString,arc4random(),[self contentTypeWithImageData:data]];
        /*
         *该方法的参数
         1. appendPartWithFileData：要上传的照片[二进制流]
         2. name：对应网站上处理文件的字段（比如upload）
         3. fileName：要保存在服务器上的文件名
         4. mimeType：上传的文件的类型
         */
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:[NSString stringWithFormat:@"image/%@",[self contentTypeWithImageData:data]]]; //
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //        NSLog(@"上传进度:%.2f%%",100.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            NSLog(@"responseObject = %@",responseObject);
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            NSLog(@"error = %@",error);
            
        }
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}
/**
 *  上传单/多张图片
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param imageDatas     图片数组
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                                       parameters:(id)parameters
                                       ImageDatas:(NSArray *)imageDatas
                                          success:(JHHttpRequestSuccess)success
                                          failure:(JHHttpRequestFailed)failure{
    // －－－－－－－－－－－－－－－－－－－－－－－－－－－－上传图片－－－－
    // 基于AFN3.0+ 封装的HTPPSession句柄
    // 在parameters里存放照片以外的对象
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
        // 这里的images是你存放图片的数组
        for (int i = 0; i < imageDatas.count; i++) {
            //            UIImage *image = images[i];
            NSData *imageData =nil;
            NSData *tempData = imageDatas[i];
            if ([self isGifWithImageData:tempData]||(tempData.length < 0.2*(1024*1024))) {
                imageData=imageDatas[i];
            }else{
                //小于200k不缩放   大于1M 0.5比例压缩  小于1M 0.7比例压缩
                double scale =tempData.length>(1024*1024)?.5:.7;
                UIImage *image =[UIImage imageWithData:tempData];
                imageData = UIImageJPEGRepresentation(image, scale);
            }
            //            UIImageJPEGRepresentation(image, 0.3);
            // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
            // 要解决此问题，
            // 可以在上传时使用当前的系统事件作为文件名
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString  stringWithFormat:@"%@_%i.%@", dateString,arc4random(),[self contentTypeWithImageData:imageData]];
            /*
             *该方法的参数
             1. appendPartWithFileData：要上传的照片[二进制流]
             2. name：对应网站上处理文件的字段（比如upload）
             3. fileName：要保存在服务器上的文件名
             4. mimeType：上传的文件的类型
             */
            [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:[NSString stringWithFormat:@"image/%@",[self contentTypeWithImageData:imageData]]]; //
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //        NSLog(@"上传进度:%.2f%%",100.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {NSLog(@"responseObject = %@",responseObject);}
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {NSLog(@"error = %@",error);}
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}

/**
 *  上传文件
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param fileData   文件
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                        fileData:(NSData *)fileData
                                         success:(JHHttpRequestSuccess)success
                                         failure:(JHHttpRequestFailed)failure{
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        NSError *error = nil;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString  stringWithFormat:@"%@_%i.MP4", dateString,arc4random()];
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"video/mp4"];
        (failure && error) ? failure(error) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //        QQLog(@"上传进度:%.2f%%",100.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {NSLog(@"responseObject = %@",responseObject);}
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {NSLog(@"error = %@",error);}
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}
/**
 *  下载文件
 *
 *  @param URL      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(JHHttpProgress)progress
                                       success:(void(^)(NSString *filePath))success
                                       failure:(JHHttpRequestFailed)failure{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self allSessionTask] removeObject:downloadTask];
        if(failure && error) {failure(error) ; return ;};
        success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
        
    }];
    //开始下载
    [downloadTask resume];
    // 添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil ;
    
    return downloadTask;
}
#pragma mark - 判断图片种类

+ (BOOL)isGifWithImageData: (NSData *)data {
    if ([[self contentTypeWithImageData:data] isEqualToString:@"gif"]) {
        return YES;
    }
    return NO;
}
+ (NSString *)contentTypeWithImageData: (NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}

#pragma mark - 初始化AFHTTPSessionManager相关属性
    /**
     开始监测网络状态
     */
+ (void)load {
    [self startMonitoring];
}
    /**
     *  所有的HTTP请求共享一个AFHTTPSessionManager
     *  原理参考地址:http://www.jianshu.com/p/5969bbb4af9f
     */
+ (void)initialize {
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.timeoutInterval = 10.f;
    //    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [_sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded"  forHTTPHeaderField:@"Content-Type"];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    
    ((AFJSONResponseSerializer*)_sessionManager.responseSerializer).removesKeysWithNullValues=YES;
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    _sessionManager.requestSerializer.HTTPShouldHandleCookies =YES;
}
    
#pragma mark - 重置AFHTTPSessionManager相关属性
    
+ (void)setAFHTTPSessionManagerProperty:(void (^)(AFHTTPSessionManager *))sessionManager {
    sessionManager ? sessionManager(_sessionManager) : nil;
}
    
+ (void)setRequestSerializer:(JHRequestSerializer)requestSerializer {
    _sessionManager.requestSerializer = requestSerializer==JHRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}
    
+ (void)setResponseSerializer:(JHResponseSerializer)responseSerializer {
    _sessionManager.responseSerializer = responseSerializer==JHResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}
    
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time {
    _sessionManager.requestSerializer.timeoutInterval = time;
}
    
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}
    
+ (void)openNetworkActivityIndicator:(BOOL)open {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}
    
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName {
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 如果需要验证自建证书(无效证书)，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    // 是否需要验证域名，默认为YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    [_sessionManager setSecurityPolicy:securityPolicy];
}

@end

#pragma mark - NSDictionary,NSArray的分类
/*
 ************************************************************************************
 *新建NSDictionary与NSArray的分类, 控制台打印json数据中的中文
 ************************************************************************************
 */

#ifdef DEBUG
@implementation NSArray (ShowLog)
    
- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    [strM appendString:@")"];
    
    return strM;
}
    
@end

@implementation NSDictionary (ShowLog)
    
- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    
    [strM appendString:@"}\n"];
    
    return strM;
}
    @end
#endif

