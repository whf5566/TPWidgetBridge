//
//  TPWidgetBridge.h
//
//  Created by whf5566 on 17/1/6.
//  Copyright © 2017年 whf5566. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TPWidgetBridgeResponseResult) {
    TPWidgetBridgeResponseSuccess = 0,
    TPWidgetBridgeResponseTimeOut,
};

typedef void (^TPWidgetBridgeCallBackBlock)(id<NSCoding> message);
typedef void (^TPWidgetBridgeObserverBlock)(id<NSCoding> message, TPWidgetBridgeCallBackBlock callback);
typedef void (^TPWidgetBridgeResponseBlock)(TPWidgetBridgeResponseResult result, id<NSCoding> message);

@interface TPWidgetBridge : NSObject

- (instancetype)initWithAppGroupId:(NSString *)appGroupId
                         directory:(NSString *)directory NS_DESIGNATED_INITIALIZER;

- (void)postNotificationName:(NSString *)name message:(id<NSCoding>)message;
- (void)postNotificationName:(NSString *)name message:(id<NSCoding>)message response:(TPWidgetBridgeResponseBlock)responesCallback;
- (void)postNotificationName:(NSString *)name message:(id<NSCoding>)message timeout:(NSTimeInterval)timeout response:(TPWidgetBridgeResponseBlock)responesCallback;

- (void)observeNotificationName:(NSString *)name observer:(TPWidgetBridgeObserverBlock)observer;
- (void)stopObserveNotificationName:(NSString *)name;

@end
