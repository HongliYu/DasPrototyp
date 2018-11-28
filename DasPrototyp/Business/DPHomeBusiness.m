//
//  DPHomeBusiness.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/30.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPHomeBusiness.h"
#import "DPMainTableViewCell.h"
#import "DPMainViewModel.h"
#import "DPPhotoCollectViewController.h"
#import "DPHomeViewController.h"
#import "SVPullToRefresh.h"
#import "AFNetworking.h"
#import "DPDeviceUtils.h"

@interface DPHomeBusiness()

@property (nonatomic, weak, readwrite) DPHomeViewController *homeViewController;
@property (nonatomic, weak, readwrite) UITableView *homeTableView;

@end

@implementation DPHomeBusiness

- (void)bindHomeViewController:(DPHomeViewController *)homeViewController {
  _homeViewController = homeViewController;
}

- (void)bindHomeTableView:(UITableView *)homeTableView {
  _homeTableView = homeTableView;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row <= [DPMainManager sharedDPMainManager].mainViewModels.count - 1) {
    DPMainViewModel *mainViewModel = [DPMainManager sharedDPMainManager].mainViewModels[indexPath.row];
    float optionsHeight = mainViewModel.expanded? 42.f : 0;
    return kMainCellHeightNormal + optionsHeight;
  }
  return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.row <= [DPMainManager sharedDPMainManager].mainViewModels.count - 1) {
    DPMainViewModel *mainViewModel = [DPMainManager sharedDPMainManager].mainViewModels[indexPath.row];
    [[DPMainManager sharedDPMainManager] setCurrentMainViewModel:mainViewModel];
    DPPhotoCollectViewController *photoCollectVC = [[DPPhotoCollectViewController alloc] init];
    [self.homeViewController.navigationController pushViewController:photoCollectVC
                                                            animated:YES];
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [DPMainManager sharedDPMainManager].mainViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  DPMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMainCellIdentifier];
  if (!cell) {
    cell = [[DPMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kMainCellIdentifier];
  }
  if (indexPath.row <= [DPMainManager sharedDPMainManager].mainViewModels.count) {
    DPMainViewModel *mainViewModel = [DPMainManager sharedDPMainManager].mainViewModels[indexPath.row];
    [cell bindData:mainViewModel];
    
    // cell actions
    __weak typeof(self) weakSelf = self;
    [cell setMoreAction:^{
      __strong typeof(self) strongSelf = weakSelf;
      [strongSelf.homeTableView beginUpdates];
      [strongSelf.homeTableView endUpdates];
    }];
    [cell setRenameAction:^{
      __strong typeof(self) strongSelf = weakSelf;
      SCLAlertView *renameProjectAlertView = [[SCLAlertView alloc] init];
      UITextField *textField = [renameProjectAlertView addTextField:NSLocalizedString(@"New Name", @"")];
      [renameProjectAlertView addButton:NSLocalizedString(@"OK", @"")
                            actionBlock:^(void) {
                              if (![textField.text isValid]) {
                                return;
                              }
                              [[DPMainManager sharedDPMainManager] updateMainViewModel:mainViewModel
                                                                             withTitle:textField.text];
                            }];
      [renameProjectAlertView showEdit:strongSelf.homeViewController
                                 title:NSLocalizedString(@"Rename Project", @"")
                              subTitle:NSLocalizedString(@"New Name", @"")
                      closeButtonTitle:NSLocalizedString(@"Cancel", @"")
                              duration:0.0f];
    }];
    [cell setShareAction:^{
      __strong typeof(self) strongSelf = weakSelf;
      [strongSelf shareAction:mainViewModel];
    }];
    [cell setDeleteAction:^{
      __strong typeof(self) strongSelf = weakSelf;
      [[DPMainManager sharedDPMainManager] removeMainViewModel:mainViewModel];
      [CATransaction begin];
      [CATransaction setCompletionBlock:^{
        [strongSelf.homeTableView reloadData];
      }];
      [strongSelf.homeTableView beginUpdates];
      [strongSelf.homeTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [strongSelf.homeTableView endUpdates];
      [CATransaction commit];
    }];
  }
  return cell;
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  NSString *msg = nil;
  switch (result) {
    case MFMailComposeResultCancelled: {
      break;
    }
    case MFMailComposeResultSaved: {
      msg = NSLocalizedString(@"Mail saved", @"");
      SCLAlertView *alert = [[SCLAlertView alloc] init];
      alert.shouldDismissOnTapOutside = YES;
      [alert showInfo:self.homeViewController
                title:NSLocalizedString(@"Message", @"")
             subTitle:msg
     closeButtonTitle:NSLocalizedString(@"OK", @"")
             duration:0.0f];
      break;
    }
    case MFMailComposeResultSent: {
      msg = NSLocalizedString(@"Mail sent", @"");
      SCLAlertView *alert = [[SCLAlertView alloc] init];
      alert.shouldDismissOnTapOutside = YES;
      [alert showInfo:self.homeViewController
                title:NSLocalizedString(@"Success", @"")
             subTitle:msg
     closeButtonTitle:NSLocalizedString(@"OK", @"")
             duration:0.0f];
      break;
    }
    case MFMailComposeResultFailed: {
      msg = NSLocalizedString(@"Mail failed", @"");
      SCLAlertView *alert = [[SCLAlertView alloc] init];
      alert.shouldDismissOnTapOutside = YES;
      [alert showInfo:self.homeViewController
                title:NSLocalizedString(@"Error", @"")
             subTitle:msg
     closeButtonTitle:NSLocalizedString(@"OK", @"")
             duration:0.0f];
      break;
    }
    default:
      break;
  }
  [self.homeViewController dismissViewControllerAnimated:YES completion:^{
    // TODO: clean zip archive
  }];
}

- (void)launchMailAppOnDevice {
  NSString *recipients = @"mailto:first@example.com&subject=my email!";
  NSString *body = @"&body=email body!";
  NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
  email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email] options:@{} completionHandler:nil];
}

- (void)sendEmail:(DPMainViewModel *)mainViewModel {
  Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
  if (mailClass) {
    if ([mailClass canSendMail]) {
      [self displayComposerSheet:mainViewModel];
    } else {
      [self launchMailAppOnDevice];
    }
  } else {
    [self launchMailAppOnDevice];
  }
}

- (void)displayComposerSheet:(DPMainViewModel *)mainViewModel {
  NSString *screenSize = [DPDeviceUtils checkDeviceScreen]; // TODO: 更新下载链接
  MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
  mailPicker.mailComposeDelegate = self;
  [mailPicker setSubject:[NSString stringWithFormat:@"%@ -- %@", mainViewModel.title, NSLocalizedString(@"DasPrototyp", @"")]];
  NSData *sharedData = [NSData dataWithContentsOfFile:
                        [[DPFileManager CachesDirectory]
                         stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"%@.dparchive", mainViewModel.title]]];
  
  [mailPicker addAttachmentData:sharedData
                       mimeType:@"application/DasPrototyp"
                       fileName:[NSString stringWithFormat:@"%@.dparchive", mainViewModel.title]];
  
  NSMutableString *emailBody = [NSMutableString string];
  if ([CurrentLanguage containsString:@"zh-Hans"]) {
    [emailBody appendString:@"<h2>来自DP原型的示例</h2>\n"];
    [emailBody appendString:[NSString stringWithFormat:
                             @"<div>#示例环境#</div> <div>屏幕大小: %@</div> <div>OS: %@</div>"
                             @"<div>(请确保与接收方的设备屏幕大小一致)接收方点击附件选择在DP原型中打开</div>\n",
                            screenSize, [UIDevice currentDevice].systemVersion]];
    [emailBody appendString:@"<a "
     @"href=\"https://itunes.apple.com/app/dasprototyp/"
     @"id910117892\">下载 DP原型</a>\n"];
  }
  if ([CurrentLanguage containsString:@"en"]) {
    [emailBody appendString:@"<h2>Demo From DasPrototyp</h2>\n"];
    [emailBody appendString:[NSString stringWithFormat:
                             @"<div>#Demo environment#</div>"
                             @"<div>Screen Size: %@</div> <div>OS :%@</div>"
                             @"(please make sure all receivers have the right screen size) Click the attachment and Open In DasPrototyp</div>\n",
                             screenSize, [UIDevice currentDevice].systemVersion]];
    [emailBody appendString:@"<a href=\"https://itunes.apple.com/app/dasprototyp/id910117892\">Download DasPrototyp</a>\n"];
  }
  if ([CurrentLanguage containsString:@"de"]) {
    [emailBody appendString:@"<h2>Demo von DasPrototyp</h2>\n"];
    [emailBody appendString:[NSString stringWithFormat:
                             @"<div>#Demo-Umgebung#</div>"
                             @"<div>Bildschirmgröße: %@</div> <div>OS :%@</div>"
                             @"(Vergewissern Sie sich, dass alle Empfänger die richtige Bildschirmgröße haben) Klicken Sie auf den Anhang und öffnen Sie in DasPrototyp</div>\n",
                             screenSize, [UIDevice currentDevice].systemVersion]];
    [emailBody appendString:@"<a href=\"https://itunes.apple.com/app/dasprototyp/id910117892\">Laden Sie DasPrototyp herunter</a>\n"];
  }

  [mailPicker setMessageBody:emailBody isHTML:YES];
  [self.homeViewController presentViewController:mailPicker
                                        animated:YES
                                      completion:nil];
}

- (void)shareAction:(DPMainViewModel *)mainViewModel {
  if (![AFNetworkReachabilityManager sharedManager].isReachableViaWiFi) {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:NSLocalizedString(@"I insist", @"")
         actionBlock:^{
           [[DPMainManager sharedDPMainManager] createSharedArchive:mainViewModel
                                                         completion:^(BOOL finished) {
                                                           if (finished) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                               [self sendEmail:mainViewModel];
                                                             });
                                                           }
                                                         }];
         }];
    [alert showWarning:self.homeViewController
                 title:NSLocalizedString(@"No wifi connection", @"")
              subTitle:NSLocalizedString(@"It may take you a lot of time "
                                         @"sending an email with a big "
                                         @"attachment",
                                         @"")
      closeButtonTitle:NSLocalizedString(@"I changed my mind", @"")
              duration:0];
  } else {
    [[DPMainManager sharedDPMainManager] createSharedArchive:mainViewModel
                                                  completion:^(BOOL finished) {
                                                    if (finished) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self sendEmail:mainViewModel];
                                                      });
                                                    }
                                                  }];
  }
}

- (void)tableViewAddProjectAnimated {
  [self.homeTableView beginUpdates];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[DPMainManager sharedDPMainManager].mainViewModels.count - 1 inSection:0];
  [self.homeTableView insertRowsAtIndexPaths:@[indexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
  [self.homeTableView endUpdates];
}

- (void)configComponents {
  if (self.homeTableView) {
    self.homeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.homeTableView registerNib:[UINib nibWithNibName:@"DPMainTableViewCell" bundle:nil]
             forCellReuseIdentifier:kMainCellIdentifier];
  }
  __weak typeof(self) weakSelf = self;
  [self.homeTableView addPullToRefreshWithActionHandler:^{
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf refreshMainTableViewData];
  }];
}

- (void)tableViewReloadData {
  [self.homeTableView reloadData];
  [self.homeTableView.pullToRefreshView stopAnimating];
}

- (void)refreshMainTableViewData {
  int64_t delayInSeconds = 1.f;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
    [self tableViewReloadData];
  });
}

@end
