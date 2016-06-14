//
//  DPImageUtils.h
//  DasPrototyp
//
//  Created by HongliYu on 14-8-16.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPImageUtils : NSObject

+ (NSData *)compressImage:(UIImage *)image;
+ (CGSize)createPhotoSizeWithRowNumber:(int)row;
+ (UIImage*)generateHandleImageWithColor:(UIColor*)color;

@end
