//
//  JHRequest.h
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHBaseRequest.h"
/**
 
 这是对AFNetworking的第三层隔离封装,封装需要传递的参数进行完成的URL拼接,请求逻辑判断以及Model生成
 
 */
typedef NS_ENUM(NSInteger, JHRequestType){
    JHRequestType_Get = 0,
    JHRequestType_Post,
};
@interface JHRequest : JHBaseRequest
    
/**
使用这个方法做请求
@param parameters 请求参数
@param requestApi 请求链接名称,RestFul风格请自己拼接URL    内部会在前边拼接baseURL
@param requestType Get 或者 Post
@param modelClass Model名称
@param success 成功回调
@param failure 失败回调
*/
+ (NSURLSessionTask *)requestManager:(id)parameters
                          requestApi:(NSString *)requestApi
                         requestType:(JHRequestType)requestType
                          modelClass:(NSString *)modelClass
                             success:(JHRequestSuccess)success
                             failure:(JHRequestFailure)failure;
@end
