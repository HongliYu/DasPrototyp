//
//  DPPageViewModel.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPPageModel.h"

@class DPMaskViewModel;

@interface DPPageViewModel : DPPageModel

@property (nonatomic, assign, readonly) BOOL selected;
@property (nonatomic, copy, readonly) NSMutableArray *maskViewModels;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithSeparatedDictionary:(NSDictionary *)dictionary;
- (void)setMaskViewModels:(NSMutableArray *)maskViewModels;

- (void)addMaskViewModel:(DPMaskViewModel *)maskViewModel;
- (void)removeMaskViewModel:(DPMaskViewModel *)maskViewModel;
- (void)setSelected:(BOOL)selected;

@end
