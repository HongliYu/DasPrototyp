//
//  DPPlainColorViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-7-9.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPPlainColorViewController.h"
#import "DPDeviceUtils.h"

@interface DPPlainColorViewController ()

@property (strong, nonatomic) UIButton *openDrawerButton;

@end

@implementation DPPlainColorViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.openDrawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
  CGFloat originY = 5.f;
  if ([DPDeviceUtils checkIfDeviceHasBangs]) {
    originY = originY + 44;
  }
  self.openDrawerButton.frame = CGRectMake(5.f, originY, 34.f, 34.f);
  [self.openDrawerButton setTitle:@"\U0000e9bd"
                         forState:UIControlStateNormal];
  [self.openDrawerButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:28.f]];
  [self.openDrawerButton addTarget:self
                            action:@selector(openDrawer:)
                  forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.openDrawerButton];
}

#pragma mark - ICSDawerControllerPresenting
- (void)drawerControllerWillOpen:(DPDrawerViewController *)drawerController {
  self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(DPDrawerViewController *)drawerController {
  self.view.userInteractionEnabled = YES;
}

#pragma mark - Open drawer button
- (void)openDrawer:(id)sender {
  [self.drawer open];
}

@end
