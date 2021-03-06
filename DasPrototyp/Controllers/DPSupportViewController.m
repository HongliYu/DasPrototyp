//
//  DPSupportViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-8-18.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPSupportViewController.h"
#import <MessageUI/MessageUI.h>

@interface DPSupportViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *contactMeButton;
@property (strong, nonatomic) IBOutlet UILabel *blogLabel;
@property (strong, nonatomic) IBOutlet UILabel *githubLabel;

@end

@implementation DPSupportViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseUI];
}

- (void)configBaseUI {
  UITapGestureRecognizer* tapBlog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlogAction)];
  [_blogLabel addGestureRecognizer:tapBlog];
  UITapGestureRecognizer* tapGitRepo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGitRepoAction)];
  [_githubLabel addGestureRecognizer:tapGitRepo];
}

- (void)tapBlogAction {
  NSURL *targetURL = [NSURL URLWithString:@"http://hongliyu.github.io"];
  [[UIApplication sharedApplication] openURL:targetURL options:@{} completionHandler:nil];
}

- (void)tapGitRepoAction {
  NSURL *targetURL = [NSURL URLWithString:@"https://github.com/HongliYu/DasPrototyp"];
  [[UIApplication sharedApplication] openURL:targetURL options:@{} completionHandler:nil];
}

- (IBAction)contactMeAction:(id)sender {
  Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
  if (mailClass != nil) {
    if ([mailClass canSendMail]) {
      [self displayComposerSheet];
    } else {
      [self launchMailAppOnDevice];
    }
  } else {
    [self launchMailAppOnDevice];
  }
}

- (void)displayComposerSheet {
  MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
  mailPicker.mailComposeDelegate = self;
  
  [mailPicker setSubject:@"DasPrototyp"];

  NSArray *toRecipients = [NSArray arrayWithObject:@"hongliyu90@icloud.com"];
  [mailPicker setToRecipients:toRecipients];
  
  NSString *emailBody = @"Hi Hongli:";
  [mailPicker setMessageBody:emailBody isHTML:YES];
  [self presentViewController:mailPicker
                     animated:YES
                   completion:^{
                     ;
                   }];
}

- (void)launchMailAppOnDevice {
  NSString *recipients = @"mailto:first@example.com&subject=my email!";
  NSString *body = @"&body=email body!";

  NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
  email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email] options: @{} completionHandler:nil];
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  NSString *msg;
  switch (result) {
    case MFMailComposeResultCancelled: {
      break;
    }
    case MFMailComposeResultSaved: {
      msg = @"Mail saved";
      SCLAlertView *alert = [[SCLAlertView alloc] init];
      alert.shouldDismissOnTapOutside = YES;
      [alert alertIsDismissed:^{
        ;
      }];
      [alert showInfo:self
                     title:@"Message"
                  subTitle:msg
          closeButtonTitle:@"OK"
                  duration:0.0f];
      break;
    }
    case MFMailComposeResultSent: {
      msg = @"Mail sent";
      SCLAlertView *alert = [[SCLAlertView alloc] init];
      alert.shouldDismissOnTapOutside = YES;
      [alert alertIsDismissed:^{
        ;
      }];
      [alert showInfo:self
                     title:@"Success"
                  subTitle:msg
          closeButtonTitle:@"OK"
                  duration:0.0f];
      break;
    }
    case MFMailComposeResultFailed: {
      msg = @"Mail failed";
      SCLAlertView *alert = [[SCLAlertView alloc] init];
      alert.shouldDismissOnTapOutside = YES;
      [alert alertIsDismissed:^{
        ;
      }];
      [alert showInfo:self
                     title:@"Error"
                  subTitle:msg
          closeButtonTitle:@"OK"
                  duration:0.0f];
      break;
    }
    default:
      break;
  }
  [self dismissViewControllerAnimated:YES
                           completion:^{
                             ;
                           }];
}

@end
