//
//  DPDrawerViewController.h
//  DasPrototyp
//
//  Created by HongliYu on 16/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPDrawerControllerChild;
@protocol DPDrawerControllerPresenting;

@interface DPDrawerViewController : UIViewController

@property(nonatomic, strong, readonly) UIViewController<DPDrawerControllerChild, DPDrawerControllerPresenting> *leftViewController;
@property(nonatomic, strong, readonly) UIViewController<DPDrawerControllerChild, DPDrawerControllerPresenting> *centerViewController;

- (id)initWithLeftViewController:(UIViewController<DPDrawerControllerChild, DPDrawerControllerPresenting> *)leftViewController
            centerViewController:(UIViewController<DPDrawerControllerChild, DPDrawerControllerPresenting> *)centerViewController;

- (void)open;
- (void)close;
- (void)reloadCenterViewControllerUsingBlock:(void (^)(void))reloadBlock;
- (void)replaceCenterViewControllerWithViewController:(UIViewController<DPDrawerControllerChild, DPDrawerControllerPresenting> *)viewController;

@end

@protocol DPDrawerControllerChild <NSObject>

@property(nonatomic, weak) DPDrawerViewController *drawer;

@end

@protocol  DPDrawerControllerPresenting <NSObject>

@optional

- (void)drawerControllerWillOpen:(DPDrawerViewController *)drawerController;
- (void)drawerControllerDidOpen:(DPDrawerViewController *)drawerController;
- (void)drawerControllerWillClose:(DPDrawerViewController *)drawerController;
- (void)drawerControllerDidClose:(DPDrawerViewController *)drawerController;

@end
