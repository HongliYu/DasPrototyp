//
//  DPPhotoCollectViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-3-10.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPPhotoCollectViewController.h"
#import "DPPhotoCollectionViewCell.h"
#import "DPTakePhotosViewController.h"
#import "DPPhotoDetailsViewController.h"
#import "DPPlayViewController.h"
#import "DPCommentViewController.h"
#import "DPImageCrop.h"
#import "DPMainViewModel.h"
#import "DPPageViewModel.h"

@interface DPPhotoCollectViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DPImageCropDelegate>

// normal mode
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *takePhotoButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *albumButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *palyButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentButtonWidth;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *albumButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) IBOutlet UIView *normalOptionsView;
@property (weak, nonatomic) IBOutlet UILabel *photoCollectionTitleLabel;

// edit mode
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replaceButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonWidth;
@property (strong, nonatomic) IBOutlet UIView *editOptionsView;
@property (strong, nonatomic) IBOutlet UIButton *repalceButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation DPPhotoCollectViewController

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
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

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (void)dealloc {
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - State
- (void)configBaseState {
  [[DPMainManager sharedDPMainManager] setCollectState:DPCollectStateNormal];
  [self setPageMark:NSStringFromClass(self.class)];
}

#pragma mark - UI
- (void)configBaseUI {
  [self.photoCollectionTitleLabel setText:[DPMainManager sharedDPMainManager].currentMainViewModel.title];
  // edit mode
  [self.repalceButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:28.f]];
  [self.deleteButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:28.f]];
  [self.repalceButton setTitle:@"\U0000e90e" forState:UIControlStateNormal];
  [self.deleteButton setTitle:@"\U0000e9ac" forState:UIControlStateNormal];

  // normal mode
  self.takePhotoButtonWidth.constant = self.albumButtonWidth.constant
  = self.palyButtonWidth.constant = self.commentButtonWidth.constant = SCREEN_WIDTH / 4.f;
  self.deleteButtonWidth.constant = self.replaceButtonWidth.constant = SCREEN_WIDTH / 2.f;
  
  [self.takePhotoButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:28.f]];
  [self.albumButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:28.f]];
  [self.playButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:28.f]];
  [self.commentButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:28.f]];
  
  [self.takePhotoButton setTitle:@"\U0000e90f" forState:UIControlStateNormal];
  [self.albumButton setTitle:@"\U0000e927" forState:UIControlStateNormal];
  [self.playButton setTitle:@"\U0000e929" forState:UIControlStateNormal];
  [self.commentButton setTitle:@"\U0000e926" forState:UIControlStateNormal];
  
  [self.photoCollectionView registerNib:[UINib nibWithNibName:@"DPPhotoCollectionViewCell" bundle:nil]
             forCellWithReuseIdentifier:kPhotoCellIdentifier];
//  [self.photoCollectionView registerClass:[DPPhotoCollectionViewCell class]
//               forCellWithReuseIdentifier:kPhotoCellIdentifier];
  self.flowLayout.itemSize = CGSizeMake([DPMainManager sharedDPMainManager].photoCellSize.width,
                                        [DPMainManager sharedDPMainManager].photoCellSize.height);
}

#pragma mark - Data
- (void)configBaseData {
  DPMainManager *mainManager = [DPMainManager sharedDPMainManager];
  [mainManager configBaseDataWithPageMark:self.pageMark];
  [self.photoCollectionView setHidden:YES]; // hide the view before data is ready
  [mainManager restorePageViewModelsWithMainViewModelID:mainManager.currentMainViewModel.identifier
                                             completion:^(BOOL finished) {
                                               if (finished) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                   [self.photoCollectionView reloadData];
                                                   [self.photoCollectionView setHidden:NO];
                                                 });
                                               }
                                             }];
}

#pragma mark - Actions
- (void)bindActions {
  [[DPMainManager sharedDPMainManager] setTakePhotoActionCallBack:^{ // TODO: 与照片剪切以后的数据处理合并
    if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateNormal) {
      dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        [self.photoCollectionView performBatchUpdates:^{
          __strong typeof(self) strongSelf = weakSelf;
          NSIndexPath *addedIndexPath = [NSIndexPath indexPathForRow:
                                         [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count - 1
                                                           inSection:0];
          NSArray *addedItemsIndexPaths = @[addedIndexPath];
          [strongSelf.photoCollectionView insertItemsAtIndexPaths:addedItemsIndexPaths];
        } completion:^(BOOL finished) {
          ;
        }];
      });
    }
    if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateEdit) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:
                                          [DPMainManager sharedDPMainManager].selecedIndexInEditMode inSection:0];
        DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
        DPPhotoCollectionViewCell *selectedCell = (DPPhotoCollectionViewCell *)[self.photoCollectionView cellForItemAtIndexPath:selectedIndexPath];
        [selectedCell bindData:pageViewModel];
        [SVProgressHUD dismiss];
      });
    }
  }];
}

- (IBAction)backAction:(id)sender {
  if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateEdit) {
    [self exitEditMode];
  }
  [[DPMainManager sharedDPMainManager] persistMainViewModel];
  // TODO: clean reference tree
  [DPMainManager sharedDPMainManager].currentMainViewModel = nil;
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)exitEditMode {
  [self.editButton setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
  [self.normalOptionsView setHidden:NO];
  [self.editOptionsView setHidden:YES];
  DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
  [pageViewModel setSelected:NO];
  [[DPMainManager sharedDPMainManager] setSelecedIndexInEditMode:0];
}

- (void)enterEditMode {
  [self.editButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
  [self.normalOptionsView setHidden:YES];
  [self.editOptionsView setHidden:NO];
  [[DPMainManager sharedDPMainManager] setSelecedIndexInEditMode:0];
  DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
  [pageViewModel setSelected:YES];
}

- (IBAction)editAction:(id)sender {
  if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateNormal) {
    [self enterEditMode];
  }
  if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateEdit) {
    [self exitEditMode];
  }
  [[DPMainManager sharedDPMainManager] setCollectState:![DPMainManager sharedDPMainManager].collectState];
}

- (IBAction)takePhotoAction:(id)sender {
  DPTakePhotosViewController *takePhotoViewController = [[DPTakePhotosViewController alloc] init];
  [self.navigationController pushViewController:takePhotoViewController animated:YES];
}

- (IBAction)albumAction:(id)sender {
  UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.delegate = self;
//  imagePickerController.allowsEditing = YES;
//  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
  [self presentViewController:imagePickerController
                     animated:YES
                   completion:^{
                     ;
                   }];
}

- (IBAction)playAction:(id)sender {
  DPPlayViewController *playViewController = [[DPPlayViewController alloc] init];
  [self.navigationController pushViewController:playViewController
                                       animated:YES];
}

- (IBAction)commentAction:(id)sender {
  DPCommentViewController *commentViewController = [[DPCommentViewController alloc] init];
  [self.navigationController pushViewController:commentViewController
                                       animated:YES];
}

- (IBAction)replaceAction:(id)sender {
  if (![[DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels firstObject]) {
    return;
  }
  PSTAlertController *controller = [PSTAlertController actionSheetWithTitle:nil];
  [controller addAction:[PSTAlertAction actionWithTitle:@"Album"
                                                  style:PSTAlertActionStyleDestructive
                                                handler:^(PSTAlertAction * _Nonnull action) {
                                                  [self albumAction:self];
                                                }]];
  [controller addAction:[PSTAlertAction actionWithTitle:@"Take Photo"
                                                  style:PSTAlertActionStyleDestructive
                                                handler:^(PSTAlertAction * _Nonnull action) {
                                                  [self takePhotoAction:self];
                                                }]];
  [controller addCancelActionWithHandler:nil];
  [controller showWithSender:sender
              arrowDirection:UIPopoverArrowDirectionAny
                  controller:self
                    animated:YES
                  completion:nil];
}

- (IBAction)deleteAction:(id)sender {
  if (![[DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels firstObject]) {
    return;
  }
  __weak typeof(self) weakSelf = self;
  [self.photoCollectionView performBatchUpdates:^{
    __strong typeof(self) strongSelf = weakSelf;
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:[DPMainManager sharedDPMainManager].selecedIndexInEditMode
                                                        inSection:0];
    NSArray *selectedItemsIndexPaths = @[selectedIndexPath];
    DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
    [[DPMainManager sharedDPMainManager] removePageViewModel:pageViewModel];
    [strongSelf.photoCollectionView deleteItemsAtIndexPaths:selectedItemsIndexPaths];
  } completion:^(BOOL finished) {
    if (finished) {
      if ([DPMainManager sharedDPMainManager].selecedIndexInEditMode >= 0) {
        if ([DPMainManager sharedDPMainManager].selecedIndexInEditMode
            > [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count) {
          [[DPMainManager sharedDPMainManager] setSelecedIndexInEditMode:
           [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count - 1];
        }
        DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
        [pageViewModel setSelected:YES];
      }
    }
  }];
}

#pragma mark UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  if (section == 0) {
    DLog(@"### %lu", (unsigned long)[DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count);
    return [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count;
  }
  return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  DPPhotoCollectionViewCell *photoCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier
                                                                                                 forIndexPath:indexPath];
  if (photoCollectionViewCell) {
    DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[indexPath.row];
    [photoCollectionViewCell bindData:pageViewModel];
  }
  return photoCollectionViewCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateNormal) {
    DPPhotoDetailsViewController *photoDetailsViewController = [[DPPhotoDetailsViewController alloc] init];
    [[DPMainManager sharedDPMainManager] setCurrentPageViewModel:
     [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[indexPath.row]];
    [self.navigationController pushViewController:photoDetailsViewController animated:YES];
  }
  if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateEdit) {
    DPPageViewModel *preSelectedPageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
    [preSelectedPageViewModel setSelected:NO];
    DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels[indexPath.row];
    [pageViewModel setSelected:YES];
    [[DPMainManager sharedDPMainManager] setSelecedIndexInEditMode:indexPath.row];
  }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [[UIApplication sharedApplication] setStatusBarHidden:YES]; // TODO: UIImagepicker custom design
  DPImageCrop *imageCrop = [[DPImageCrop alloc] init];
  imageCrop.delegate = self;
  imageCrop.ratioOfWidthAndHeight = SCREEN_PROPORTION;
  imageCrop.image = [info objectForKey:UIImagePickerControllerOriginalImage];
  
  [self dismissViewControllerAnimated:YES
                           completion:^{
                             if (imageCrop) {
                               [imageCrop showWithAnimation:YES];
                             }
                           }];
}

// 点击Cancel按钮后执行方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self dismissViewControllerAnimated:YES
                           completion:^{
                             [[UIApplication sharedApplication] setStatusBarHidden:YES];
                           }];
}

#pragma mark - crop delegate
- (void)cropImage:(UIImage *)cropImage
 forOriginalImage:(UIImage *)originalImage { // TODO: move to business router
  [SVProgressHUD show];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    NSData *compressedImageData = [DPImageUtils compressImage:cropImage];
    if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateNormal) {
      [[DPMainManager sharedDPMainManager] createCacheOnDiskWithImageData:compressedImageData];
      dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        [self.photoCollectionView performBatchUpdates:^{
          __strong typeof(self) strongSelf = weakSelf;
          NSIndexPath *addedIndexPath = [NSIndexPath indexPathForRow:
                                         [DPMainManager sharedDPMainManager].currentMainViewModel.pageViewModels.count - 1
                                                           inSection:0];
          NSArray *addedItemsIndexPaths = @[addedIndexPath];
          [strongSelf.photoCollectionView insertItemsAtIndexPaths:addedItemsIndexPaths];
        } completion:^(BOOL finished) {
          [SVProgressHUD dismiss];
        }];
      });
    }
    if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateEdit) {
      DPPageViewModel *selectedPageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
      NSString *imageName = selectedPageViewModel.imageName;
      [[DPMainManager sharedDPMainManager] replaceCachedImageDataWithImageData:compressedImageData
                                                                     imageName:imageName];
      dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:
                                          [DPMainManager sharedDPMainManager].selecedIndexInEditMode inSection:0];
        DPPageViewModel *pageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
        DPPhotoCollectionViewCell *selectedCell = (DPPhotoCollectionViewCell *)[self.photoCollectionView cellForItemAtIndexPath:selectedIndexPath];
        [selectedCell bindData:pageViewModel];
        [SVProgressHUD dismiss];
      });
    }
  });
}

#pragma mark - Notifications
- (void)addNotifications {

}

#pragma mark - Business
- (void)configBusinessRouter {
  
}

@end
