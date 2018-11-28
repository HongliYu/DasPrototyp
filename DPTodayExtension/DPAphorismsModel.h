//
//  DPAphorismsModel.h
//  DPTodayExtension
//
//  Created by Hongli Yu on 2018/11/19.
//  Copyright © 2018 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPAphorismsModel : NSObject

@property (nonatomic, strong, readonly) NSNumber *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSString *link;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

