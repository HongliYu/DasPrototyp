//
//  NSDate+Additions.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/7.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

+ (NSString *)formattedDateNow {
  NSDate *now = [NSDate date];
  return [self stringFromDate:now];
}

+ (NSDate *)dateFromString:(NSString *)dateString {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
  NSDate *date = [dateFormatter dateFromString:dateString];
  return date;
}

+ (NSString *)stringFromDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
  [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
  NSString *dateString = [dateFormatter stringFromDate:date];
  return dateString;
}

@end
