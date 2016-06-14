//
//  GDStyle.h
//  DuiTang
//
//  Created by ls on 14-8-13.
//
//

#import <UIKit/UIKit.h>
#import "UIViewAdditions.h"

@interface GDUIViewStyleMaker : NSObject

- (id)initWithView:(UIView *)view;

- (GDUIViewStyleMaker * (^)(CGFloat))width;
- (GDUIViewStyleMaker * (^)(CGFloat))height;
- (GDUIViewStyleMaker * (^)(CGFloat))left;
- (GDUIViewStyleMaker * (^)(CGFloat))right;
- (GDUIViewStyleMaker * (^)(CGFloat))top;
- (GDUIViewStyleMaker * (^)(CGFloat))bottom;
- (GDUIViewStyleMaker * (^)(CGRect))frame;
- (GDUIViewStyleMaker * (^)(UIViewAutoresizing))autoresizingMask;
- (GDUIViewStyleMaker * (^)(UIImage *))image;
- (GDUIViewStyleMaker * (^)(UIFont *))font;
- (GDUIViewStyleMaker * (^)(NSInteger))numberOfLines;
- (GDUIViewStyleMaker * (^)(UIColor *))textColor;
- (GDUIViewStyleMaker * (^)(NSLineBreakMode ))lineBreakMode;
- (GDUIViewStyleMaker * (^)(void ))sizeToFit;
- (GDUIViewStyleMaker * (^)(CGPoint))center;
- (GDUIViewStyleMaker * (^)(UIColor *))backgroundColor;
- (GDUIViewStyleMaker * (^)(UIFont *))titleFont;
- (GDUIViewStyleMaker * (^)(NSLineBreakMode ))titleLineBreakMode;
- (GDUIViewStyleMaker * (^)(UIControlContentHorizontalAlignment ))contentHorizontalAlignment;
- (GDUIViewStyleMaker * (^)(UIColor *, UIControlState))titleColor;
- (GDUIViewStyleMaker * (^)(UIImage *, UIControlState))backgroundImage;
- (GDUIViewStyleMaker * (^)(UIImage *, UIControlState))buttonImage;
- (GDUIViewStyleMaker * (^)(UIEdgeInsets))titleEdgeInsets;
- (GDUIViewStyleMaker * (^)(UIEdgeInsets))imageEdgeInsets;
- (GDUIViewStyleMaker * (^)(UIColor *, CGFloat))bottomBorder;
- (GDUIViewStyleMaker * (^)(UIColor *, CGFloat))rightBorder;
- (GDUIViewStyleMaker * (^)(UIColor *, CGFloat))leftBorder;
- (GDUIViewStyleMaker * (^)(UIColor *, CGFloat))topBorder;

@end
