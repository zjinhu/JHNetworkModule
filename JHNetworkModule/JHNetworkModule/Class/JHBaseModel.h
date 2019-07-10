//
//  JHBaseModel.h
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

//#import <JSONModel/JSONModel.h>
#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
@interface JHBaseModel : NSObject
///将model存储,子类去实现
+ (void)saveWithDic:(NSDictionary *)dic;
- (void)saveModel;
///删除存储,子类去实现
+ (void)remove;
//读取存储,子类去实现
+ (__kindof JHBaseModel *)getCurrentSaveModel;
//Model 转 字典
-(NSDictionary *)getCurrentDic;
@end
