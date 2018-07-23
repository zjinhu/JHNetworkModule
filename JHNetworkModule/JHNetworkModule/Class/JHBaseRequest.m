//
//  JHBaseRequest.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHBaseRequest.h"
#import "JHBaseModel.h"
@implementation JHBaseRequest
/*****************************APP线上环境地质*******************************/

static NSString *const HostURL = @"https://api.github.com/";

/************************************************************************/
///此处方法配合JHNetworkConfig使用,无害化嵌入环境
static NSString *const urlNetwork = @"JHNetworkSettingHostURL";
/************************************************************************/
#pragma mark - 请求的公共方法
+(NSString *)getURLWithName:(NSString *)name{
#ifdef DEBUG
    ///此处方法配合JHNetworkConfig使用,无害化嵌入环境
    NSString *url =  [[NSUserDefaults standardUserDefaults] objectForKey:urlNetwork];
    NSString *debugUrl =[NSString stringWithFormat:@"%@%@",url.length>0? url :HostURL, name];
    return debugUrl;
#else
    NSString *releaseUrl =[NSString stringWithFormat:@"%@%@", HostURL, name];
    return releaseUrl;
#endif
}

+(void)cookTheResponse:(id)responseObject
            modelClass:(Class)modelClass
               success:(JHRequestSuccess)success
               failure:(JHRequestFailure)failure{
    
    if([responseObject isKindOfClass:[NSDictionary class]]){
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSInteger code = [responseDict[@"code"] integerValue];
        if (code == 1) {
            //TODO: 此处判断错误码再进行相应的操作
        }else{
            if (modelClass) {
                ///此处多一步解包,也可以直接用原始数据
                NSDictionary *data = responseDict;
                if (data!=nil) {
                    NSError * err = nil;
                    JHBaseModel * resultModel = [[modelClass alloc] initWithDictionary:data error:&err];
                    success(resultModel);
                }
            }
            else{
                success(responseDict);
            }
        }
    }
}

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
                      failure:(JHRequestFailure)failure{
    return [JHNetworking request:[self getURLWithName:apiName] requestType:requestType parameters:parameter success:^(id responseObject) {
        [self cookTheResponse:responseObject modelClass:NSClassFromString(modelClass) success:success failure:failure];
    } failure:^(NSError *error) {
        failure(error);
    }];
}
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
                                   failure:(JHHttpRequestFailed)failure{
    return [JHNetworking uploadImagesWithURL:[self getURLWithName:apiName] parameters:parameters ImageDatas:imageDatas success:success failure:failure];
}
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
                          failure:(JHHttpRequestFailed)failure{
    return [JHNetworking uploadImageWithURL:[self getURLWithName:apiName] parameters:parameters withImage:image success:success failure:failure];
}


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
                                failure:(JHHttpRequestFailed)failure{
    return [JHNetworking downloadWithURL:[self getURLWithName:apiName] fileDir:fileDir progress:progress success:success failure:failure];
}
@end
