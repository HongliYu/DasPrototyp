//
//  DPDataManager.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DPMainViewModel;
@class DPPageViewModel;
@class DPMaskViewModel;

/**
 *  Disk Data
 */
@interface DPDataManager : NSObject

#pragma mark - Network
- (void)requestAphorismsCompletion:(resultCompletionHandler)completion;
- (void)loginWithUserName:(NSString *)name
              andPassword:(NSString *)password
               completion:(resultCompletionHandler)completion;

#pragma mark - File
- (void)renameDirectory:(NSString *)originalDirectory
                   with:(NSString *)newDirectory;
- (void)removeAll:(NSString *)path;
- (void)removeFile:(NSString *)filePath;
- (void)checkNewProjectWithDirectory:(NSString *)directory
                          completion:(resultCompletionHandler)completion;
- (void)createJSONDataWithMainViewModel:(DPMainViewModel *)mainViewModel
                             completion:(finishedCompletionHandler)completion;

#pragma mark - Database
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
- (void)selectMainViewModels:(mutableArrayCompletionHandler)completion;
- (void)selectPageViewModelsWithMainViewModelID:(NSString *)mainViewModelID
                                     completion:(mutableArrayCompletionHandler)completion;
- (void)selectMaskViewModelsWithPageViewModelID:(NSString *)pageViewModelID
                                     completion:(mutableArrayCompletionHandler)completion;
- (void)selectMaskViewModelsWithPageViewModelID_dispatchSync:(NSString *)pageViewModelID
                                                  completion:(mutableArrayCompletionHandler)completion;

// persist
- (void)persistMainViewModel:(DPMainViewModel *)mainViewModel;

#pragma mark - RAM
- (void)createReferenceTreeWithPageViewModels:(NSMutableArray *)pageViewModels
                                   completion:(finishedCompletionHandler)completion;
- (void)createReferenceTreeWithMainViewModel:(DPMainViewModel *)mainViewModel
                                  completion:(finishedCompletionHandler)completion;

@end
