//
//  DPMaskViewModel.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPMaskModel.h"

typedef NS_ENUM (NSUInteger, DPEventSignal) {
  DPEventSignalPressDown,
  DPEventSignalLongPress,
  DPEventSignalSwipeLeft,
  DPEventSignalSwipeUp,
  DPEventSignalSwipeRight,
  DPEventSignalSwipeDown,
  DPEventSignalRotate,
  DPEventSignalPinch
};

typedef NS_ENUM (NSUInteger, DPSwitchMode) {
  DPSwitchModePush,
  DPSwitchModeCover,
  DPSwitchModeUncover,
};

typedef NS_ENUM (NSUInteger, DPSwitchDirection) {
  DPSwitchDirectionNone,
  DPSwitchDirectionUp,
  DPSwitchDirectionDown,
  DPSwitchDirectionleft,
  DPSwitchDirectionRight
};

@interface DPMaskViewModel : DPMaskModel

@property (nonatomic, assign, readonly, getter=isSelected) BOOL selected;
@property (nonatomic, assign, readonly) DPEventSignal eventSignal;
@property (nonatomic, assign, readonly) DPSwitchMode switchMode;
@property (nonatomic, assign, readonly) DPSwitchDirection switchDirection;
@property (nonatomic, assign, readonly) NSInteger linkIndex;
@property (nonatomic, assign, readonly) NSTimeInterval animationDelayTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithSeparatedDictionary:(NSDictionary *)dictionary;

- (void)setSwitchMode:(DPSwitchMode)switchMode;
- (void)setSwitchDirection:(DPSwitchDirection)switchDirection;
- (void)setEventSignal:(DPEventSignal)eventSignal;
- (void)setLinkIndex:(NSInteger)linkIndex;
- (void)setAnimationDelayTime:(NSTimeInterval)animationDelayTime;
- (void)setSelected:(BOOL)selected;

@end
