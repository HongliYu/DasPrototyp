//
//  DPDraggableButton.h
//  DasPrototyp
//
//  Created by HongliYu on 14/5/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPDraggableButton : UIButton {
  BOOL _isDragging;
  BOOL _singleTapBeenCanceled;
  CGPoint _beginLocation;
  UILongPressGestureRecognizer *_longPressGestureRecognizer;
}
@property (nonatomic) BOOL draggable;
@property (nonatomic) BOOL autoDocking;

@property (nonatomic, copy) void(^longPressBlock)(DPDraggableButton *button);
@property (nonatomic, copy) void(^tapBlock)(DPDraggableButton *button);
@property (nonatomic, copy) void(^doubleTapBlock)(DPDraggableButton *button);
@property (nonatomic, copy) void(^draggingBlock)(DPDraggableButton *button);
@property (nonatomic, copy) void(^dragDoneBlock)(DPDraggableButton *button);
@property (nonatomic, copy) void(^autoDockingBlock)(DPDraggableButton *button);
@property (nonatomic, copy) void(^autoDockingDoneBlock)(DPDraggableButton *button);

- (id)initInKeyWindowWithFrame:(CGRect)frame;
- (id)initInView:(id)view WithFrame:(CGRect)frame;

- (BOOL)isDragging;
+ (void)removeAllFromKeyWindow;
+ (void)removeAllFromView:(id)superView;

@end
