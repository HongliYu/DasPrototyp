//
//  DPFileManager.m
//  DasPrototyp
//
//  Created by HongliYu on 16/4/28.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPFileManager.h"

@implementation DPFileManager

#pragma mark - File
+ (void)createFile:(NSString *)filePath {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:filePath]) {
    if (![fileManager createFileAtPath:filePath
                              contents:nil
                            attributes:nil]) {
      NSLog(@"Unable to create file: %@", [error localizedDescription]);
    }
  }
}

+ (void)removeFile:(NSString *)filePath {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager removeItemAtPath:filePath
                               error:&error]) {
    NSLog(@"removeFile error: %@", [error localizedDescription]);
  }
}

+ (void)renameFile:(NSString *)originalPath
              with:(NSString *)newPath {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager moveItemAtPath:originalPath
                            toPath:newPath
                             error:&error]) {
    NSLog(@"renameFile error: %@", [error localizedDescription]);
  }
}

+ (void)copyFile:(NSString *)originalPath
              to:(NSString *)destinationPath {
  NSError *error = nil;
  if (!originalPath) {
    return;
  }
  if (![[NSFileManager defaultManager] copyItemAtPath:originalPath
                                                toPath:destinationPath
                                                 error:&error]) {
    NSLog(@"copyFile error: %@", [error localizedDescription]);
  }
}

+ (NSDictionary *)fileAttributes:(NSString *)filePath {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSDictionary *fileAttributes = [fileManager attributesOfFileSystemForPath:filePath
                                                                      error:&error];
  if (fileAttributes && !error) {
    NSNumber *size = nil;
    NSString *owner = nil;
    NSString *createdTime = nil;
    NSDate *updatedTime = nil;
    if ((size = [fileAttributes objectForKey:NSFileSize])) {
      NSLog(@"File size: %qi\n", [size unsignedLongLongValue]);
    }
    if ((createdTime = [fileAttributes objectForKey:NSFileCreationDate])) {
      NSLog(@"File creationDate: %@\n", createdTime);
    }
    if ((owner = [fileAttributes objectForKey:NSFileOwnerAccountName])) {
      NSLog(@"Owner: %@\n", owner);
    }
    if ((updatedTime = [fileAttributes objectForKey:NSFileModificationDate])) {
      NSLog(@"Modification date: %@\n", updatedTime);
    }
  } else {
    NSLog(@"fileAttributes error: %@", [error localizedDescription]);
  }
  return fileAttributes;
}

+ (double)fileSize:(NSString *)filePath {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL dir = NO;
  BOOL exits = [fileManager fileExistsAtPath:filePath
                                 isDirectory:&dir];
  if (!exits) {
    return 0;
  }
  if (dir) {
    NSArray *subpaths = [fileManager subpathsAtPath:filePath];
    int totalSize = 0;
    for (NSString *subpath in subpaths) {
      NSString *fullsubpath = [filePath stringByAppendingPathComponent:subpath];
      BOOL subdir = NO;
      [fileManager fileExistsAtPath:fullsubpath
                        isDirectory:&subdir];
      if (!subdir) {
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:fullsubpath
                                                            error:&error];
        if (error) {
          NSLog(@"fileSize error: %@", [error localizedFailureReason]);
          return 0;
        }
        totalSize += [attrs[NSFileSize] intValue];
      }
    }
    return totalSize / (1000 * 1000.0);
  } else {  // 文件
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath
                                                        error:&error];
    if (error) {
      NSLog(@"fileSize error: %@", [error localizedFailureReason]);
      return 0;
    }
    return [attrs[NSFileSize] intValue] / (1000 * 1000.0);
  }
}

#pragma mark - File Content String
+ (void)printContent:(NSString *)filePath {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSLog(@"File Array: %@", [fileManager contentsOfDirectoryAtPath:filePath
                                                            error:&error]);
  if (error) {
    NSLog(@"printContent error: %@", [error localizedFailureReason]);
  }
}

+ (NSString *)fileContentWithString:(NSString *)filePath {
  NSError *error = nil;
  NSString *textFileContents = [NSString stringWithContentsOfFile:filePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];
  if (error) {
    NSLog(@"fileContentWithString error: %@", [error localizedFailureReason]);
  }
  return textFileContents;
}

+ (void)writeContent:(NSString *)content
              toFile:(NSString *)filePath {
  NSError *error = nil;
  [content writeToFile:filePath
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:&error];
  if (error) {
    NSLog(@"writeContent error: %@", [error localizedDescription]);
  }
}

#pragma mark - Directory
+ (void)createDirectory:(NSString *)path {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL existed = [fileManager fileExistsAtPath:path
                                   isDirectory:NULL];
  if (!existed) {
    [fileManager createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
    if (error) {
      NSLog(@"createDirectory error: %@", [error localizedDescription]);
    }
  }
}

+ (void)removeDirectory:(NSString *)path {
  NSError *error = nil;
  BOOL isDir = NO;

  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL existed = [fileManager fileExistsAtPath:path
                                   isDirectory:&isDir];
  if (existed && isDir) {
    [[NSFileManager defaultManager] removeItemAtPath:path
                                               error:&error];
    if (error) {
      NSLog(@"removeDirectory error: %@", [error localizedDescription]);
    }
  }
}

+ (void)removeFilesInDirectory:(NSString *)path {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *contents = [fileManager contentsOfDirectoryAtPath:path
                                                       error:&error];
  NSEnumerator *enumerator = [contents objectEnumerator];
  NSString *filename = nil;
  while ((filename = [enumerator nextObject])) {
    [fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename]
                            error:&error];
    if (error) {
      NSLog(@"removeAll error: %@", [error localizedDescription]);
    }
  }
}

+ (void)removeAll:(NSString *)path {
  [self removeFilesInDirectory:path];
  [self removeDirectory:path];
}

+ (void)renameDirectory:(NSString *)originalDirectory
                   with:(NSString *)newDirectory {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL isDir = NO;
  BOOL existed = [fileManager fileExistsAtPath:originalDirectory
                                   isDirectory:&isDir];
  if (isDir && existed) {
    [fileManager moveItemAtPath:originalDirectory
                         toPath:newDirectory
                          error:&error];
    if (error) {
      NSLog(@"renameDirectory error: %@", [error localizedDescription]);
    }
  }
}

#pragma mark - Directory Sandbox
+ (NSString *)LibraryDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)DocumentDirectory {
  //    NSString * documentsDirectory = [NSHomeDirectory()
  //    stringByAppendingPathComponent:@"Documents"];
  //    NSString *filePath= [documentsDirectory
  //    stringByAppendingPathComponent:fileName];
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)PreferencePanesDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)CachesDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

@end
