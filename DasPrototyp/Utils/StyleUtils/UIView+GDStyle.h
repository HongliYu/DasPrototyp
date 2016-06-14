//
//  UIView+GDStyle.h
//  DuiTang
//
//  Created by ls on 14-8-13.
//
//

#import <UIKit/UIKit.h>
#import "GDUIViewStyleMaker.h"

@interface UIView (GDStyle)

- (void)makeStyle:(void(^)(GDUIViewStyleMaker *make))block;

@end
