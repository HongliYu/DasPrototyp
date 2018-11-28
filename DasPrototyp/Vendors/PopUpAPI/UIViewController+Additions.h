//
//  UIViewController+Additions.h
//  DasPrototyp
//
//  Created by HongliYu on 16/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DPAnimationType) {
  DPSlideBottomTop = 0,
  DPSlideBottomBottom,
  DPSlideTopBottom,
  DPSlideTopTop,
  DPSlideRightLeft,
  DPSlideLeftRight,
  DPFade,
  DPBounce,
  DPPushBack,
  DPBlur,
  DPFrost
};

@interface UIViewController (Additions)

- (void)presentPopupViewController:(UIViewController*)viewController
                     animationType:(DPAnimationType)animationType;
- (void)dismissWithAnimationType:(DPAnimationType)animationType
                      completion:(void(^)(BOOL finished))completion;
- (void)presentPopupView:(UIView *)popupView
           animationType:(DPAnimationType)animationType;
- (UIView*)getTheTopView;

@end
