//
//  DPMaskModel.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPMaskModel : NSObject <NSCopying, NSCoding>

/**
 *  the shape of each mask view is rectangular.
    startPoint == left top point
    endPoint == right bottom point
 */
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign, readonly) CGPoint startPoint;
@property (nonatomic, assign, readonly) CGPoint endPoint;
@property (nonatomic, copy, readonly) NSString *createdTime;
@property (nonatomic, copy, readonly) NSString *updatedTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (void)setStartPoint:(CGPoint)startPoint;
- (void)setEndPoint:(CGPoint)endPoint;
- (void)setUpdatedTime:(NSString *)updatedTime;

@end
