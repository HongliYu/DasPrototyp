//
//  DPDBRoot.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/3.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DPMainViewModel;
@class DPPageViewModel;
@class DPMaskViewModel;

@interface DPDBRoot : NSObject

// config
- (void)configDataBase;

// insert
- (void)insertMainViewModel:(DPMainViewModel *)mainViewModel;
- (void)insertPageViewModel:(DPPageViewModel *)pageViewModel
        withMainViewModelID:(NSString *)mainViewModelID;
- (void)insertMaskViewModel:(DPMaskViewModel *)maskViewModel
        withPageViewModelID:(NSString *)pageViewModelID;

// delete
- (void)deleteMainViewModel:(DPMainViewModel *)mainViewModel;
- (void)deletePageViewModel:(DPPageViewModel *)pageViewModel;
- (void)deleteMaskViewModel:(DPMaskViewModel *)maskViewModel;

// update
- (void)updateMainViewModel:(DPMainViewModel *)mainViewModel;
- (void)updatePageViewModel:(DPPageViewModel *)pageViewModel
        withMainViewModelID:(NSString *)mainViewModelID;
- (void)updateMaskViewModel:(DPMaskViewModel *)maskViewModel
        withPageViewModelID:(NSString *)pageViewModelID;

// select
- (void)selectMainViewModels:(mutableArrayComplitionHandler)complition;
- (void)selectPageViewModelsWithMainViewModelID:(NSString *)mainViewModelID
                                     complition:(mutableArrayComplitionHandler)complition;
- (void)selectMaskViewModelsWithPageViewModelID:(NSString *)pageViewModelID
                                     complition:(mutableArrayComplitionHandler)complition;
#pragma mark - Persist
- (void)persistMainViewModel:(DPMainViewModel *)mainViewModel;

@end
