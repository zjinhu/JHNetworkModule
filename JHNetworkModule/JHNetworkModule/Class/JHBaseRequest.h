//
//  JHBaseRequest.h
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHNetworking.h"
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
 获取完整URL
 @param name         api名称
 @return     URL
 */
+(NSString *)getURLWithName:(NSString *)name;
/**
请求
@param apiName     api名字
@param parameter   传递参数
@param modelClass model类名称,不传则返回解析后的字典
@param success  请求成功回调
@param failure 请求失败回调
@return     ...
*/
+ (NSURLSessionTask *)request:(NSString *)apiName
                          parameters:(id)parameter
                         requestType:(JHRequestType)requestType
                          modelClass:(NSString *)modelClass
                             success:(JHRequestSuccess)success
                             failure:(JHRequestFailure)failure;
/**
 *  上传单/多张图片
 *
 *  @param apiName        请求地址
 *  @param parameters 请求参数
 *  @param imageDatas     图片数组
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+(__kindof NSURLSessionTask *)uploadImages:(NSString *)apiName
                                       parameters:(id)parameters
                                       ImageDatas:(NSArray *)imageDatas
                                          success:(JHHttpRequestSuccess)success
                                          failure:(JHHttpRequestFailed)failure;
/**
 *  上传单张图片
 *
 *  @param apiName        请求地址
 *  @param parameters 请求参数
 *  @param image     图片
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (NSURLSessionTask *)uploadImage:(NSString *)apiName
                              parameters:(id)parameters
                               withImage:(UIImage *)image
                                 success:(JHHttpRequestSuccess)success
                                 failure:(JHHttpRequestFailed)failure;
 

/**
 *  下载文件
 *
 *  @param apiName      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)download:(NSString *)apiName
                                       fileDir:(NSString *)fileDir
                                      progress:(JHHttpProgress)progress
                                       success:(void(^)(NSString *filePath))success
                                       failure:(JHHttpRequestFailed)failure;
@end
