//
//  DPMaskViewModel.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPMaskViewModel.h"

@interface DPMaskViewModel() <NSCopying, NSCoding>

@property (nonatomic, assign, readwrite, getter=isSelected) BOOL selected;
@property (nonatomic, assign, readwrite) DPEventSignal eventSignal;
@property (nonatomic, assign, readwrite) DPSwitchMode switchMode;
@property (nonatomic, assign, readwrite) DPSwitchDirection switchDirection;
@property (nonatomic, assign, readwrite) NSInteger linkIndex;
@property (nonatomic, assign, readwrite) NSTimeInterval animationDelayTime;

@end

@implementation DPMaskViewModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super initWithDictionary:dictionary];
  if (self) {
    _selected = [[dictionary objectForKey:@"selected"] boolValue];
    _eventSignal = [[dictionary objectForKey:@"event_signal"] integerValue];
    _switchMode = [[dictionary objectForKey:@"switch_mode"] integerValue];
    _switchDirection = [[dictionary objectForKey:@"switch_direction"] integerValue];
    _linkIndex = [[dictionary objectForKey:@"link_index"] integerValue];
    _animationDelayTime = [[dictionary objectForKey:@"animation_delaytime"] floatValue];
  }
  return self;
}

- (instancetype)initWithSeparatedDictionary:(NSDictionary *)dictionary {
  self = [super initWithDictionary:dictionary];
  if (self) {
    _selected = [[dictionary objectForKey:@"selected"] boolValue];
    _eventSignal = [[dictionary objectForKey:@"event_signal"] integerValue];
    _switchMode = [[dictionary objectForKey:@"switch_mode"] integerValue];
    _switchDirection = [[dictionary objectForKey:@"switch_direction"] integerValue];
    _linkIndex = [[dictionary objectForKey:@"link_index"] integerValue];
    _animationDelayTime = [[dictionary objectForKey:@"animation_delaytime"] floatValue];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  _selected = [coder decodeBoolForKey:@"selected"];
  _eventSignal = [coder decodeIntegerForKey:@"event_signal"];
  _switchMode = [coder decodeIntegerForKey:@"switch_mode"];
  _switchDirection = [coder decodeIntegerForKey:@"switch_direction"];
  _linkIndex = [coder decodeIntegerForKey:@"link_index"];
  _animationDelayTime = [coder decodeFloatForKey:@"animation_delaytime"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeBool:self.selected forKey:@"selected"];
  [coder encodeInteger:self.eventSignal forKey:@"event_signal"];
  [coder encodeInteger:self.switchMode forKey:@"switch_mode"];
  [coder encodeInteger:self.switchDirection forKey:@"switch_direction"];
  [coder encodeInteger:self.linkIndex forKey:@"link_index"];
  [coder encodeFloat:self.animationDelayTime forKey:@"animation_delaytime"];
}

- (id)copyWithZone:(NSZone *)zone {
  DPMaskViewModel *maskViewModel = [super copyWithZone:zone];
  maskViewModel->_selected = self.selected;
  maskViewModel->_eventSignal = self.eventSignal;
  maskViewModel->_switchMode = self.switchMode;
  maskViewModel->_switchDirection = self.switchDirection;
  maskViewModel->_linkIndex = self.linkIndex;
  maskViewModel->_animationDelayTime = self.animationDelayTime;
  return maskViewModel;
}

- (NSUInteger)hash {
  return [super hash];
}

- (BOOL)isEqual:(DPMaskViewModel *)maskViewModel {
  if (![maskViewModel isKindOfClass:DPMaskViewModel.class]) return NO;
  return [self.identifier isEqualToString:maskViewModel.identifier]
  && [self.createdTime isEqualToString:maskViewModel.createdTime];
}


- (void)setSwitchMode:(DPSwitchMode)switchMode {
  _switchMode = switchMode;
}

- (void)setSwitchDirection:(DPSwitchDirection)switchDirection {
  _switchDirection = switchDirection;
}

- (void)setEventSignal:(DPEventSignal)eventSignal {
  _eventSignal = eventSignal;
}

- (void)setLinkIndex:(NSInteger)linkIndex {
  _linkIndex = linkIndex;
}

- (void)setAnimationDelayTime:(NSTimeInterval)animationDelayTime {
  _animationDelayTime = animationDelayTime;
}

- (void)setSelected:(BOOL)selected {
  _selected = selected;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, %@>",
          [self class], self, @{@"identifier" : self.identifier,
                                @"startPoint" : NSStringFromCGPoint(self.startPoint),
                                @"endPoint" : NSStringFromCGPoint(self.endPoint),
                                @"createdTime" : self.createdTime,
                                @"updatedTime" : self.updatedTime,
                                @"selected" : @(self.selected),
                                @"eventSignal" : @(self.eventSignal),
                                @"switchMode" : @(self.switchMode),
                                @"switchDirection" : @(self.switchDirection),
                                @"linkIndex" : @(self.linkIndex),
                                @"animationDelayTime" : @(self.animationDelayTime)
                                }];
}

@end
