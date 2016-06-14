//
//  DPPageViewModel.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPPageViewModel.h"
#import "DPMaskViewModel.h"

@interface DPPageViewModel() <NSCopying, NSCoding>

@property (nonatomic, assign, readwrite) BOOL selected;
@property (nonatomic, copy, readwrite) NSMutableArray *maskViewModels;

@end

@implementation DPPageViewModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super initWithDictionary:dictionary];
  if (self) {
    _selected = [[dictionary objectForKey:@"selected"] boolValue];
    _maskViewModels = [[NSMutableArray alloc] init];
    NSMutableArray *maskViewModelsRawData = [dictionary objectForKey:@"mask_viewmodels"];
    if ([maskViewModelsRawData firstObject]) {
      for (NSDictionary *maskViewModelDictionary in maskViewModelsRawData) {
        DPMaskViewModel *maskViewModel = [[DPMaskViewModel alloc] initWithDictionary:maskViewModelDictionary];
        [_maskViewModels addObject:maskViewModel];
      }
    }
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    _selected = [coder decodeBoolForKey:@"selected"];
    _maskViewModels = [coder decodeObjectForKey:@"maskViewModels"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeBool:self.selected forKey:@"selected"];
  [coder encodeObject:self.maskViewModels forKey:@"maskViewModels"];
}

- (id)copyWithZone:(NSZone *)zone {
  DPPageViewModel *pageViewModel = [super copyWithZone:zone];
  pageViewModel->_selected = self.selected;
  pageViewModel->_maskViewModels = self.maskViewModels;
  return pageViewModel;
}

- (NSUInteger)hash {
  return [super hash];
}

- (BOOL)isEqual:(DPPageViewModel *)pageViewModel {
  if (![pageViewModel isKindOfClass:DPPageViewModel.class]) return NO;
  return [self.identifier isEqualToString:pageViewModel.identifier]
  && [self.createdTime isEqualToString:pageViewModel.createdTime];
}

- (instancetype)initWithSeparatedDictionary:(NSDictionary *)dictionary {
  self = [super initWithDictionary:dictionary];
  if (self) {
    _selected = [[dictionary objectForKey:@"selected"] boolValue];
    _maskViewModels = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)setMaskViewModels:(NSMutableArray *)maskViewModels {
  _maskViewModels = [maskViewModels mutableCopy];
}

- (void)addMaskViewModel:(DPMaskViewModel *)maskViewModel {
  if (![self.maskViewModels containsObject:maskViewModel]) {
    [self.maskViewModels addObject:maskViewModel];
  }
}

- (void)removeMaskViewModel:(DPMaskViewModel *)maskViewModel {
  if ([self.maskViewModels containsObject:maskViewModel]) {
    [self.maskViewModels removeObject:maskViewModel];
  }
}

- (void)setSelected:(BOOL)selected {
  _selected = selected;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, %@>",
          [self class], self, @{@"identifier" : self.identifier,
                                @"imageName" : self.imageName,
                                @"createdTime" : self.createdTime,
                                @"updatedTime" : self.updatedTime,
                                @"selected" : @(self.selected),
                                }];
}

@end
