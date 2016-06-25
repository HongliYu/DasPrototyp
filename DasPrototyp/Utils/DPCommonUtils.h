//
//  DPCommonUtils.h
//  DasPrototyp
//
//  Created by HongliYu on 16/6/11.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DPCommonUtils : NSObject

+ (CGSize)rectSizeWithText:(NSString *)text
               andFontSize:(CGFloat)fontSize;
+ (CGSize)rectSizeWithText:(NSString *)text
                 withWidth:(CGFloat)width
               andFontSize:(CGFloat)fontSize;

@end
