//
//  DPEventSignalTableViewCell.h
//  DasPrototyp
//
//  Created by HongliYu on 16/6/3.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPEventSignalTableViewCell : UITableViewCell

- (void)bindData:(NSString *)text
        selected:(BOOL)selected;

@end
