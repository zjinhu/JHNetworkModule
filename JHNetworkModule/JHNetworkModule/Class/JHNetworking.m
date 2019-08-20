//
//  JHNetworking.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
@implementation JHNetworking

#pragma makr - 开始监听网络连接
/**
 开始监测网络状态
 */
+ (void)load {
    [self startMonitoring];
}

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

+ (instancetype)sharedNetworking{
    static JHNetworking *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[JHNetworking alloc] init];
    });
    return handler;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //无条件地信任服务器端返回的证书。
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        self.securityPolicy = [AFSecurityPolicy defaultPolicy];
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        ((AFJSONResponseSerializer*)self.responseSerializer).removesKeysWithNullValues=YES;
        
        [self.requestSerializer setValue:@"application/x-www-form-urlencoded"  forHTTPHeaderField:@"Content-Type"];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*",nil];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        self.requestSerializer.HTTPShouldHandleCookies =YES;
    }
    return self;
}

- (void)dealloc {
    [self invalidateSessionCancelingTasks:YES];
}

#pragma mark - 其他配置
- (void)requestSerializerConfig:(JHNetworkConfig *)request{
    self.requestSerializer =request.requestSerializer==JHRequestSerializerJSON ? [AFJSONRequestSerializer serializer]:[AFHTTPRequestSerializer serializer];
}

- (void)headersAndTimeConfig:(JHNetworkConfig *)request{
    self.requestSerializer.timeoutInterval=request.timeoutInterval?request.timeoutInterval:30;
    
    if ([[request mutableHTTPRequestHeaders] allKeys].count>0) {
        [[request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [self.requestSerializer setValue:value forHTTPHeaderField:field];
        }];
    }
}
#pragma mark - 取消请求
- (void)cancelRequest:(NSString *)URLString completion:(JHCancelRequestBlock)completion{
    __block NSString *currentUrlString=nil;
    BOOL results;
    @synchronized (self.tasks) {
        [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[task.currentRequest URL] absoluteString] isEqualToString:[URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]) {
                currentUrlString =[[task.currentRequest URL] absoluteString];
                [task cancel];
                *stop = YES;
            }
        }];
    }
    if (currentUrlString==nil) {
        results=NO;
    }else{
        results=YES;
    }
    completion ? completion(results,currentUrlString) : nil;
}
#pragma mark - GET/POST/PUT/PATCH/DELETE
- (NSURLSessionDataTask *)request:(JHNetworkConfig *)request
                    progressBlock:(void (^)(NSProgress *))progressBlock
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    
    [self requestSerializerConfig:request];
    [self headersAndTimeConfig:request];
    
    NSString *URLString=[request.URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if (request.requestType==JHRequestType_Post) {
        return [self POST:URLString parameters:request.parameters progress:progressBlock success:success failure:failure];
    }else if (request.requestType==JHRequestType_Put){
        return [self PUT:URLString parameters:request.parameters success:success failure:failure];
    }else if (request.requestType==JHRequestType_Patch){
        return [self PATCH:URLString parameters:request.parameters success:success failure:failure];
    }else if (request.requestType==JHRequestType_Delete){
        return [self DELETE:URLString parameters:request.parameters success:success failure:failure];
    }else{
        return [self GET:URLString parameters:request.parameters progress:progressBlock success:success failure:failure];
    }
}
#pragma mark - upload
- (NSURLSessionDataTask *)uploadWithRequest:(JHNetworkConfig *)request
                              progressBlock:(void (^)(NSProgress *))progressBlock
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    
    NSString *URLString=[request.URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURLSessionDataTask *uploadTask = [self POST:URLString parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [request.uploadDatas enumerateObjectsUsingBlock:^(JHUploadDataConfig *obj, NSUInteger idx, BOOL *stop) {
            if (obj.fileData) {
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                } else {
                    [formData appendPartWithFormData:obj.fileData name:obj.name];
                }
            } else if (obj.fileURL) {
                
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:nil];
                } else {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name error:nil];
                }
                
            }
        }];
        
    } progress:^(NSProgress * uploadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            progressBlock ? progressBlock(uploadProgress) : nil;
        });
    } success:success failure:failure];
    return uploadTask;
}

#pragma mark - DownLoad
- (NSURLSessionDownloadTask *)downloadWithRequest:(JHNetworkConfig *)request
                                    progressBlock:(void (^)(NSProgress *downloadProgress)) progressBlock
                                completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    NSString *URLString=[request.URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    [self headersAndTimeConfig:request];
    
    NSURL *downloadFileSavePath;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:request.downloadSavePath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadFileSavePath = [NSURL fileURLWithPath:[NSString pathWithComponents:@[request.downloadSavePath, fileName]] isDirectory:NO];
    } else {
        downloadFileSavePath = [NSURL fileURLWithPath:request.downloadSavePath isDirectory:NO];
    }
    NSURLSessionDownloadTask *dataTask = [self downloadTaskWithRequest:urlRequest progress:^(NSProgress * downloadProgress) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            progressBlock ? progressBlock(downloadProgress) : nil;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * targetPath, NSURLResponse * response) {
        return downloadFileSavePath;
    } completionHandler:completionHandler];
    
    [dataTask resume];
    return dataTask;
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
- (NSURLSessionDownloadTask *)downloadWithURL:(NSString *)URL
                                      fileDir:(NSString *)fileDir
                                     fileName:(NSString *)fileName
                                     progress:(JHHttpProgress)progress
                                      success:(void(^)(NSString *filePath))success
                                      failure:(void (^)(NSError *error))failure{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    
    NSURLSessionDownloadTask *dataTask = [self downloadTaskWithRequest:request progress:^(NSProgress * downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * targetPath, NSURLResponse * response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        //        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        NSString *filePath = [downloadDir stringByAppendingPathComponent:fileName];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSDictionary *dic = httpResponse.allHeaderFields;
        NSString *contentType = dic[@"Content-Type"];
        if ([contentType containsString:@"json"]) {
            NSError *err = [NSError errorWithDomain:@"json" code:2019 userInfo:nil];
            if(failure) {failure(err) ; return ;};
        }
        if(failure && error) {failure(error) ; return ;};
        success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
        
    }];
    
    //开始下载
    [dataTask resume];
    
    return dataTask;
}
@end

