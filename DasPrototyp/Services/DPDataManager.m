//
//  DPDataManager.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPDataManager.h"
#import "DPDBRoot.h"
#import "DPNetworkService.h"
#import "SSZipArchive.h"
#import "DPMainViewModel.h"
#import "DPPageViewModel.h"
#import "DPMaskViewModel.h"

@interface DPDataManager()

@property (strong, nonatomic) DPDBRoot *dbRoot;
@property (strong, nonatomic) DPNetworkService *networkService;
@property (strong, nonatomic) dispatch_queue_t dataQueue;

@end

@implementation DPDataManager

- (instancetype)init {
  self = [super init];
  if (self) {
    _dbRoot = [[DPDBRoot alloc] init];
    _networkService = [[DPNetworkService alloc] init];
    _dataQueue = dispatch_queue_create("com.hongliyu.dasprototyp.dataservice", DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}

#pragma mark - Network
- (void)requestAphorismsCompletion:(resultCompletionHandler)completion {
  dispatch_async(_dataQueue, ^{
    if (completion) {
      [self.networkService requestAphorismsCompletion:completion];
    }
  });
}

- (void)loginWithUserName:(NSString *)name
              andPassword:(NSString *)password
               completion:(resultCompletionHandler)completion {
  dispatch_async(_dataQueue, ^{
    if ([name isValid] && [password isValid] && completion) {
      [self.networkService loginWithUserModel:nil
                                   completion:completion];
    }
  });
}

#pragma mark - File
- (void)renameDirectory:(NSString *)originalDirectory
                   with:(NSString *)newDirectory {
  [DPFileManager renameDirectory:originalDirectory
                            with:newDirectory];
}

- (void)removeAll:(NSString *)path {
  [DPFileManager removeAll:path];
}

- (void)removeFile:(NSString *)filePath {
  [DPFileManager removeFile:filePath];
}

- (void)checkNewProjectWithDirectory:(NSString *)directory
                          completion:(resultCompletionHandler)completion {
  dispatch_async(_dataQueue, ^{
    NSError *error = nil;
    NSString *mailAttachmentDirectoryPath = [[DPFileManager DocumentDirectory]
                                             stringByAppendingPathComponent:directory];
    NSArray *contentOfFolder = [[NSFileManager defaultManager]
                                contentsOfDirectoryAtPath:mailAttachmentDirectoryPath
                                error:&error];
    if (error) {
      DLog(@"Check new project path error");
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
                                         [path replaceCharcter:@".dparchive"
                                                  withCharcter:@".zip"]];
            [DPFileManager renameFile:fullPath with:zipFileFullPath];
            NSString *projectTitle = [path removeSubString:@".dparchive"];
            NSString *unzipFileFullPath = [[[DPFileManager DocumentDirectory]
                                            stringByAppendingPathComponent:@"Projects"]
                                           stringByAppendingPathComponent:projectTitle];
            BOOL success = [SSZipArchive unzipFileAtPath:zipFileFullPath
                                           toDestination:unzipFileFullPath];
            if (!success) {
              DLog(@"Unzip error");
              return;
            }
            [DPFileManager removeFile:zipFileFullPath];
            NSString* JSONFilePath = [self findRightJSONFilePath:unzipFileFullPath];
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
            if (completion) {
              completion(mainViewModel, nil);
            }
          }
        }
      }
    }
  });
}

// MARK: JSON 文件解压缩以后，文件名中文乱码问题的临时解决方案
- (NSString *)findRightJSONFilePath: (NSString *)sourcePath {
  NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath
                                                                      error:NULL];
  NSMutableArray *files = [[NSMutableArray alloc] init];
  [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSString *filename = (NSString *)obj;
    NSString *extension = [[filename pathExtension] lowercaseString];
    if ([extension isEqualToString:@"json"]) {
      [files addObject:[sourcePath stringByAppendingPathComponent:filename]];
    }
  }];
  return [files firstObject];
}

- (void)createJSONDataWithMainViewModel:(DPMainViewModel *)mainViewModel
                             completion:(finishedCompletionHandler)completion {
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
       NSDictionary *pageViewModelsDictionary = @{
         @"id": pageViewModel.identifier,
         @"image_name": pageViewModel.imageName,
         @"created_time": pageViewModel.createdTime,
         @"updated_time": pageViewModel.updatedTime,
         @"mask_viewmodels": maskViewModelsArray
        };
       [pageViewModelsArray addObject:pageViewModelsDictionary];
     }
   }];
  NSDictionary *mainViewModelsDictionary = @{
   @"projects" :
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
      if (completion) {
        completion(YES);
      }
    } else {
      DLog(@"zipArchive error");
    }
  }
}

#pragma mark - Database
// insert
- (void)insertMainViewModel:(DPMainViewModel *)mainViewModel {
  if (mainViewModel) {
    [self.dbRoot insertMainViewModel:mainViewModel];
  }
}

- (void)insertPageViewModel:(DPPageViewModel *)pageViewModel
        withMainViewModelID:(NSString *)mainViewModelID {
  if (pageViewModel && mainViewModelID) {
    [self.dbRoot insertPageViewModel:pageViewModel
                 withMainViewModelID:mainViewModelID];
  }
}

- (void)insertMaskViewModel:(DPMaskViewModel *)maskViewModel
        withPageViewModelID:(NSString *)pageViewModelID {
  if (maskViewModel && pageViewModelID) {
    [self.dbRoot insertMaskViewModel:maskViewModel
                 withPageViewModelID:pageViewModelID];
  }
}

// delete
- (void)deleteMainViewModel:(DPMainViewModel *)mainViewModel {
  if (mainViewModel) {
    [self.dbRoot deleteMainViewModel:mainViewModel];
  }
}

- (void)deletePageViewModel:(DPPageViewModel *)pageViewModel {
  if (pageViewModel) {
    [self.dbRoot deletePageViewModel:pageViewModel];
  }
}

- (void)deleteMaskViewModel:(DPMaskViewModel *)maskViewModel {
  if (maskViewModel) {
    [self.dbRoot deleteMaskViewModel:maskViewModel];
  }
}

// update
- (void)updateMainViewModel:(DPMainViewModel *)mainViewModel {
  if (mainViewModel) {
    [self.dbRoot updateMainViewModel:mainViewModel];
  }
}

- (void)updatePageViewModel:(DPPageViewModel *)pageViewModel
        withMainViewModelID:(NSString *)mainViewModelID {
  if (pageViewModel && mainViewModelID) {
    [self.dbRoot updatePageViewModel:pageViewModel
                 withMainViewModelID:mainViewModelID];
  }
}

- (void)updateMaskViewModel:(DPMaskViewModel *)maskViewModel
        withPageViewModelID:(NSString *)pageViewModelID {
  if (maskViewModel && pageViewModelID) {
    [self.dbRoot updateMaskViewModel:maskViewModel
                 withPageViewModelID:pageViewModelID];
  }
}

// select
- (void)selectMainViewModels:(mutableArrayCompletionHandler)completion {
  dispatch_async(_dataQueue, ^{
    if (completion) {
      [self.dbRoot selectMainViewModels:completion];
    }
  });
}

- (void)selectPageViewModelsWithMainViewModelID:(NSString *)mainViewModelID
                                     completion:(mutableArrayCompletionHandler)completion {
  dispatch_async(_dataQueue, ^{
    if (mainViewModelID && completion) {
      [self.dbRoot selectPageViewModelsWithMainViewModelID:mainViewModelID
                                                completion:completion];
    }
  });
}

- (void)selectMaskViewModelsWithPageViewModelID:(NSString *)pageViewModelID
                                     completion:(mutableArrayCompletionHandler)completion {
  dispatch_async(_dataQueue, ^{
    if (pageViewModelID && completion) {
      [self.dbRoot selectMaskViewModelsWithPageViewModelID:pageViewModelID
                                                completion:completion];
    }
  });
}

- (void)selectMaskViewModelsWithPageViewModelID_dispatchSync:(NSString *)pageViewModelID
                                                  completion:(mutableArrayCompletionHandler)completion {
  if (pageViewModelID && completion) {
    [self.dbRoot selectMaskViewModelsWithPageViewModelID:pageViewModelID completion:completion];
  }
}

// persist
- (void)persistMainViewModel:(DPMainViewModel *)mainViewModel {
  dispatch_async(_dataQueue, ^{
    if (mainViewModel) {
      [self.dbRoot persistMainViewModel:mainViewModel];
    }
  });
}

#pragma mark - RAM
- (void)createReferenceTreeWithPageViewModels:(NSMutableArray *)pageViewModels
                                   completion:(finishedCompletionHandler)completion {
  dispatch_queue_t notifyQueue = dispatch_get_main_queue();
  dispatch_group_t dispatchGroup = dispatch_group_create();
  for (DPPageViewModel *pageViewModel in pageViewModels) {
    dispatch_group_async(dispatchGroup, _dataQueue, ^{
      [self selectMaskViewModelsWithPageViewModelID_dispatchSync:pageViewModel.identifier
                                                      completion:^(NSMutableArray *mutableArrayResult) {
        for (NSDictionary *rawMaskViewModelDictionary in mutableArrayResult) {
          DPMaskViewModel *maskViewModel = [[DPMaskViewModel alloc]
                                            initWithSeparatedDictionary:rawMaskViewModelDictionary];
          if (![pageViewModel.maskViewModels containsObject:maskViewModel]) {
            [pageViewModel.maskViewModels addObject:maskViewModel];
          }
        }
      }];
    });
  }
  dispatch_group_notify(dispatchGroup, notifyQueue, ^{
    if (completion) {
      completion(YES);
    }
  });
}

- (void)createReferenceTreeWithMainViewModel:(DPMainViewModel *)mainViewModel
                                  completion:(finishedCompletionHandler)completion {
  if (!mainViewModel.pageViewModels || ![mainViewModel.pageViewModels firstObject]) {
    [self selectPageViewModelsWithMainViewModelID:mainViewModel.identifier
                                       completion:^(NSMutableArray *mutableArrayResult) {
       for (NSDictionary *rawPageViewModelDictionary in mutableArrayResult) {
         DPPageViewModel *pageViewModel = [[DPPageViewModel alloc]
                                           initWithSeparatedDictionary:rawPageViewModelDictionary];
         if (![mainViewModel.pageViewModels containsObject:pageViewModel]) {
           [mainViewModel.pageViewModels addObject:pageViewModel];
         }
       }
       if (mainViewModel.pageViewModels) {
         [self createReferenceTreeWithPageViewModels:mainViewModel.pageViewModels
                                          completion:^(BOOL finished) {
            if (finished && completion) {
              completion(YES);
            }
          }];
       }
     }];
  } else {
    [self createReferenceTreeWithPageViewModels:mainViewModel.pageViewModels
                                     completion:^(BOOL finished) {
       if (finished && completion) {
         completion(YES);
       }
     }];
  }
}

@end
