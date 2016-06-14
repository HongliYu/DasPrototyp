//
//  DPDropShadowView.m
//  DasPrototyp
//
//  Created by HongliYu on 16/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPDropShadowView.h"

@implementation DPDropShadowView

- (void)drawRect:(CGRect)rect {
  self.layer.shadowOffset = CGSizeZero;
  self.layer.shadowOpacity = 0.7f;
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
  self.layer.shadowPath = shadowPath.CGPath;
}

@end
