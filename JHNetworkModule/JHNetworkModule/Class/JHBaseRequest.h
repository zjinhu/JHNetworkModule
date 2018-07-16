//
//  JHBaseRequest.h
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 
 这是对AFNetworking的第二层隔离封装,简单化封装各种网络请求方法,并且统一处理回调逻辑
 
 */
/**
 请求成功的block
 @param response 响应体数据 当传需要解析的model时返回model model为nil则表示不需要解析,返回字典
 */
typedef void(^JHRequestSuccess)(id response);
/**
 请求失败的block
 @param error 扩展信息
 */
typedef void(^JHRequestFailure)(NSError *error);

@interface JHBaseRequest : NSObject

/**
请求子类调用父类的GET请求
@param URL         完整请求地址
@param parameter   传递参数
@param modelClass model类名称,不传则返回解析后的字典
@param success  请求成功回调
@param failure 请求失败回调
@return     ...
*/
+(NSURLSessionTask *)getWithURL:(NSString *)URL
                     parameters:(id)parameter
                     modelClass:(Class)modelClass
                        success:(JHRequestSuccess)success
                        failure:(JHRequestFailure)failure;
/**
请求子类调用父类的POST请求
@param URL         完整请求地址
@param parameter   传递参数
@param modelClass model类名称,不传则返回解析后的字典
@param success  请求成功回调
@param failure 请求失败回调
@return     ...
*/
+(NSURLSessionTask *)postWithURL:(NSString *)URL
                      parameters:(id)parameter
                      modelClass:(Class)modelClass
                         success:(JHRequestSuccess)success
                         failure:(JHRequestFailure)failure;

@end
