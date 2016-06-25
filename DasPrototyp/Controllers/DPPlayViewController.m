//
//  DPPlayViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-3-18.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPPlayViewController.h"
#import "DPPhotoCollectViewController.h"
#import "DPMainManager.h"
#import "DPMainViewModel.h"
#import "DPPageViewModel.h"
#import "DPMaskViewModel.h"
#import "DPMaskView.h"

@interface DPPlayViewController ()

@property (strong, nonatomic) UIImageView *currentImageView;
@property (strong, nonatomic) NSMutableArray *playedMaskViews;
@property (strong, nonatomic) DPPageViewModel *playedPageViewModel;

@end

@implementation DPPlayViewController

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self checkIfNeedTips];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseState];
  [self configBaseUI];
  [self configBaseData];
  [self bindActions];
  [self addNotifications];
  [self configBusinessRouter];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  
}

#pragma mark - State
- (void)configBaseState {
  
}

#pragma mark - UI
- (void)configBaseUI {
  _currentImageView = [[UIImageView alloc] init];
  _currentImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  [_currentImageView setUserInteractionEnabled:YES];
  [self.view addSubview:_currentImageView];
  
  DPPageViewModel *startPageViewModel = nil;
  if ([DPMainManager sharedDPMainManager].currentPageViewModel) {
    startPageViewModel = [DPMainManager sharedDPMainManager].currentPageViewModel;
  } else {
    startPageViewModel = [[DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels firstObject];
  }
  if (startPageViewModel.imageName) {
    [[DPMainManager sharedDPMainManager] imageWithProjectTitle:[DPMainManager sharedDPMainManager].currentMainViewModel.title
                                                     imageName:startPageViewModel.imageName
                                                    completion:^(UIImage *image) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                        self.currentImageView.image = image;
                                                      });
                                                    }];
  }
  _playedPageViewModel = startPageViewModel;
  [self bindActions];
  
  UITapGestureRecognizer *twoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(twoFingerTapAction)];
  twoFingerTapGesture.numberOfTapsRequired = 1;
  twoFingerTapGesture.numberOfTouchesRequired = 3;
  [self.view addGestureRecognizer:twoFingerTapGesture];
  
}

- (void)twoFingerTapAction {
  [[DPMainManager sharedDPMainManager] exitPlayMode];
  [self .navigationController popViewControllerAnimated:YES];
}

- (void)addMaskViewsWithMaskViewModels:(NSMutableArray *)maskViewModels
                           toImageView:(UIImageView *)imageView {
  _playedMaskViews = [[NSMutableArray alloc] initWithCapacity:maskViewModels.count];
  for (DPMaskViewModel *maskViewModel in maskViewModels) {
    DPMaskView *maskView = [[DPMaskView alloc] initWithPlayMode];
    [imageView addSubview:maskView];
    [maskView bindData:maskViewModel];
    [_playedMaskViews addObject:maskView];
    [maskView setActionCallBack:^{
      if (maskViewModel.animationDelayTime == 0) { // replace with no animation
        UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                              linkIndex:maskViewModel.linkIndex];
        [self.view addSubview:nextImageView];
        self.currentImageView = nextImageView;
        [[DPMainManager sharedDPMainManager] exitAnimationMode];
      }
      switch (maskViewModel.switchMode) {
        case DPSwitchModePush: {
          switch (maskViewModel.switchDirection) {
            case DPSwitchDirectionNone: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              self.currentImageView = nextImageView;
              [[DPMainManager sharedDPMainManager] exitAnimationMode];
              break;
            }
            case DPSwitchDirectionUp: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 nextImageView.top = 0;
                                 self.currentImageView.bottom = nextImageView.top;
              } completion:^(BOOL finished) {
                self.currentImageView = nextImageView;
                [[DPMainManager sharedDPMainManager] exitAnimationMode];
              }];
              break;
            }
            case DPSwitchDirectionDown: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 nextImageView.top = 0;
                                 self.currentImageView.top = nextImageView.bottom;
              } completion:^(BOOL finished) {
                self.currentImageView = nextImageView;
                [[DPMainManager sharedDPMainManager] exitAnimationMode];
              }];
              break;
            }
            case DPSwitchDirectionleft: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 nextImageView.left = 0;
                                 self.currentImageView.right = nextImageView.left;
                               } completion:^(BOOL finished) {
                                 self.currentImageView = nextImageView;
                                 [[DPMainManager sharedDPMainManager] exitAnimationMode];
                               }];
              break;
            }
            case DPSwitchDirectionRight: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 nextImageView.left = 0;
                                 self.currentImageView.left = nextImageView.right;
                               } completion:^(BOOL finished) {
                                 self.currentImageView = nextImageView;
                                 [[DPMainManager sharedDPMainManager] exitAnimationMode];
                               }];
              break;
            }
          }
          break;
        }
        case DPSwitchModeCover: {
          switch (maskViewModel.switchDirection) {
            case DPSwitchDirectionNone: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              self.currentImageView = nextImageView;
              [[DPMainManager sharedDPMainManager] exitAnimationMode];
              break;
            }
            case DPSwitchDirectionUp: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 nextImageView.top = 0;
              } completion:^(BOOL finished) {
                self.currentImageView = nextImageView;
                [[DPMainManager sharedDPMainManager] exitAnimationMode];
              }];
              break;
            }
            case DPSwitchDirectionDown: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 nextImageView.top = 0;
              } completion:^(BOOL finished) {
                self.currentImageView = nextImageView;
                [[DPMainManager sharedDPMainManager] exitAnimationMode];
              }];
              break;
            }
            case DPSwitchDirectionleft: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 nextImageView.left = 0;
                               } completion:^(BOOL finished) {
                                 self.currentImageView = nextImageView;
                                 [[DPMainManager sharedDPMainManager] exitAnimationMode];
                               }];
              break;
            }
            case DPSwitchDirectionRight: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 nextImageView.left = 0;
                               } completion:^(BOOL finished) {
                                 self.currentImageView = nextImageView;
                                 [[DPMainManager sharedDPMainManager] exitAnimationMode];
                               }];
              break;
            }
          }
          break;
        }
        case DPSwitchModeUncover: {
          switch (maskViewModel.switchDirection) {
            case DPSwitchDirectionNone: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view addSubview:nextImageView];
              self.currentImageView = nextImageView;
              [[DPMainManager sharedDPMainManager] exitAnimationMode];
              break;
            }
            case DPSwitchDirectionUp: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view insertSubview:nextImageView belowSubview:self.currentImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 self.currentImageView.top = -SCREEN_HEIGHT;
                               } completion:^(BOOL finished) {
                                 self.currentImageView = nextImageView;
                                 [[DPMainManager sharedDPMainManager] exitAnimationMode];
                               }];
              break;
            }
            case DPSwitchDirectionDown: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view insertSubview:nextImageView
                          belowSubview:self.currentImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 self.currentImageView.top = SCREEN_HEIGHT;
                               } completion:^(BOOL finished) {
                                 self.currentImageView = nextImageView;
                                 [[DPMainManager sharedDPMainManager] exitAnimationMode];
                               }];
              break;
            }
            case DPSwitchDirectionleft: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view insertSubview:nextImageView
                          belowSubview:self.currentImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 self.currentImageView.left = -SCREEN_WIDTH;
              } completion:^(BOOL finished) {
                self.currentImageView = nextImageView;
                [[DPMainManager sharedDPMainManager] exitAnimationMode];
              }];
              break;
            }
            case DPSwitchDirectionRight: {
              UIImageView *nextImageView = [self createNextImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                    linkIndex:maskViewModel.linkIndex];
              [self.view insertSubview:nextImageView
                          belowSubview:self.currentImageView];
              [UIView animateWithDuration:maskViewModel.animationDelayTime
                               animations:^{
                                 self.currentImageView.left = SCREEN_WIDTH;
              } completion:^(BOOL finished) {
                self.currentImageView = nextImageView;
                [[DPMainManager sharedDPMainManager] exitAnimationMode];
              }];
              break;
            }
          }
          break;
        }
      }
    }];
  }
}

- (UIImageView *)createNextImageViewWithFrame:(CGRect)frame
                                    linkIndex:(NSInteger)index {
  NSInteger linkIndex = 0;
  NSInteger pageCount = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count;
  if (index <= pageCount - 1) {
    linkIndex = index;
  } else {
    linkIndex = pageCount - 1;
  }
  
  UIImageView *nextImageView = [[UIImageView alloc] init];
  [nextImageView setUserInteractionEnabled:YES];
  nextImageView.frame = frame;
  self.playedPageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[linkIndex];
  [[DPMainManager sharedDPMainManager] imageWithProjectTitle:[DPMainManager sharedDPMainManager].currentMainViewModel.title
                                                   imageName:self.playedPageViewModel.imageName
                                                  completion:^(UIImage *image) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                      nextImageView.image = image;
                                                    });
                                                  }];
  [self addMaskViewsWithMaskViewModels:self.playedPageViewModel.maskViewModels
                           toImageView:nextImageView];
  [self bindActions];
  return nextImageView;
}

- (void)configBaseData {
  [SVProgressHUD show];
  [[DPMainManager sharedDPMainManager] enterPlayMode:^(BOOL finished) {
    if (finished) {
      if (self.playedPageViewModel.maskViewModels) {
        [self addMaskViewsWithMaskViewModels:self.playedPageViewModel.maskViewModels
                                 toImageView:self.currentImageView];
      }
      [SVProgressHUD dismiss];
    }
  }];
}

- (void)bindActions {
  __weak typeof(self) weakSelf = self;
  [self.view setMenuActionWithBlock:^(UITapGestureRecognizer *tapGesture) {
    __strong typeof(self) strongSelf = weakSelf;
    CGPoint tapPointPosition = [tapGesture locationInView:strongSelf.view];
    BOOL getSelectedMaskView = NO;
    for (int i = 0; i < strongSelf.playedPageViewModel.maskViewModels.count; i++) {
      DPMaskViewModel *maskViewModel = strongSelf.playedPageViewModel.maskViewModels[i];
      if (tapPointPosition.x > maskViewModel.startPoint.x
          && tapPointPosition.x < maskViewModel.endPoint.x
          && tapPointPosition.y > maskViewModel.startPoint.y
          && tapPointPosition.y < maskViewModel.endPoint.y) {
        getSelectedMaskView = YES;
        break;
      }
    }
    
    if (!getSelectedMaskView) {
      [strongSelf.playedMaskViews
       enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DPMaskView *maskView = (DPMaskView *)obj;
        [UIView animateWithDuration:0.4f animations:^{
          [maskView setBackgroundColor:MAIN_GREEN_COLOR];
          [maskView setAlpha:0.4f];
        } completion:^(BOOL finished) {
          if (finished) {
            [maskView setBackgroundColor:[UIColor clearColor]];
            [maskView setAlpha:1.f];
          }
        }];
      }];
    }
  }];
}

- (void)checkIfNeedTips {
  BOOL playModeTipsShowed = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlayModeTipsShowed"];
  if (!playModeTipsShowed) {
    SCLAlertView *playModeTipsAlertView = [[SCLAlertView alloc] init];
    [playModeTipsAlertView addButton:NSLocalizedString(@"Got it", @"") actionBlock:^{
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PlayModeTipsShowed"];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [playModeTipsAlertView showInfo:self
                              title:NSLocalizedString(@"Tips", @"")
                           subTitle:NSLocalizedString(@"Three fingers pressed once to return", @"")
                   closeButtonTitle:NSLocalizedString(@"Cancel", @"")
                           duration:0];
  }
}

- (void)addNotifications {

}

- (void)configBusinessRouter {

}

@end
