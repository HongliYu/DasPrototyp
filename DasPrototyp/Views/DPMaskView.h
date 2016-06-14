//
//  DPMaskView.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/6.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPMaskViewModel;

extern const float kButtonHeight;

typedef NS_ENUM (NSUInteger, DPMaskViewDisplayMode) {
  DPMaskViewDisplayModeEdit,
  DPMaskViewDisplayModePlay
};

@interface DPMaskView : UIView

- (instancetype)initWithEditMode;
- (instancetype)initWithPlayMode;

// state
@property (assign, nonatomic, readonly) DPMaskViewDisplayMode displayMode;

// data
- (void)bindData:(DPMaskViewModel *)maskViewModel;
@property (strong, nonatomic, readonly) DPMaskViewModel *maskViewModel;

// play mode
@property (nonatomic, copy) void (^actionCallBack)();

// edit mode
// moving
@property (assign, nonatomic, readonly) CGPoint lastOriginPoint;
@property (assign, nonatomic, readonly, getter=isMoving) BOOL moving;
- (void)enterMovingMode;
- (void)exitMovingMode;

// resizing
@property (assign, nonatomic, readonly) CGSize lastRectSize;
@property (assign, nonatomic, readonly, getter=isResizing) BOOL resizing;
- (void)enterResizingMode;
- (void)exitResizingMode;

// actions
@property (nonatomic, copy) void (^resizingAction)(UIGestureRecognizer *gestureRecognizer);
@property (nonatomic, copy) void (^deleteAction)();
@property (nonatomic, copy) void (^tapAction)();

@end
