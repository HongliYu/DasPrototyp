//
//  UIView+MenuActionHandlers.h
//  DasPrototyp
//
//  Created by HongliYu on 14-8-9.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MenuActionHandlers)

- (void)setMenuActionWithBlock:(void (^)(UITapGestureRecognizer *tapGesture))block;

@end
