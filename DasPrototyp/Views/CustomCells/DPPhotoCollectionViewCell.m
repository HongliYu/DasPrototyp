//
//  DPPhotoCollectionViewCell.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/8.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPPhotoCollectionViewCell.h"
#import "DPPageViewModel.h"
#import "DPMainViewModel.h"

static void *PhotoCollectionViewCellContext = &PhotoCollectionViewCellContext;

@interface DPPhotoCollectionViewCell()

@property (strong, nonatomic) DPPageViewModel *pageViewModel;
@property (assign, nonatomic) BOOL pageViewModelKVOAdded;
@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation DPPhotoCollectionViewCell

#pragma mark - Life Cycle
- (void)awakeFromNib {
  [super awakeFromNib];
  [self configBaseUI];
}

- (void)dealloc {
  if (_pageViewModelKVOAdded) {
    [self removeObserver:self
              forKeyPath:@"pageViewModel.selected"
                 context:&PhotoCollectionViewCellContext];
  }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
  if (context == &PhotoCollectionViewCellContext) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self updateUI];
    });
  }
}

#pragma mark - UI
- (void)configBaseUI {
  _pageViewModelKVOAdded = NO;
  _backgroundImageView = [[UIImageView alloc] init];
  self.backgroundView = _backgroundImageView;
}

- (void)updateUI {
  if (_pageViewModel.selected) {
    self.layer.borderWidth = 3.f;
    self.layer.borderColor = MAIN_GREEN_COLOR.CGColor;
  } else {
    self.layer.borderWidth = 3.f;
    self.layer.borderColor = [UIColor clearColor].CGColor;
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

#pragma mark - Bind Data
- (void)bindData:(DPPageViewModel *)pageViewModel {
  if (_pageViewModel) {
    if (![_pageViewModel isEqual:pageViewModel]
        && self.pageViewModelKVOAdded) {
      [self removeObserver:self
                forKeyPath:@"pageViewModel.selected"
                   context:&PhotoCollectionViewCellContext];
      self.pageViewModelKVOAdded = NO;
    }
  }
  _pageViewModel = pageViewModel;
  if (!self.pageViewModelKVOAdded) {
    [self addObserver:self
           forKeyPath:@"pageViewModel.selected"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:PhotoCollectionViewCellContext];
    self.pageViewModelKVOAdded = YES;
  }
  [[DPMainManager sharedDPMainManager] imageWithProjectTitle:[DPMainManager sharedDPMainManager].currentMainViewModel.title
                                                   imageName:_pageViewModel.imageName
                                                  complition:^(UIImage *image) {
                                                    if (image) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                        self.backgroundImageView.image = image;
                                                      });
                                                    }
                                                  }];
  [self updateUI];
}

@end
