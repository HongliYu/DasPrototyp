//
//  DPPageModel.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPPageModel : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *imageName;
@property (nonatomic, copy, readonly) NSString *createdTime;
@property (nonatomic, copy, readonly) NSString *updatedTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (void)setUpdatedTime:(NSString *)updatedTime;

@end
