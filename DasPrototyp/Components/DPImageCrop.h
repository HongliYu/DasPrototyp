//
//  DPImageCrop.h
//  DasPrototyp
//
//  Created by HongliYu on 15/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPImageCropDelegate <NSObject>

- (void)cropImage:(UIImage*)cropImage
 forOriginalImage:(UIImage*)originalImage;

@end

@interface DPImageCrop : UIViewController

//下面俩哪个后面设置，即是哪个有效
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) NSURL *imageURL;

@property(nonatomic,weak) id<DPImageCropDelegate> delegate;
@property(nonatomic,assign) CGFloat ratioOfWidthAndHeight; //截取比例，宽高比

- (void)showWithAnimation:(BOOL)animation;

@end
