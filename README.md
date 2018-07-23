# JHNetworkModule
网络请求组件，封装AFNetwork，JSONModel
仅封装简单的方法，以后扩展
## 使用方法

```objc
    [JHBaseRequest request:接口名称 parameters:参数字典 requestType:JHRequestType_Get modelClass:model类名字 success:^(id response) {
        成功返回（如果传了model类，则response为所传递的model对象，如果没传model，response则是字典）
    } failure:^(NSError *error) {
        失败返回
    }];
```
```objc
    [JHBaseRequest uploadImage:接口名称 parameters:参数字典 withImage:UIImage success:^(id responseObject) {
        成功返回
    } failure:^(NSError *error) {
        失败返回
    }];
```
详见JHNetworking.h API

##  安装
### 1.手动添加:<br>
*   1.将 JHNetworkModule 文件夹添加到工程目录中<br>
*   2.导入 JHBaseRequest.h 或者 #import "JHNetworking.h"

### 2.CocoaPods:<br>
*   1.在 Podfile 中添加 pod 'JHNetworkModule'<br>
*   2.执行 pod install 或 pod update<br>
*   3.导入 JHBaseRequest.h 或者 #import "JHNetworking.h"



##  许可证
JHNetworkModule 使用 MIT 许可证，详情见 LICENSE 文件
