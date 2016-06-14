//
//  NSDate+Additions.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/7.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

+ (NSString *)formattedDateNow;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSString *)stringFromDate:(NSDate *)date;

@end
