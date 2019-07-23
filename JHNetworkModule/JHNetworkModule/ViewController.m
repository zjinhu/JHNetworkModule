//
//  ViewController.m
//  JHNetworkModule
//
//  Created by HU on 2018/7/16.
//  Copyright © 2018年 HU. All rights reserved.
//

#import "ViewController.h"
#import "JHRequest.h"
#import "JHFaceModel.h"
#import "JHNetworking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [JHRequest requestWithConfig:^(JHNetworkConfig *requestConfig) {
        requestConfig.URLString = @"http://newuat.ikapp.ikang.com/appService/city/allCity";
        requestConfig.modelClass = @"JHAllCityModel";
    } success:^(id responseObject) {
        NSLog(@"%@",responseObject);
        
    } failure:^(NSError *error) {
        
    }];
    // Do any additional setup after loading the view, typically from a nib.
//    [JHRequest requestWithConfig:^(JHNetworkConfig *requestConfig) {
//        requestConfig.URLString = @"http://newuat.ikapp.ikang.com/appService/city/allCity";
//        requestConfig.requestType = JHRequestType_Upload;
////        [requestConfig addFormDataWithName:@"" fileName:@"" mimeType:[requestConfig mimeTypeWithImageData:..] fileData:..];
//    } success:^(id responseObject) {
//        NSLog(@"%@",responseObject);
//        
//    } failure:^(NSError *error) {
//        
//    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
