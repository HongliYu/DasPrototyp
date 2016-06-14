//
//  DPMainViewModel.m
//  DasPrototyp
//
//  Created by HongliYu on 16/4/28.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPMainViewModel.h"
#import "DPPageViewModel.h"

@interface DPMainViewModel() <NSCopying, NSCoding>

@property (nonatomic, assign, readwrite) BOOL expanded;
@property (nonatomic, strong, readwrite) NSMutableArray *pageViewModels;

@end

@implementation DPMainViewModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super initWithDictionary:dictionary];
  if (self) {
    _expanded = [[dictionary objectForKey:@"expanded"] boolValue];
    _pageViewModels = [[NSMutableArray alloc] init];
    NSArray *pageViewModelsRawData = [dictionary objectForKey:@"page_viewmodels"];
    if ([pageViewModelsRawData firstObject]) {
      for (NSDictionary *pageViewModelsDictionary in pageViewModelsRawData) {
        DPPageViewModel *pageViewModel = [[DPPageViewModel alloc] initWithDictionary:pageViewModelsDictionary];
        [_pageViewModels addObject:pageViewModel];
      }
    }
  }
  return self;
}

- (instancetype)initWithSeparatedDictionary:(NSDictionary *)dictionary {
  self = [super initWithDictionary:dictionary];
  if (self) {
    _expanded = [[dictionary objectForKey:@"expanded"] boolValue];
    _pageViewModels = [[NSMutableArray alloc] init];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    _expanded = [coder decodeBoolForKey:@"expanded"];
    _pageViewModels = [coder decodeObjectForKey:@"pageViewModels"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeBool:self.expanded forKey:@"expanded"];
  if (self.pageViewModels) [coder encodeObject:self.pageViewModels forKey:@"pageViewModels"];
}

- (id)copyWithZone:(NSZone *)zone {
  DPMainViewModel *mainViewModel = [super copyWithZone:zone];
  mainViewModel->_expanded = self.expanded;
  mainViewModel->_pageViewModels = self.pageViewModels;
  return mainViewModel;
}

- (NSUInteger)hash {
  return [super hash];
}

- (BOOL)isEqual:(DPMainViewModel *)mainViewModel {
  if (![mainViewModel isKindOfClass:DPMainViewModel.class]) return NO;
  return [self.identifier isEqualToString:mainViewModel.identifier]
  && [self.createdTime isEqualToString:mainViewModel.createdTime];
}

- (void)setPageViewModels:(NSMutableArray *)pageViewModels {
  _pageViewModels = [pageViewModels mutableCopy];
}

- (void)addPageViewModel:(DPPageViewModel *)pageViewModel {
  if (![self.pageViewModels containsObject:pageViewModel]) {
    [self.pageViewModels addObject:pageViewModel];
  }
}

- (void)removePageViewModel:(DPPageViewModel *)pageViewModel {
  if ([self.pageViewModels containsObject:pageViewModel]) {
    [self.pageViewModels removeObject:pageViewModel];
  }
}

- (void)reverseExpanded {
  self.expanded = !self.expanded;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, %@>",
          [self class], self, @{@"identifier" : self.identifier,
                                @"title" : self.title,
                                @"owner" : self.owner,
                                @"thumbnailName" : self.thumbnailName,
                                @"comment" : self.comment,
                                @"createdTime" : self.createdTime,
                                @"updatedTime" : self.updatedTime,
                                @"expanded" : @(self.expanded),
                                }];
}

@end
