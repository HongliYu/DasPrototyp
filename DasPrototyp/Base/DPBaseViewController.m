//
//  DPBaseViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14/11/26.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPBaseViewController.h"

@interface DPBaseViewController ()

@property (strong, nonatomic, readwrite) NSString *pageMark;

@end

@implementation DPBaseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Configuring the view’s layout behavior
- (BOOL)prefersStatusBarHidden {
  return YES;
}

@end
