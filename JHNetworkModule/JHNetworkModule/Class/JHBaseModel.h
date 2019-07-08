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
///删除存储,子类去实现
+ (void)remove;
//读取存储,子类去实现
+ (__kindof JHBaseModel *)getCurrentSaveModel;

-(NSDictionary *)getCurrentDic;
@end
