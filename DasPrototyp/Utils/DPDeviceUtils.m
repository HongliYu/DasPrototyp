//
//  DPDeviceUtils.m
//  DasPrototyp
//
//  Created by Hongli Yu on 2018/11/21.
//  Copyright © 2018 HongliYu. All rights reserved.
//

#import "DPDeviceUtils.h"
#import "DeviceUtil.h"

@implementation DPDeviceUtils

+ (BOOL)checkIfDeviceHasBangs {
  DeviceUtil *deviceUtil = [[DeviceUtil alloc] init];
  Hardware hardware = [deviceUtil hardware];
  if (hardware == IPHONE_X
      || hardware == IPHONE_XS
      || hardware == IPHONE_XS_MAX
      || hardware == IPHONE_XS_MAX_CN
      || hardware == IPHONE_XR) {
    return YES;
  }
  return NO;
}

+ (NSString *)checkDeviceScreen {
  if (SCREEN_HEIGHT == 568.f && SCREEN_WIDTH == 320.f) {
    return @"4_inch";
  }
  if (SCREEN_HEIGHT == 667.f && SCREEN_WIDTH == 375.f) {
    return @"4_dot_7_inch";
  }
  if (SCREEN_HEIGHT == 736.f && SCREEN_WIDTH == 414.f) {
    return @"5_dot_5_inch";
  }
  if (SCREEN_HEIGHT == 812.f && SCREEN_WIDTH == 375.f) {
    return @"5_dot_8_inch";
  }
  if (SCREEN_HEIGHT == 896.f && SCREEN_WIDTH == 414.f) {
    return @"6_dot_5_inch";
  }
  return @"Unsupported Device";
}

@end
