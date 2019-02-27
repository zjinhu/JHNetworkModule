//
//  JHFaceModel.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHFaceModel.h"

@implementation JHFaceModel

@end

@implementation JHCityModel
@end

@implementation JHAllCityModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"results" : [JHCityModel class]};
}
@end
