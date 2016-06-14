//
//  DPPlainColorViewController.h
//  DasPrototyp
//
//  Created by HongliYu on 14-7-9.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPDrawerViewController.h"

@interface DPPlainColorViewController : DPBaseViewController <DPDrawerControllerChild,
DPDrawerControllerPresenting>

@property (nonatomic, weak) DPDrawerViewController *drawer;

@end
