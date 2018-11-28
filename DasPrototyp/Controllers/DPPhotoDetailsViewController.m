//
//  DPPhotoDetailsViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-3-14.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPPhotoDetailsViewController.h"
#import "DPPhotoCollectViewController.h"
#import "DPLinkCollectViewController.h"
#import "DPPlayViewController.h"
#import "DPDraggableButton.h"
#import "DPSideMenu.h"
#import "DPPageViewModel.h"
#import "DPMaskViewModel.h"
#import "DPMaskView.h"
#import "DPMainViewModel.h"
#import "DPEventSignalComponent.h"
#import "DPPhoneDetailsView.h"

static const float kDragLinkPadding = 8.f;

@interface DPPhotoDetailsViewController ()

@property (strong, nonatomic) DPDraggableButton *linkButton;
@property (strong, nonatomic) DPDraggableButton *dragButton;
@property (strong, nonatomic) DPSideMenu *sideMenu;
@property (strong, nonatomic) UILabel *addMaskViewLabel;
@property (strong, nonatomic) UILabel *playLabel;
@property (strong, nonatomic) UILabel *backLabel;
@property (strong, nonatomic) NSMutableArray *maskViews;
@property (strong, nonatomic) DPMaskView *selectedMaskView;
@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;

@end

@implementation DPPhotoDetailsViewController

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self showWidgets];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self showWidgets];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseState];
  [self configBaseUI];
  [self configBaseData];
  [self bindActions];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self dismissWithAnimationType:DPFade
                      completion:^(BOOL finished) {
    ;
  }];
}

#pragma mark - State
- (void)configBaseState {
  [self setPageMark:NSStringFromClass(self.class)];
}

#pragma mark - UI
- (void)configBaseUI {
  [[DPMainManager sharedDPMainManager] imageWithProjectTitle:[DPMainManager sharedDPMainManager].currentMainViewModel.title
                                                   imageName:[DPMainManager sharedDPMainManager].currentPageViewModel.imageName
                                                  completion:^(UIImage *image) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                      self.detailImageView.image = image;
                                                    });
                                                  }];
  // dragButton
  _dragButton = [[DPDraggableButton alloc] initInKeyWindowWithFrame:
                 CGRectMake(0, SCREEN_HEIGHT * 0.75f, 44.f, 44.f)];
  [_dragButton setTitle:@"\U0000ea0c" forState:UIControlStateNormal];
  [_dragButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:30.f]];
  _dragButton.layer.masksToBounds = YES;
  _dragButton.layer.borderWidth = 1.f;
  _dragButton.layer.borderColor = [UIColor whiteColor].CGColor;
  _dragButton.backgroundColor = MAIN_COLOR;
  
  // linkButton
  _linkButton = [[DPDraggableButton alloc] initInKeyWindowWithFrame:
                 CGRectMake(_dragButton.width + kDragLinkPadding,
                            _dragButton.top, 44.f, 44.f)];
  [_linkButton setTitle:@"\U0000ea2d" forState:UIControlStateNormal];
  [_linkButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:30.f]];
  _linkButton.layer.masksToBounds = YES;
  _linkButton.layer.borderWidth = 1.f;
  _linkButton.layer.borderColor = [UIColor whiteColor].CGColor;
  _linkButton.backgroundColor = MAIN_COLOR;
  
  // sideMenu
  // addMaskViewLabel
  _addMaskViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40.f, 40.f)];
  [_addMaskViewLabel setBackgroundColor:MAIN_COLOR];
  [_addMaskViewLabel setTextColor:[UIColor whiteColor]];
  _addMaskViewLabel.alpha = 0.8f;
  _addMaskViewLabel.text = @"\U0000ea0a";
  _addMaskViewLabel.font = [UIFont fontWithName:@"dp_iconfont" size:30.0];
  _addMaskViewLabel.textAlignment = NSTextAlignmentCenter;
  [_addMaskViewLabel setUserInteractionEnabled:YES];
  
  // playLabel
  _playLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40.f, 40.f)];
  [_playLabel setBackgroundColor:MAIN_COLOR];
  [_playLabel setTextColor:[UIColor whiteColor]];
  _playLabel.alpha = 0.8f;
  _playLabel.text = @"\U0000e929";
  _playLabel.font = [UIFont fontWithName:@"dp_iconfont" size:30.0];
  _playLabel.textAlignment = NSTextAlignmentCenter;
  [_playLabel setUserInteractionEnabled:YES];
  
  // backLabel
  _backLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40.f, 40.f)];
  [_backLabel setBackgroundColor:MAIN_COLOR];
  [_backLabel setTextColor:[UIColor whiteColor]];
  _backLabel.alpha = 0.8f;
  _backLabel.text = @"\U0000ea14";
  _backLabel.font = [UIFont fontWithName:@"dp_iconfont" size:30.0];
  _backLabel.textAlignment = NSTextAlignmentCenter;
  [_backLabel setUserInteractionEnabled:YES];
  
  _sideMenu = [[DPSideMenu alloc] initWithItems:@[_addMaskViewLabel, _playLabel, _backLabel]];
  [_sideMenu setItemSpacing:5.0f];
  [_sideMenu setAnimationDuration:0.8f];
  [_sideMenu open];
  [[UIApplication sharedApplication].keyWindow addSubview:_sideMenu];
  
  // maskviews
  NSUInteger maskViewCount = [DPMainManager sharedDPMainManager].currentPageViewModel.maskViewModels.count;
  _maskViews = [[NSMutableArray alloc] initWithCapacity:maskViewCount];
}

- (void)restoreMaskView:(DPMaskViewModel *)maskViewModel {
  DPMaskView *maskView = [[DPMaskView alloc] initWithEditMode];
  [maskView makeStyle:^(GDUIViewStyleMaker *make) {
    make.left(maskViewModel.startPoint.x);
    make.top(maskViewModel.startPoint.y);
    make.width(fabs(maskViewModel.endPoint.y - maskViewModel.startPoint.x));
    make.height(fabs(maskViewModel.endPoint.y - maskViewModel.startPoint.y));
  }];
  if (maskViewModel.isSelected) {
    [[DPMainManager sharedDPMainManager] setCurrentMaskViewModel:maskViewModel];
    self.selectedMaskView = maskView;
    [self bindActionWithMaskView:maskView];
  }
  [maskView bindData:maskViewModel];
  [self.maskViews addObject:maskView];
  [self.view addSubview:maskView];
}

- (void)updateSideBar {
  self.sideMenu.isOpen ? [self.sideMenu close] : [self.sideMenu open];
}

- (void)showWidgets {
  [self.dragButton setHidden:NO];
  [self.linkButton setHidden:NO];
  [self.sideMenu setHidden:NO];
}

- (void)hideWidgets {
  [self.dragButton setHidden:YES];
  [self.linkButton setHidden:YES];
  [self.sideMenu setHidden:YES];
}

- (void)addMaskView {
  NSString *createdTime = [NSDate formattedDateNow];
  NSInteger currentPageViewModelIndex =
  [[DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels
   indexOfObject:[DPMainManager sharedDPMainManager].currentPageViewModel];
  // in default mode, a new maskview link to its own page

  NSDictionary *rawMaskViewModelDictionary = @{@"id" : [NSString stringWithUUID],
                                               @"start_point_x" : @100,
                                               @"start_point_y" : @100,
                                               @"end_point_x" : @200,
                                               @"end_point_y" : @200,
                                               @"created_time" : createdTime,
                                               @"updated_time" : createdTime,
                                               @"selected" : @1,
                                               @"event_signal" : @0,
                                               @"switch_mode" : @0,
                                               @"switch_direction" : @0,
                                               @"link_index" : @(currentPageViewModelIndex),
                                               @"animation_delaytime" : @0.f};
  DPMaskViewModel *maskViewModel = [[DPMaskViewModel alloc] initWithDictionary:rawMaskViewModelDictionary];
  [[DPMainManager sharedDPMainManager] addMaskViewModel:maskViewModel];
  [[DPMainManager sharedDPMainManager] setCurrentMaskViewModel:maskViewModel];
  DPMaskView *maskView = [[DPMaskView alloc] initWithEditMode];
  [maskView bindData:maskViewModel];
  [self.view addSubview:maskView];
  [self.maskViews addObject:maskView];
  
  // reset selected view
  if (self.selectedMaskView) {
    DPMaskView *preSelectedMaskView = self.selectedMaskView;
    [self cancelActionWithMaskView:preSelectedMaskView];
    NSUInteger index = [self.maskViews indexOfObject:preSelectedMaskView];
    DPMaskViewModel *preSelectedMaskViewModel = [DPMainManager sharedDPMainManager].currentPageViewModel.maskViewModels[index];
    [preSelectedMaskViewModel setSelected:NO];
    [preSelectedMaskView bindData:preSelectedMaskViewModel];
  }
  self.selectedMaskView = maskView;
  [self bindActionWithMaskView:maskView];
}

- (void)deleteMaskView {
  // mask view delete action
}

#pragma mark - Data
- (void)configBaseData {
  DPMainManager *mainManager = [DPMainManager sharedDPMainManager];
  __weak typeof(DPMainManager *) weakMainManager = mainManager;
  [mainManager restoreMaskViewModelsWithPageViewModelID:mainManager.currentPageViewModel.identifier
                                             completion:^(BOOL finished) {
                                               if (finished) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                   __strong typeof(DPMainManager *) strongMainManager = weakMainManager;
                                                   [strongMainManager.currentPageViewModel.maskViewModels
                                                    enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                      if ([obj isKindOfClass:[DPMaskViewModel class]]) {
                                                        [self restoreMaskView:(DPMaskViewModel *)obj];
                                                      }
                                                    }];
                                                 });
                                               }
                                             }];
}

#pragma mark - Actions
- (void)bindActions {
  // dragButton
  __weak typeof(self) weakSelf = self;
  [self.dragButton setTapBlock:^(DPDraggableButton *avatar) {
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf gesturePopViewDismiss];
    [strongSelf updateSideBar];
  }];
  [self.dragButton setDragDoneBlock:^(DPDraggableButton *avatar) {
    DLog(@"DragDone");
  }];
  [self.dragButton setAutoDockingDoneBlock:^(DPDraggableButton *avatar) {
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf animateLinkButton];
    DLog(@"AutoDockingDone");
  }];
  [self.linkButton addTarget:self
                      action:@selector(linkAction)
            forControlEvents:UIControlEventTouchUpInside];
  [self.linkButton setAutoDockingDoneBlock:^(DPDraggableButton *avatar) {
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf animateLinkButton];
  }];

  [self.addMaskViewLabel setMenuActionWithBlock:^(UITapGestureRecognizer *tapGesture) {
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf gesturePopViewDismiss];
    [strongSelf addMaskView];
  }];
  [self.playLabel setMenuActionWithBlock:^(UITapGestureRecognizer *tapGesture) {
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf gesturePopViewDismiss];
    [strongSelf hideWidgets];
    [[DPMainManager sharedDPMainManager] updateAllMaskViewModels];
    DPPlayViewController *playViewController = [[DPPlayViewController alloc] init];
    [strongSelf.navigationController pushViewController:playViewController animated:YES];
  }];
  [self.backLabel setMenuActionWithBlock:^(UITapGestureRecognizer *tapGesture) {
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf hideWidgets];
    [strongSelf gesturePopViewDismiss];
    [[DPMainManager sharedDPMainManager] updateAllMaskViewModels];
    [DPMainManager sharedDPMainManager].currentPageViewModel = nil;
    [DPMainManager sharedDPMainManager].currentMaskViewModel = nil;
    [strongSelf.navigationController popViewControllerAnimated:YES];
  }];
  [self.view setMenuActionWithBlock:^(UITapGestureRecognizer *tapGesture) {
    __strong typeof(self) strongSelf = weakSelf;
    CGPoint tapPointPosition = [tapGesture locationInView:strongSelf.view];
    BOOL getSelectedMaskView = NO;
    for (int i = 0; i < [DPMainManager sharedDPMainManager].currentPageViewModel.maskViewModels.count; i++) {
      DPMaskViewModel *maskViewModel = [DPMainManager sharedDPMainManager].currentPageViewModel.maskViewModels[i];
      DPMaskView *maskView = strongSelf.maskViews[i];
      if (!getSelectedMaskView
          && tapPointPosition.x > maskViewModel.startPoint.x
          && tapPointPosition.x < maskViewModel.endPoint.x
          && tapPointPosition.y > maskViewModel.startPoint.y
          && tapPointPosition.y < maskViewModel.endPoint.y) {
        [maskViewModel setSelected:YES];
        [[DPMainManager sharedDPMainManager] setCurrentMaskViewModel:maskViewModel];
        strongSelf.selectedMaskView = maskView;
        [strongSelf bindActionWithMaskView:maskView];
        getSelectedMaskView = YES;
      } else {
        [maskViewModel setSelected:NO];
        [strongSelf cancelActionWithMaskView:maskView];
      }
      [maskView bindData:maskViewModel];
    }
    if (!getSelectedMaskView) {
      strongSelf.selectedMaskView = nil;
      [[DPMainManager sharedDPMainManager] setCurrentMaskViewModel:nil];
    }
  }];
  UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(panMainViewAction:)];
  [self.view addGestureRecognizer:panGesture];
  [self.view setUserInteractionEnabled:YES];
}

- (void)panMainViewAction:(UIPanGestureRecognizer *)panGesture {
  CGPoint panPointPosition = [panGesture locationInView:self.view];
  if (!self.selectedMaskView.isMoving && (panPointPosition.x < self.selectedMaskView.left ||
                                          panPointPosition.x > self.selectedMaskView.right ||
                                          panPointPosition.y < self.selectedMaskView.top ||
                                          panPointPosition.y > self.selectedMaskView.bottom)) {
    return;
  }
  CGFloat translationy = [panGesture translationInView:self.view].y;
  CGFloat translationx = [panGesture translationInView:self.view].x;
  switch (panGesture.state) {
    case UIGestureRecognizerStateBegan: {
      [self.selectedMaskView enterMovingMode];
      break;
    }
    case UIGestureRecognizerStateChanged: {
      self.selectedMaskView.left = self.selectedMaskView.lastOriginPoint.x + translationx;
      self.selectedMaskView.top = self.selectedMaskView.lastOriginPoint.y + translationy;
      break;
    }
    case UIGestureRecognizerStateEnded: {
      [self.selectedMaskView exitMovingMode];
      CGPoint startPoint = CGPointMake(self.selectedMaskView.left, self.selectedMaskView.top);
      CGPoint endPoint = CGPointMake(self.selectedMaskView.right, self.selectedMaskView.bottom);
      [[DPMainManager sharedDPMainManager].currentMaskViewModel setStartPoint:startPoint];
      [[DPMainManager sharedDPMainManager].currentMaskViewModel setEndPoint:endPoint];
      [[DPMainManager sharedDPMainManager]
       updateMaskViewModel:[DPMainManager sharedDPMainManager].currentMaskViewModel
       withPageViewModelID:[DPMainManager sharedDPMainManager].currentPageViewModel.identifier];
      break;
    }
    default: {
      break;
    }
  }
}

- (void)linkAction {
  if (!self.selectedMaskView) {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showError:self
               title:NSLocalizedString(@"Hold On...", @"")
            subTitle:NSLocalizedString(@"Select a hotspot please", @"")
    closeButtonTitle:NSLocalizedString(@"OK", @"")
            duration:0.0f];
    return;
  }
  if (![[DPMainManager sharedDPMainManager].currentPageViewModel.maskViewModels firstObject]) {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showError:self
               title:NSLocalizedString(@"Hold On...", @"")
            subTitle:NSLocalizedString(@"Add a hotspot please", @"")
    closeButtonTitle:NSLocalizedString(@"OK", @"")
            duration:0.0f];
    return;
  }
  [self hideWidgets];
  DPLinkCollectViewController *linkCollectViewController = [[DPLinkCollectViewController alloc] init];
  [self.navigationController pushViewController:linkCollectViewController
                                       animated:YES];
}

- (void)bindActionWithMaskView:(DPMaskView *)maskView {
  __weak typeof(self) weakSelf = self;
  DPEventSignalComponent *eventSignalComponent = [[DPEventSignalComponent alloc]
                                                  initWithDatasource:[DPMainManager sharedDPMainManager].currentMaskViewModel];
  // MARK: 不要在block内部创建DPEventSignalComponent对象，会导致组件内部tableview的delegate的一部分没有执行，这是个经典的坑
  [maskView setTapAction:^{
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf presentPopupView:eventSignalComponent.switchSignalTableView
                   animationType:DPSlideTopBottom];
  }];
  
  [maskView setResizingAction:^(UIGestureRecognizer *gestureRecognizer) {
    __strong typeof(self) strongSelf = weakSelf;
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
      UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
      CGFloat translationy = [panGestureRecognizer translationInView:strongSelf.view].y;
      CGFloat translationx = [panGestureRecognizer translationInView:strongSelf.view].x;
      switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStatePossible: {
          break;
        }
        case UIGestureRecognizerStateBegan: {
          [strongSelf.selectedMaskView enterResizingMode];
          break;
        }
        case UIGestureRecognizerStateChanged: {
          strongSelf.selectedMaskView.height = MAX(strongSelf.selectedMaskView.lastRectSize.height + translationy, kButtonHeight);
          strongSelf.selectedMaskView.width = MAX(strongSelf.selectedMaskView.lastRectSize.width + translationx, kButtonHeight);
          break;
        }
        case UIGestureRecognizerStateEnded: {
          [strongSelf.selectedMaskView exitResizingMode];
          CGPoint startPoint = CGPointMake(strongSelf.selectedMaskView.left, strongSelf.selectedMaskView.top);
          CGPoint endPoint = CGPointMake(strongSelf.selectedMaskView.right, strongSelf.selectedMaskView.bottom);
          [[DPMainManager sharedDPMainManager].currentMaskViewModel setStartPoint:startPoint];
          [[DPMainManager sharedDPMainManager].currentMaskViewModel setEndPoint:endPoint];
          [[DPMainManager sharedDPMainManager]
           updateMaskViewModel:[DPMainManager sharedDPMainManager].currentMaskViewModel
           withPageViewModelID:[DPMainManager sharedDPMainManager].currentPageViewModel.identifier];
          break;
        }
        case UIGestureRecognizerStateCancelled: {
          break;
        }
        case UIGestureRecognizerStateFailed: {
          ;
          break;
        }
      }
    }
  }];
  [maskView setDeleteAction:^{
    __strong typeof(self) strongSelf = weakSelf;
    [[DPMainManager sharedDPMainManager] removeMaskViewModel:[DPMainManager sharedDPMainManager].currentMaskViewModel];
    [[DPMainManager sharedDPMainManager] setCurrentMaskViewModel:nil];
    [strongSelf.maskViews removeObject:strongSelf.selectedMaskView];
    strongSelf.selectedMaskView = nil;
  }];
}

- (void)cancelActionWithMaskView:(DPMaskView *)maskView {
  [maskView setResizingAction:nil];
  [maskView setDeleteAction:nil];
}

#pragma mark - Animations
- (void)animateLinkButton {
  if (self.dragButton.frame.origin.x == 0) {
    [UIView animateWithDuration:0.4f
                     animations:^{
                       self.linkButton.top = self.dragButton.top;
                       self.linkButton.left = self.dragButton.right + kDragLinkPadding;
                     }];
  }
  if (self.dragButton.frame.origin.x == SCREEN_WIDTH - self.dragButton.width) {
    [UIView animateWithDuration:0.4f
                     animations:^{
                       self.linkButton.top = self.dragButton.top;
                       self.linkButton.left = self.dragButton.left - kDragLinkPadding - self.linkButton.width;
                     }];
  }
}

- (void)gesturePopViewDismiss {
  [self dismissWithAnimationType:DPFade completion:^(BOOL finished) {
    ;
  }];
}

@end
