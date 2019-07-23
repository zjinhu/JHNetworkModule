//
//  JHNetworkConst.h
//  JHNetworkModule
//
//  Created by 狄烨 . on 23/7/2019.
//  Copyright © 2019 HU. All rights reserved.
//
#ifndef JHNetworkConst_h
#define JHNetworkConst_h

#ifdef DEBUG
#define CNLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define CNLog(...)
#endif

#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

@class JHNetworkConfig,JHQueueNetworkConfig;

typedef NS_ENUM(NSUInteger, JHNetworkStatus) {
    StatusUnknown           = -1, //未知网络
    StatusNotReachable      = 0,    //没有网络
    StatusReachableViaWWAN  = 1,    //手机自带网络
    StatusReachableViaWiFi  = 2     //wifi
};

typedef NS_ENUM(NSUInteger, JHRequestSerializer) {
    /** 设置请求数据为JSON格式*/
    JHRequestSerializerJSON,
    /** 设置请求数据为二进制格式*/
    JHRequestSerializerHTTP,
};

typedef NS_ENUM(NSUInteger, JHResponseSerializer) {
    /** 设置响应数据为JSON格式*/
    JHResponseSerializerJSON,
    /** 设置响应数据为二进制格式*/
    JHResponseSerializerHTTP,
};

typedef NS_ENUM(NSInteger, JHRequestType){
    /**GET请求*/
    JHRequestType_Get = 0,
    /**POST请求*/
    JHRequestType_Post,
    /**Upload请求*/
    JHRequestType_Upload,
    /**DownLoad请求*/
    JHRequestType_DownLoad,
    /**PUT请求*/
    JHRequestType_Put,
    /**PATCH请求*/
    JHRequestType_Patch,
    /**DELETE请求*/
    JHRequestType_Delete
};

/** 请求成功的Block */
typedef void(^JHHttpRequestSuccess)(id responseObject);
/** 请求失败的Block */
typedef void(^JHHttpRequestFailed)(NSError *error);
/** 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小*/
typedef void (^JHHttpProgress)(NSProgress *progress);
/** 请求配置的Block */
typedef void (^JHNetworkConfigBlock)(JHNetworkConfig * requestConfig);
/** 请求取消的Block */
typedef void (^JHCancelRequestBlock)(BOOL results,NSString * urlString);

#endif /* JHNetworkConst_h */
