//
//  DPPhoneDetailsView.m
//  DasPrototyp
//
//  Created by HongliYu on 16/6/7.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPPhoneDetailsView.h"
#import "DPMaskView.h"
#import "DPMaskViewModel.h"

@implementation DPPhoneDetailsView

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event {
  UIView *hitTestView = [super hitTest:point withEvent:event];
  if ([hitTestView isKindOfClass:[DPMaskView class]]) {
    DPMaskView *maskView = (DPMaskView *)hitTestView;
    if (!maskView.maskViewModel.isSelected) {
      if ([[maskView nextResponder] isKindOfClass:[DPPhoneDetailsView class]]) {
        DPPhoneDetailsView *phoneDetailsView = (DPPhoneDetailsView *)[maskView nextResponder];
        return phoneDetailsView;
      }
    } else {
      return hitTestView;
    }
  }
  if ([hitTestView isKindOfClass:[DPPhoneDetailsView class]]) {
    NSLog(@"DPPhoneDetailsView");
  }
  return hitTestView;
}

@end
