//
//  JHNetworkConfig.h
//  JHNetworkModule
//
//  Created by 狄烨 . on 23/7/2019.
//  Copyright © 2019 HU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHNetworkConst.h"
NS_ASSUME_NONNULL_BEGIN
@class JHUploadDataConfig;
@interface JHNetworkConfig : NSObject
/**
 *  用于标识不同类型的request
 */
@property (nonatomic,assign) JHRequestType requestType;

/**
 *  请求参数的类型
 */
@property (nonatomic,assign) JHRequestSerializer requestSerializer;

/**
 *  响应数据的类型
 */
@property (nonatomic,assign) JHResponseSerializer responseSerializer;
/**
 *  接口(请求地址)
 */
@property (nonatomic,copy) NSString * URLString;
/**
 *  需要生成Model的类名
 */
@property (nonatomic,copy) NSString * modelClass;
/**
 *  接口返回成功时的code码字段Key
 */
@property (nonatomic,copy) NSString * codeName;
/**
 *  接口返回成功时的请求信息码字段Key
 */
@property (nonatomic,copy) NSString * messageName;
/**
 *  接口返回成功时的code码,用于区分接口请求成功但是是返回的错误信息
 */
@property (nonatomic,assign) NSInteger successCode;
/**
 *  提供给外部配置参数使用
 */
@property (nonatomic,strong) id parameters;
/**
 *  设置超时时间  默认30秒
 *   The timeout interval, in seconds, for created requests. The default timeout interval is 15 seconds.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  存储路径 只有下载文件方法有用
 */
@property (nonatomic,copy,nullable) NSString *downloadSavePath;
/**
 *  为上传请求提供数据
 */
@property (nonatomic, strong, nullable) NSMutableArray<JHUploadDataConfig *> *uploadDatas;
/**
 *  用于维护 请求头的request对象
 */
@property ( nonatomic, strong) NSMutableDictionary * mutableHTTPRequestHeaders;

/**
 *  添加请求头
 *
 *  @param value value
 *  @param field field
 */
- (void)setValue:(NSString *)value forHeaderField:(NSString *)field;

/**
 *
 *  @param key request 对象
 *
 *  @return request 对象
 */
- (NSString *)objectHeaderForKey:(NSString *)key;

/**
 *  删除请求头的key
 *
 *  @param key key
 */
- (void)removeHeaderForkey:(NSString *)key;
//============================================================
/**
 *  上传文件生成表单,多次add会生成多个文件上传
 */
- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;

/**
 *  判断上传文件是不是gif
 */
- (BOOL)isGifWithImageData: (NSData *)fileData;
/**
 *  根据上传图片的文件返回文件类型 image/png
 */
- (NSString *)mimeTypeWithImageData: (NSData *)fileData;
/**
 *  返回上传图片的后缀   .png .jpeg 等等
 */
- (NSString *)imageTypeWithImageData: (NSData *)fileData;
@end

#pragma mark - JHUploadDataConfig
/**
 上传文件数据的类
 */
@interface JHUploadDataConfig : NSObject
/**
 文件对应服务器上的字段
 */
@property (nonatomic, copy) NSString * name;

/**
 文件名
 */
@property (nonatomic, copy, nullable) NSString *fileName;

/**
 图片文件的类型,例:png、jpeg....
 */
@property (nonatomic, copy, nullable) NSString *mimeType;

/**
 The data to be encoded and appended to the form data, and it is prior than `fileURL`.
 */
@property (nonatomic, strong, nullable) NSData *fileData;

/**
 The URL corresponding to the file whose content will be appended to the form, BUT, when the `fileData` is assigned，the `fileURL` will be ignored.
 */
@property (nonatomic, strong, nullable) NSURL *fileURL;

//注意:“fileData”和“fileURL”中的任何一个都不应该是“nil”，“fileName”和“mimeType”都必须是“nil”，或者同时被分配，

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData;
+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;
+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;
+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;
@end
NS_ASSUME_NONNULL_END
