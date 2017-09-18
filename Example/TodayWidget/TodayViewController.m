//
//  TodayViewController.m
//  TodayWidget
//
//  Created by whf5566 on 2017/9/12.
//  Copyright © 2017年 tpkit. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <TPLayout/TPLayout.h>
#import <TPWidgetBridge/TPWidgetBridge.h>

static NSString *const kAppGroupId = @"group.com.tpkit.TPWidgetBridgeDemo";
static NSString *const kWidgetNotifyNewText = @"kWidgetNotifyNewText";



@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic,strong) UILabel *textLabel;
@property (nonatomic,strong) UIButton *sendTextButton;

@property (nonatomic, assign) NSInteger sendNumber;

@property (nonatomic,strong) TPWidgetBridge *widgetBridge;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self observerAppContainer];
}

- (void)initViews {
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.text = [NSString stringWithFormat:@"%ld", (long)self.sendNumber];
    [self.view addSubview:self.textLabel];
    
    self.sendTextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendTextButton.backgroundColor = [UIColor lightGrayColor];
    [self.sendTextButton setTitle:@"sendText" forState:UIControlStateNormal];
    [self.sendTextButton addTarget:self action:@selector(sendTextToAppContainer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendTextButton];
    
    self.textLabel.al_left.equal(10);
    self.textLabel.al_height.multiplier(0.75).equal(self.view);
    self.textLabel.al_centerY.equal(self.view);
    self.textLabel.al_width.lessOrEqual(self.view);
    
    self.sendTextButton.al_left.equal(self.textLabel.al_right);
    self.sendTextButton.al_height.multiplier(0.75).equal(self.view);
    self.sendTextButton.al_centerY.equal(self.view);
    self.sendTextButton.al_width.equal(self.textLabel);
    self.sendTextButton.al_right.equal(self.view.al_right).offset(-10);
}

- (void)observerAppContainer {
    if (self.widgetBridge == nil) {
        self.widgetBridge = [[TPWidgetBridge alloc] initWithAppGroupId:kAppGroupId directory:nil];
    }
}


- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

#pragma mark - Action

- (void)sendTextToAppContainer {
    self.sendNumber++;
    self.textLabel.text = [NSString stringWithFormat:@"%ld", (long)self.sendNumber];
    NSString *text = self.textLabel.text;
    __weak typeof(self) weakSelf = self;
    [self.widgetBridge postNotificationName:kWidgetNotifyNewText message:text timeout:0.5f response:^(TPWidgetBridgeResponseResult result, id<NSCoding> message) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"widgetBridge notify %@ send %@ , recieve response: %@", kWidgetNotifyNewText, text, message);
        if (result == TPWidgetBridgeResponseSuccess) {
            [strongSelf showResponseMessage:(NSString *)message];
        } else if (result == TPWidgetBridgeResponseTimeOut) {
            [strongSelf showResponseMessage:@"Timeout: App did not respond"];
        }
    }];
}

- (void)showResponseMessage:(NSString *)message {
    UILabel *label = [[UILabel alloc] init];
    [self.view addSubview:label];
    label.al_edges.equal(self.view).inset(10);
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = message;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
}

@end
