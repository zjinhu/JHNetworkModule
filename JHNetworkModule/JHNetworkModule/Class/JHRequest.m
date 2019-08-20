//
//  JHBaseRequest.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHRequest.h"
#import "JHBaseModel.h"
#import <YYModel/YYModel.h>
@implementation JHRequest

static BOOL _isOpenLog;   // 是否已开启日志打印

+ (void)openLog {
    _isOpenLog = YES;
}

+ (void)closeLog {
    _isOpenLog = NO;
}

+ (void)requestWithConfig:(JHNetworkConfigBlock)config success:(JHHttpRequestSuccess)success failure:(JHHttpRequestFailed)failure{
    [self requestWithConfig:config progressBlock:nil success:success failure:failure];
}

+ (void)requestWithConfig:(JHNetworkConfigBlock)config progressBlock:(JHHttpProgress)progressBlock success:(JHHttpRequestSuccess)success failure:(JHHttpRequestFailed)failure {
    JHNetworkConfig *request=[[JHNetworkConfig alloc]init];
    config ? config(request) : nil;
    [self sendRequest:request progressBlock:progressBlock success:success failure:failure];
}

#pragma mark - 发起请求
+ (void)sendRequest:(JHNetworkConfig *)request progressBlock:(JHHttpProgress)progressBlock success:(JHHttpRequestSuccess)success failure:(JHHttpRequestFailed)failure{
    
    if([request.URLString isEqualToString:@""]||request.URLString==nil)return;
    
    if (request.requestType==JHRequestType_Upload) {
        [self sendUploadRequest:request progressBlock:progressBlock success:success failure:failure];
    }else if (request.requestType==JHRequestType_DownLoad){
        [self sendDownLoadRequest:request progressBlock:progressBlock success:success failure:failure];
    }else{
        [self sendHTTPRequest:request progressBlock:progressBlock success:success failure:failure];
    }
}

+ (void)sendUploadRequest:(JHNetworkConfig *)request progressBlock:(JHHttpProgress)progressBlock success:(JHHttpRequestSuccess)success failure:(JHHttpRequestFailed)failure{
    [[JHNetworking sharedNetworking] uploadWithRequest:request progressBlock:progressBlock success:^(NSURLSessionDataTask *task, id responseObject) {
        [self LogSuccess:request responseObject:responseObject];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self LogFailed:request error:error];
        failure ? failure(error) : nil;
    }];
}

+ (void)sendDownLoadRequest:(JHNetworkConfig *)request progressBlock:(JHHttpProgress)progressBlock success:(JHHttpRequestSuccess)success failure:(JHHttpRequestFailed)failure{
    [[JHNetworking sharedNetworking] downloadWithRequest:request progressBlock:progressBlock completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if(failure && error) {
            [self LogFailed:request error:error];
            failure(error) ;
            return ;
        };
        [self LogSuccess:request responseObject:filePath];
        success ? success([filePath path]) : nil;
    }];
}

+ (void)sendHTTPRequest:(JHNetworkConfig *)request progressBlock:(JHHttpProgress)progressBlock success:(JHHttpRequestSuccess)success failure:(JHHttpRequestFailed)failure{
    [[JHNetworking sharedNetworking] request:request progressBlock:^(NSProgress *progress) {
        progressBlock ? progressBlock(progress) : nil;
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self LogSuccess:request responseObject:responseObject];
        
        [self cookTheResponse:responseObject request:request success:success failure:failure];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self LogFailed:request error:error];
        failure ? failure(error) : nil;
    }];
}

+ (void)download:(NSString *)URLString
         fileDir:(NSString *)fileDir
        fileName:(NSString *)fileName
        progress:(JHHttpProgress)progress
         success:(void(^)(NSString *filePath))success
         failure:(JHHttpRequestFailed)failure{
    [[JHNetworking sharedNetworking] downloadWithURL:URLString
                                             fileDir:fileDir
                                            fileName:fileName
                                            progress:progress
                                             success:success
                                             failure:failure];
}

#pragma mark - 其他配置
+(void)cookTheResponse:(id)responseObject
               request:(JHNetworkConfig *)request
               success:(JHHttpRequestSuccess)success
               failure:(JHHttpRequestFailed)failure{
    
    
    if([responseObject isKindOfClass:[NSArray class]]){
        NSArray *responseArray = (NSArray *)responseObject;
        if (request.modelClass && request.modelClass.length>0) {
            NSArray *resultArray = [NSArray yy_modelArrayWithClass:NSClassFromString(request.modelClass) json:responseArray];
            success(resultArray);
        }else{
            success(responseArray);
        }
    }else if([responseObject isKindOfClass:[NSDictionary class]]){
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSInteger code = [responseDict[request.codeName] integerValue];
        NSString *message = responseDict[request.messageName];
        if (code == request.successCode) {
            if (request.modelClass && request.modelClass.length>0) {
                ///此处多一步解包,也可以直接用原始数据
                NSDictionary *data = responseDict;
                if (data!=nil) {
                    JHBaseModel * resultModel = [NSClassFromString(request.modelClass) yy_modelWithDictionary:data];
                    success(resultModel);
                }
            }else{
                success(responseDict);
            }
        }else{
            NSError *error = [NSError errorWithDomain:message?:@"" code:code userInfo:responseDict];
            failure(error);
        }
    }
}

+(void)LogProgress:(NSProgress *)progress{
    if (_isOpenLog) {
        CNLog(@"进度:%.2f%%",100.0 * progress.completedUnitCount/progress.totalUnitCount);
    }
}

+(void)LogSuccess:(JHNetworkConfig *)request responseObject:(id)responseObject{
    if (_isOpenLog) {
        CNLog(@"\n\n url = %@,\n\n parameters = %@,\n\n responseObject = %@", request.URLString, request.parameters,responseObject);
    }
}

+(void)LogFailed:(JHNetworkConfig *)request error:(NSError *)error{
    if (_isOpenLog) {
        CNLog(@"\n\n url = %@,\n\n  parameters = %@,\n\n  error = %@", request.URLString, request.parameters, error);
    }
}

+ (void)cancelRequest:(NSString *)URLString completion:(JHCancelRequestBlock)completion{
    if([URLString isEqualToString:@""]||URLString==nil)return;
    [[JHNetworking sharedNetworking]cancelRequest:URLString completion:completion];
}
@end


#ifdef DEBUG
@implementation NSDictionary (CNLog)

- (NSString *)descriptionWithLocale:(id)locale {
    NSString *logString;
    @try {
        
        logString=[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        
    } @catch (NSException *exception) {
        
        NSString *reason = [NSString stringWithFormat:@"reason:%@",exception.reason];
        logString = [NSString stringWithFormat:@"转换失败:\n%@,\n转换终止,输出如下:\n%@",reason,self.description];
        
    } @finally {
        
    }
    return logString;
}
@end
#endif
