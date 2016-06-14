//
//  UIView+GDStyle.m
//  DuiTang
//
//  Created by ls on 14-8-13.
//
//

#import "UIView+GDStyle.h"

@implementation UIView (GDStyle)

- (void)makeStyle:(void(^)(GDUIViewStyleMaker *make))block {
    self.autoresizingMask = UIViewAutoresizingNone;
    [self removeConstraints:self.constraints];
    GDUIViewStyleMaker *styleMaker = [[GDUIViewStyleMaker alloc] initWithView:self];
    block(styleMaker);
}

@end
