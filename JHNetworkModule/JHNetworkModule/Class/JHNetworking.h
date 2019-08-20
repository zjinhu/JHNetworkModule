//
//  JHNetworking.h
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "JHNetworkConst.h"
#import "JHNetworkConfig.h"
NS_ASSUME_NONNULL_BEGIN
@interface JHNetworking : AFHTTPSessionManager
/**
 *  单例
 */
+ (instancetype)sharedNetworking;

/**
 *  获取网络
 */
@property (nonatomic,assign)JHNetworkStatus networkStats;

/**
 *  开启网络监测
 */
+ (void)startMonitoring;

/**
 发起网络请求
 
 @param request JHNetworkConfig
 @param progressBlock 进度
 @param success 成功回调
 @param failure 失败回调
 @return task
 */
- (NSURLSessionDataTask *)request:(JHNetworkConfig *)request
                    progressBlock:(void (^)(NSProgress *))progressBlock
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 上传文件
 
 @param request JHNetworkConfig
 @param progressBlock 进度
 @param success 成功回调
 @param failure 失败回调
 @return task
 */
- (NSURLSessionDataTask *)uploadWithRequest:(JHNetworkConfig *)request
                              progressBlock:(void (^)(NSProgress *))progressBlock
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 下载文件
 
 @param request JHNetworkConfig
 @param progressBlock 进度
 @param completionHandler 回调
 @return task
 */
- (NSURLSessionDownloadTask *)downloadWithRequest:(JHNetworkConfig *)request
                                    progressBlock:(void (^)(NSProgress *downloadProgress)) progressBlock
                                completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
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
                                      failure:(void (^)(NSError *error))failure;
/**
 取消请求任务
 @param urlString           协议接口
 */
- (void)cancelRequest:(NSString *)urlString  completion:(JHCancelRequestBlock)completion;

@end
NS_ASSUME_NONNULL_END
