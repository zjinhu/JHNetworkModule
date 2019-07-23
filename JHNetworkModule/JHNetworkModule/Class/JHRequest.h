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

@end
