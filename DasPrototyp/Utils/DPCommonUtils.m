//
//  DPCommonUtils.m
//  DasPrototyp
//
//  Created by HongliYu on 16/6/11.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPCommonUtils.h"
#import "DPMainMacro.h"

@implementation DPCommonUtils

+ (CGSize)rectSizeWithText:(NSString *)text
               andFontSize:(CGFloat)fontSize {
  NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]};
  CGSize size = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, MAXFLOAT)
                                   options:NSStringDrawingTruncatesLastVisibleLine |
                 NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:attribute
                                   context:nil].size;
  return size;
}

+ (CGSize)rectSizeWithText:(NSString *)text
                 withWidth:(CGFloat)width
               andFontSize:(CGFloat)fontSize {
  NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]};
  CGSize size = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                   options:NSStringDrawingTruncatesLastVisibleLine |
                 NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:attribute
                                   context:nil].size;
  return size;
}

@end
