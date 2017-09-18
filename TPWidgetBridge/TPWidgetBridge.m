//
//  TPWidgetBridge.m
//
//  Created by whf5566 on 17/1/6.
//  Copyright © 2017年 whf5566. All rights reserved.
//

#import "TPWidgetBridge.h"

static NSString *const kTPWidgetBridgeDarwinNotification = @"kTPWidgetBridgeDarwinNotification";
static NSString *const kTPWidgetBridgeDarwinNotificationUserInfoKeyName = @"name";

static NSTimeInterval const kDefaultTimeout = 0.5f;

@interface TPWidgetBridge () {
    NSMutableDictionary *_observerDic;
    NSString *_appGroupId;
    NSString *_directory;
}

@end

@implementation TPWidgetBridge

- (instancetype)init {
    return [self initWithAppGroupId:nil directory:nil];
}

- (instancetype)initWithAppGroupId:(NSString *)appGroupId
                         directory:(NSString *)directory {
    self = [super init];
    if (self) {
        _observerDic = [NSMutableDictionary dictionary];
        _appGroupId = appGroupId;
        _directory = directory;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recieveDarwinNotification:)
                                                     name:kTPWidgetBridgeDarwinNotification
                                                   object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)postNotificationName:(NSString *)name message:(id<NSCoding>)message {
    [self postNotificationName:name message:message response:nil];
}

- (void)postNotificationName:(NSString *)name message:(id<NSCoding>)message response:(TPWidgetBridgeResponseBlock)responesCallback {
    [self postNotificationName:name message:message timeout:kDefaultTimeout response:responesCallback];
}

- (void)postNotificationName:(NSString *)name message:(id<NSCoding>)message timeout:(NSTimeInterval)timeout response:(TPWidgetBridgeResponseBlock)responesCallback {
    NSTimeInterval begintime = [NSDate date].timeIntervalSince1970;
    __block BOOL callOnceToken = NO;
    void (^resultBlock)(TPWidgetBridgeResponseResult result, id message) = ^(TPWidgetBridgeResponseResult result, id message) {
        if (!callOnceToken && responesCallback) {
            responesCallback(result, message);
        }
        callOnceToken = YES;
    };
    BOOL needObserveCallback = (responesCallback != nil);
    if (needObserveCallback) {
        NSString *callbackname = [self commonResponseNotificationNameWith:name];
        [self observeNotificationName:callbackname
                             observer:^(id<NSCoding> message, TPWidgetBridgeCallBackBlock callBack) {
                                 if (fabs(begintime - [NSDate date].timeIntervalSince1970) < timeout) {
                                     resultBlock(TPWidgetBridgeResponseSuccess, message);
                                 }
                             }];
    }
    
    if ([self writeMessage:message forNotificationName:name]) {
        [self sendDarwinNotificationName:name];
    }
    
    if (needObserveCallback) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            resultBlock(TPWidgetBridgeResponseTimeOut, nil);
        });
    }
}

- (void)observeNotificationName:(NSString *)name observer:(TPWidgetBridgeObserverBlock)observer {
    if (!name) {
        return;
    }
    [self addObserver:observer ForNotificationName:name];
    [self registerDarwinNotificationName:name];
}

- (void)stopObserveNotificationName:(NSString *)name {
    if (!name) {
        return;
    }
    [self removeObserverForNotificationName:name];
    [self unregisterDarwinNotificationName:name];
}

- (void)addObserver:(TPWidgetBridgeObserverBlock)block ForNotificationName:(NSString *)name {
    if (name) {
        _observerDic[name] = block;
    }
}

- (void)removeObserverForNotificationName:(NSString *)name {
    if (name) {
        _observerDic[name] = nil;
    }
}

- (NSString *)commonResponseNotificationNameWith:(NSString *)name {
    return [NSString stringWithFormat:@"%@__commoncallback__", name];
}

- (TPWidgetBridgeObserverBlock)observerBlockForNotificationName:(NSString *)name {
    return _observerDic[name];
}

- (id)readMessageForNotificationName:(NSString *)name {
    NSString *filePath = [self filePathForNotificationName:name];
    if (filePath == nil) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data == nil) {
        return nil;
    }
    id msg = nil;
    @try {
        msg = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        msg = nil;
    }
    
    return msg;
}

- (BOOL)writeMessage:(id<NSCoding>)message forNotificationName:(NSString *)name {
    if (message) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
        NSString *filePath = [self filePathForNotificationName:name];
        
        if (data == nil || filePath == nil) {
            return NO;
        }
        
        return [data writeToFile:filePath atomically:YES];
    }
    
    return YES;
}

- (NSString *)filePathForNotificationName:(NSString *)name {
    if (name.length == 0) {
        return nil;
    }
    NSString *fileName = [NSString stringWithFormat:@"%@.msg", name];
    return [[self messageDirectory] stringByAppendingPathComponent:fileName];
}

- (NSString *)messageDirectory {
    NSURL *appGroupContainer = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:_appGroupId];
    NSString *appGroupContainerPath = [appGroupContainer path];
    NSString *dir = appGroupContainerPath;
    
    if (_directory != nil) {
        dir = [appGroupContainerPath stringByAppendingPathComponent:_directory];
    }
    
    BOOL isFolder = NO;
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isFolder];
    if (isDirExist && !isFolder) {
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }
    if (!isDirExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return dir;
}

#pragma mark - Darwin Notification

- (void)recieveDarwinNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *name = userInfo[kTPWidgetBridgeDarwinNotificationUserInfoKeyName];
    NSString *callbackname = [self commonResponseNotificationNameWith:name];
    TPWidgetBridgeObserverBlock observer = [self observerBlockForNotificationName:name];
    id message = [self readMessageForNotificationName:name];
    if (observer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            observer(message, ^(id<NSCoding> msg) {
                [self postNotificationName:callbackname message:msg];
            });
        });
    }
}

- (void)sendDarwinNotificationName:(NSString *)name {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)name;
    CFNotificationCenterPostNotification(center, str, NULL, NULL, YES);
}

- (void)registerDarwinNotificationName:(NSString *)name {
    [self unregisterDarwinNotificationName:name];
    
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)name;
    CFNotificationCenterAddObserver(center, (__bridge const void *)(self), darwinNotificationCallback, str, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)unregisterDarwinNotificationName:(NSString *)name {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)name;
    CFNotificationCenterRemoveObserver(center, (__bridge const void *)(self), str, NULL);
}

void darwinNotificationCallback(CFNotificationCenterRef center,
                                void *observer,
                                CFStringRef name,
                                void const *object,
                                CFDictionaryRef userInfo) {
    NSString *identifier = (__bridge NSString *)name;
    NSObject *sender = (__bridge NSObject *)(observer);
    NSDictionary *infoDic = @{ kTPWidgetBridgeDarwinNotificationUserInfoKeyName: identifier ?: @"" };
    [[NSNotificationCenter defaultCenter] postNotificationName:kTPWidgetBridgeDarwinNotification
                                                        object:sender
                                                      userInfo:infoDic];
}

@end
