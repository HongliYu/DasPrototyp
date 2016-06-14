//
//  DPEventSignalComponent.h
//  DasPrototyp
//
//  Created by HongliYu on 16/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DPMaskViewModel;

@interface DPEventSignalComponent : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) UITableView *switchSignalTableView;

- (instancetype)initWithTableViewRect:(CGRect)rect
                           datasource:(DPMaskViewModel *)maskViewModel;

@end
