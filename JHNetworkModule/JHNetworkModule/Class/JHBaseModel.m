//
//  JHBaseModel.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHBaseModel.h"

@implementation JHBaseModel

+ (void)saveWithDic:(NSDictionary *)dic{
    //    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:AccountInfoModelSaveKey];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveModel{
    //    [[NSUserDefaults standardUserDefaults] setObject:[self getCurrentDic] forKey:AccountInfoModelSaveKey];
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

-(NSDictionary *)getCurrentDic{
    NSString *json = [self yy_modelToJSONString];
    return [self dictionaryWithJsonString:json];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
