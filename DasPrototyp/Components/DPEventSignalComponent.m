//
//  DPEventSignalComponent.m
//  DasPrototyp
//
//  Created by HongliYu on 16/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPEventSignalComponent.h"
#import "DPEventSignalTableViewCell.h"
#import "DPMaskViewModel.h"
#import "DPCommonUtils.h"

static NSString *const kDPEventSignalTableViewCell = @"DPEventSignalTableViewCell";

@interface DPEventSignalComponent()

@property (nonatomic, strong, readwrite) UITableView *switchSignalTableView;
@property (nonatomic, strong, readwrite) DPMaskViewModel *maskViewModel;
@property (nonatomic, strong, readwrite) NSArray *dataArray;
@property (nonatomic, assign, readwrite) float cellHeight;

@end

@implementation DPEventSignalComponent

- (instancetype)initWithDatasource:(DPMaskViewModel *)maskViewModel {
  self = [super init];
  if (self) {
    _dataArray = @[NSLocalizedString(@"PressDown", @""),
                   NSLocalizedString(@"LongPress", @""),
                   NSLocalizedString(@"SwipeLeft", @""),
                   NSLocalizedString(@"SwipeUp", @""),
                   NSLocalizedString(@"SwipeRight", @""),
                   NSLocalizedString(@"SwipeDown", @""),
                   NSLocalizedString(@"Rotate", @""),
                   NSLocalizedString(@"Pinch", @""),];
    _maskViewModel = maskViewModel;
    float maxWidth = 0;
    for (NSString* gestureString in _dataArray) {
      float widthIs = [DPCommonUtils rectSizeWithText:gestureString
                                          andFontSize:(15.f * (SCREEN_WIDTH / 375.f))].width;
      if (widthIs > maxWidth) {
        maxWidth = widthIs;
      }
    }
    CGRect rect = CGRectMake(0, 0, maxWidth + 40, SCREEN_HEIGHT / 4.f);
    _switchSignalTableView = [[UITableView alloc] initWithFrame:rect];
    _switchSignalTableView.dataSource = self;
    _switchSignalTableView.delegate = self;
    _switchSignalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _switchSignalTableView.backgroundColor = MAIN_COLOR;
    [_switchSignalTableView registerNib:[UINib nibWithNibName:@"DPEventSignalTableViewCell"
                                                       bundle:nil]
                 forCellReuseIdentifier:kDPEventSignalTableViewCell];
    _cellHeight = _switchSignalTableView.height / (self.dataArray.count * 1.f + 1); // 1 is header
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, _cellHeight)];
    [titleLabel setBackgroundColor:MAIN_PINK_COLOR];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica"
                                        size:16.f * (SCREEN_WIDTH / 375.f)]];
    titleLabel.text = NSLocalizedString(@"Gesture", @"");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    _switchSignalTableView.tableHeaderView = titleLabel;
  }
  return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  DPEventSignalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDPEventSignalTableViewCell];
  if (!cell) {
    cell = [[DPEventSignalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:kDPEventSignalTableViewCell];
  }
  if (self.maskViewModel.eventSignal == indexPath.row) {
    [cell bindData:self.dataArray[indexPath.row]
          selected:YES];
  } else {
    [cell bindData:self.dataArray[indexPath.row]
          selected:NO];
  }
  return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  NSIndexPath *preSelectedIndexPath = [NSIndexPath indexPathForRow:self.maskViewModel.eventSignal
                                                         inSection:0];
  DPEventSignalTableViewCell *preSelectedCell = (DPEventSignalTableViewCell *)[tableView cellForRowAtIndexPath:preSelectedIndexPath];
  [preSelectedCell bindData:self.dataArray[self.maskViewModel.eventSignal] selected:NO];
  
  self.maskViewModel.eventSignal = indexPath.row;
  DPEventSignalTableViewCell *selectedCell = (DPEventSignalTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  [selectedCell bindData:self.dataArray[indexPath.row] selected:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return self.cellHeight;
}

@end
