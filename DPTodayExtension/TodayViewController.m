//
//  TodayViewController.m
//  DPTodayExtension
//
//  Created by Hongli Yu on 2018/11/19.
//  Copyright © 2018 HongliYu. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "DPNetworkService.h"
#import "DPBlockCallBackHeader.h"
#import "DPAphorismsModel.h"
#import "DPCommonUtils.h"
#import "DPMainMacro.h"
#import "NSString+HTML.h"

@interface TodayViewController () <NCWidgetProviding>

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation TodayViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self refreshRequest];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseUI];
}

- (void)configBaseUI {
  self.preferredContentSize = CGSizeMake(0, 0);
  self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
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
  }];
}

- (void)updateUIWithData:(DPAphorismsModel *)aphorismsModel {
  NSString *filteredContent =  [self removeHTML: aphorismsModel.content];
  NSString *filteredTitle =  [self removeHTML: aphorismsModel.title];
  self.contentLabel.text = [NSString stringWithFormat:@"%@ <<< %@ ",
                            filteredContent.stringByDecodingHTMLEntities,
                            filteredTitle.stringByDecodingHTMLEntities];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode
                         withMaximumSize:(CGSize)maxSize {
  if (activeDisplayMode == NCWidgetDisplayModeCompact) {
    self.preferredContentSize = maxSize;
  } else {
    CGSize contentSize = [DPCommonUtils rectSizeWithText:self.contentLabel.text
                                               withWidth:(SCREEN_WIDTH - 16 * 2)
                                             andFontSize:16.f];
    self.preferredContentSize = CGSizeMake(0, contentSize.height);
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

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
  // Perform any setup necessary in order to update the view.
  
  // If an error is encountered, use NCUpdateResultFailed
  // If there's no update required, use NCUpdateResultNoData
  // If there's an update, use NCUpdateResultNewData
  completionHandler(NCUpdateResultNewData);
}

@end
