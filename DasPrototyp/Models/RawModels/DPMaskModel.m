//
//  DPMaskModel.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPMaskModel.h"

@interface DPMaskModel()

@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, assign, readwrite) CGPoint startPoint;
@property (nonatomic, assign, readwrite) CGPoint endPoint;
@property (nonatomic, copy, readwrite) NSString *createdTime;
@property (nonatomic, copy, readwrite) NSString *updatedTime;

@end

@implementation DPMaskModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _identifier = [[dictionary objectForKey:@"id"] copy];
    CGFloat startPoint_X = [[dictionary objectForKey:@"start_point_x"] floatValue];
    CGFloat startPoint_Y = [[dictionary objectForKey:@"start_point_y"] floatValue];
    _startPoint = CGPointMake(startPoint_X, startPoint_Y);
    CGFloat endPoint_X = [[dictionary objectForKey:@"end_point_x"] floatValue];
    CGFloat endPoint_Y = [[dictionary objectForKey:@"end_point_y"] floatValue];
    _endPoint = CGPointMake(endPoint_X, endPoint_Y);
    _createdTime = [[dictionary objectForKey:@"created_time"] copy];
    _updatedTime = [[dictionary objectForKey:@"updated_time"] copy];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [self init];
  if (self == nil) return nil;
  _identifier = [coder decodeObjectForKey:@"id"];
  _startPoint = CGPointMake([coder decodeDoubleForKey:@"start_point_x"],
                            [coder decodeDoubleForKey:@"start_point_y"]);
  _endPoint = CGPointMake([coder decodeDoubleForKey:@"end_point_x"],
                          [coder decodeDoubleForKey:@"end_point_y"]);
  _createdTime = [coder decodeObjectForKey:@"created_time"];
  _updatedTime = [coder decodeObjectForKey:@"updated_time"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  if (self.identifier) [coder encodeObject:self.identifier forKey:@"id"];
  [coder encodeDouble:self.startPoint.x forKey:@"start_point_x"];
  [coder encodeDouble:self.startPoint.y forKey:@"start_point_y"];
  [coder encodeDouble:self.endPoint.x forKey:@"end_point_x"];
  [coder encodeDouble:self.endPoint.y forKey:@"end_point_y"];
  if (self.createdTime) [coder encodeObject:self.createdTime forKey:@"created_time"];
  if (self.updatedTime) [coder encodeObject:self.updatedTime forKey:@"updated_time"];
}

- (id)copyWithZone:(NSZone *)zone {
  DPMaskModel *maskModel = [[self.class allocWithZone:zone] init];
  maskModel->_identifier = self.identifier;
  maskModel->_startPoint = self.startPoint;
  maskModel->_endPoint = self.endPoint;
  maskModel->_createdTime = self.createdTime;
  maskModel->_updatedTime = self.updatedTime;
  return maskModel;
}

- (NSUInteger)hash {
  return self.identifier.hash;
}

- (BOOL)isEqual:(DPMaskModel *)maskModel {
  if (![maskModel isKindOfClass:DPMaskModel.class]) return NO;
  return [self.identifier isEqualToString:maskModel.identifier];
}

- (void)setStartPoint:(CGPoint)startPoint {
  _startPoint.x = startPoint.x;
  _startPoint.y = startPoint.y;
}

- (void)setEndPoint:(CGPoint)endPoint {
  _endPoint.x = endPoint.x;
  _endPoint.y = endPoint.y;
}

- (void)setUpdatedTime:(NSString *)updatedTime {
  _updatedTime = updatedTime;
}

@end
