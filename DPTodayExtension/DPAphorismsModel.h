//
//  DPAphorismsModel.h
//  DasPrototyp
//
//  Created by HongliYu on 16/6/24.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPAphorismsModel : NSObject

@property (nonatomic, strong, readonly) NSNumber *identifier;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSString *mrname;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
