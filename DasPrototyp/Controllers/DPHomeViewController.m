//
//  DPHomeViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-3-10.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPHomeViewController.h"
#import "DPPhotoCollectViewController.h"
#import "DPMainTableViewCell.h"
#import "DPMainViewModel.h"
#import "DPHomeBusiness.h"
#import "DPDeviceUtils.h"

@interface DPHomeViewController ()

@property (strong, nonatomic) IBOutlet UITableView *homeTableView;
@property (strong, nonatomic) IBOutlet UIButton *addNewProjectButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeight;
@property (strong, nonatomic) DPHomeBusiness *homeBusiness;

@end

@implementation DPHomeViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseState];
  [self configBusiness];
  [self configBaseUI];
  [self configBaseData];
  [self bindActions];
  [[DPMainManager sharedDPMainManager] checkIfNeedDemo];
}

#pragma mark - State
- (void)configBaseState {
  [self setPageMark:NSStringFromClass(self.class)];
}

#pragma mark - Business
- (void)configBusiness {
  _homeBusiness = [[DPHomeBusiness alloc] init];
  _homeTableView.dataSource = _homeBusiness;
  _homeTableView.delegate = _homeBusiness;
  [_homeBusiness bindHomeViewController:self];
  [_homeBusiness bindHomeTableView:self.homeTableView];
  [_homeBusiness configComponents];
}

#pragma mark - UI
- (void)configBaseUI {
  [self.addNewProjectButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont"
                                                               size:28.f]];
  [self.addNewProjectButton setTitle:@"\U0000ea0a"
                            forState:UIControlStateNormal];
  if ([DPDeviceUtils checkIfDeviceHasBangs]) {
    self.navigationBarHeight.constant = 44 + 44;
  }
}

#pragma mark - Data
- (void)configBaseData {
  [[DPMainManager sharedDPMainManager] configBaseDataWithPageMark:self.pageMark];
  [[DPMainManager sharedDPMainManager] restoreMainViewModels:^(BOOL finished) {
    if (finished) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.homeBusiness tableViewReloadData];
      });
    }
  }];
}

#pragma mark - Actions
- (void)bindActions {
  [[DPMainManager sharedDPMainManager] setAddProjectFromMailCallBack:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.homeBusiness tableViewReloadData];
    });
  }];
}

- (IBAction)addAction:(id)sender {
  SCLAlertView *addNewProjectAlertView = [[SCLAlertView alloc] init];
  UITextField *textField = [addNewProjectAlertView addTextField:NSLocalizedString(@"Project Name", @"")];
  [addNewProjectAlertView addButton:NSLocalizedString(@"OK", @"")
                        actionBlock:^(void) {
                          if (![textField.text isValid]) { // not valid
                            SCLAlertView *alertNoTitle = [[SCLAlertView alloc] init];
                            [alertNoTitle showError:self
                                              title:NSLocalizedString(@"Hold On...", @"")
                                           subTitle:NSLocalizedString(@"Name can not be empty", @"")
                                   closeButtonTitle:NSLocalizedString(@"OK", @"")
                                           duration:0.0f];
                            return;
                          }
                          // TODO:owner need signup API from server, for now it's just a placeholder
                          // create new view model
                          NSString *createdTime = [NSDate formattedDateNow];
                          NSDictionary *rawMainViewModelDictionary = @{@"id" : [NSString stringWithUUID],
                                                                       @"title" : textField.text,
                                                                       @"owner" : @"owner",
                                                                       @"thumbnail_name" : @"",
                                                                       @"comment" : NSLocalizedString(@"Describe the project", @""),
                                                                       @"created_time" : createdTime,
                                                                       @"updated_time" : createdTime};
                          DPMainViewModel *mainViewModel = [[DPMainViewModel alloc] initWithSeparatedDictionary:rawMainViewModelDictionary];
                          [[DPMainManager sharedDPMainManager] addMainViewModel:mainViewModel];
                          [self.homeBusiness tableViewAddProjectAnimated];
                        }];
  [addNewProjectAlertView showEdit:self
                             title:NSLocalizedString(@"New Project", @"")
                          subTitle:NSLocalizedString(@"Name", @"")
                  closeButtonTitle:NSLocalizedString(@"Cancel", @"")
                          duration:0.0f];
}

@end
