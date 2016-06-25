//
//  DPMainTableViewCell.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/7.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPMainTableViewCell.h"
#import "DPMainViewModel.h"

const float kMainCellHeightNormal = 90.f;
static void *MainTableViewCellContextTitle = &MainTableViewCellContextTitle;
static void *MainTableViewCellContextThumbnail = &MainTableViewCellContextThumbnail;
static void *MainTableViewCellContextComment = &MainTableViewCellContextComment;

@interface DPMainTableViewCell()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shareButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *renameButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *thumbnailWidth;

@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) IBOutlet UIButton *renameButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;

@property (strong, nonatomic) DPMainViewModel *mainViewModel;
@property (assign, nonatomic) BOOL mainViewModelKVOAdded;

@end

@implementation DPMainTableViewCell

#pragma mark - Life Cycle
- (void)awakeFromNib {
  [super awakeFromNib];
  [self configBaseUI];
}

- (void)dealloc {
  if (_mainViewModelKVOAdded) {
    [self removeObserver:self
              forKeyPath:@"mainViewModel.title"
                 context:&MainTableViewCellContextTitle];
    [self removeObserver:self
              forKeyPath:@"mainViewModel.thumbnailName"
                 context:&MainTableViewCellContextThumbnail];
    [self removeObserver:self
              forKeyPath:@"mainViewModel.comment"
                 context:&MainTableViewCellContextComment];
  }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
  if (context == &MainTableViewCellContextTitle
      || context == &MainTableViewCellContextThumbnail
      || context == &MainTableViewCellContextComment) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self updateUI];
    });
  }
}

- (void)configBaseUI {
  self.thumbnailWidth.constant = SCREEN_PROPORTION * 80.f;
  self.deleteButtonWidth.constant
  = self.shareButtonWidth.constant
  = self.renameButtonWidth.constant = SCREEN_WIDTH / 3.f;
  [self.moreButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:16.f]];
  self.thumbnailImageView.image = nil;
  self.thumbnailImageView.alpha = 0.4f;
}

- (void)updateUI {
  if ([_mainViewModel.comment isValid]) {
    self.descLabel.text = _mainViewModel.comment;
  }
  if ([_mainViewModel.thumbnailName isValid]) {
    [[DPMainManager sharedDPMainManager] imageWithProjectTitle:_mainViewModel.title
                                                     imageName:_mainViewModel.thumbnailName
                                                    completion:^(UIImage *image) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                        if (image) {
                                                          self.thumbnailImageView.image = image;
                                                          self.thumbnailImageView.alpha = 1.f;
                                                        }
                                                      });
                                                    }];
  } else {
    self.thumbnailImageView.image = nil;
    self.thumbnailImageView.alpha = 0.4f;
  }
  if ([_mainViewModel.title isValid]) {
    self.titleLabel.text = _mainViewModel.title;
  }
}

- (void)bindData:(DPMainViewModel *)mainViewModel {
  if (_mainViewModel) {
    if (![_mainViewModel isEqual:mainViewModel]
        && self.mainViewModelKVOAdded) {
      [self removeObserver:self
                forKeyPath:@"mainViewModel.title"
                   context:&MainTableViewCellContextTitle];
      [self removeObserver:self
                forKeyPath:@"mainViewModel.thumbnailName"
                   context:&MainTableViewCellContextThumbnail];
      [self removeObserver:self
                forKeyPath:@"mainViewModel.comment"
                   context:&MainTableViewCellContextComment];
      self.mainViewModelKVOAdded = NO;
    }
  }
  _mainViewModel = mainViewModel;
  if (!self.mainViewModelKVOAdded) {
    [self addObserver:self
           forKeyPath:@"mainViewModel.title"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:MainTableViewCellContextTitle];
    [self addObserver:self
           forKeyPath:@"mainViewModel.thumbnailName"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:MainTableViewCellContextThumbnail];
    [self addObserver:self
           forKeyPath:@"mainViewModel.comment"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:MainTableViewCellContextComment];
    self.mainViewModelKVOAdded = YES;
  }
  [self updateMoreButtonUI];
  [self updateUI];
}

- (void)updateMoreButtonUI {
  if (_mainViewModel.expanded) {
    [self.moreButton setTitle:@"\U0000e9c0" forState:UIControlStateNormal];
  } else {
    [self.moreButton setTitle:@"\U0000e9bf" forState:UIControlStateNormal];
  }
}

- (void)enableOptionButtons:(BOOL)enabled {
  self.renameButton.enabled = enabled;
  self.shareButton.enabled = enabled;
  self.deleteButton.enabled = enabled;
}

- (IBAction)moreAction:(id)sender {
  [_mainViewModel reverseExpanded];
  [self updateMoreButtonUI];
  [self enableOptionButtons:_mainViewModel.expanded];
  if (self.moreAction) {
    self.moreAction();
  }
}

- (IBAction)renameAction:(id)sender {
  if (self.renameAction) {
    self.renameAction();
  }
}

- (IBAction)shareAction:(id)sender {
  if (self.shareAction) {
    self.shareAction();
  }
}

- (IBAction)deleteAction:(id)sender {
  if (self.deleteAction) {
    if (self.mainViewModelKVOAdded) {
      [self removeObserver:self
                forKeyPath:@"mainViewModel.title"
                   context:&MainTableViewCellContextTitle];
      [self removeObserver:self
                forKeyPath:@"mainViewModel.thumbnailName"
                   context:&MainTableViewCellContextThumbnail];
      [self removeObserver:self
                forKeyPath:@"mainViewModel.comment"
                   context:&MainTableViewCellContextComment];
      self.mainViewModelKVOAdded = NO;
    }
    self.deleteAction();
  }
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated {
    [super setSelected:selected
              animated:animated];
}

@end
