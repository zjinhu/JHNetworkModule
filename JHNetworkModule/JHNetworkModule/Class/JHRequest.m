//
//  JHRequest.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHRequest.h"
#define NetworkHost        @""

@implementation JHRequest
+ (NSURLSessionTask *)requestManager:(id)parameters
                          requestApi:(NSString *)requestApi
                         requestType:(JHRequestType)requestType
                          modelClass:(NSString *)modelClass
                             success:(JHRequestSuccess)success
                             failure:(JHRequestFailure)failure{
    
    switch (requestType) {
        case JHRequestType_Get:
        return [self getWithURL:[self getInterfaceWithName:requestApi] parameters:parameters modelClass:NSClassFromString(modelClass) success:success failure:failure];
        break;
        case JHRequestType_Post:
        return [self postWithURL:[self getInterfaceWithName:requestApi] parameters:parameters modelClass:NSClassFromString(modelClass) success:success failure:failure];
        break;
        default:
        break;
    }
    return nil;
}
    
+(NSString *)getInterfaceWithName:(NSString *)name{
    NSString *url =[NSString stringWithFormat:@"%@/%@", NetworkHost, name];
    return url;
}
@end
