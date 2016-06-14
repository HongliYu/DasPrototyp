//
//  UIView+MenuActionHandlers.m
//  DasPrototyp
//
//  Created by HongliYu on 14-8-9.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "UIView+MenuActionHandlers.h"
#import <objc/runtime.h>

static char kActionHandlerTapBlockKey;

@implementation UIView (MenuActionHandlers)

- (void)setMenuActionWithBlock:(void (^)(UITapGestureRecognizer *tapGesture))block {
  UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleActionForTapGesture:)];
  [self addGestureRecognizer:gesture];
  objc_setAssociatedObject(self, &kActionHandlerTapBlockKey,
                           block, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForTapGesture:(UITapGestureRecognizer *)gesture {
  if (gesture.state == UIGestureRecognizerStateRecognized) {
    void (^action)(UITapGestureRecognizer *tapGesture) = objc_getAssociatedObject(self, &kActionHandlerTapBlockKey);
    if (action) {
      action(gesture);
    }
  }
}

@end
