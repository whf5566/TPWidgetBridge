//
//  MainViewController.m
//  TPWidgetBridgeDemo
//
//  Created by whf5566 on 2017/9/12.
//  Copyright © 2017年 tpkit. All rights reserved.
//

#import "MainViewController.h"
#import <TPLayout/TPLayout.h>
#import <TPWidgetBridge/TPWidgetBridge.h>

static NSString *const kAppGroupId = @"group.com.tpkit.TPWidgetBridgeDemo";
static NSString *const kWidgetNotifyNewText = @"kWidgetNotifyNewText";

@interface MainViewController ()
@property (nonatomic, strong) UIButton *sendTextButton;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, assign) NSInteger sendNumber;
@property (nonatomic, strong) TPWidgetBridge *widgetBridge;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initData];
    self.widgetBridge = [[TPWidgetBridge alloc] initWithAppGroupId:kAppGroupId directory:nil];
    [self observeWidget];
}

- (void)initViews {
    // self
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"TPWidgetBridgeDemo";
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.font = [UIFont systemFontOfSize:48];
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.textLabel];
    
    self.sendTextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendTextButton setTitle:@"" forState:UIControlStateNormal];
    [self.view addSubview:self.sendTextButton];
    
    self.textLabel.al_top.equal(180);
    self.textLabel.al_height.equal(50);
    self.textLabel.al_width.equal(self.view);
    self.textLabel.al_centerX.equal(self.view);
    
    self.sendTextButton.al_top.equal(self.textLabel.al_bottom).offset(20);
    self.sendTextButton.al_size.equal(CGSizeMake(200, 30));
    self.sendTextButton.al_centerX.equal(self.view);
}

- (void)initData {
    self.textLabel.text = [NSString stringWithFormat:@"%ld", (long)self.sendNumber];
}

- (void)showAlert:(NSString *)text {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"WidgetMessage" message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)observeWidget {
    __weak typeof(self) weakSelf = self;
    [self.widgetBridge observeNotificationName:kWidgetNotifyNewText
                                      observer:^(id<NSCoding> message, TPWidgetBridgeCallBackBlock callback) {
                                          __strong typeof(weakSelf) strongSelf = weakSelf;
                                          NSString *text = [NSString stringWithFormat:@"App recieved message: %@ ", message];
                                          strongSelf.textLabel.text = (NSString *)message;
                                          [strongSelf showAlert:text];
                                          NSLog(@"%@", text);
                                          callback(text);
                                      }];
}

@end
