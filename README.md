[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/whf5566/TPWidgetBridge/master/LICENSE)&nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/TPWidgetBridge.svg?style=flat)](http://cocoapods.org/pods/TPWidgetBridge)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/TPWidgetBridge.svg?style=flat)](http://cocoadocs.org/docsets/TPWidgetBridge)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![Build Status](https://travis-ci.org/whf5566/TPWidgetBridge.svg?branch=master)](https://travis-ci.org/whf5566/TPWidgetBridge)  

# TPWidgetBridge
TPWidgetBridge是一个简单的工具，能让App container 和 widget 更方便的通信。TPWidgetBridge使用了 CFNotificationCenter Darwin 通知，能实时地在App container 和 widget之间传递消息。

## 安装使用
### 开发环境  

-  xcode8及以上
-  ios7及以上  

### 使用CocoaPods安装  
* 添加「 pod 'TPWidgetBridge' 」到你的Podfile文件中，然后在命令行中运行 pod install   

### 使用Carthage安装  
* 添加「 git "https://github.com/whf5566/TPWidgetBridge.git" "master"  」到你的Cartfile文件中，然后在命令行中运行 carthage update --platform iOS
* 在你的项目中添加刚才生成的TPWidgetBridge.framework动态库  

### 源码引入  
* 将TPWidgetBridge.h TPWidgetBridge.m文件拖入到你的项目中即可

## Demo
 
```objectivec
// 发送通知
__weak typeof(self) weakSelf = self;
[self.widgetBridge postNotificationName:kWidgetNotifyNewText message:text timeout:0.5f response:^(TPWidgetBridgeResponseResult result, id<NSCoding> message) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (result == TPWidgetBridgeResponseSuccess) {
            [strongSelf showResponseMessage:message];
        } else if (result == TPWidgetBridgeResponseTimeOut) {
            [strongSelf showResponseMessage:@"Timeout: App did not respond"];
        }
    }];


// 接收通知
__weak typeof(self) weakSelf = self;
[self.widgetBridge observeNotificationName:kWidgetNotifyNewText
                                  observer:^(id<NSCoding> message, TPWidgetBridgeCallBackBlock callback) {
                                          __strong typeof(weakSelf) strongSelf = weakSelf;
                                          strongSelf.textLabel.text = message;
                                          callback(@"did received"）;
                                }];


```  

## Blog
[Wellphone](https://www.wellphone.me)

