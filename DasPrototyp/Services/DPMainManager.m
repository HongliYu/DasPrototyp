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

- (NSString *)tempUnzipPath {
  NSString *path = [NSString stringWithFormat:@"%@/\%@",
                    NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0],
                    [NSUUID UUID].UUIDString];
  NSURL *url = [NSURL fileURLWithPath:path];
  NSError *error = nil;
  [[NSFileManager defaultManager] createDirectoryAtURL:url
                           withIntermediateDirectories:YES
                                            attributes:nil
                                                 error:&error];
  if (error) {
    return nil;
  }
  return url.path;
}

- (void)checkIfNeedDemo {
  if (![USER_DEFAULT objectForKey:@"NeedDemo"]) {
    NSString *resourcePath = nil;
    NSString *archiveName = nil;
    if (DEVICE_IS_IPHONE4s) {
      archiveName = @"iPhone4sDemo";
      resourcePath = [[NSBundle mainBundle] pathForResource:archiveName
                                                     ofType:@"dparchive"];
    }
    if (DEVICE_IS_IPHONE5) {
      archiveName = @"iPhone5Demo";
      resourcePath = [[NSBundle mainBundle] pathForResource:archiveName
                                                     ofType:@"dparchive"];
    }
    if (DEVICE_IS_IPHONE6) {
      archiveName = @"iPhone6Demo";
      resourcePath = [[NSBundle mainBundle] pathForResource:archiveName
                                                     ofType:@"dparchive"];
    }
    if (DEVICE_IS_IPHONE6_PLUS) {
      archiveName = @"iPhone6PlusDemo";
      resourcePath = [[NSBundle mainBundle] pathForResource:archiveName
                                                     ofType:@"dparchive"];
    }
    NSString *demoDirectoryPath = [[DPFileManager DocumentDirectory] stringByAppendingPathComponent:@"Demos"];
    [DPFileManager createDirectory:demoDirectoryPath];
    NSString *demoFilePath = [NSString stringWithFormat:@"%@/%@.dparchive", demoDirectoryPath, archiveName];
    [DPFileManager copyFile:resourcePath to:demoFilePath];
    [self checkNewProjectWithDirectory:@"Demos"];
    [USER_DEFAULT setObject:@"OK" forKey:@"NeedDemo"];
  }
}

- (void)checkNewProjectWithDirectory:(NSString *)directory {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSError *error = nil;
    NSString *mailAttachmentDirectoryPath = [[DPFileManager DocumentDirectory] stringByAppendingPathComponent:directory];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mailAttachmentDirectoryPath
                                                                                   error:&error];
    if (error) {
      DLog(@"checkNewProject error");
      return;
    }
    for (NSString *path in contentOfFolder) {
      if ([path isEndsWith:@".dparchive"]) {
        NSString *fullPath = [mailAttachmentDirectoryPath stringByAppendingPathComponent:path];
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath
                                                 isDirectory:&isDir]) {
          if (!isDir) {
            NSString *zipFileFullPath = [[DPFileManager DocumentDirectory]
                                         stringByAppendingPathComponent:
                                         [path replaceCharcter:@".dparchive" withCharcter:@".zip"]];
            [DPFileManager renameFile:fullPath with:zipFileFullPath];
            NSString *projectTitle = [path removeSubString:@".dparchive"];
            NSString *unzipFileFullPath = [[[DPFileManager DocumentDirectory]
                                            stringByAppendingPathComponent:@"Projects"]
                                           stringByAppendingPathComponent:projectTitle];
            BOOL success = [SSZipArchive unzipFileAtPath:zipFileFullPath
                                           toDestination:unzipFileFullPath];
            if (!success) {
              return;
            }
            [DPFileManager removeFile:zipFileFullPath];
            NSString *JSONFilePath = [NSString stringWithFormat:@"%@/%@.json",unzipFileFullPath, projectTitle];
            
            NSData *JSONData = [NSData dataWithContentsOfFile:JSONFilePath];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                       options:kNilOptions
                                                                         error:&error];
            if (error) {
              DLog(@"parse JSON data error");
              return;
            }
            NSArray *array = [dictionary objectForKey:@"projects"];
            NSDictionary *mainViewModelRawDictionary = [array firstObject];
            DPMainViewModel *mainViewModel = [[DPMainViewModel alloc] initWithDictionary:mainViewModelRawDictionary];
            [self addMainViewModel:mainViewModel];
            
            // persist data to database
            [mainViewModel.pageViewModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
              DPPageViewModel *pageViewModel = (DPPageViewModel *)obj;
              [self addPageViewModel:pageViewModel];
              [self.dataManager insertPageViewModel:pageViewModel
                                withMainViewModelID:mainViewModel.identifier];
              [pageViewModel.maskViewModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DPMaskViewModel *maskViewModel = (DPMaskViewModel *)obj;
                [self.dataManager insertMaskViewModel:maskViewModel
                                  withPageViewModelID:pageViewModel.identifier];
              }];
            }];
            
            if (self.addProjectFromMailCallBack) {
              self.addProjectFromMailCallBack();
            }
          }
        }
      }
    }
  });
}

- (void)createReferenceTreeWithMainViewModel:(DPMainViewModel *)mainViewModel
                                  complition:(finishedComplitionHandler)complition {
  if (!mainViewModel.pageViewModels) {
    [self.dataManager selectPageViewModelsWithMainViewModelID:mainViewModel.identifier
                                                   complition:^(NSMutableArray *mutableArrayResult) {
                                                     for (NSDictionary *rawPageViewModelDictionary in mutableArrayResult) {
                                                       DPPageViewModel *pageViewModel = [[DPPageViewModel alloc] initWithSeparatedDictionary:rawPageViewModelDictionary];
                                                       if (![mainViewModel.pageViewModels containsObject:pageViewModel]) {
                                                         [mainViewModel.pageViewModels addObject:pageViewModel];
                                                       }
                                                     }
                                                     if (mainViewModel.pageViewModels) {
                                                       [self createReferenceTreeWithPageViewModels:mainViewModel.pageViewModels
                                                                                        complition:^(BOOL finished) {
                                                                                          if (finished && complition) {
                                                                                            complition(YES);
                                                                                          }
                                                                                        }];
                                                     }
                                                   }];
  } else {
    [self createReferenceTreeWithPageViewModels:mainViewModel.pageViewModels
                                     complition:^(BOOL finished) {
                                       if (finished && complition) {
                                         complition(YES);
                                       }
                                     }];
  }
}

- (void)createReferenceTreeWithPageViewModels:(NSMutableArray *)pageViewModels
                                   complition:(finishedComplitionHandler)complition {
  dispatch_queue_t concurrentQueue = dispatch_queue_create("com.hongliyu.dasprototyp.reference_tree", DISPATCH_QUEUE_CONCURRENT);
  dispatch_queue_t notifyQueue = dispatch_get_main_queue();
  dispatch_group_t dispatchGroup = dispatch_group_create();
  for (DPPageViewModel *pageViewModel in pageViewModels) {
    dispatch_group_async(dispatchGroup, concurrentQueue, ^{
      [self.dataManager selectMaskViewModelsWithPageViewModelID:pageViewModel.identifier
                                                     complition:^(NSMutableArray *mutableArrayResult) {
                                                       for (NSDictionary *rawMaskViewModelDictionary in mutableArrayResult) {
                                                         DPMaskViewModel *maskViewModel = [[DPMaskViewModel alloc] initWithSeparatedDictionary:rawMaskViewModelDictionary];
                                                         if (![pageViewModel.maskViewModels containsObject:maskViewModel]) {
                                                           [pageViewModel.maskViewModels addObject:maskViewModel];
                                                         }
                                                       }
                                                     }];
    });
  }
  dispatch_group_notify(dispatchGroup, notifyQueue, ^{
    if (complition) {
      complition(YES);
    }
  });
}

// play mode
- (void)enterPlayMode:(finishedComplitionHandler)complition {
  NSMutableArray *pageViewModels = [self.currentMainViewModel.pageViewModels mutableCopy];
  [self createReferenceTreeWithPageViewModels:pageViewModels
                                   complition:^(BOOL finished) {
                                     if (finished && complition) {
                                       complition(YES);
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
    // TODO: config hud when first use
    [SVProgressHUD setMinimumDismissTimeInterval:1.f];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient]; // mask will block main thread
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
                   complition:(void (^)(UIImage *image))complition {
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
    if (complition) {
      complition(image);
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


- (void)restoreMainViewModels:(finishedComplitionHandler)complition {
  if (complition) {
    __weak typeof(self) weakSelf = self;
    [self.dataManager selectMainViewModels:^(NSMutableArray *mutableArrayResult) {
      __strong typeof(self) strongSelf = weakSelf;
      for (NSDictionary *rawMainViewModelDictionary in mutableArrayResult) {
        DPMainViewModel *mainViewModel = [[DPMainViewModel alloc] initWithSeparatedDictionary:rawMainViewModelDictionary];
        if (![strongSelf.mainViewModels containsObject:mainViewModel]) {
          [strongSelf.mainViewModels addObject:mainViewModel];
        }
      }
      complition(YES);
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
                                      complition:(finishedComplitionHandler)complition {
  if (complition) {
    __weak typeof(self) weakSelf = self;
    [self.dataManager selectPageViewModelsWithMainViewModelID:mainViewModelID
                                                   complition:^(NSMutableArray *mutableArrayResult) {
                                                     __strong typeof(self) strongSelf = weakSelf;
                                                     for (NSDictionary *rawPageViewModelDictionary in mutableArrayResult) {
                                                       DPPageViewModel *pageViewModel = [[DPPageViewModel alloc] initWithSeparatedDictionary:rawPageViewModelDictionary];
                                                       if (![strongSelf.currentMainViewModel.pageViewModels containsObject:pageViewModel]) {
                                                         [strongSelf.currentMainViewModel.pageViewModels addObject:pageViewModel];
                                                       }
                                                     }
                                                     complition(YES);
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
                                      complition:(finishedComplitionHandler)complition {
  if (complition) {
    __weak typeof(self) weakSelf = self;
    [self.dataManager selectMaskViewModelsWithPageViewModelID:pageViewModelID
                                                   complition:^(NSMutableArray *mutableArrayResult) {
                                                     __strong typeof(self) strongSelf = weakSelf;
                                                     for (NSDictionary *rawPageViewModelDictionary in mutableArrayResult) {
                                                       DPMaskViewModel *maskViewModel = [[DPMaskViewModel alloc] initWithSeparatedDictionary:rawPageViewModelDictionary];
                                                       if (![strongSelf.currentPageViewModel.maskViewModels containsObject:maskViewModel]) {
                                                         [strongSelf.currentPageViewModel.maskViewModels addObject:maskViewModel];
                                                       }
                                                     }
                                                     complition(YES);
                                                   }];
  }
}

- (void)createJSONDataWithMainViewModel:(DPMainViewModel *)mainViewModel
                             complition:(finishedComplitionHandler)complition {
  NSMutableArray *pageViewModelsArray = [[NSMutableArray alloc] init];
  [mainViewModel.pageViewModels
   enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     if ([obj isKindOfClass:[DPPageViewModel class]]) {
       NSMutableArray *maskViewModelsArray = [[NSMutableArray alloc] init];
       DPPageViewModel *pageViewModel = (DPPageViewModel *)obj;
       [pageViewModel.maskViewModels
        enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          if ([obj isKindOfClass:[DPMaskViewModel class]]) {
            DPMaskViewModel *maskViewModel = (DPMaskViewModel *)obj;
            NSDictionary *maskViewModelsDictionary = @{
                                                       @"id": maskViewModel.identifier,
                                                       @"start_point_x": @(maskViewModel.startPoint.x),
                                                       @"start_point_y": @(maskViewModel.startPoint.y),
                                                       @"end_point_x": @(maskViewModel.endPoint.x),
                                                       @"end_point_y": @(maskViewModel.endPoint.y),
                                                       @"created_time": maskViewModel.createdTime,
                                                       @"updated_time": maskViewModel.updatedTime,
                                                       @"selected": @(maskViewModel.selected ? 1 : 0),
                                                       @"event_signal": @(maskViewModel.eventSignal),
                                                       @"switch_mode": @(maskViewModel.switchMode),
                                                       @"switch_direction": @(maskViewModel.switchDirection),
                                                       @"link_index": @(maskViewModel.linkIndex),
                                                       @"animation_delaytime": @(maskViewModel.animationDelayTime)
                                                       };
            [maskViewModelsArray addObject:maskViewModelsDictionary];
          }
        }];
       NSDictionary *pageViewModelsDictionary = @{ @"id": pageViewModel.identifier,
                                                   @"image_name": pageViewModel.imageName,
                                                   @"created_time": pageViewModel.createdTime,
                                                   @"updated_time": pageViewModel.updatedTime,
                                                   @"mask_viewmodels": maskViewModelsArray
                                                   };
       [pageViewModelsArray addObject:pageViewModelsDictionary];
     }
   }];
  NSDictionary *mainViewModelsDictionary = @{ @"projects" :
                                                @[
                                                  @{ @"id": mainViewModel.identifier,
                                                     @"title": mainViewModel.title,
                                                     @"owner": mainViewModel.owner,
                                                     @"thumbnail_name": mainViewModel.thumbnailName,
                                                     @"comment": mainViewModel.comment,
                                                     @"created_time": mainViewModel.createdTime,
                                                     @"updated_time": mainViewModel.updatedTime,
                                                     @"expanded": @(mainViewModel.expanded ? 1 : 0),
                                                     @"page_viewmodels": pageViewModelsArray
                                                     }
                                                  ]
                                              };
  // TODO: encapsulate method of generate JSON Data to viewmodel
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mainViewModelsDictionary
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  if (!jsonData) {
    DLog(@"createJSONDataWithMainViewModel error: %@", error);
  } else {
    NSString *JSONFilePath = [NSString stringWithFormat:@"%@/%@/%@/%@.json",
                              [DPFileManager DocumentDirectory], @"Projects",
                              mainViewModel.title, mainViewModel.title];
    [jsonData writeToFile:JSONFilePath atomically:YES];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData
//                                                 encoding:NSUTF8StringEncoding];
//    DLog(@"jsonString :%@", jsonString);
    
    // archive zip file with pics
    NSString *projectDirectoryPath = [NSString stringWithFormat:@"%@/%@/%@/",
                                    [DPFileManager DocumentDirectory],
                                    @"Projects", mainViewModel.title];
    NSString *zipArchivePath = [NSString stringWithFormat:@"%@/%@.zip",
                                [DPFileManager CachesDirectory], mainViewModel.title ];
    if ([SSZipArchive createZipFileAtPath:zipArchivePath
                  withContentsOfDirectory:projectDirectoryPath]) {
      NSString *renamedZipFilePath = [zipArchivePath replaceCharcter:@".zip"
                                                        withCharcter:@".dparchive"];
      [DPFileManager renameFile:zipArchivePath
                           with:renamedZipFilePath];
      if (complition) {
        complition(YES);
      }
    } else {
      DLog(@"zipArchive error");
    }
  }
}

- (void)cleanLocalArchiveFiles {
  // TODO: DPFileManager new interface: remove files in directory with suffix:xxx
  //  NSString *archivedFileDirectoryPath = [DPFileManager CachesDirectory];
}

- (void)createSharedArchive:(DPMainViewModel *)mainViewModel
                 complition:(finishedComplitionHandler)complition {
  [self createReferenceTreeWithMainViewModel:mainViewModel
                                  complition:^(BOOL finished) {
                                    if (finished) {
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        [self createJSONDataWithMainViewModel:mainViewModel
                                                                   complition:^(BOOL finished) {
                                                                       if (finished && complition) {
                                                                         complition(YES);
                                                                       }
                                                                   }];
                                      });
                                    }
  }];
}

@end
