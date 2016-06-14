//
//  DPHomeBusiness.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/30.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@class DPMainTableViewCell;
@class DPMainViewModel;
@class DPHomeViewController;

@interface DPHomeBusiness : NSObject <UITableViewDelegate,
UITableViewDataSource, MFMailComposeViewControllerDelegate>

- (void)bindHomeViewController:(DPHomeViewController *)homeViewController;
- (void)bindHomeTableView:(UITableView *)homeTableView;
- (void)tableViewAddProjectAnimated;
- (void)configComponents;
- (void)tableViewReloadData;

@end
