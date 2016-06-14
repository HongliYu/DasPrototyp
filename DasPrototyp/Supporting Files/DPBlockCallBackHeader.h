//
//  DPBlockCallBackHeader.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/7.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

typedef void (^mutableArrayComplitionHandler)(NSMutableArray* mutableArrayResult);
typedef void (^finishedComplitionHandler)(BOOL finished);
typedef void (^gestureComplitionHandler)(UIGestureRecognizer *gestureRecognizer);
typedef void (^complitionHandler)();
