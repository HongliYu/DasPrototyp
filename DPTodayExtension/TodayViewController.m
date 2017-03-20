//
//  TodayViewController.m
//  DPTodayExtension
//
//  Created by HongliYu on 16/6/23.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "DPNetworkService.h"
#import "DPBlockCallBackHeader.h"
#import "DPAphorismsModel.h"
#import "NSString+Additions.h"
#import "DPCommonUtils.h"
#import "UIViewAdditions.h"
#import "DPMainMacro.h"
#import "Masonry.h"

@interface TodayViewController () <NCWidgetProviding>

@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UILabel *loadingView;

@end

@implementation TodayViewController

//- (void)loadView {
//  self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
//}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self refreshRequest];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseUI];
}

- (void)configBaseUI {

  self.preferredContentSize = CGSizeMake(0, 0);
  [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  self.contentLabel = [[UILabel alloc] init];
  self.contentLabel.numberOfLines = 0;
  [self.contentLabel setFont:[UIFont systemFontOfSize:16.f]];
  [self.contentLabel setTextColor:[UIColor lightTextColor]];
  [self.contentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.view addSubview:self.contentLabel];
  
  self.loadingView = [[UILabel alloc] init];
  self.loadingView.text = NSLocalizedString(@"loading...", @"");
  [self.loadingView setFont:[UIFont systemFontOfSize:18.f]];
  [self.loadingView setTextColor:[UIColor lightTextColor]];
  [self.loadingView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.loadingView setHidden:NO];
  [self.view addSubview:self.loadingView];
  
  [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@20);
  }];

  [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(@0);
    make.top.equalTo(@0);
    make.width.equalTo(@(SCREEN_WIDTH));
    make.height.equalTo(@0);
  }];
  
  NSString *version = [UIDevice currentDevice].systemVersion;
  if (version.doubleValue >= 10.0) {
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
  }
  
}

- (void)refreshRequest {
  DPNetworkService *networkService = [[DPNetworkService alloc] init];
  [networkService requestAphorismsCompletion:^(id result, NSError *error) {
    // parse data
    if ([result isKindOfClass:[NSArray class]]) {
      NSArray *retArray = (NSArray *)result;
      if (retArray.firstObject != nil) {
        if ([retArray.firstObject isKindOfClass:[NSDictionary class]]) {
          NSDictionary *retDictionary = (NSDictionary* )retArray.firstObject;
          DPAphorismsModel *aphorismsModel = [[DPAphorismsModel alloc] initWithDictionary:retDictionary];
          // update UI
          [self updateUIWithData:aphorismsModel];
        }
      }
    }
    [self.loadingView setHidden:YES];
  }];
}

- (void)updateUIWithData:(DPAphorismsModel *)aphorismsModel {
  NSString *filteredContent =  [self removeHTML: aphorismsModel.content];
  self.contentLabel.text = [NSString stringWithFormat:@"%@ <<< %@ ", filteredContent, aphorismsModel.title];
  CGSize contentSize = [DPCommonUtils rectSizeWithText:self.contentLabel.text
                                           andFontSize:18.f];
  [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@(contentSize.height));
  }];
  [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(@18);
    make.top.equalTo(@0);
    make.width.equalTo(@(SCREEN_WIDTH - 18 * 2));
    make.height.equalTo(@(contentSize.height));
  }];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
  if (activeDisplayMode == NCWidgetDisplayModeCompact) {
    self.preferredContentSize = maxSize;
  } else {
    self.preferredContentSize = CGSizeMake(0, 200);
  }
}

- (NSString *)removeHTML:(NSString *)html {
  NSArray *components = [html componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  NSMutableArray *componentsToKeep = [NSMutableArray array];
  for (int i = 0; i < [components count]; i = i + 2) {
    [componentsToKeep addObject:[components objectAtIndex:i]];
  }
  NSString *plainText = [componentsToKeep componentsJoinedByString:@""];
  return plainText;
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
  return UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
  // Perform any setup necessary in order to update the view.
  
  // If an error is encountered, use NCUpdateResultFailed
  // If there's no update required, use NCUpdateResultNoData
  // If there's an update, use NCUpdateResultNewData
  completionHandler(NCUpdateResultNewData);
}

@end
