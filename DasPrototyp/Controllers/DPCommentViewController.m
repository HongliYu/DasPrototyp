//
//  DPCommentViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-8-19.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPCommentViewController.h"
#import "ACEExpandableTextCell.h"
#import "DPMainViewModel.h"

@interface DPCommentViewController () <ACEExpandableTableViewDelegate>

@property(strong, nonatomic) IBOutlet UIButton *backButton;
@property(strong, nonatomic) IBOutlet UITableView *commentTableView;
@property(assign, nonatomic) CGFloat cellHeight;
@property(strong, nonatomic) SZTextView *commentTextView;
@property(copy, nonatomic) NSString *commentText;

@end

@implementation DPCommentViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseUI];
  [self configBaseData];
  [self bindActions];
  [self addNotifications];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Notifications
- (void)addNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShown:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHidden:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)keyboardWillShown:(NSNotification *)notification {
  NSDictionary *info = [notification userInfo];
  NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGSize keyboardSize = [value CGRectValue].size;
  NSLog(@"shown keyBoard height :%f", keyboardSize.height);
  self.commentTableView.height = SCREEN_HEIGHT - 44.f - keyboardSize.height;
  if (self.cellHeight - self.commentTableView.height > 0) {
    [self.commentTableView setContentOffset:CGPointMake(0, self.cellHeight - self.commentTableView.height)
                                   animated:YES];
  }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
//  NSDictionary *info = [notification userInfo];
//  NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
//  CGSize keyboardSize = [value CGRectValue].size;
//  DLog(@"hidden keyBoard height :%f", keyboardSize.height);
  self.commentTableView.height = SCREEN_HEIGHT - 44.f;
}

#pragma mark - UI
- (void)configBaseUI {
  CGSize size = [DPCommonUtils rectSizeWithText:self.commentText
                                    andFontSize:18.f];
  self.cellHeight = size.height;
}

#pragma mark - Data
- (void)configBaseData {
  
}

#pragma mark - Actions
- (void)bindActions {

}

- (IBAction)backAction:(id)sender {
  DPMainViewModel *mainViewModel = [DPMainManager sharedDPMainManager].currentMainViewModel;
  if ([self.commentText isValid]) {
    [[DPMainManager sharedDPMainManager] updateMainViewModel:mainViewModel
                                                 withComment:self.commentText];
  }
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ACEExpandableTextCell *cell = [tableView expandableTextCellWithId:@"cellId"];
  cell.textView.placeholder = NSLocalizedString(@"Describe the project", @"");
  self.commentTextView = cell.textView;
  cell.text = self.commentText;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return MAX(50.f, self.cellHeight);
}

- (void)tableView:(UITableView *)tableView
    updatedHeight:(CGFloat)height
      atIndexPath:(NSIndexPath *)indexPath {
  self.cellHeight = height;
}

- (void)tableView:(UITableView *)tableView
      updatedText:(NSString *)text
      atIndexPath:(NSIndexPath *)indexPath {
  self.commentText = text;
}

@end
