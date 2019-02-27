//
//  JHFaceModel.h
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "JHBaseModel.h"

@interface JHFaceModel : JHBaseModel
@property(nonatomic,strong) NSString *login;
@property(nonatomic,strong) NSString *nodeId;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) NSString *followingUrl;
@property(nonatomic,strong) NSString *starredUrl;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *blog;
@end

@interface JHCityModel : JHBaseModel
@property(nonatomic,strong) NSString *isLocation;
@property(nonatomic,strong) NSString *cityCode;
@property(nonatomic,strong) NSString *cityName;
@end

@interface JHAllCityModel : JHBaseModel
@property(nonatomic,strong) NSString *code;
@property(nonatomic,strong) NSString *message;
@property(nonatomic,strong) NSArray <JHCityModel *>*results;
@end

