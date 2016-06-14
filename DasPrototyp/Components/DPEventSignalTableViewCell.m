//
//  DPEventSignalTableViewCell.m
//  DasPrototyp
//
//  Created by HongliYu on 16/6/3.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPEventSignalTableViewCell.h"

@interface DPEventSignalTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *eventSignalLabel;
@property (weak, nonatomic) IBOutlet UIView *maskView;

@end

@implementation DPEventSignalTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  [self.eventSignalLabel setFont:[UIFont fontWithName:@"Helvetica"
                                                 size:15.f * (SCREEN_WIDTH / 375.f)]];
}

- (void)bindData:(NSString *)text
        selected:(BOOL)selected {
  _eventSignalLabel.text = text;
  if (selected) {
    _maskView.backgroundColor = [UIColor colorWithRed:86 / 255.f
                                                green:202 / 255.f
                                                 blue:139 / 255.f
                                                alpha:0.6f];
  } else {
    _maskView.backgroundColor = [UIColor clearColor];
  }
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated {
    [super setSelected:selected
              animated:animated];
}

@end
