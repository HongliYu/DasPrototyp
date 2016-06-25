//
//  DPDBRoot.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/3.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPDBRoot.h"
#import "DPMainViewModel.h"
#import "DPPageViewModel.h"
#import "DPMaskViewModel.h"
#import "FMDB.h"

NSString *const kDPMainViewModelTableName = @"DPMAINVIEWMODEL";
NSString *const kDPPageViewModelTableName = @"DPPAGEVIEWMODEL";
NSString *const kDPMaskViewModelTableName = @"DPMASKVIEWMODEL";

@interface DPDBRoot()

@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation DPDBRoot

#pragma mark - Life Cycle
- (instancetype)init {
  self = [super init];
  if(self) {
    _databasePath = [NSString stringWithFormat:@"%@/%@",
                     [DPFileManager DocumentDirectory], @"DPDataBase.sqlite3"];
    _database = [FMDatabase databaseWithPath:_databasePath];
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
    if (![_database open]) {
      [_database close];
      DLog(@"DB Open Error");
    }
    [self configDataBase];
  }
  return self;
}

- (void)dealloc {
  [_database close];
}

#pragma mark - Config
- (void)configDataBase {
  [self createTablesIfNeeded];
}

- (void)createTablesIfNeeded {
  if ([self checkTableIfExists:kDPMainViewModelTableName]) {
    DLog(@"DPMAINVIEWMODEL table exists");
  } else {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
      NSString *sql = [NSString stringWithFormat: @"create table %@ (id VARCHAR(255) PRIMARY KEY, title VARCHAR(255), owner VARCHAR(255), thumbnail_name TEXT, comment TEXT, created_time VARCHAR(255), updated_time VARCHAR(255), expanded INTEGER)", kDPMainViewModelTableName];
      if ([db executeStatements:sql]) {
        DLog(@"DPMAINVIEWMODEL table created");
      } else {
        DLog(@"cteate table DPMAINVIEWMODEL Error");
      }
    }];
  }
  if ([self checkTableIfExists:kDPPageViewModelTableName]) {
    DLog(@"DPPAGEVIEWMODEL table exists");
  } else {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
      NSString *sql = [NSString stringWithFormat: @"create table %@ (id VARCHAR(255) PRIMARY KEY, image_name TEXT, created_time VARCHAR(255), updated_time VARCHAR(255), main_view_model_id VARCHAR(255), FOREIGN KEY(main_view_model_id) REFERENCES DPMAINVIEWMODEL(id) ON DELETE CASCADE)", kDPPageViewModelTableName];
      if ([db executeStatements:sql]) {
        DLog(@"DPPAGEVIEWMODEL table created");
      } else {
        DLog(@"cteate table DPPAGEVIEWMODEL Error");
      }
    }];
  }
  if ([self checkTableIfExists:kDPMaskViewModelTableName]) {
    DLog(@"DPMainViewModel table exists");
  } else {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
      NSString *sql = [NSString stringWithFormat: @"create table %@ (id VARCHAR(255) PRIMARY KEY, start_point_x REAL, start_point_y REAL, end_point_x REAL, end_point_y REAL, selected INTEGER, event_signal INTEGER, switch_mode INTEGER, switch_direction INTEGER, link_index INTEGER, animation_delaytime REAL, created_time VARCHAR(255), updated_time VARCHAR(255), page_view_model_id VARCHAR(255), FOREIGN KEY(page_view_model_id) REFERENCES DPPAGEVIEWMODEL(id) ON DELETE CASCADE)", kDPMaskViewModelTableName];
      if ([db executeStatements:sql]) {
        DLog(@"DPMainViewModel table created");
      } else {
        DLog(@"cteate table Error");
      }
    }];
  }
}

#pragma mark - Insert
// insert
- (void)insertMainViewModel:(DPMainViewModel *)mainViewModel {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"INSERT INTO %@ VALUES (?,?,?,?,?,?,?,?)", kDPMainViewModelTableName];
    BOOL succeed = [db executeUpdate:sql, mainViewModel.identifier,
                    mainViewModel.title, mainViewModel.owner, mainViewModel.thumbnailName,
                    mainViewModel.comment, mainViewModel.createdTime, mainViewModel.updatedTime,
                    @(mainViewModel.expanded? 1 : 0)
                    ];
    if (!succeed) {
      DLog(@"MainViewModel insert faild");
    }
  }];
}

- (void)insertPageViewModel:(DPPageViewModel *)pageViewModel
        withMainViewModelID:(NSString *)mainViewModelID {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"INSERT INTO %@ (id, image_name, created_time, updated_time, main_view_model_id) VALUES (?,?,?,?,?)", kDPPageViewModelTableName];
    BOOL succeed = [db executeUpdate:sql, pageViewModel.identifier,
                    pageViewModel.imageName, pageViewModel.createdTime, pageViewModel.updatedTime,
                    mainViewModelID];
    if (!succeed) {
      DLog(@"PageViewModel insert faild");
    }
  }];
}

- (void)insertMaskViewModel:(DPMaskViewModel *)maskViewModel
        withPageViewModelID:(NSString *)pageViewModelID {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"INSERT INTO %@ (id, start_point_x, start_point_y, end_point_x, end_point_y, selected, event_signal, switch_mode, switch_direction, link_index, animation_delaytime, created_time, updated_time, page_view_model_id) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)", kDPMaskViewModelTableName];
    BOOL succeed = [db executeUpdate:sql, maskViewModel.identifier,
                    @(maskViewModel.startPoint.x), @(maskViewModel.startPoint.y),
                    @(maskViewModel.endPoint.x), @(maskViewModel.endPoint.y),
                    @(maskViewModel.selected ? 1:0), @(maskViewModel.eventSignal),
                    @(maskViewModel.switchMode), @(maskViewModel.switchDirection),
                    @(maskViewModel.linkIndex), @(maskViewModel.animationDelayTime),
                    maskViewModel.createdTime, maskViewModel.updatedTime, pageViewModelID];
    if (!succeed) {
      DLog(@"MaskViewModel insert faild");
    }
  }];
}

#pragma mark - Delete
- (void)deleteMainViewModel:(DPMainViewModel *)mainViewModel {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"DELETE FROM %@ WHERE id=?", kDPMainViewModelTableName];
    BOOL succeed = [db executeUpdate:sql, mainViewModel.identifier];
    if (!succeed) {
      DLog(@"removeMainViewModel faild");
    }
  }];
}

- (void)deletePageViewModel:(DPPageViewModel *)pageViewModel {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"DELETE FROM %@ WHERE id=?",
                     kDPPageViewModelTableName];
    BOOL succeed = [db executeUpdate:sql, pageViewModel.identifier];
    if (!succeed) {
      DLog(@"removePageViewModel faild");
    }
  }];
}

- (void)deleteMaskViewModel:(DPMaskViewModel *)maskViewModel {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"DELETE FROM %@ WHERE id=?", kDPMaskViewModelTableName];
    BOOL succeed = [db executeUpdate:sql, maskViewModel.identifier];
    if (!succeed) {
      DLog(@"removePageViewModel faild");
    }
  }];
}

#pragma mark - Update
- (void)updateMainViewModel:(DPMainViewModel *)mainViewModel {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"UPDATE %@ SET title=?, owner=?, thumbnail_name=?, comment=?, created_time=?, updated_time=?, expanded=? WHERE id=?", kDPMainViewModelTableName];
    BOOL succeed = [db executeUpdate:sql, mainViewModel.title, mainViewModel.owner,
                    mainViewModel.thumbnailName, mainViewModel.comment, mainViewModel.createdTime,
                    mainViewModel.updatedTime, @(mainViewModel.expanded? 1 : 0), mainViewModel.identifier
                    ];
    if (!succeed) {
      DLog(@"MainViewModel update faild");
    }
  }];
}

- (void)updatePageViewModel:(DPPageViewModel *)pageViewModel
        withMainViewModelID:(NSString *)mainViewModelID {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"UPDATE %@ SET image_name=?, created_time=?, updated_time=?, main_view_model_id=? WHERE id=?", kDPPageViewModelTableName];
    BOOL succeed = [db executeUpdate:sql, pageViewModel.imageName,
                    pageViewModel.createdTime, pageViewModel.updatedTime,
                    mainViewModelID, pageViewModel.identifier];
    if (!succeed) {
      DLog(@"PageViewModel update faild");
    }
  }];
}

- (void)updateMaskViewModel:(DPMaskViewModel *)maskViewModel
        withPageViewModelID:(NSString *)pageViewModelID {
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = [NSString stringWithFormat: @"UPDATE %@ SET start_point_x=?, start_point_y=?, end_point_x=?, end_point_y=?, selected=?, event_signal=?, switch_mode=?, switch_direction=?, link_index=?, animation_delaytime=?, created_time=?, updated_time=?, page_view_model_id=? WHERE id=?", kDPMaskViewModelTableName];
    BOOL succeed = [db executeUpdate:sql,
                    @(maskViewModel.startPoint.x), @(maskViewModel.startPoint.y),
                    @(maskViewModel.endPoint.x), @(maskViewModel.endPoint.y),
                    @(maskViewModel.selected ? 1:0), @(maskViewModel.eventSignal),
                    @(maskViewModel.switchMode), @(maskViewModel.switchDirection),
                    @(maskViewModel.linkIndex), @(maskViewModel.animationDelayTime),
                    maskViewModel.createdTime, maskViewModel.updatedTime, pageViewModelID,
                    maskViewModel.identifier];
    if (!succeed) {
      DLog(@"MaskViewModel update faild");
    }
  }];
}

#pragma mark - Select
- (void)selectMainViewModels:(mutableArrayCompletionHandler)completion {
  NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", kDPMainViewModelTableName];
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSMutableArray *rawMainViewModels = [[NSMutableArray alloc] init];
    FMResultSet *resaultSet = [db executeQuery:sql];
    while ([resaultSet next]) {
      NSDictionary *rawMainViewModelDictionary = @{@"id" : [resaultSet stringForColumn:@"id"],
                                                   @"title" : [resaultSet stringForColumn:@"title"],
                                                   @"owner" : [resaultSet stringForColumn:@"owner"],
                                                   @"thumbnail_name" : [resaultSet stringForColumn:@"thumbnail_name"],
                                                   @"comment" : [resaultSet stringForColumn:@"comment"],
                                                   @"created_time" : [resaultSet stringForColumn:@"created_time"],
                                                   @"updated_time" : [resaultSet stringForColumn:@"updated_time"]};
      [rawMainViewModels addObject:rawMainViewModelDictionary];
    }
    [resaultSet close];
    if (completion) {
      completion(rawMainViewModels);
    }
  }];
}

- (void)selectPageViewModelsWithMainViewModelID:(NSString *)mainViewModelID
                                     completion:(mutableArrayCompletionHandler)completion {
  NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE main_view_model_id=?", kDPPageViewModelTableName];
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSMutableArray *rawPageViewModels = [[NSMutableArray alloc] init];
    FMResultSet *resaultSet = [db executeQuery:sql, mainViewModelID];
    while ([resaultSet next]) {
      NSDictionary *rawMainViewModelDictionary = @{@"id" : [resaultSet stringForColumn:@"id"],
                                                   @"image_name" : [resaultSet stringForColumn:@"image_name"],
                                                   @"created_time" : [resaultSet stringForColumn:@"created_time"],
                                                   @"updated_time" : [resaultSet stringForColumn:@"updated_time"]};
      [rawPageViewModels addObject:rawMainViewModelDictionary];
    }
    [resaultSet close];
    if (completion) {
      completion(rawPageViewModels);
    }
  }];
}

- (void)selectMaskViewModelsWithPageViewModelID:(NSString *)pageViewModelID
                                     completion:(mutableArrayCompletionHandler)completion {
  NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE page_view_model_id=?", kDPMaskViewModelTableName];
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSMutableArray *rawMaskViewModels = [[NSMutableArray alloc] init];
    FMResultSet *resaultSet = [db executeQuery:sql, pageViewModelID];
    while ([resaultSet next]) {
      NSDictionary *rawMainViewModelDictionary = @{@"id" : [resaultSet stringForColumn:@"id"],
                                                   @"start_point_x" : [resaultSet stringForColumn:@"start_point_x"],
                                                   @"start_point_y" : [resaultSet stringForColumn:@"start_point_y"],
                                                   @"end_point_x" : [resaultSet stringForColumn:@"end_point_x"],
                                                   @"end_point_y" : [resaultSet stringForColumn:@"end_point_y"],
                                                   @"selected" : [resaultSet stringForColumn:@"selected"],
                                                   @"event_signal" : [resaultSet stringForColumn:@"event_signal"],
                                                   @"switch_mode" : [resaultSet stringForColumn:@"switch_mode"],
                                                   @"switch_direction" : [resaultSet stringForColumn:@"switch_direction"],
                                                   @"link_index" : [resaultSet stringForColumn:@"link_index"],
                                                   @"animation_delaytime" : [resaultSet stringForColumn:@"animation_delaytime"],
                                                   @"created_time" : [resaultSet stringForColumn:@"created_time"],
                                                   @"updated_time" : [resaultSet stringForColumn:@"updated_time"]};
      [rawMaskViewModels addObject:rawMainViewModelDictionary];
    }
    [resaultSet close];
    if (completion) {
      completion(rawMaskViewModels);
    }
  }];
}

#pragma mark - Persist
- (void)persistMainViewModel:(DPMainViewModel *)mainViewModel {
  BOOL __block exist = NO;
  [self.databaseQueue inDatabase:^(FMDatabase *db) { // check if existed
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id=?", kDPMainViewModelTableName];
    FMResultSet *resaultSet = [db executeQuery:sql, mainViewModel.identifier];
    while ([resaultSet next]) {
      exist = YES;
      break;
    }
    [resaultSet close];
  }];
  if (exist) {
    [self updateMainViewModel:mainViewModel];
  } else {
    [self insertMainViewModel:mainViewModel];
  }
}

- (void)persistPageViewModel:(DPPageViewModel *)pageViewModel
         withMainViewModelID:(NSString *)mainViewModelID {
  BOOL __block exist = NO;
  [self.databaseQueue inDatabase:^(FMDatabase *db) { // check if existed
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id=?", kDPPageViewModelTableName];
    FMResultSet *resaultSet = [db executeQuery:sql, pageViewModel.identifier];
    while ([resaultSet next]) {
      exist = YES;
      break;
    }
    [resaultSet close];
  }];
  if (exist) {
    [self updatePageViewModel:pageViewModel
          withMainViewModelID:mainViewModelID];
  } else {
    [self insertPageViewModel:pageViewModel
          withMainViewModelID:mainViewModelID];
  }
}

- (void)persistMaskViewModel:(DPMaskViewModel *)maskViewModel
         withPageViewModelID:(NSString *)pageViewModelID {
  BOOL __block exist = NO;
  [self.databaseQueue inDatabase:^(FMDatabase *db) { // check if existed
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id=?", kDPMaskViewModelTableName];
    FMResultSet *resaultSet = [db executeQuery:sql, maskViewModel.identifier];
    while ([resaultSet next]) {
      exist = YES;
      break;
    }
    [resaultSet close];
  }];
  if (exist) {
    [self updateMaskViewModel:maskViewModel
          withPageViewModelID:pageViewModelID];
  } else {
    [self insertMaskViewModel:maskViewModel
          withPageViewModelID:pageViewModelID];
  }
}

#pragma mark - Common
- (BOOL)checkTableIfExists:(NSString *)tableName {
  NSInteger __block count = 0;
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sql = @"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?";
    FMResultSet *resultSet = [db executeQuery:sql, tableName];
    while ([resultSet next]) {
      count = [resultSet intForColumn:@"count"];
    }
    [resultSet close];
  }];
  return (count > 0);
}

- (NSInteger)tableItemsCount:(NSString *)tableName {
  NSInteger __block count = 0;
  [self.databaseQueue inDatabase:^(FMDatabase *db) {
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *resultSet = [self.database executeQuery:sqlstr];
    while ([resultSet next]) {
      count = [resultSet intForColumn:@"count"];
    }
    [resultSet close];
  }];
  return count;
}

// TODO: common db operation
- (BOOL)createTable:(NSString *)tableName
      withArguments:(NSString *)arguments {
  NSString *sqlstr = [NSString stringWithFormat:@"CREATE TABLE %@ (%@)", tableName, arguments];
  return [self.database executeUpdate:sqlstr];
}

- (BOOL)dropTable:(NSString *)tableName {
  NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
  return [self.database executeUpdate:sqlstr];
}

- (BOOL)deleteTable:(NSString *)tableName {
  NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
  return [self.database executeUpdate:sqlstr];
}

@end
