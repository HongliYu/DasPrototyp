//
//  DPNetworkService.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPBlockCallBackHeader.h"

@class DPUserModel;

typedef NS_ENUM (NSUInteger, DPHTTPMethod) {
  GET,
  POST,
  PATCH,
  PUT,
  DELETE
};

@interface DPNetworkService : NSObject

- (NSInteger)loginWithUserModel:(DPUserModel *)userModel
                     completion:(resultCompletionHandler)completion;
- (void)requestAphorismsCompletion:(resultCompletionHandler)completion;

@end
