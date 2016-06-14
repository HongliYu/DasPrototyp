//
//  NSString+Additions.h
//  BaiduBrowser
//
//  Created by HongliYu on 15/9/29.
//  Copyright © 2015年 Baidu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (BOOL)isBlank;
- (BOOL)isValid;
- (NSString *)removeWhiteSpacesFromString;

- (NSUInteger)countNumberOfWords;
- (BOOL)containsString:(NSString *)subString;
- (BOOL)isBeginsWith:(NSString *)string;
- (BOOL)isEndsWith:(NSString *)string;

- (NSString *)replaceCharcter:(NSString *)olderChar
                 withCharcter:(NSString *)newerChar;
- (NSString *)getSubstringFrom:(NSInteger)begin
                            to:(NSInteger)end;
- (NSString *)addString:(NSString *)string;
- (NSString *)removeSubString:(NSString *)subString;

- (BOOL)containsFloat;
- (BOOL)containsOnlyLetters;
- (BOOL)containsOnlyNumbers;
- (BOOL)containsOnlyNumbersAndLetters;
- (BOOL)isInThisArray:(NSArray *)array;

+ (NSString *)getStringFromArray:(NSArray *)array;
- (NSArray *)getArray;

+ (NSString *)getMyApplicationVersion;
+ (NSString *)getMyApplicationName;

- (NSData *)convertToData;
+ (NSString *)getStringFromData:(NSData *)data;

- (BOOL)isValidEmail;
- (BOOL)isVAlidPhoneNumber;
- (BOOL)isValidUrl;

+ (NSString *)stringWithUUID;
+ (NSString *)md5:(NSString *)string;

@end
