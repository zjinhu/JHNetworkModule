# JHNetworkModule
V1.3.0：添加AFNetwork 4.0.1的适配
网络请求组件，封装AFNetwork，YYModel
仅封装简单的方法，以后扩展
## 使用方法

```objc
普通请求
    [JHRequest requestWithConfig:^(JHNetworkConfig *requestConfig) {
        requestConfig.URLString = @"接口名称";
        requestConfig.modelClass = @"数据model";
        requestConfig.parameters = 参数;
        requestConfig.requestType = 请求类型;
    } success:^(id responseObject) {
        NSLog(@"%@",responseObject);
        
    } failure:^(NSError *error) {
        
    }];
    上传图片
        [JHRequest requestWithConfig:^(JHNetworkConfig *requestConfig) {
        requestConfig.URLString = @"接口名称";
        requestConfig.requestType = JHRequestType_Upload;
        [requestConfig addFormDataWithName:文件类型名称 fileName:文件名 mimeType:[requestConfig mimeTypeWithImageData:数据data] fileData:数据data];
    } success:^(id responseObject) {
        NSLog(@"%@",responseObject);
        
    } failure:^(NSError *error) {
        
    }];
```
##  安装
### 1.手动添加:<br>
*   1.将 JHNetworkModule 文件夹添加到工程目录中<br>
*   2.导入 JHRequest.h   #import "JHNetworkModule.h"

### 2.CocoaPods:<br>
*   1.在 Podfile 中添加 pod 'JHNetworkModule'<br>
*   2.执行 pod install 或 pod update<br>
*   3.导入 JHRequest.h 或者 #import "JHNetworkModule.h"



##  许可证
JHNetworkModule 使用 MIT 许可证，详情见 LICENSE 文件
