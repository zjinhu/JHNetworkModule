//
//  JHBaseRequest.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHBaseRequest.h"
#import "JHNetworking.h"
#import "JHBaseModel.h"
@implementation JHBaseRequest
    
#pragma mark - 请求的公共方法
+(NSURLSessionTask *)getWithURL:(NSString *)URL
                     parameters:(id)parameter
                     modelClass:(Class)modelClass
                        success:(JHRequestSuccess)success
                        failure:(JHRequestFailure)failure{
    // 发起请求
    return [JHNetworking GET:URL parameters:parameter success:^(id responseObject) {
        [self cookTheResponse:responseObject modelClass:modelClass success:success failure:failure];
    } failure:^(NSError *error) {
        failure(error);
    }];
}
    
+(NSURLSessionTask *)postWithURL:(NSString *)URL
                      parameters:(id)parameter
                      modelClass:(Class)modelClass
                         success:(JHRequestSuccess)success
                         failure:(JHRequestFailure)failure{
    // 发起请求
    return [JHNetworking POST:URL parameters:parameter success:^(id responseObject) {
        // 在这里你可以根据项目自定义其他一些重复操作,比如加载页面时候的等待效果, 提醒弹窗....
        [self cookTheResponse:responseObject modelClass:modelClass success:success failure:failure];
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
    
+(void)cookTheResponse:(id)responseObject
            modelClass:(Class)modelClass
               success:(JHRequestSuccess)success
               failure:(JHRequestFailure)failure{

    if([responseObject isKindOfClass:[NSDictionary class]]){
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSInteger code = [responseDict[@"code"] integerValue];
        if (code == 1) {
            //TODO: 此处判断错误码再进行相应的操作
        }else{
            if (modelClass) {
                ///此处多一步解包,也可以直接用原始数据
                NSDictionary *data = responseDict;
                if (data!=nil) {
                    NSError * err = nil;
                    JHBaseModel * resultModel = [[modelClass alloc] initWithDictionary:data error:&err];
                    success(resultModel);
                }
            }
            else{
                success(responseDict);
            }
        }
    }
}
    
@end
