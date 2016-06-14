//
//  DPColorsViewController.h
//  DasPrototyp
//
//  Created by HongliYu on 14-7-9.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPDrawerViewController.h"

// Left View Controller
typedef NS_ENUM (NSUInteger, DPLeftViewControllerCellState) {
  DPLeftViewControllerCellProjects,
  DPLeftViewControllerCellSupport,
  DPLeftViewControllerCellRate,
  DPLeftViewControllerCellDonate
};

@interface DPColorsViewController : UITableViewController <DPDrawerControllerChild,
DPDrawerControllerPresenting>

@property(nonatomic, weak) DPDrawerViewController *drawer;

- (id)initWithColors:(NSArray *)colors;

@end
