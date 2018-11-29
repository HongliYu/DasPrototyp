//
//  DPMainManager.m
//  DasPrototyp
//
//  Created by HongliYu on 16/4/28.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPMainManager.h"
#import "DPDataManager.h"
#import "DPHomeViewController.h"
#import "DPMainViewModel.h"
#import "DPPageViewModel.h"
#import "DPMaskViewModel.h"
#import "SSZipArchive.h"
#import "DPDeviceUtils.h"

NSString *const kMainCellIdentifier = @"DPMainTableViewCell";
NSString *const kPhotoCellIdentifier = @"DPPhotoCollectionViewCell";

@interface DPMainManager()

@property (nonatomic, strong, readwrite) NSMutableArray *mainViewModels;
@property (nonatomic, strong, readwrite) DPDataManager *dataManager;
@property (nonatomic, strong, readwrite) DPMainViewModel *currentMainViewModel;
@property (nonatomic, strong, readwrite) DPMaskViewModel *currentMaskViewModel;
@property (nonatomic, strong, readwrite) DPPageViewModel *currentPageViewModel;
@property (nonatomic, strong, readwrite) NSCache *imageCache;

// Constant state
@property (assign, nonatomic, readwrite) DPCollectState collectState;
@property (assign, nonatomic, readwrite) CGSize photoCellSize;
@property (assign, nonatomic, readwrite) float leftVCCellHeight;

@end

@implementation DPMainManager
DEFINE_SINGLETON_FOR_CLASS(DPMainManager)

- (void)checkIfNeedDemo {
  if (![USER_DEFAULT objectForKey:@"NeedDemo"]) {
    NSString *resourcePath = nil;
    NSString *screenSize = [DPDeviceUtils checkDeviceScreen];
    resourcePath = [[NSBundle mainBundle] pathForResource:screenSize ofType:@"dparchive"];
    NSString *demoDirectoryPath = [[DPFileManager DocumentDirectory] stringByAppendingPathComponent:@"Demos"];
    [DPFileManager createDirectory:demoDirectoryPath];
    NSString *demoFilePath = [NSString stringWithFormat:@"%@/%@.dparchive", demoDirectoryPath, screenSize];
    [DPFileManager copyFile:resourcePath to:demoFilePath];
    [self checkNewProjectWithDirectory:@"Demos"];
    [USER_DEFAULT setObject:@"Deployed" forKey:@"NeedDemo"];
  }
}

- (void)checkNewProjectWithDirectory:(NSString *)directory {
  [self.dataManager checkNewProjectWithDirectory:directory
                                      completion:^(id result, NSError *error) {
    if ([result isMemberOfClass:[DPMainViewModel class]]) {
      DPMainViewModel *mainViewModel = (DPMainViewModel *) result;
      [self addMainViewModel:mainViewModel];
      // persist data to database
      // TODO: Async dispatch
      [mainViewModel.pageViewModels
       enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DPPageViewModel *pageViewModel = (DPPageViewModel *)obj;
        [self addPageViewModel:pageViewModel];
        [self.dataManager insertPageViewModel:pageViewModel
                          withMainViewModelID:mainViewModel.identifier];
        [pageViewModel.maskViewModels
         enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          DPMaskViewModel *maskViewModel = (DPMaskViewModel *)obj;
          [self.dataManager insertMaskViewModel:maskViewModel
                            withPageViewModelID:pageViewModel.identifier];
        }];
      }];
      if (self.addProjectFromMailCallBack) {
        self.addProjectFromMailCallBack();
      }
    }
  }];
}

- (void)createReferenceTreeWithMainViewModel:(DPMainViewModel *)mainViewModel
                                  completion:(finishedCompletionHandler)completion {
  [self.dataManager createReferenceTreeWithMainViewModel:mainViewModel completion:^(BOOL finished) {
    if (completion) {
      completion(YES);
    }
  }];
}

// play mode
- (void)enterPlayMode:(finishedCompletionHandler)completion {
  NSMutableArray *pageViewModels = [self.currentMainViewModel.pageViewModels mutableCopy];
  [self.dataManager createReferenceTreeWithPageViewModels:pageViewModels completion:^(BOOL finished) {
    if (finished && completion) {
      completion(YES);
    }
  }];
}

- (void)exitPlayMode {
  // release irrelevant maskViewModels
  for (DPPageViewModel *pageViewModel in self.currentMainViewModel.pageViewModels) {
    if (![pageViewModel isEqual:self.currentPageViewModel]) {
      // TODO: clean reference tree
    }
  }
}

- (void)enterAnimationMode {
  _doingAnimation = YES;
}

- (void)exitAnimationMode {
  _doingAnimation = NO;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _imageCache = [[NSCache alloc] init];
    _imageCache.countLimit = 50;
    _imageCache.totalCostLimit = 50 * 1024 * 1024;
    _mainViewModels = [[NSMutableArray alloc] init];
    _leftVCCellHeight = SCREEN_HEIGHT / 10.f;
    _photoCellSize = [DPImageUtils createPhotoSizeWithRowNumber:3];
    _dataManager = [[DPDataManager alloc] init];
    _doingAnimation = NO;
    [SVProgressHUD setMinimumDismissTimeInterval:1.f];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
  }
  return self;
}

#pragma mark Constant state
- (void)setCollectState:(DPCollectState)collectState {
  _collectState = collectState;
}

#pragma mark Data
- (void)configBaseDataWithPageMark:(NSString *)pageMark { // TODO: Statistics
  if ([pageMark isEqualToString:@"DPPhotoCollectViewController"]) {
    return;
  }
  if ([pageMark isEqualToString:@"DPPhotoCollectViewController"]) {
    return;
  }
}

- (void)createCacheOnDiskWithImageData:(NSData *)imageData {
  NSString *projectDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@",
                                    [DPFileManager DocumentDirectory],
                                    @"Projects",
                                    self.currentMainViewModel.title];
  [DPFileManager createDirectory:projectDirectoryPath]; // create if not existed
  NSString *createdTime = [NSDate formattedDateNow];
  NSString *salt = [NSString stringWithFormat:@"%@%@",
                    [DPMainManager sharedDPMainManager].currentMainViewModel.owner,
                    createdTime];
  NSString *imageName = [NSString md5:salt];
  NSDictionary *rawPageViewModelDictionary = @{@"id" : [NSString stringWithUUID],
                                               @"image_name" : imageName,
                                               @"created_time" : createdTime,
                                               @"updated_time" : createdTime};
  DPPageViewModel *pageViewModel = [[DPPageViewModel alloc] initWithSeparatedDictionary:rawPageViewModelDictionary];
  [self cacheImageData:imageData
         withImageName:imageName
          projectTitle:self.currentMainViewModel.title]; // 先写入硬盘，然后再触发更新
  [self addPageViewModel:pageViewModel];
}

- (void)replaceCachedImageDataWithImageData:(NSData *)imageData
                                  imageName:(NSString *)imageName {
  [self cacheImageData:imageData
         withImageName:imageName
          projectTitle:self.currentMainViewModel.title];
}

- (void)cacheImageData:(NSData *)imageData
         withImageName:(NSString *)imageName
          projectTitle:(NSString *)title {
  NSString *imagePath = [self imagePathWithProjectTitle:title
                                              imageName:imageName];
  [self.imageCache setObject:[UIImage imageWithData:imageData]
                      forKey:imageName];
  if ([imageData writeToFile:imagePath
                  atomically:YES]) {
    DLog(@"imageData succeed");
  } else {
    DLog(@"imageData writeToFile error");
  }
}

- (NSString *)imagePathWithProjectTitle:(NSString *)title
                              imageName:(NSString *)imageName {
  NSString *imagePath = [NSString stringWithFormat:@"%@/%@/%@/%@.png",
                                    [DPFileManager DocumentDirectory],
                                    @"Projects", title, imageName];
  return imagePath;
}

- (void)imageWithProjectTitle:(NSString *)title
                    imageName:(NSString *)imageName
                   completion:(void (^)(UIImage *image))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    UIImage *image = [self.imageCache objectForKey:imageName];
    if (!image) {
      image = [UIImage imageWithContentsOfFile:
               [self imagePathWithProjectTitle:title
                                     imageName:imageName]];
      if (image) {
        [self.imageCache setObject:image forKey:imageName];
      } else {
        DLog(@"imageWithProjectTitle image is nil");
      }
    }
    if (completion) {
      completion(image);
    }
  });
}

- (void)setCurrentMainViewModel:(DPMainViewModel *)currentMainViewModel {
  _currentMainViewModel = currentMainViewModel;
}

- (void)setCurrentPageViewModel:(DPPageViewModel *)currentPageViewModel {
  _currentPageViewModel = currentPageViewModel;
}

- (void)setCurrentMaskViewModel:(DPMaskViewModel *)currentMaskViewModel {
  _currentMaskViewModel = currentMaskViewModel;
}

- (void)setSelecedIndexInEditMode:(NSInteger)selecedIndexInEditMode {
  _selecedIndexInEditMode = selecedIndexInEditMode;
}

- (DPPageViewModel *)selectedPageViewModelInEditMode {
  NSInteger lastIndex = _currentMainViewModel.pageViewModels.count - 1;
  if (lastIndex >= _selecedIndexInEditMode) {
    return _currentMainViewModel.pageViewModels[_selecedIndexInEditMode];
  }
  return nil;
}

- (void)addMainViewModel:(DPMainViewModel *)mainViewModel {
  if (![self.mainViewModels containsObject:mainViewModel]) {
    [self.mainViewModels addObject:mainViewModel];
    [self.dataManager insertMainViewModel:mainViewModel];
  }
}

- (void)removeMainViewModel:(DPMainViewModel *)mainViewModel {
  if ([self.mainViewModels containsObject:mainViewModel]) {
    [self.mainViewModels removeObject:mainViewModel];
    [self.dataManager deleteMainViewModel:mainViewModel];
    NSString *dirPath = [NSString stringWithFormat:@"%@/%@/%@/",
                         [DPFileManager DocumentDirectory],
                         @"Projects", mainViewModel.title];
    [self.dataManager removeAll:dirPath];
  }
}

- (void)updateMainViewModel:(DPMainViewModel *)mainViewModel
                  withTitle:(NSString *)title {
  if ([self.mainViewModels containsObject:mainViewModel]) {
    [mainViewModel setUpdatedTime:[NSDate formattedDateNow]];
    NSString *originalDirectory = [NSString stringWithFormat:@"%@/%@/%@/",
                                   [DPFileManager DocumentDirectory],
                                   @"Projects", mainViewModel.title];
    NSString *newDirectory = [NSString stringWithFormat:@"%@/%@/%@/",
                              [DPFileManager DocumentDirectory],
                              @"Projects", title];
    [mainViewModel setTitle:title];
    [self.dataManager updateMainViewModel:mainViewModel];
    [self.dataManager renameDirectory:originalDirectory
                                 with:newDirectory];
  }
}

- (void)updateMainViewModel:(DPMainViewModel *)mainViewModel
                withComment:(NSString *)comment {
  if ([self.mainViewModels containsObject:mainViewModel]) {
    [mainViewModel setUpdatedTime:[NSDate formattedDateNow]];
    [mainViewModel setComment:comment];
    [self.dataManager updateMainViewModel:mainViewModel];
  }
}

- (void)restoreMainViewModels:(finishedCompletionHandler)completion {
  if (completion) {
    __weak typeof(self) weakSelf = self;
    [self.dataManager selectMainViewModels:^(NSMutableArray *mutableArrayResult) {
      __strong typeof(self) strongSelf = weakSelf;
      for (NSDictionary *rawMainViewModelDictionary in mutableArrayResult) {
        DPMainViewModel *mainViewModel = [[DPMainViewModel alloc] initWithSeparatedDictionary:rawMainViewModelDictionary];
        if (![strongSelf.mainViewModels containsObject:mainViewModel]) {
          [strongSelf.mainViewModels addObject:mainViewModel];
        }
      }
      completion(YES);
    }];
  }
}

- (void)persistMainViewModel {
  if (self.currentMainViewModel) {
    [self.dataManager persistMainViewModel:self.currentMainViewModel];
  }
}

- (void)resetCurrentThumbnail {
  DPPageViewModel *firstPageViewModel = [self.currentMainViewModel.pageViewModels firstObject];
  if (firstPageViewModel) {
    [self.currentMainViewModel setThumbnailName:firstPageViewModel.imageName];
  } else {
    [self.currentMainViewModel setThumbnailName:@""];
  }
}

- (void)addPageViewModel:(DPPageViewModel *)pageViewModel {
  if (![self.currentMainViewModel.pageViewModels containsObject:pageViewModel]) {
    [self.currentMainViewModel addPageViewModel:pageViewModel];
    [self.dataManager insertPageViewModel:pageViewModel
                      withMainViewModelID:self.currentMainViewModel.identifier];
    [self resetCurrentThumbnail];
  }
}

- (void)removePageViewModel:(DPPageViewModel *)pageViewModel {
  if ([self.currentMainViewModel.pageViewModels containsObject:pageViewModel]) {
    [self.currentMainViewModel removePageViewModel:pageViewModel];
    [self.dataManager deletePageViewModel:pageViewModel];
    NSString *imagePath = [self imagePathWithProjectTitle:self.currentMainViewModel.title
                                                imageName:pageViewModel.imageName];
    [self.dataManager removeFile:imagePath];
    [self resetCurrentThumbnail];
  }
}

- (void)updatePageViewModel:(DPPageViewModel *)pageViewModel
        withMainViewModelID:(NSString *)mainViewModelID  {
  if ([self.currentMainViewModel.pageViewModels containsObject:pageViewModel]) {
    [pageViewModel setUpdatedTime:[NSDate formattedDateNow]];
    [self.dataManager updatePageViewModel:pageViewModel
                      withMainViewModelID:mainViewModelID];
    [self resetCurrentThumbnail];
  }
}

- (void)restorePageViewModelsWithMainViewModelID:(NSString *)mainViewModelID
                                      completion:(finishedCompletionHandler)completion {
  if (completion) {
    __weak typeof(self) weakSelf = self;
    [self.dataManager selectPageViewModelsWithMainViewModelID:mainViewModelID
                                                   completion:^(NSMutableArray *mutableArrayResult) {
       __strong typeof(self) strongSelf = weakSelf;
       for (NSDictionary *rawPageViewModelDictionary in mutableArrayResult) {
         DPPageViewModel *pageViewModel = [[DPPageViewModel alloc] initWithSeparatedDictionary:rawPageViewModelDictionary];
         if (![strongSelf.currentMainViewModel.pageViewModels containsObject:pageViewModel]) {
           [strongSelf.currentMainViewModel.pageViewModels addObject:pageViewModel];
         }
       }
       completion(YES);
     }];
  }
}

- (void)addMaskViewModel:(DPMaskViewModel *)maskViewModel {
  if (![self.currentPageViewModel.maskViewModels containsObject:maskViewModel]) {
    [self.currentPageViewModel addMaskViewModel:maskViewModel];
    [self.dataManager insertMaskViewModel:maskViewModel
                      withPageViewModelID:self.currentPageViewModel.identifier];
  }
}

- (void)removeMaskViewModel:(DPMaskViewModel *)maskViewModel {
  if ([self.currentPageViewModel.maskViewModels containsObject:maskViewModel]) {
    [self.currentPageViewModel removeMaskViewModel:maskViewModel];
    [self.dataManager deleteMaskViewModel:maskViewModel];
  }
}

- (void)updateMaskViewModel:(DPMaskViewModel *)maskViewModel
        withPageViewModelID:(NSString *)pageViewModelID {
  if ([self.currentPageViewModel.maskViewModels containsObject:maskViewModel]) {
    [maskViewModel setUpdatedTime:[NSDate formattedDateNow]];
    [self.dataManager updateMaskViewModel:maskViewModel
                      withPageViewModelID:pageViewModelID];
  }
}

- (void)updateAllMaskViewModels {
  __weak typeof(self) weakSelf = self;
  [self.currentPageViewModel.maskViewModels
   enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     __strong typeof(self) strongSelf = weakSelf;
    DPMaskViewModel *maskViewModel = (DPMaskViewModel *)obj;
     [maskViewModel setUpdatedTime:[NSDate formattedDateNow]];
     [strongSelf updateMaskViewModel:maskViewModel
                 withPageViewModelID:strongSelf.currentPageViewModel.identifier];
  }];
}

- (void)restoreMaskViewModelsWithPageViewModelID:(NSString *)pageViewModelID
                                      completion:(finishedCompletionHandler)completion {
  if (completion) {
    __weak typeof(self) weakSelf = self;
    [self.dataManager selectMaskViewModelsWithPageViewModelID:pageViewModelID
                                                   completion:^(NSMutableArray *mutableArrayResult) {
       __strong typeof(self) strongSelf = weakSelf;
       for (NSDictionary *rawPageViewModelDictionary in mutableArrayResult) {
         DPMaskViewModel *maskViewModel = [[DPMaskViewModel alloc] initWithSeparatedDictionary:rawPageViewModelDictionary];
         if (![strongSelf.currentPageViewModel.maskViewModels containsObject:maskViewModel]) {
           [strongSelf.currentPageViewModel.maskViewModels addObject:maskViewModel];
         }
       }
       completion(YES);
     }];
  }
}

- (void)createJSONDataWithMainViewModel:(DPMainViewModel *)mainViewModel
                             completion:(finishedCompletionHandler)completion {
  [self.dataManager createJSONDataWithMainViewModel:mainViewModel
                                         completion:^(BOOL finished) {
    if (completion) {
      completion(YES);
    }
  }];
}

- (void)cleanLocalArchiveFiles {
  // TODO: DPFileManager new interface: remove files in directory with suffix:xxx
  // NSString *archivedFileDirectoryPath = [DPFileManager CachesDirectory];
}

- (void)createSharedArchive:(DPMainViewModel *)mainViewModel
                 completion:(finishedCompletionHandler)completion {
  [self createReferenceTreeWithMainViewModel:mainViewModel
                                  completion:^(BOOL finished) {
    if (finished) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createJSONDataWithMainViewModel:mainViewModel
                                   completion:^(BOOL finished) {
                                       if (finished && completion) {
                                         completion(YES);
                                       }
                                   }];
      });
    }
  }];
}

#pragma mark - Network
- (void)requestAphorismsCompletion:(resultCompletionHandler)completion {
  [self.dataManager requestAphorismsCompletion:^(id result, NSError *error) {
    completion(result, error);
  }];
}

- (void)loginWithUserName:(NSString *)name
              andPassword:(NSString *)password
               completion:(resultCompletionHandler)completion {
  [self.dataManager loginWithUserName:name
                          andPassword:password
                           completion:^(id result, NSError *error) {
    completion(result, error);
  }];
}

@end
