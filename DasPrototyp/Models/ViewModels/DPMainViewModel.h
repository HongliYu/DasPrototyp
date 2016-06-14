//
//  DPMainViewModel.h
//  DasPrototyp
//
//  Created by HongliYu on 16/4/28.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPMainModel.h"

@class DPPageViewModel;

@interface DPMainViewModel : DPMainModel

@property (nonatomic, assign, readonly) BOOL expanded;
@property (nonatomic, strong, readonly) NSMutableArray *pageViewModels;

// no persistent
@property (nonatomic, copy, readonly) NSString *thumbnailPath;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithSeparatedDictionary:(NSDictionary *)dictionary;
- (void)setPageViewModels:(NSMutableArray *)pageViewModels;

- (void)addPageViewModel:(DPPageViewModel *)pageViewModel;
- (void)removePageViewModel:(DPPageViewModel *)pageViewModel;
- (void)reverseExpanded;

@end
