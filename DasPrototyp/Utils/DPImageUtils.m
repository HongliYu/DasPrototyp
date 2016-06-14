//
//  DPImageUtils.m
//  DasPrototyp
//
//  Created by HongliYu on 14-8-16.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPImageUtils.h"

#define PHOTOCELL_PADDING 8.f

@implementation DPImageUtils

+ (NSData *)compressImage:(UIImage *)image {
  CGFloat compression = 0.9f;
  CGFloat maxCompression = 0.1f;
  // 1024kb
  int maxFileSize = 1024 * 1024;
  NSData *imageData = UIImageJPEGRepresentation(image, compression);
  while ([imageData length] > maxFileSize && compression > maxCompression) {
    compression -= 0.1;
    imageData = UIImageJPEGRepresentation(image, compression);
  }
  return imageData;
}

+ (CGSize)createPhotoSizeWithRowNumber:(int)row {
  return CGSizeMake((SCREEN_WIDTH - (row + 1) * PHOTOCELL_PADDING) / row,
                    ((SCREEN_WIDTH - (row + 1) * PHOTOCELL_PADDING) / row) /
                        SCREEN_PROPORTION);
  //    return CGSizeMake((SCREEN_WIDTH - (row+1)*PHOTOCELL_PADDING)/row,100);
}

+ (UIImage*)generateHandleImageWithColor:(UIColor*)color {
  CGRect rect = CGRectMake(0.0f, 0.0f, 8.f, 8.f);
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.f);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, color.CGColor);
  CGContextFillRect(context, CGRectInset(rect, 0, 0));
  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@end
