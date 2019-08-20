//
//  JHBaseRequest.h
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHNetworking.h"
#import "JHNetworkConst.h"
@interface JHRequest : NSObject

/// 开启日志打印 (Debug级别)
+ (void)openLog;

/// 关闭日志打印,默认关闭
+ (void)closeLog;
/**
 *  请求方法 GET/POST/PUT/PATCH/DELETE
 *
 *  @param config           请求配置  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)requestWithConfig:(JHNetworkConfigBlock)config success:(JHHttpRequestSuccess)success failure:(JHHttpRequestFailed)failure;

/**
 *  请求方法 GET/POST/PUT/PATCH/DELETE/Upload/DownLoad
 *
 *  @param config           请求配置  Block
 *  @param progressBlock         请求进度  Block
 *  @param success          请求成功的 Block
 *  @param failure          请求失败的 Block
 */
+ (void)requestWithConfig:(JHNetworkConfigBlock)config progressBlock:(JHHttpProgress)progressBlock success:(JHHttpRequestSuccess)success failure:(JHHttpRequestFailed)failure;

/**
 取消请求任务
 
 @param URLString           协议接口
 @param completion          后续操作
 */
+ (void)cancelRequest:(NSString *)URLString completion:(JHCancelRequestBlock)completion;

/**
 *  下载文件
 *
 *  @param URLString      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 */
+ (void)download:(NSString *)URLString
         fileDir:(NSString *)fileDir
        fileName:(NSString *)fileName
        progress:(JHHttpProgress)progress
         success:(void(^)(NSString *filePath))success
         failure:(JHHttpRequestFailed)failure;

@end
