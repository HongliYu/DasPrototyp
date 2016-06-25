//
//  DPBlockCallBackHeader.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/7.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^mutableArrayCompletionHandler)(NSMutableArray* mutableArrayResult);
typedef void (^resultCompletionHandler)(id result, NSError *error);
typedef void (^finishedCompletionHandler)(BOOL finished);
typedef void (^gestureCompletionHandler)(UIGestureRecognizer *gestureRecognizer);
typedef void (^completionHandler)();
