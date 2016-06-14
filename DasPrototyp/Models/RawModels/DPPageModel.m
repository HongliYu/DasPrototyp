//
//  DPPageModel.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPPageModel.h"

@interface DPPageModel()

@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, copy, readwrite) NSString *imageName;
@property (nonatomic, copy, readwrite) NSString *createdTime;
@property (nonatomic, copy, readwrite) NSString *updatedTime;

@end

@implementation DPPageModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _identifier = [[dictionary objectForKey:@"id"] copy];
    _imageName = [[dictionary objectForKey:@"image_name"] copy];
    _createdTime = [[dictionary objectForKey:@"created_time"] copy];
    _updatedTime = [[dictionary objectForKey:@"updated_time"] copy];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [self init];
  if (self == nil) return nil;
  _identifier = [coder decodeObjectForKey:@"id"];
  _imageName = [coder decodeObjectForKey:@"image_name"];
  _createdTime = [coder decodeObjectForKey:@"created_time"];
  _updatedTime = [coder decodeObjectForKey:@"updated_time"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  if (self.identifier) [coder encodeObject:self.identifier forKey:@"id"];
  if (self.imageName) [coder encodeObject:self.identifier forKey:@"image_name"];
  if (self.createdTime) [coder encodeObject:self.createdTime forKey:@"created_time"];
  if (self.updatedTime) [coder encodeObject:self.updatedTime forKey:@"updated_time"];
}

- (id)copyWithZone:(NSZone *)zone {
  DPPageModel *pageModel = [[self.class allocWithZone:zone] init];
  pageModel->_identifier = self.identifier;
  pageModel->_imageName = self.imageName;
  pageModel->_createdTime = self.createdTime;
  pageModel->_updatedTime = self.updatedTime;
  return pageModel;
}

- (NSUInteger)hash {
  return self.identifier.hash;
}

- (BOOL)isEqual:(DPPageModel *)pageModel {
  if (![pageModel isKindOfClass:DPPageModel.class]) return NO;
  return [self.identifier isEqualToString:pageModel.identifier];
}

- (void)setUpdatedTime:(NSString *)updatedTime {
  _updatedTime = updatedTime;
}

@end
