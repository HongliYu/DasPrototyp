//
//  DPMainModel.h
//  DasPrototyp
//
//  Created by HongliYu on 16/4/28.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPMainModel : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *owner;
@property (nonatomic, copy, readonly) NSString *thumbnailName;
@property (nonatomic, copy, readonly) NSString *comment;
@property (nonatomic, copy, readonly) NSString *createdTime;
@property (nonatomic, copy, readonly) NSString *updatedTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (void)setTitle:(NSString *)title;
- (void)setThumbnailName:(NSString *)thumbnailName;
- (void)setComment:(NSString *)comment;
- (void)setUpdatedTime:(NSString *)updatedTime;

@end
