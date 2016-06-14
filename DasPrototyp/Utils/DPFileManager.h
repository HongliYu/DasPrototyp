//
//  DPFileManager.h
//  DasPrototyp
//
//  Created by HongliYu on 16/4/28.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPFileManager : NSObject

#pragma mark - File
+ (void)createFile:(NSString *)filePath;
+ (void)removeFile:(NSString *)filePath;
+ (void)renameFile:(NSString *)originalPath
              with:(NSString *)newPath;
+ (void)copyFile:(NSString *)originalPath
              to:(NSString *)destinationPath;
+ (NSDictionary *)fileAttributes:(NSString *)filePath;
+ (double)fileSize:(NSString *)filePath;

#pragma mark - File Content String
+ (void)printContent:(NSString *)filePath;
+ (NSString *)fileContentWithString:(NSString *)filePath;
+ (void)writeContent:(NSString *)content
              toFile:(NSString *)filePath;

#pragma mark - Directory
+ (void)createDirectory:(NSString *)path;
+ (void)removeDirectory:(NSString *)path;
+ (void)removeFilesInDirectory:(NSString *)path;
+ (void)removeAll:(NSString *)path;
+ (void)renameDirectory:(NSString *)originalDirectory
                   with:(NSString *)newDirectory;

#pragma mark - Directory Sandbox
+ (NSString *)LibraryDirectory;
+ (NSString *)DocumentDirectory;
+ (NSString *)PreferencePanesDirectory;
+ (NSString *)CachesDirectory;

@end
