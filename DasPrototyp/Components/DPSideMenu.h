//
//  DPSideMenu.h
//  DasPrototyp
//
//  Created by HongliYu on 15/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+MenuActionHandlers.h"

typedef NS_ENUM(NSUInteger, DPSideMenuPosition) {
  DPSideMenuPositionLeft,
  DPSideMenuPositionRight,
  DPSideMenuPositionTop,
  DPSideMenuPositionBottom
};

@interface DPSideMenu : UIView

@property (nonatomic, assign, getter=isOpen, readonly) BOOL open;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) DPSideMenuPosition menuPosition;
@property (nonatomic, strong, readonly) NSArray *items;

- (id)initWithItems:(NSArray *)items;
- (void)open;
- (void)close;

/**
 Spacing between each menu item and the next. This will be the horizontal spacing between items in case the menu is added on the top/bottom, or vertical spacing in case the menu is added on the left/right.
 */
@property (nonatomic, assign) CGFloat itemSpacing;


@end