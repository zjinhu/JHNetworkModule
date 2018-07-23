//
//  JHBaseRequest.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHBaseRequest.h"
#import "JHBaseModel.h"
@implementation JHBaseRequest
static NSString *const HostURL = @"https://api.github.com/";
#pragma mark - 请求的公共方法
+(NSString *)getURLWithName:(NSString *)name{
    NSString *url =[NSString stringWithFormat:@"%@%@", HostURL, name];
    return url;
}

+ (NSURLSessionTask *)requestWithURL:(NSString *)URL
                          parameters:(id)parameter
                         requestType:(JHRequestType)requestType
                          modelClass:(NSString *)modelClass
                             success:(JHRequestSuccess)success
                             failure:(JHRequestFailure)failure{
 
    return [JHNetworking request:URL requestType:requestType parameters:parameter success:^(id responseObject) {
        [self cookTheResponse:responseObject modelClass:NSClassFromString(modelClass) success:success failure:failure];
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
