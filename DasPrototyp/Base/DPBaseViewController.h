//
//  DPBaseViewController.h
//  DasPrototyp
//
//  Created by HongliYu on 14/11/26.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPBaseViewController : UIViewController

@property (strong, nonatomic, readonly) NSString *pageMark;
- (void)setPageMark:(NSString *)pageMark;

@end
