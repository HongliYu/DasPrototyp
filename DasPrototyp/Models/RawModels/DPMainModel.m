//
//  DPMainModel.m
//  DasPrototyp
//
//  Created by HongliYu on 16/4/28.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPMainModel.h"
#import "DPPageModel.h"

@interface DPMainModel()

@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *owner;
@property (nonatomic, copy, readwrite) NSString *thumbnailName;
@property (nonatomic, copy, readwrite) NSString *comment;
@property (nonatomic, copy, readwrite) NSString *createdTime;
@property (nonatomic, copy, readwrite) NSString *updatedTime;

@end

@implementation DPMainModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _identifier = [[dictionary objectForKey:@"id"] copy];
    _title = [[dictionary objectForKey:@"title"] copy];
    _owner = [[dictionary objectForKey:@"owner"] copy];
    _thumbnailName = [[dictionary objectForKey:@"thumbnail_name"] copy];
    _comment = [[dictionary objectForKey:@"comment"] copy];
    _createdTime = [[dictionary objectForKey:@"created_time"] copy];
    _updatedTime = [[dictionary objectForKey:@"updated_time"] copy];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [self init];
  if (self == nil) return nil;
  _identifier = [coder decodeObjectForKey:@"id"];
  _title = [coder decodeObjectForKey:@"title"];
  _owner = [coder decodeObjectForKey:@"owner"];
  _thumbnailName = [coder decodeObjectForKey:@"thumbnail_name"];
  _comment = [coder decodeObjectForKey:@"comment"];
  _createdTime = [coder decodeObjectForKey:@"created_time"];
  _updatedTime = [coder decodeObjectForKey:@"updated_time"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  if (self.identifier) [coder encodeObject:self.identifier forKey:@"id"];
  if (self.title != nil) [coder encodeObject:self.title forKey:@"title"];
  if (self.owner != nil) [coder encodeObject:self.owner forKey:@"owner"];
  if (self.thumbnailName != nil) [coder encodeObject:self.thumbnailName forKey:@"thumbnail_name"];
  if (self.comment != nil) [coder encodeObject:self.comment forKey:@"comment"];
  if (self.createdTime != nil) [coder encodeObject:self.createdTime forKey:@"created_time"];
  if (self.updatedTime != nil) [coder encodeObject:self.updatedTime forKey:@"updated_time"];
}

- (id)copyWithZone:(NSZone *)zone {
  DPMainModel *mainModel = [[self.class allocWithZone:zone] init];
  mainModel->_identifier = self.identifier;
  mainModel->_title = self.title;
  mainModel->_owner = self.owner;
  mainModel->_thumbnailName = self.thumbnailName;
  mainModel->_comment = self.comment;
  mainModel->_createdTime = self.createdTime;
  mainModel->_updatedTime = self.updatedTime;
  return mainModel;
}

- (NSUInteger)hash {
  return self.identifier.hash;
}

- (BOOL)isEqual:(DPMainModel *)mainModel {
  if (![mainModel isKindOfClass:DPMainModel.class]) return NO;
  return [self.identifier isEqualToString:mainModel.identifier];
}

- (void)setTitle:(NSString *)title {
  _title = title;
}

- (void)setThumbnailName:(NSString *)thumbnailName {
  _thumbnailName = thumbnailName;
}

- (void)setComment:(NSString *)comment {
  _comment = comment;
}

- (void)setUpdatedTime:(NSString *)updatedTime {
  _updatedTime = updatedTime;
}

@end
