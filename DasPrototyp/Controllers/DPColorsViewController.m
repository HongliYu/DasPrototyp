//
//  DPColorsViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-7-9.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPColorsViewController.h"
#import "DPPlainColorViewController.h"
#import "DPHomeViewController.h"
#import "DPSupportViewController.h"

static NSString *const kICSColorsViewControllerCellReuseId = @"kICSColorsViewControllerCellReuseId";

@interface DPColorsViewController ()

@property (strong, nonatomic) NSArray *colors;
@property (assign, nonatomic) NSInteger lastRow;

@end

@implementation DPColorsViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (id)initWithColors:(NSArray *)colors {
  NSParameterAssert(colors);
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    _colors = colors;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.tableView registerClass:[UITableViewCell class]
         forCellReuseIdentifier:kICSColorsViewControllerCellReuseId];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.tableView setBackgroundColor:MAIN_GREEN_COLOR];
}

#pragma mark - Configuring the view’s layout behavior
- (UIStatusBarStyle)preferredStatusBarStyle {
  // Even if this view controller hides the status bar, implementing this method
  // is still needed to match the center view controller's
  // status bar style to avoid a flicker when the drawer is dragged and then
  // left to open.
  return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  NSParameterAssert(self.colors);
  return self.colors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSParameterAssert(self.colors);
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICSColorsViewControllerCellReuseId
                                                          forIndexPath:indexPath];
  DPLeftViewControllerCellState cellState = indexPath.row;
  switch (cellState) {
    case DPLeftViewControllerCellProjects: {
      cell.textLabel.text = NSLocalizedString(@"Projects", @"");
      break;
    }
    case DPLeftViewControllerCellSupport: {
      cell.textLabel.text = NSLocalizedString(@"Support", @"");
      break;
    }
    case DPLeftViewControllerCellRate: {
      cell.textLabel.text = NSLocalizedString(@"Rate This App", @"");
      break;
    }
    case DPLeftViewControllerCellDonate: {
      cell.textLabel.text = NSLocalizedString(@"Donate", @"");
      break;
    }
  }
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.textLabel.font = [UIFont boldSystemFontOfSize:20.f];
  cell.backgroundColor = self.colors[indexPath.row];
  return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.row == self.lastRow) {
    // Close the drawer without no further actions on the center view controller
    [self.drawer close];
  } else {
    // Reload the current center view controller and update its background color
    //        typeof(self) __weak weakSelf = self;
    //        [self.drawer reloadCenterViewControllerUsingBlock:^(){
    //            NSParameterAssert(weakSelf.colors);
    //            weakSelf.drawer.centerViewController.view.backgroundColor =
    //            weakSelf.colors[indexPath.row];
    //
    //        }];

    // Replace the current center view controller with a new one
    //        DPPlainColorViewController *center = [[DPPlainColorViewController
    //        alloc] init];
    //        center.view.backgroundColor = self.colors[indexPath.row];
    //        [self.drawer
    //        replaceCenterViewControllerWithViewController:center];

    DPLeftViewControllerCellState cellState = indexPath.row;
    switch (cellState) {
      case DPLeftViewControllerCellProjects: {
        DPHomeViewController *center = [[DPHomeViewController alloc] initWithNibName:@"DPHomeViewController"
                                                                              bundle:nil];
        [self.drawer replaceCenterViewControllerWithViewController:center];
        break;
      }
      case DPLeftViewControllerCellSupport: {
        DPSupportViewController *supportVC = [[DPSupportViewController alloc] init];
        supportVC.view.backgroundColor = self.colors[indexPath.row];
        [self.drawer replaceCenterViewControllerWithViewController:supportVC];
        break;
      }
      case DPLeftViewControllerCellRate: {
        NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", @"910117892"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        break;
      }
      case DPLeftViewControllerCellDonate: {
        NSURL *targetURL = [NSURL URLWithString:@"https://qr.alipay.com/apeez0tpttrt2yove2"];
        [[UIApplication sharedApplication] openURL:targetURL options:@{} completionHandler:nil];
        break;
      }
    }
  }
  self.lastRow = indexPath.row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return [DPMainManager sharedDPMainManager].leftVCCellHeight + 20.f;
  }
  return [DPMainManager sharedDPMainManager].leftVCCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 44.0f;
}

#pragma mark - ICSDrawerControllerPresenting
- (void)drawerControllerWillOpen:(DPDrawerViewController *)drawerController {
  self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidOpen:(DPDrawerViewController *)drawerController {
  self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerWillClose:(DPDrawerViewController *)drawerController {
  self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(DPDrawerViewController *)drawerController {
  self.view.userInteractionEnabled = YES;
}

@end
