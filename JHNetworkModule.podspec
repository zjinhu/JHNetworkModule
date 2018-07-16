 
Pod::Spec.new do |s|
  s.name             = 'JHNetworkModule'
  s.version          = '0.1.1'
  s.summary          = '网络请求组件.'
 
  s.description      = <<-DESC
							可单独使用也可以搭配JHNetworkEnvironmentModule作为JHNetworkEnvironmentModule的工具.
                       DESC

  s.homepage         = 'https://github.com/jackiehu/' 
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HU' => '814030966@qq.com' }
  s.source           = { :git => 'https://github.com/jackiehu/JHNetworkModule.git', :tag => s.version.to_s }
 
  s.platform         = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source_files = 'JHNetworkModule/JHNetworkModule/Class/**/*.{h,m}'
  s.frameworks   = "UIKit", "Foundation" #支持的框架
  s.requires_arc        = true
 
  s.dependency 'AFNetworking'
  s.dependency 'JSONModel'

end