//
//  DPAphorismsModel.m
//  DPTodayExtension
//
//  Created by Hongli Yu on 2018/11/19.
//  Copyright © 2018 HongliYu. All rights reserved.
//

#import "DPAphorismsModel.h"

@interface DPAphorismsModel() <NSCopying, NSCoding>

@property (nonatomic, strong, readwrite) NSNumber *identifier;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *content;
@property (nonatomic, copy, readwrite) NSString *link;

@end

@implementation DPAphorismsModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _identifier = [dictionary objectForKey:@"ID"];
    _title = [[dictionary objectForKey:@"title"] copy];
    _content = [[dictionary objectForKey:@"content"] copy];
    _link = [[dictionary objectForKey:@"link"] copy];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [self init];
  if (self == nil) return nil;
  _identifier = [coder decodeObjectForKey:@"ID"];
  _title = [coder decodeObjectForKey:@"title"];
  _content = [coder decodeObjectForKey:@"content"];
  _link = [coder decodeObjectForKey:@"link"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  if (self.identifier != nil) [coder encodeObject:self.identifier forKey:@"ID"];
  if (self.title != nil) [coder encodeObject:self.title forKey:@"title"];
  if (self.content != nil) [coder encodeObject:self.content forKey:@"content"];
  if (self.link != nil) [coder encodeObject:self.link forKey:@"link"];
}

- (id)copyWithZone:(NSZone *)zone {
  DPAphorismsModel *aphorismsModel = [[self.class allocWithZone:zone] init];
  aphorismsModel->_identifier = self.identifier;
  aphorismsModel->_title = self.title;
  aphorismsModel->_content = self.content;
  aphorismsModel->_link = self.link;
  return aphorismsModel;
}

- (NSUInteger)hash {
  return self.identifier.hash;
}

- (BOOL)isEqual:(DPAphorismsModel *)aphorismsModel {
  if (![aphorismsModel isKindOfClass:DPAphorismsModel.class]) return NO;
  return self.identifier == aphorismsModel.identifier;
}

@end
