//
//  DPMainTableViewCell.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/7.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPMainViewModel;

extern const float kMainCellHeightNormal;

@interface DPMainTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^moreAction)(void);
@property (nonatomic, copy) void (^renameAction)(void);
@property (nonatomic, copy) void (^shareAction)(void);
@property (nonatomic, copy) void (^deleteAction)(void);

- (void)bindData:(DPMainViewModel *)mainViewModel;

@end
