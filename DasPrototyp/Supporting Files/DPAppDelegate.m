//
//  hlyuAppDelegate.m
//  DasPrototyp
//
//  Created by HongliYu on 14-3-7.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPAppDelegate.h"
#import "DPHomeViewController.h"
#import "DPDrawerViewController.h"
#import "DPColorsViewController.h"
#import "DPPlainColorViewController.h"
#import "AFNetworking.h"
#import "Firebase.h"

@implementation DPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  DLog(@"%@", DOCUMENTS_DIRECTORY)
  [self configVendors];
  [self configBaseControllers];
  return YES;
}

- (void)configVendors {
  [FIRApp configure];
  [Fabric with:@[CrashlyticsKit]];
  [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)configBaseControllers {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];

  DPHomeViewController* homeVC = [[DPHomeViewController alloc] initWithNibName:@"DPHomeViewController"
                                                                        bundle:nil];
  
  NSArray *colors = @[MAIN_COLOR, MAIN_BLUE_COLOR, MAIN_PINK_COLOR, MAIN_RED_COLOR];
  DPColorsViewController *colorsVC = [[DPColorsViewController alloc] initWithColors:colors];
  DPDrawerViewController *drawer = [[DPDrawerViewController alloc] initWithLeftViewController:colorsVC
                                                                         centerViewController:homeVC];
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:drawer];
  navigationController.navigationBarHidden = YES;
  self.window.rootViewController = navigationController;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  if (url != nil && [url isFileURL]) {
    if ([[url pathExtension] isEqualToString:@"dparchive"]) {
      NSLog(@"URL:%@", [url absoluteString]);
      [[NSNotificationCenter defaultCenter] postNotificationName:@"NewSharedProject" object:self];
      [[DPMainManager sharedDPMainManager] checkNewProjectWithDirectory:@"Inbox"];
    }
  }
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [[DPMainManager sharedDPMainManager] persistMainViewModel];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
