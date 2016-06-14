//
//  DPDrawerViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 16/6/2.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPDrawerViewController.h"
#import "DPDropShadowView.h"

static const CGFloat kDPDrawerControllerDrawerDepth = 260.0f;
static const CGFloat kDPDrawerControllerLeftViewInitialOffset = -60.0f;
static const NSTimeInterval kDPDrawerControllerAnimationDuration = 0.5;
static const CGFloat kDPDrawerControllerOpeningAnimationSpringDamping = 0.7f;
static const CGFloat kDPDrawerControllerOpeningAnimationSpringInitialVelocity = 0.1f;
static const CGFloat kDPDrawerControllerClosingAnimationSpringDamping = 1.0f;
static const CGFloat kDPDrawerControllerClosingAnimationSpringInitialVelocity = 0.5f;

typedef NS_ENUM(NSUInteger, DPDrawerControllerState) {
  DPDrawerControllerStateClosed = 0,
  DPDrawerControllerStateOpening,
  DPDrawerControllerStateOpen,
  DPDrawerControllerStateClosing
};

@interface DPDrawerViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, strong, readwrite) UIViewController
<DPDrawerControllerChild, DPDrawerControllerPresenting> *leftViewController;

@property(nonatomic, strong, readwrite) UIViewController
<DPDrawerControllerChild, DPDrawerControllerPresenting> *centerViewController;

@property(nonatomic, strong) UIView *leftView;
@property(nonatomic, strong) DPDropShadowView *centerView;

@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, assign) CGPoint panGestureStartLocation;

@property(nonatomic, assign) DPDrawerControllerState drawerState;

@end



@implementation DPDrawerViewController

- (id)initWithLeftViewController:
(UIViewController<DPDrawerControllerChild, DPDrawerControllerPresenting> *)leftViewController
            centerViewController:
(UIViewController<DPDrawerControllerChild, DPDrawerControllerPresenting> *)centerViewController {
  NSParameterAssert(leftViewController);
  NSParameterAssert(centerViewController);
  self = [super init];
  if (self) {
    _leftViewController = leftViewController;
    _centerViewController = centerViewController;
    
    if ([_leftViewController respondsToSelector:@selector(setDrawer:)]) {
      _leftViewController.drawer = self;
    }
    if ([_centerViewController respondsToSelector:@selector(setDrawer:)]) {
      _centerViewController.drawer = self;
    }
  }
  return self;
}

- (void)addCenterViewController {
  NSParameterAssert(self.centerViewController);
  NSParameterAssert(self.centerView);
  
  [self addChildViewController:self.centerViewController];
  self.centerViewController.view.frame = self.view.bounds;
  [self.centerView addSubview:self.centerViewController.view];
  [self.centerViewController didMoveToParentViewController:self];
}

#pragma mark - Managing the view

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  // Initialize left and center view containers
  self.leftView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.centerView = [[DPDropShadowView alloc] initWithFrame:self.view.bounds];
  self.leftView.autoresizingMask = self.view.autoresizingMask;
  self.centerView.autoresizingMask = self.view.autoresizingMask;
  
  // Add the center view container
  [self.view addSubview:self.centerView];
  
  // Add the center view controller to the container
  [self addCenterViewController];
  
  [self setupGestureRecognizers];
}

#pragma mark - Configuring the view’s layout behavior

- (UIViewController *)childViewControllerForStatusBarHidden {
  NSParameterAssert(self.leftViewController);
  NSParameterAssert(self.centerViewController);
  
  if (self.drawerState == DPDrawerControllerStateOpening) {
    return self.leftViewController;
  }
  return self.centerViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
  NSParameterAssert(self.leftViewController);
  NSParameterAssert(self.centerViewController);
  
  if (self.drawerState == DPDrawerControllerStateOpening) {
    return self.leftViewController;
  }
  return self.centerViewController;
}

#pragma mark - Gesture recognizers

- (void)setupGestureRecognizers {
  NSParameterAssert(self.centerView);
  
  self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
  self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
  self.panGestureRecognizer.maximumNumberOfTouches = 1;
  self.panGestureRecognizer.delegate = self;
  
  [self.centerView addGestureRecognizer:self.panGestureRecognizer];
}

- (void)addClosingGestureRecognizers {
  NSParameterAssert(self.centerView);
  NSParameterAssert(self.panGestureRecognizer);
  
  [self.centerView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)removeClosingGestureRecognizers {
  NSParameterAssert(self.centerView);
  NSParameterAssert(self.panGestureRecognizer);
  
  [self.centerView removeGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark Tap to close the drawer
- (void)tapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer {
  if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    [self close];
  }
}

#pragma mark Pan to open/close the drawer
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  NSParameterAssert([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]);
  CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
  
  if (self.drawerState == DPDrawerControllerStateClosed && velocity.x > 0.0f) {
    return YES;
  }
  else if (self.drawerState == DPDrawerControllerStateOpen && velocity.x < 0.0f) {
    return YES;
  }
  return NO;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)panGestureRecognizer {
  NSParameterAssert(self.leftView);
  NSParameterAssert(self.centerView);
  
  UIGestureRecognizerState state = panGestureRecognizer.state;
  CGPoint location = [panGestureRecognizer locationInView:self.view];
  CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
  
  switch (state) {
      
    case UIGestureRecognizerStateBegan:
      self.panGestureStartLocation = location;
      if (self.drawerState == DPDrawerControllerStateClosed) {
        [self willOpen];
      }
      else {
        [self willClose];
      }
      break;
      
    case UIGestureRecognizerStateChanged: {
    CGFloat delta = 0.0f;
    if (self.drawerState == DPDrawerControllerStateOpening) {
      delta = location.x - self.panGestureStartLocation.x;
    } else if (self.drawerState == DPDrawerControllerStateClosing) {
      delta = kDPDrawerControllerDrawerDepth - (self.panGestureStartLocation.x - location.x);
    }
    CGRect l = self.leftView.frame;
    CGRect c = self.centerView.frame;
    if (delta > kDPDrawerControllerDrawerDepth) {
      l.origin.x = 0.0f;
      c.origin.x = kDPDrawerControllerDrawerDepth;
    } else if (delta < 0.0f) {
      l.origin.x = kDPDrawerControllerLeftViewInitialOffset;
      c.origin.x = 0.0f;
    } else {
      // While the centerView can move up to kDPDrawerControllerDrawerDepth points, to achieve a parallax effect
      // the leftView has move no more than kDPDrawerControllerLeftViewInitialOffset points
      l.origin.x = kDPDrawerControllerLeftViewInitialOffset
      - (delta * kDPDrawerControllerLeftViewInitialOffset) / kDPDrawerControllerDrawerDepth;
      
      c.origin.x = delta;
    }
    self.leftView.frame = l;
    self.centerView.frame = c;
    break;
    }
    case UIGestureRecognizerStateEnded:
      if (self.drawerState == DPDrawerControllerStateOpening) {
        CGFloat centerViewLocation = self.centerView.frame.origin.x;
        if (centerViewLocation == kDPDrawerControllerDrawerDepth) {
          // Open the drawer without animation, as it has already being dragged in its final position
          [self setNeedsStatusBarAppearanceUpdate];
          [self didOpen];
        } else if (centerViewLocation > self.view.bounds.size.width / 3
                 && velocity.x > 0.0f) {
          // Animate the drawer opening
          [self animateOpening];
        } else {
          // Animate the drawer closing, as the opening gesture hasn't been completed or it has
          // been reverted by the user
          [self didOpen];
          [self willClose];
          [self animateClosing];
        }
      } else if (self.drawerState == DPDrawerControllerStateClosing) {
        CGFloat centerViewLocation = self.centerView.frame.origin.x;
        if (centerViewLocation == 0.0f) {
          // Close the drawer without animation, as it has already being dragged in its final position
          [self setNeedsStatusBarAppearanceUpdate];
          [self didClose];
        } else if (centerViewLocation < (2 * self.view.bounds.size.width) / 3
                 && velocity.x < 0.0f) {
          // Animate the drawer closing
          [self animateClosing];
        } else {
          // Animate the drawer opening, as the opening gesture hasn't been completed or it has
          // been reverted by the user
          [self didClose];
          
          // Here we save the current position for the leftView since
          // we want the opening animation to start from the current position
          // and not the one that is set in 'willOpen'
          CGRect l = self.leftView.frame;
          [self willOpen];
          self.leftView.frame = l;
          
          [self animateOpening];
        }
      }
      break;
    default:
      break;
  }
}

#pragma mark - Animations
#pragma mark Opening animation
- (void)animateOpening {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateOpening);
  NSParameterAssert(self.leftView);
  NSParameterAssert(self.centerView);
  
  // Calculate the final frames for the container views
  CGRect leftViewFinalFrame = self.view.bounds;
  CGRect centerViewFinalFrame = self.view.bounds;
  centerViewFinalFrame.origin.x = kDPDrawerControllerDrawerDepth;
  
  [UIView animateWithDuration:kDPDrawerControllerAnimationDuration
                        delay:0
       usingSpringWithDamping:kDPDrawerControllerOpeningAnimationSpringDamping
        initialSpringVelocity:kDPDrawerControllerOpeningAnimationSpringInitialVelocity
                      options:UIViewAnimationOptionCurveLinear
                   animations:^{
                     self.centerView.frame = centerViewFinalFrame;
                     self.leftView.frame = leftViewFinalFrame;
                     
                     [self setNeedsStatusBarAppearanceUpdate];
                   }
                   completion:^(BOOL finished) {
                     [self didOpen];
                   }];
}

#pragma mark Closing animation
- (void)animateClosing {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateClosing);
  NSParameterAssert(self.leftView);
  NSParameterAssert(self.centerView);
  
  // Calculate final frames for the container views
  CGRect leftViewFinalFrame = self.leftView.frame;
  leftViewFinalFrame.origin.x = kDPDrawerControllerLeftViewInitialOffset;
  CGRect centerViewFinalFrame = self.view.bounds;
  
  [UIView animateWithDuration:kDPDrawerControllerAnimationDuration
                        delay:0
       usingSpringWithDamping:kDPDrawerControllerClosingAnimationSpringDamping
        initialSpringVelocity:kDPDrawerControllerClosingAnimationSpringInitialVelocity
                      options:UIViewAnimationOptionCurveLinear
                   animations:^{
                     self.centerView.frame = centerViewFinalFrame;
                     self.leftView.frame = leftViewFinalFrame;
                     
                     [self setNeedsStatusBarAppearanceUpdate];
                   }
                   completion:^(BOOL finished) {
                     [self didClose];
                   }];
}

#pragma mark - Opening the drawer

- (void)open {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateClosed);
  [self willOpen];
  [self animateOpening];
}

- (void)willOpen {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateClosed);
  NSParameterAssert(self.leftView);
  NSParameterAssert(self.centerView);
  NSParameterAssert(self.leftViewController);
  NSParameterAssert(self.centerViewController);
  
  // Keep track that the drawer is opening
  self.drawerState = DPDrawerControllerStateOpening;
  
  // Position the left view
  CGRect f = self.view.bounds;
  f.origin.x = kDPDrawerControllerLeftViewInitialOffset;
  NSParameterAssert(f.origin.x < 0.0f);
  self.leftView.frame = f;
  
  // Start adding the left view controller to the container
  [self addChildViewController:self.leftViewController];
  self.leftViewController.view.frame = self.leftView.bounds;
  [self.leftView addSubview:self.leftViewController.view];
  
  // Add the left view to the view hierarchy
  [self.view insertSubview:self.leftView belowSubview:self.centerView];
  
  // Notify the child view controllers that the drawer is about to open
  if ([self.leftViewController respondsToSelector:@selector(drawerControllerWillOpen:)]) {
    [self.leftViewController drawerControllerWillOpen:self];
  }
  if ([self.centerViewController respondsToSelector:@selector(drawerControllerWillOpen:)]) {
    [self.centerViewController drawerControllerWillOpen:self];
  }
}

- (void)didOpen {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateOpening);
  NSParameterAssert(self.leftViewController);
  NSParameterAssert(self.centerViewController);
  
  // Complete adding the left controller to the container
  [self.leftViewController didMoveToParentViewController:self];
  [self addClosingGestureRecognizers];
  
  // Keep track that the drawer is open
  self.drawerState = DPDrawerControllerStateOpen;
  
  // Notify the child view controllers that the drawer is open
  if ([self.leftViewController respondsToSelector:@selector(drawerControllerDidOpen:)]) {
    [self.leftViewController drawerControllerDidOpen:self];
  }
  if ([self.centerViewController respondsToSelector:@selector(drawerControllerDidOpen:)]) {
    [self.centerViewController drawerControllerDidOpen:self];
  }
}

#pragma mark - Closing the drawer

- (void)close {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateOpen);
  [self willClose];
  [self animateClosing];
}

- (void)willClose {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateOpen);
  NSParameterAssert(self.leftViewController);
  NSParameterAssert(self.centerViewController);
  
  // Start removing the left controller from the container
  [self.leftViewController willMoveToParentViewController:nil];
  
  // Keep track that the drawer is closing
  self.drawerState = DPDrawerControllerStateClosing;
  
  // Notify the child view controllers that the drawer is about to close
  if ([self.leftViewController respondsToSelector:@selector(drawerControllerWillClose:)]) {
    [self.leftViewController drawerControllerWillClose:self];
  }
  if ([self.centerViewController respondsToSelector:@selector(drawerControllerWillClose:)]) {
    [self.centerViewController drawerControllerWillClose:self];
  }
}

- (void)didClose {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateClosing);
  NSParameterAssert(self.leftView);
  NSParameterAssert(self.centerView);
  NSParameterAssert(self.leftViewController);
  NSParameterAssert(self.centerViewController);
  
  // Complete removing the left view controller from the container
  [self.leftViewController.view removeFromSuperview];
  [self.leftViewController removeFromParentViewController];
  
  // Remove the left view from the view hierarchy
  [self.leftView removeFromSuperview];
  
  [self removeClosingGestureRecognizers];
  
  // Keep track that the drawer is closed
  self.drawerState = DPDrawerControllerStateClosed;
  
  // Notify the child view controllers that the drawer is closed
  if ([self.leftViewController respondsToSelector:@selector(drawerControllerDidClose:)]) {
    [self.leftViewController drawerControllerDidClose:self];
  }
  if ([self.centerViewController respondsToSelector:@selector(drawerControllerDidClose:)]) {
    [self.centerViewController drawerControllerDidClose:self];
  }
}

#pragma mark - Reloading/Replacing the center view controller
- (void)reloadCenterViewControllerUsingBlock:(void (^)(void))reloadBlock {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateOpen);
  NSParameterAssert(self.centerViewController);
  
  [self willClose];
  
  CGRect f = self.centerView.frame;
  f.origin.x = self.view.bounds.size.width;
  
  [UIView animateWithDuration: kDPDrawerControllerAnimationDuration / 2
                   animations:^{
                     self.centerView.frame = f;
                   }
                   completion:^(BOOL finished) {
                     // The center view controller is now out of sight
                     if (reloadBlock) {
                       reloadBlock();
                     }
                     // Finally, close the drawer
                     [self animateClosing];
                   }];
}

- (void)replaceCenterViewControllerWithViewController:
(UIViewController<DPDrawerControllerChild, DPDrawerControllerPresenting> *)viewController {
  NSParameterAssert(self.drawerState == DPDrawerControllerStateOpen);
  NSParameterAssert(viewController);
  NSParameterAssert(self.centerView);
  NSParameterAssert(self.centerViewController);
  
  [self willClose];
  
  CGRect f = self.centerView.frame;
  f.origin.x = self.view.bounds.size.width;
  
  [self.centerViewController willMoveToParentViewController:nil];
  [UIView animateWithDuration: kDPDrawerControllerAnimationDuration / 2
                   animations:^{
                     self.centerView.frame = f;
                   }
                   completion:^(BOOL finished) {
                     // The center view controller is now out of sight
                     
                     // Remove the current center view controller from the container
                     if ([self.centerViewController respondsToSelector:@selector(setDrawer:)]) {
                       self.centerViewController.drawer = nil;
                     }
                     [self.centerViewController.view removeFromSuperview];
                     [self.centerViewController removeFromParentViewController];
                     
                     // Set the new center view controller
                     self.centerViewController = viewController;
                     if ([self.centerViewController respondsToSelector:@selector(setDrawer:)]) {
                       self.centerViewController.drawer = self;
                     }
                     
                     // Add the new center view controller to the container
                     [self addCenterViewController];
                     
                     // Finally, close the drawer
                     [self animateClosing];
                   }];
}

@end
