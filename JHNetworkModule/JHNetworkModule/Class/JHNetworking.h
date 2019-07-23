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
 取消请求任务
 @param urlString           协议接口
 */
- (void)cancelRequest:(NSString *)urlString  completion:(JHCancelRequestBlock)completion;

@end
NS_ASSUME_NONNULL_END
