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
