//
//  ViewController.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "ViewController.h"
#import "JHBaseRequest.h"
#import "JHFaceModel.h"
#import "JHNetworking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [JHBaseRequest request:@"users/facebook" parameters:nil requestType:JHRequestType_Get modelClass:@"JHFaceModel" success:^(id response) {
        JHFaceModel *model = response;
        NSLog(@"%@",model);
    } failure:^(NSError *error) {
        NSLog(@"请求失败");
    }];
    
    [JHBaseRequest request:@"users/facebook" parameters:nil requestType:JHRequestType_Get modelClass:NSStringFromClass([JHFaceModel class]) success:^(id response) {
        NSLog(@"%@",response);
    } failure:^(NSError *error) {
        NSLog(@"请求失败");
    }];
    // Do any additional setup after loading the view, typically from a nib.

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
