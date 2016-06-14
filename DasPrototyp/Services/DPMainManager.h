//
//  DPMainManager.h
//  DasPrototyp
//
//  Created by HongliYu on 16/4/28.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DPMainViewModel;
@class DPHomeViewController;
@class DPMaskViewModel;
@class DPPageViewModel;

extern NSString *const kPhotoCellIdentifier;
extern NSString *const kMainCellIdentifier;

typedef NS_ENUM (NSUInteger, DPCollectState) {
  DPCollectStateNormal,
  DPCollectStateEdit
};// TODO: encapsulate to business

@interface DPMainManager : NSObject
DEFINE_SINGLETON_FOR_HEADER(DPMainManager)

// The first time open app
- (void)checkIfNeedDemo;
// mail attachemnt
- (void)checkNewProjectWithDirectory:(NSString *)directory;
- (void)createSharedArchive:(DPMainViewModel *)mainViewModel
                 complition:(finishedComplitionHandler)complition;
@property (nonatomic, copy) void(^addProjectFromMailCallBack)();

// play mode
- (void)enterPlayMode:(finishedComplitionHandler)complition;
- (void)exitPlayMode;
@property (nonatomic, assign, getter=isDoingAnimation) BOOL doingAnimation; // animation lock
- (void)enterAnimationMode;
- (void)exitAnimationMode;// TODO: encapsulate to business

// Constant state
@property (assign, nonatomic, readonly) DPCollectState collectState;
@property (assign, nonatomic, readonly) CGSize photoCellSize;
@property (assign, nonatomic, readonly) float leftVCCellHeight;
- (void)setCollectState:(DPCollectState)collectState;

// Data
@property (nonatomic, strong, readonly) NSCache *imageCache;
- (void)configBaseDataWithPageMark:(NSString *)pageMark;

- (void)createCacheOnDiskWithImageData:(NSData *)imageData;
- (void)replaceCachedImageDataWithImageData:(NSData *)imageData
                                  imageName:(NSString *)imageName;
- (void)imageWithProjectTitle:(NSString *)title
                    imageName:(NSString *)imageName
                   complition:(void (^)(UIImage *image))complition;

@property (nonatomic, strong, readonly) NSMutableArray *mainViewModels;
@property (nonatomic, strong, readonly) DPMainViewModel *currentMainViewModel;
@property (nonatomic, strong, readonly) DPPageViewModel *currentPageViewModel;
@property (nonatomic, strong, readonly) DPMaskViewModel *currentMaskViewModel;
@property (nonatomic, assign, readonly) NSInteger selecedIndexInEditMode; // TODO: encapsulate to business
@property (nonatomic, strong, readonly) DPPageViewModel *selectedPageViewModelInEditMode;
@property (nonatomic, copy) void (^takePhotoActionCallBack)();

- (void)setCurrentMainViewModel:(DPMainViewModel *)currentMainViewModel;
- (void)setCurrentPageViewModel:(DPPageViewModel *)currentPageViewModel;
- (void)setCurrentMaskViewModel:(DPMaskViewModel *)currentMaskViewModel;
- (void)setSelecedIndexInEditMode:(NSInteger)selecedIndexInEditMode;

- (void)addMainViewModel:(DPMainViewModel *)mainViewModel;
- (void)removeMainViewModel:(DPMainViewModel *)mainViewModel;
- (void)updateMainViewModel:(DPMainViewModel *)mainViewModel
                  withTitle:(NSString *)title;
- (void)updateMainViewModel:(DPMainViewModel *)mainViewModel
                withComment:(NSString *)comment;
- (void)restoreMainViewModels:(finishedComplitionHandler)complition;
- (void)persistMainViewModel;

- (void)addPageViewModel:(DPPageViewModel *)pageViewModel;
- (void)removePageViewModel:(DPPageViewModel *)pageViewModel;
- (void)updatePageViewModel:(DPPageViewModel *)pageViewModel
        withMainViewModelID:(NSString *)mainViewModelID;
- (void)restorePageViewModelsWithMainViewModelID:(NSString *)mainViewModelID
                                      complition:(finishedComplitionHandler)complition;

- (void)addMaskViewModel:(DPMaskViewModel *)maskViewModel;
- (void)removeMaskViewModel:(DPMaskViewModel *)maskViewModel;
- (void)updateMaskViewModel:(DPMaskViewModel *)maskViewModel
        withPageViewModelID:(NSString *)pageViewModelID;
- (void)updateAllMaskViewModels; // sync selected with database
- (void)restoreMaskViewModelsWithPageViewModelID:(NSString *)pageViewModelID
                                      complition:(finishedComplitionHandler)complition;

@end
