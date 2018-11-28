//
//  DPLinkCollectViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-3-19.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPLinkCollectViewController.h"
#import "ASValueTrackingSlider.h"
#import "HMSegmentedControl.h"
#import "DPPhotoCollectionViewCell.h"
#import "DPMaskViewModel.h"
#import "DPMainViewModel.h"
#import "DPPageViewModel.h"
#import "DPDeviceUtils.h"

@interface DPLinkCollectViewController () <UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, ASValueTrackingSliderDataSource>

@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) IBOutlet UICollectionView* linkCollectionView;
@property (nonatomic, strong) IBOutlet ASValueTrackingSlider* delayTimeSlider;
@property (nonatomic, strong) IBOutlet UIButton* backButton;
@property (nonatomic, strong) IBOutlet UIButton* confirmButton;
@property (nonatomic, strong) IBOutlet UIButton* sliderValueButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeight;
@property (strong, nonatomic) IBOutlet UIView *toolsView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toolsViewHeight;
@property (strong, nonatomic) IBOutlet UILabel *delayTimeLabel;
@property (nonatomic, strong) HMSegmentedControl* switchModeSegmentedControl;
@property (nonatomic, strong) HMSegmentedControl* switchDirectionSegmentedControl;

@end

@implementation DPLinkCollectViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseState];
  [self configBaseUI];
  [self configBaseData];
  [self bindActions];
}

#pragma mark - State
- (void)configBaseState {
  [self setPageMark:NSStringFromClass(self.class)];
  // reset pageViewModels selected state
  for (int i = 0; i < [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count; i++) {
    DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[i];
    if (i == [DPMainManager sharedDPMainManager].currentMaskViewModel.linkIndex) {
      [pageViewModel setSelected:YES];
    } else {
      [pageViewModel setSelected:NO];
    }
  }
}

#pragma mark - UI
- (void)configBaseUI {
  [_confirmButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:18.f]];
  [_confirmButton setTitle:@"\U0000ea10" forState:UIControlStateNormal];
  [_delayTimeLabel setText:NSLocalizedString(@"Delay Time", @"")];
  [_sliderValueButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:18.f]];
  [_sliderValueButton setBackgroundColor:MAIN_GREEN_COLOR];
  [_sliderValueButton setTitle:NSLocalizedString(@"Value", @"") forState:UIControlStateNormal];
  [_linkCollectionView registerNib:[UINib nibWithNibName:@"DPPhotoCollectionViewCell" bundle:nil]
        forCellWithReuseIdentifier:kPhotoCellIdentifier];
  _flowLayout.itemSize = CGSizeMake([DPMainManager sharedDPMainManager].photoCellSize.width,
                                    [DPMainManager sharedDPMainManager].photoCellSize.height);

  _switchModeSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                                 @[NSLocalizedString(@"push", @""),
                                   NSLocalizedString(@"cover", @""),
                                   NSLocalizedString(@"uncover", @"")]];
  [_switchModeSegmentedControl setSelectionIndicatorHeight:4.0f];
  [_switchModeSegmentedControl setBackgroundColor:MAIN_BLUE_COLOR];
  [_switchModeSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
  [_switchModeSegmentedControl setSelectionIndicatorColor:MAIN_RED_COLOR];
  [_switchModeSegmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
  _switchModeSegmentedControl.selectionIndicatorBoxOpacity = 1.0;
  [_switchModeSegmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationNone];
  [_switchModeSegmentedControl setSegmentEdgeInset:UIEdgeInsetsMake(0, 6, 0, 6)];
  [_switchModeSegmentedControl setFrame:CGRectMake(0, 28.5f, SCREEN_WIDTH, 30.f)];
  [_switchModeSegmentedControl setSelectedSegmentIndex:[DPMainManager sharedDPMainManager].currentMaskViewModel.switchMode];
  [_toolsView addSubview:_switchModeSegmentedControl];
  
  _switchDirectionSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                                      @[NSLocalizedString(@"none", @""),
                                        NSLocalizedString(@"up", @""),
                                        NSLocalizedString(@"down", @""),
                                        NSLocalizedString(@"left", @""),
                                        NSLocalizedString(@"right", @"")]];
  [_switchDirectionSegmentedControl setSelectionIndicatorHeight:4.0f];
  [_switchDirectionSegmentedControl setBackgroundColor:MAIN_GREEN_COLOR];
  [_switchDirectionSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
  [_switchDirectionSegmentedControl setSelectionIndicatorColor:MAIN_RED_COLOR];
  [_switchDirectionSegmentedControl setSelectionIndicatorLocation: HMSegmentedControlSelectionIndicatorLocationDown];
  [_switchDirectionSegmentedControl setSegmentEdgeInset:UIEdgeInsetsMake(0, 6, 0, 6)];
  [_switchDirectionSegmentedControl setFrame:CGRectMake(0, 58.5f, SCREEN_WIDTH, 30.f)];
  [_switchDirectionSegmentedControl setSelectedSegmentIndex:[DPMainManager sharedDPMainManager].currentMaskViewModel.switchDirection];
  [_toolsView addSubview:_switchDirectionSegmentedControl];
  
  [_delayTimeSlider setThumbImage:[DPImageUtils generateHandleImageWithColor:[UIColor redColor]]
                         forState:UIControlStateNormal];
  _delayTimeSlider.popUpViewCornerRadius = 0;
  [_delayTimeSlider setMaxFractionDigitsDisplayed:0];
  _delayTimeSlider.popUpViewColor = [UIColor colorWithHue:0.55f
                                               saturation:0.8f
                                               brightness:0.9f
                                                    alpha:0.7f];
  _delayTimeSlider.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
  _delayTimeSlider.textColor = [UIColor colorWithHue:0.55f
                                          saturation:1.f
                                          brightness:0.5f
                                               alpha:1.f];
  _delayTimeSlider.dataSource = self;
  _delayTimeSlider.value = [DPMainManager sharedDPMainManager].currentMaskViewModel.animationDelayTime;
  [self.view bringSubviewToFront:self.delayTimeSlider];
  
  if ([DPDeviceUtils checkIfDeviceHasBangs]) {
    self.navigationBarHeight.constant = 44 + 44;
    self.toolsViewHeight.constant = 88 + 20;
  }
}

#pragma mark - Data
- (void)configBaseData {

}

#pragma mark - Actions
- (void)bindActions {
  [_switchModeSegmentedControl setIndexChangeBlock:^(NSInteger index) {
    [[DPMainManager sharedDPMainManager].currentMaskViewModel setSwitchMode:index];
  }];
  [_switchDirectionSegmentedControl setIndexChangeBlock:^(NSInteger index) {
    [[DPMainManager sharedDPMainManager].currentMaskViewModel setSwitchDirection:index];
  }];
}

- (IBAction)backAction:(id)sender {
  NSInteger preLinkedIndex = [DPMainManager sharedDPMainManager].currentMaskViewModel.linkIndex;
  DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[preLinkedIndex];
  [pageViewModel setSelected:NO];
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmAction:(id)sender {
  NSInteger preLinkedIndex = [DPMainManager sharedDPMainManager].currentMaskViewModel.linkIndex;
  DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[preLinkedIndex];
  [pageViewModel setSelected:NO]; // TODO: clean
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sliderValueAction:(id)sender {
  SCLAlertView *sliderValueAlertView = [[SCLAlertView alloc] init];
  UITextField *textField = [sliderValueAlertView addTextField:NSLocalizedString(@"Delay time", @"")];
  [sliderValueAlertView addButton:NSLocalizedString(@"OK", @"")
                      actionBlock:^(void) {
                        if ([textField.text isValid] && [textField.text containsFloat]) {
                          float tempFloat = [textField.text floatValue];
                          if (tempFloat >= 0 && tempFloat <= 5.0) {
                            self.delayTimeSlider.value = [textField.text floatValue];
                          } else {
                            SCLAlertView *alert = [[SCLAlertView alloc] init];
                            [alert showError:self
                                       title:NSLocalizedString(@"Hold On...", @"")
                                    subTitle:NSLocalizedString(@"Please input a float between 0 and 5", @"")
                            closeButtonTitle:NSLocalizedString(@"OK", @"")
                                    duration:0.0f];
                          }
                        }
                      }];
  [sliderValueAlertView showEdit:self
                           title:NSLocalizedString(@"Input", @"")
                        subTitle:NSLocalizedString(@"Delay Time", @"")
                closeButtonTitle:NSLocalizedString(@"Cancel", @"")
                        duration:0.0f];
}

#pragma mark UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  DPPhotoCollectionViewCell* photoCollectionViewCell = [collectionView
                                                        dequeueReusableCellWithReuseIdentifier:@"DPPhotoCollectionViewCell"
                                                        forIndexPath:indexPath];
  if (photoCollectionViewCell) {
    DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[indexPath.row];
    [photoCollectionViewCell bindData:pageViewModel];
    return photoCollectionViewCell;
  }
  return [[UICollectionViewCell alloc] init];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger preLinkedIndex = [DPMainManager sharedDPMainManager].currentMaskViewModel.linkIndex;
  if (preLinkedIndex > [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count - 1) {
    preLinkedIndex = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count - 1;
  }
  DPPageViewModel *preLinkedPageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[preLinkedIndex];
  [preLinkedPageViewModel setSelected:NO];
  DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[indexPath.row];
  [pageViewModel setSelected:YES];
  [[DPMainManager sharedDPMainManager].currentMaskViewModel setLinkIndex:indexPath.row];
}

#pragma mark ASValueTrackingSliderDataSource
- (NSString *)slider:(ASValueTrackingSlider *)slider
     stringForValue:(float)value {
  [[DPMainManager sharedDPMainManager].currentMaskViewModel setAnimationDelayTime:value];
  NSString *string = [NSString stringWithFormat:@"%@:%.2fs", NSLocalizedString(@"delay", @""), value];
  return string;
}

@end
