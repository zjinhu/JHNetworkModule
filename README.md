# JHNetworkModule
网络请求组件，封装AFNetwork，JSONModel

## Requirements 要求
* iOS 9+
* Xcode 8+

 
### CocoaPods安装:
first
`pod 'JHNetworkModule',:git => 'https://github.com/jackiehu/JHNetworkModule.git'`
then
`pod install或pod install --no-repo-update`

```objc
    [JHRequest requestManager:nil requestApi:@"" requestType:JHRequestType_Get modelClass:nil success:^(id response) {
        
    } failure:^(NSError *error) {
        
    }];
```
