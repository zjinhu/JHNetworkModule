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
@implementation NSArray (PP)
    
- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    [strM appendString:@")"];
    
    return strM;
}
    
    @end

@implementation NSDictionary (PP)
    
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
