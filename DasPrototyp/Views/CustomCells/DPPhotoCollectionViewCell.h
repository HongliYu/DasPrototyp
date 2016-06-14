//
//  DPPhotoCollectionViewCell.h
//  DasPrototyp
//
//  Created by HongliYu on 16/5/8.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPPageViewModel;

@interface DPPhotoCollectionViewCell : UICollectionViewCell

- (void)bindData:(DPPageViewModel *)pageViewModel;

@end
