//
//  JHBaseModel.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHBaseModel.h"

@implementation JHBaseModel
//+(BOOL)propertyIsOptional:(NSString*)propertyName{
//    return YES;
//}
//
//+(JSONKeyMapper*)keyMapper{
//    return [JSONKeyMapper mapperForSnakeCase];
//}
+ (void)saveWithDic:(NSDictionary *)dic{
//    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:AccountInfoModelSaveKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}
    
+ (void)remove{
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AccountInfoModelSaveKey];
}
    
+ (__kindof JHBaseModel *)getCurrentSaveModel{
//    NSDictionary * dic= [[NSUserDefaults standardUserDefaults] objectForKey:AccountInfoModelSaveKey];
//    AccountInfoModel * model  = [[AccountInfoModel alloc] initWithDictionary:dic error:nil];
//    return model;
    return nil;
}
@end
