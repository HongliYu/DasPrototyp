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

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self loadBaseData];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseUI];
}

- (void)configBaseUI {
  self.preferredContentSize = CGSizeZero;
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
  [self.view addSubview:self.loadingView];
  [self.loadingView setHidden:NO];

  [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@20.f);
  }];
  [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(@0);
    make.top.equalTo(@0);
    make.width.equalTo(@(SCREEN_WIDTH));
    make.height.equalTo(@20.f);
  }];
  
}

- (void)loadBaseData {
  DPNetworkService *networkService = [[DPNetworkService alloc] init];
  [networkService requestAphorismsCompletion:^(id result, NSError *error) {
    // parse data
    if ([result isKindOfClass:[NSDictionary class]]) {
      NSDictionary *retDictionary = (NSDictionary *)result;
      NSNumber *code = [retDictionary objectForKey:@"code"];
      NSString *msg = [retDictionary objectForKey:@"msg"];
      if ([code integerValue] == 200 && [msg isEqualToString:@"success"]) {
        NSObject *retArrayObject = [retDictionary objectForKey:@"newslist"];
        if ([retArrayObject isKindOfClass:[NSArray class]]) {
          NSArray *newslistArray = (NSArray *)retArrayObject;
          NSObject *newslistFirstItem = [newslistArray firstObject];
          if ([newslistFirstItem isKindOfClass:[NSDictionary class]]) {
            NSDictionary *newslistDictionary = (NSDictionary *)newslistFirstItem;
            DPAphorismsModel *aphorismsModel = [[DPAphorismsModel alloc] initWithDictionary:newslistDictionary];
            // update UI
            [self updateUIWithData:aphorismsModel];
          }
        }
      }
    }
    [self.loadingView setHidden:YES];
  }];
}

- (void)updateUIWithData:(DPAphorismsModel *)aphorismsModel {
  self.contentLabel.text = [NSString stringWithFormat:@"“%@” <<< %@ ",
                            aphorismsModel.content, aphorismsModel.mrname];
  CGSize contentSize = [DPCommonUtils rectSizeWithText:self.contentLabel.text
                                           andFontSize:18.f];
  [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@(contentSize.height + 4.f));
  }];
  [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(@0);
    make.top.equalTo(@0);
    make.width.equalTo(@(SCREEN_WIDTH));
    make.height.equalTo(@(contentSize.height));
  }];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
  return UIEdgeInsetsMake(0, 0, 0, 0);
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
