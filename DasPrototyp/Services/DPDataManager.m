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

@interface DPDataManager()

@property (strong, nonatomic) DPDBRoot *dbRoot;
@property (strong, nonatomic, readwrite) DPNetworkService *networkService;

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

#pragma mark - User Default

#pragma mark - Plist

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

// MARK: For reference tree
- (void)selectMaskViewModelsWithPageViewModelID_dispatchSync:(NSString *)pageViewModelID
                                                  completion:(mutableArrayCompletionHandler)completion {
//  dispatch_sync(_dataQueue, ^{
    if (pageViewModelID && completion) {
      [self.dbRoot selectMaskViewModelsWithPageViewModelID:pageViewModelID
                                                completion:completion];
    }

//  });
}

// persist
- (void)persistMainViewModel:(DPMainViewModel *)mainViewModel {
  dispatch_async(_dataQueue, ^{
    if (mainViewModel) {
      [self.dbRoot persistMainViewModel:mainViewModel];
    }
  });
}

@end
