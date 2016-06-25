//
//  DPUserModel.h
//  DasPrototyp
//
//  Created by HongliYu on 16/6/20.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPUserModel : NSObject

@property (nonatomic, copy, readonly) NSString *identity;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, copy, readonly) NSString *createdTime;
@property (nonatomic, copy, readonly) NSString *updatedTime;

@end
