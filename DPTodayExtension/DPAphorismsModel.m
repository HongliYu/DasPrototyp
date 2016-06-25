//
//  DPAphorismsModel.m
//  DasPrototyp
//
//  Created by HongliYu on 16/6/24.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPAphorismsModel.h"

@interface DPAphorismsModel() <NSCopying, NSCoding>

@property (nonatomic, strong, readwrite) NSNumber *identifier;
@property (nonatomic, copy, readwrite) NSString *content;
@property (nonatomic, copy, readwrite) NSString *mrname;

@end

@implementation DPAphorismsModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _identifier = [dictionary objectForKey:@"id"];
    _content = [[dictionary objectForKey:@"content"] copy];
    _mrname = [[dictionary objectForKey:@"mrname"] copy];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [self init];
  if (self == nil) return nil;
  _identifier = [coder decodeObjectForKey:@"id"];
  _content = [coder decodeObjectForKey:@"content"];
  _mrname = [coder decodeObjectForKey:@"mrname"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  if (self.identifier) [coder encodeObject:self.identifier forKey:@"id"];
  if (self.content != nil) [coder encodeObject:self.content forKey:@"content"];
  if (self.mrname != nil) [coder encodeObject:self.mrname forKey:@"mrname"];
}

- (id)copyWithZone:(NSZone *)zone {
  DPAphorismsModel *aphorismsModel = [[self.class allocWithZone:zone] init];
  aphorismsModel->_identifier = self.identifier;
  aphorismsModel->_content = self.content;
  aphorismsModel->_mrname = self.mrname;
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
