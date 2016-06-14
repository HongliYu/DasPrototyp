//
//  UIViewController+Additions.m
//  DasPrototyp
//
//  Created by HongliYu on 16/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "UIViewController+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Blur.h"
#import "UIView+Screenshot.h"
#import "DKLiveBlurView.h"

#define SourceViewTag 10001
#define PopupViewTag 10002
#define OverlayViewTag 10003
#define BackgroundViewTag 10004
#define AnimationDuration 0.35

@interface BlurView : UIImageView

- (id)initWithCoverView:(UIView*)view;

@end

#pragma mark BlurView
@implementation BlurView {
  UIView *_coverView;
}

- (id)initWithCoverView:(UIView *)view {
  if (self = [super initWithFrame:CGRectMake(0, 0,
                                             view.bounds.size.width, view.bounds.size.height)]) {
    _coverView = view;
    UIImage *blur = [_coverView screenshot];
    self.image = [blur boxblurImageWithBlur:0.2f];
  }
  return self;
}
@end

@implementation UIViewController (popUpViewYu)
DPAnimationType animationTypeLocal;

- (void)presentPopupViewController:(UIViewController *)viewController
                     animationType:(DPAnimationType)animationType{
  animationTypeLocal = animationType;
  [self presentPopupView:viewController.view
           animationType:animationType];
}

- (void)dismissWithAnimationType:(DPAnimationType)animationType
                      completion:(void(^)(BOOL finished))completion {
  UIView *sourceView = [self getTheTopView];
  UIView *popupView = [sourceView viewWithTag:PopupViewTag];
  UIView *overlayView = [sourceView viewWithTag:OverlayViewTag];
  
  if(animationType == DPSlideBottomTop
     || animationType == DPSlideBottomBottom
     || animationType == DPSlideTopBottom
     || animationType == DPSlideTopTop
     || animationType == DPSlideRightLeft
     || animationType == DPSlideLeftRight) {
    [self slideViewOut:popupView
            sourceView:sourceView
           overlayView:overlayView
     withAnimationType:animationType];
  } else if(animationType == DPFade){
    [self fadeViewOut:popupView
           sourceView:sourceView
          overlayView:overlayView];
  }else if(animationType == DPBounce) {
    [self bounceViewOut:popupView
             sourceView:sourceView
            overlayView:overlayView];
  }else if (animationType == DPPushBack){
    [self pushBackViewOut:popupView
               sourceView:sourceView
              overlayView:overlayView];
  }else if (animationType == DPBlur){
    [self blurViewOut:popupView
           sourceView:sourceView
          overlayView:overlayView];
  }else if (animationType == DPFrost){
    [self frostedCustomViewOut:popupView
                    sourceView:sourceView
                   overlayView:overlayView];
  }
  completion(YES);
}

#pragma mark View Handing
- (void)presentPopupView:(UIView *)popupView
           animationType:(DPAnimationType)animationType {
  UIView *sourceView = [self getTheTopView];
  sourceView.tag = SourceViewTag;
  popupView.tag = PopupViewTag;
  if ([sourceView.subviews containsObject:popupView]) {
    return;
  }
  
  popupView.clipsToBounds = YES;
  popupView.layer.masksToBounds = YES;
  
  //增加透明层
  UIView *overlayView = [[UIView alloc]initWithFrame:sourceView.bounds];
  overlayView.tag = OverlayViewTag;
  overlayView.backgroundColor = [UIColor clearColor];
  
  //背景层
  if (animationType == DPFrost) {
    DKLiveBlurView *backgroundView = [[DKLiveBlurView alloc]initWithFrame: sourceView.bounds];
    backgroundView.tag = BackgroundViewTag;
    [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    backgroundView.originalImage = [sourceView screenshot];
    backgroundView.isGlassEffectOn = YES;
    [backgroundView setBlurLevel:0.9];
    [overlayView addSubview:backgroundView];
  } else {
    UIView *backgroundView = [[UIView alloc] initWithFrame:sourceView.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.tag = BackgroundViewTag;
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.alpha = 0.0f;
    [overlayView addSubview:backgroundView];
  }
  
  //给覆盖层加上隐形的按钮
  UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
  dismissButton.backgroundColor = [UIColor clearColor];
  dismissButton.frame = sourceView.bounds;
  [overlayView addSubview:dismissButton];
  popupView.alpha = 0.0f;
  [overlayView addSubview:popupView];
  [sourceView addSubview:overlayView];
  switch (animationType) {
    case DPSlideBottomTop:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeSlideBottomTop)
              forControlEvents:UIControlEventTouchUpInside];
      [self slideViewIn:popupView
             sourceView:(UIView*)sourceView
            overlayView:(UIView*)overlayView
      withAnimationType:(DPAnimationType)animationType];
      break;
    case DPSlideBottomBottom:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeSlideBottomBottom)
              forControlEvents:UIControlEventTouchUpInside];
      [self slideViewIn:popupView
             sourceView:(UIView*)sourceView
            overlayView:(UIView*)overlayView
      withAnimationType:(DPAnimationType)animationType];
      break;
    case DPSlideTopBottom:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeSlideTopBottom)
              forControlEvents:UIControlEventTouchUpInside];
      [self slideViewIn:popupView
             sourceView:(UIView*)sourceView
            overlayView:(UIView*)overlayView
      withAnimationType:(DPAnimationType)animationType];
      break;
    case DPSlideTopTop:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeSlideTopTop)
              forControlEvents:UIControlEventTouchUpInside];
      [self slideViewIn:popupView
             sourceView:(UIView*)sourceView
            overlayView:(UIView*)overlayView
      withAnimationType:(DPAnimationType)animationType];
      break;
    case DPSlideLeftRight:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeSlideLeftRight)
              forControlEvents:UIControlEventTouchUpInside];
      [self slideViewIn:popupView
             sourceView:(UIView*)sourceView
            overlayView:(UIView*)overlayView
      withAnimationType:(DPAnimationType)animationType];
      break;
    case DPSlideRightLeft:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeSlideRightLeft)
              forControlEvents:UIControlEventTouchUpInside];
      [self slideViewIn:popupView
             sourceView:(UIView*)sourceView
            overlayView:(UIView*)overlayView
      withAnimationType:(DPAnimationType)animationType];
      break;
    case DPFade:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeFade)
              forControlEvents:UIControlEventTouchUpInside];
      [self fadeViewIn:popupView
            sourceView:sourceView
           overlayView:overlayView];
      break;
    case DPBounce:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeBounce)
              forControlEvents:UIControlEventTouchUpInside];
      [self bounceViewIn:popupView
              sourceView:sourceView
             overlayView:overlayView];
      break;
    case DPPushBack:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypePushBack)
              forControlEvents:UIControlEventTouchUpInside];
      [self pushBackViewIn:popupView
                sourceView:sourceView
               overlayView:overlayView];
      break;
    case DPBlur:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeBlur)
              forControlEvents:UIControlEventTouchUpInside];
      [self blurViewIn:popupView
            sourceView:sourceView
           overlayView:overlayView];
      break;
    case DPFrost:
      [dismissButton addTarget:self
                        action:@selector(dismissPopupViewControllerWithanimationTypeFrost)
              forControlEvents:UIControlEventTouchUpInside];
      [self frostedCustomViewIn:popupView
                     sourceView:sourceView
                    overlayView:overlayView];
      break;
    default:
      break;
  }
}

- (UIView*)getTheTopView {
  UIViewController *recentView = self;
  //只要还有父类控制器，当前视图就往前迭代，直到获得stack顶部的视图并返回
  while (recentView.parentViewController != nil) {
    recentView = recentView.parentViewController;
  }
  return recentView.view;
}

- (void)dismissPopupViewControllerWithanimationTypeSlideBottomTop {
  [self dismissWithAnimationType:DPSlideBottomTop completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideBottomBottom {
  [self dismissWithAnimationType:DPSlideBottomBottom completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideTopBottom {
  [self dismissWithAnimationType:DPSlideTopBottom completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideTopTop {
  [self dismissWithAnimationType:DPSlideTopTop completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideRightLeft {
  [self dismissWithAnimationType:DPSlideRightLeft completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideLeftRight {
  [self dismissWithAnimationType:DPSlideLeftRight completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeFade {
  [self dismissWithAnimationType:DPFade completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeBounce {
  [self dismissWithAnimationType:DPBounce completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypePushBack {
  [self dismissWithAnimationType:DPPushBack completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeBlur {
  [self dismissWithAnimationType:DPBlur completion:^(BOOL finished) {
    ;
  }];
}

- (void)dismissPopupViewControllerWithanimationTypeFrost{
  [self dismissWithAnimationType:DPFrost completion:^(BOOL finished) {
    ;
  }];
}

#pragma mark Slide
- (void)slideViewIn:(UIView*)popupView
         sourceView:(UIView*)sourceView
        overlayView:(UIView*)overlayView
  withAnimationType:(DPAnimationType)animationType {
  CGSize sourceSize = sourceView.bounds.size;
  CGSize popupSize = popupView.bounds.size;
  CGRect popupStartRect;
  if (animationType == DPSlideBottomTop
      || animationType == DPSlideBottomBottom) {
    popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                                sourceSize.height,
                                popupSize.width,
                                popupSize.height);
  } else if (animationType == DPSlideTopBottom
             || animationType == DPSlideTopTop) {
    popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                                -sourceSize.height,
                                popupSize.width,
                                popupSize.height);
  } else if (animationType == DPSlideRightLeft) {
    popupStartRect = CGRectMake(sourceSize.width,
                                (sourceSize.height - popupSize.height) / 2.f,
                                popupSize.width,
                                popupSize.height);
  } else {
    popupStartRect = CGRectMake(-sourceSize.width,
                                (sourceSize.height - popupSize.height) / 2.f,
                                popupSize.width,
                                popupSize.height);
  }
  CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                                   (sourceSize.height - popupSize.height) / 2.f,
                                   popupSize.width,
                                   popupSize.height);
  popupView.frame = popupStartRect;
  popupView.alpha = 1.0f;
  [UIView animateWithDuration:AnimationDuration
                   animations:^{
                     popupView.frame = popupEndRect;
                   } completion:^(BOOL finished) {
                     ;
                   }];
}

- (void)slideViewOut:(UIView*)popupView
          sourceView:(UIView*)sourceView
         overlayView:(UIView*)overlayView
   withAnimationType:(DPAnimationType)animationType {
  CGSize sourceSize = sourceView.bounds.size;
  CGSize popupSize = popupView.bounds.size;
  CGRect popupEndRect;
  if (animationType == DPSlideBottomTop
      || animationType == DPSlideTopTop) {
    popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                              -popupSize.height,
                              popupSize.width,
                              popupSize.height);
  } else if (animationType == DPSlideBottomBottom
             || animationType == DPSlideTopBottom) {
    popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                              sourceSize.height,
                              popupSize.width,
                              popupSize.height);
  } else if (animationType == DPSlideRightLeft) {
    popupEndRect = CGRectMake(-popupSize.width,
                              popupView.frame.origin.y,
                              popupSize.width,
                              popupSize.height);
  } else {
    popupEndRect = CGRectMake(popupSize.width,
                              popupView.frame.origin.y,
                              popupSize.width,
                              popupSize.height);
  }
  [UIView animateWithDuration:AnimationDuration
                   animations:^{
                     popupView.frame = popupEndRect;
                   } completion:^(BOOL finished) {
                     [popupView removeFromSuperview];
                     [overlayView removeFromSuperview];
                   }];
}

#pragma mark Fade
- (void)fadeViewIn:(UIView*)popupView
        sourceView:(UIView*)sourceView
       overlayView:(UIView*)overlayView {
  CGSize sourceSize = sourceView.bounds.size;
  CGSize popupSize = popupView.bounds.size;
  CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                                   (sourceSize.height - popupSize.height) / 2.f,
                                   popupSize.width,
                                   popupSize.height);
  popupView.frame = popupEndRect;
  popupView.alpha = 0.0f;
  [UIView animateWithDuration:AnimationDuration
                   animations:^{
                     popupView.alpha = 1.0f;
                   } completion:^(BOOL finished) {
                   }];
}

- (void)fadeViewOut:(UIView*)popupView
         sourceView:(UIView*)sourceView
        overlayView:(UIView*)overlayView {
  [UIView animateWithDuration:AnimationDuration
                   animations:^{
                     popupView.alpha = 0.0f;
                   } completion:^(BOOL finished) {
                     [popupView removeFromSuperview];
                     [overlayView removeFromSuperview];
                   }];
}

#pragma mark Bounce
- (void)bounceViewIn:(UIView*)popupView
          sourceView:(UIView*)sourceView
         overlayView:(UIView*)overlayView {
  UIView *backgroundView = [overlayView viewWithTag:BackgroundViewTag];
  CGSize sourceSize = sourceView.bounds.size;
  CGSize popupSize = popupView.bounds.size;
  CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                                   (sourceSize.height - popupSize.height) / 2.f,
                                   popupSize.width,
                                   popupSize.height);
  popupView.frame = popupEndRect;
  popupView.alpha = 0.0f;
  popupView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6f, 0.6f);
  [UIView animateWithDuration:0.2f
                   animations:^{
                     self.view.backgroundColor = [UIColor blackColor];
                     backgroundView.alpha = 0.5f;
                     backgroundView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9f, 0.9f);
                     popupView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1f, 1.1f);
                     popupView.alpha = 1.f;
                   } completion:^(BOOL finished) {
                     [self bounceOutAnimationStoped:popupView
                                        overlayView:(UIView*)overlayView];
                   }];
}

- (void)bounceOutAnimationStoped:(UIView*)popupView
                     overlayView:(UIView*)overlayView {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     popupView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9f, 0.9f);
                   } completion:^(BOOL finished) {
                     [self bounceInAnimationStoped:popupView
                                       overlayView:(UIView*)overlayView];
                   }];
}

- (void)bounceInAnimationStoped:(UIView*)popupView
                    overlayView:(UIView*)overlayView {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     popupView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f);
                   } completion:^(BOOL finished) {
                     ;
                   }];
}

- (void)bounceViewOut:(UIView*)popupView
           sourceView:(UIView*)sourceView
          overlayView:(UIView*)overlayView {
  UIView *backgroundView = [overlayView viewWithTag:BackgroundViewTag];
  [UIView animateWithDuration:AnimationDuration
                   animations:^{
                     self.view.backgroundColor = [UIColor whiteColor];
                     backgroundView.alpha = 0;
                     backgroundView.transform = CGAffineTransformIdentity;
                     popupView.alpha = 0;
                   } completion:^(BOOL finished) {
                     [popupView removeFromSuperview];
                     [overlayView removeFromSuperview];
                   }];
}

#pragma mark PushBack
- (void)pushBackViewIn:(UIView*)popupView
            sourceView:(UIView*)sourceView
           overlayView:(UIView*)overlayView {
  UIView *backgroundView = [overlayView viewWithTag:BackgroundViewTag];
  CGSize sourceSize = sourceView.bounds.size;
  CGSize popupSize = popupView.bounds.size;
  CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                                   (sourceSize.height - popupSize.height) / 2.f,
                                   popupSize.width, popupSize.height);
  popupView.frame = popupEndRect;
  popupView.alpha = 0;
  [UIView animateWithDuration:0.3f
                   animations:^{
                     self.view.backgroundColor = [UIColor blackColor];
                     backgroundView.alpha = 0.35f;
                     CALayer *layer = backgroundView.layer;
                     layer.zPosition = -4000;
                     CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                     rotationAndPerspectiveTransform.m34 = 1.0 / -300;
                     layer.transform = CATransform3DRotate(rotationAndPerspectiveTransform,
                                                           10.0f * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
                   } completion:^(BOOL finished) {
                     [UIView animateWithDuration:0.3f animations:^{
                       backgroundView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
                       backgroundView.alpha = 0.5f;
                       popupView.alpha = 1.f;
                     }];
                   }];
}

- (void)pushBackViewOut:(UIView*)popupView
             sourceView:(UIView*)sourceView
            overlayView:(UIView*)overlayView {
  UIView *backgroundView = [overlayView viewWithTag:BackgroundViewTag];
  [UIView animateWithDuration:0.4f
                   animations:^{
                     CALayer *layer = backgroundView.layer;
                     layer.zPosition = -4000;
                     CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                     rotationAndPerspectiveTransform.m34 = 1.0 / 300;
                     layer.transform = CATransform3DRotate(rotationAndPerspectiveTransform,
                                                           -10.0f * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
                     backgroundView.alpha = 0.35f;
                     popupView.alpha = 0;
                   } completion:^(BOOL finished) {
                     self.view.backgroundColor = [UIColor whiteColor];
                     [UIView animateWithDuration:0.3f
                                      animations:^{
                                        [popupView removeFromSuperview];
                                        [overlayView removeFromSuperview];
                                      }];
                   }];
}

#pragma mark frost
- (void)frostedCustomViewIn:(UIView*)popupView
                 sourceView:(UIView*)sourceView
                overlayView:(UIView*)overlayView {
  UIView *backgroundView = [overlayView viewWithTag:BackgroundViewTag];
  CGSize sourceSize = sourceView.bounds.size;
  CGSize popupSize = popupView.bounds.size;
  CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                                   (sourceSize.height - popupSize.height) / 2.f,
                                   popupSize.width,
                                   popupSize.height);
  popupView.frame = popupEndRect;
  popupView.alpha = 0;
  [UIView animateWithDuration:AnimationDuration
                   animations:^{
                     backgroundView.alpha = 1.f;
                     popupView.alpha = 1.f;
                   } completion:^(BOOL finished) {
                     ;
                   }];
}

- (void)frostedCustomViewOut:(UIView*)popupView
                  sourceView:(UIView*)sourceView
                 overlayView:(UIView*)overlayView {
  UIView *backgroundView = [overlayView viewWithTag:BackgroundViewTag];
  [UIView animateWithDuration:AnimationDuration
                   animations:^{
                     backgroundView.alpha = 0;
                     backgroundView.transform = CGAffineTransformIdentity;
                     popupView.alpha = 0;
                   } completion:^(BOOL finished) {
                     [popupView removeFromSuperview];
                     [overlayView removeFromSuperview];
                   }];
}

#pragma mark Blur
- (void)blurViewIn:(UIView*)popupView
        sourceView:(UIView*)sourceView
       overlayView:(UIView*)overlayView {
  UIView *backgroundView = [overlayView viewWithTag:BackgroundViewTag];
  UIImage *blurImage = [sourceView screenshot];
  UIImage *image = [blurImage boxblurImageWithBlur:0.2f];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.alpha = 1.f;
  [backgroundView addSubview:imageView];
  
  CGSize sourceSize = sourceView.bounds.size;
  CGSize popupSize = popupView.bounds.size;
  CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2.f,
                                   (sourceSize.height - popupSize.height) / 2.f,
                                   popupSize.width, popupSize.height);
  popupView.frame = popupEndRect;
  popupView.alpha = 0.0f;
  
  //backgroundView.transform = CGAffineTransformIdentity;
  [UIView animateWithDuration:AnimationDuration animations:^{
    backgroundView.alpha = 1.0f;
    popupView.alpha = 1.0f;
  } completion:^(BOOL finished) {
    ;
  }];
}

- (void)blurViewOut:(UIView*)popupView
         sourceView:(UIView*)sourceView
        overlayView:(UIView*)overlayView {
  UIView *backgroundView = [overlayView viewWithTag:BackgroundViewTag];
  [UIView animateWithDuration:AnimationDuration
                   animations:^{
                     self.view.backgroundColor = [UIColor whiteColor];
                     backgroundView.alpha = 0;
                     backgroundView.transform = CGAffineTransformIdentity;
                     popupView.alpha = 0;
                   } completion:^(BOOL finished) {
                     [popupView removeFromSuperview];
                     [overlayView removeFromSuperview];
                   }];
}

@end