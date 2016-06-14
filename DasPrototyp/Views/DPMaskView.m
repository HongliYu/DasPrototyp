//
//  DPMaskView.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/6.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPMaskView.h"
#import "DPMaskViewModel.h"

const float kButtonHeight = 20.f;

@interface DPMaskView()

// state
@property (assign, nonatomic, readwrite) DPMaskViewDisplayMode displayMode;

// play mode

// edit mode
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIImageView *zoomImageView;
@property (assign, nonatomic, readwrite) CGPoint lastOriginPoint;
@property (assign, nonatomic, readwrite, getter=isMoving) BOOL moving;
@property (assign, nonatomic, readwrite) CGSize lastRectSize;
@property (assign, nonatomic, readwrite, getter=isResizing) BOOL resizing;
@property (strong, nonatomic, readwrite) DPMaskViewModel *maskViewModel;

@end

@implementation DPMaskView

- (instancetype)initWithEditMode {
  self = [super init];
  if (self) {
    _displayMode = DPMaskViewDisplayModeEdit;
    _deleteButton = [[UIButton alloc] init];
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"MaskDelete"]
                             forState:UIControlStateNormal];
    [_deleteButton addTarget:self
                      action:@selector(deleteAction:)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
    _zoomImageView = [[UIImageView alloc] init];
    _zoomImageView.image = [UIImage imageNamed:@"MaskZoom"];
    [_zoomImageView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *resizingPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(resizingAction:)];
    [_zoomImageView addGestureRecognizer:resizingPanGesture];
    [self addSubview:_zoomImageView];
    
    UITapGestureRecognizer *tapSwitchSignalGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapAction:)];
    [self addGestureRecognizer:tapSwitchSignalGesture];
    
    self.layer.borderWidth = 2.f;
    [self hideButtons];
  }
  return self;
}

- (instancetype)initWithPlayMode {
  self = [super init];
  if (self) {
    _displayMode = DPMaskViewDisplayModePlay;
  }
  return self;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    ;
  }
  return self;
}

- (void)tapAction:(UITapGestureRecognizer *)tapSwitchSignalGesture {
  if (!self.maskViewModel.selected) {
    return;
  }
  if (self.tapAction) {
    self.tapAction();
  }
}

- (void)resizingAction:(UIPanGestureRecognizer *)resizingPanGesture {
  if (self.resizingAction) {
    self.resizingAction(resizingPanGesture);
  }
}

- (void)deleteAction:(id)sender {
  [self removeFromSuperview];
  if (self.deleteAction) {
    self.deleteAction();
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (self.displayMode == DPMaskViewDisplayModeEdit) {
    self.deleteButton.frame = CGRectMake(0, 0, 20.f, 20.f);
    self.zoomImageView.frame = CGRectMake(self.bounds.size.width - 20.f,
                                          self.bounds.size.height - 20.f,
                                          20.f, 20.f);
  }
}

- (void)showButtons {
  [self.deleteButton setHidden:NO];
  [self.zoomImageView setHidden:NO];
}

- (void)hideButtons {
  [self.deleteButton setHidden:YES];
  [self.zoomImageView setHidden:YES];
}

- (void)bindData:(DPMaskViewModel *)maskViewModel {
  _maskViewModel = maskViewModel;
  self.frame = CGRectMake(maskViewModel.startPoint.x,
                          maskViewModel.startPoint.y,
                          maskViewModel.endPoint.x - maskViewModel.startPoint.x,
                          maskViewModel.endPoint.y - maskViewModel.startPoint.y);
  if (self.displayMode == DPMaskViewDisplayModeEdit) {
    if (maskViewModel.isSelected) {
      self.layer.borderColor = [UIColor whiteColor].CGColor;
      self.backgroundColor = [UIColor colorWithRed:86/255.0 green:202/255.0 blue:139/255.0 alpha:0.8f];
      [self showButtons];
    } else {
      self.layer.borderColor = [UIColor clearColor].CGColor;
      self.backgroundColor = [UIColor colorWithRed:86/255.0 green:202/255.0 blue:139/255.0 alpha:0.4f];
      [self hideButtons];
    }
  }
  if (self.displayMode == DPMaskViewDisplayModePlay) {
    UITapGestureRecognizer *tapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(gestureTipsAction:)];
    if (tapGestureRecognizer) {
      [self addGestureRecognizer:tapGestureRecognizer];
    }
    
    switch (maskViewModel.eventSignal) {
      case DPEventSignalPressDown: {
        break;
      }
      case DPEventSignalLongPress: {
        UILongPressGestureRecognizer *longPressGestureRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(gestureAction:)];
        if (longPressGestureRecognizer) {
          [self addGestureRecognizer:longPressGestureRecognizer];
        }
        break;
      }
      case DPEventSignalSwipeLeft: {
        UISwipeGestureRecognizer *swipeGestureRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(gestureAction:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        if (swipeGestureRecognizer) {
          [self addGestureRecognizer:swipeGestureRecognizer];
        }
        break;
      }
      case DPEventSignalSwipeUp: {
        UISwipeGestureRecognizer *swipeGestureRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(gestureAction:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        if (swipeGestureRecognizer) {
          [self addGestureRecognizer:swipeGestureRecognizer];
        }
        break;
      }
      case DPEventSignalSwipeRight: {
        UISwipeGestureRecognizer *swipeGestureRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(gestureAction:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        if (swipeGestureRecognizer) {
          [self addGestureRecognizer:swipeGestureRecognizer];
        }
        break;
      }
      case DPEventSignalSwipeDown: {
        UISwipeGestureRecognizer *swipeGestureRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(gestureAction:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        if (swipeGestureRecognizer) {
          [self addGestureRecognizer:swipeGestureRecognizer];
        }
        break;
      }
      case DPEventSignalRotate: {
        UIRotationGestureRecognizer *rotationGestureRecognizer =
        [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                     action:@selector(gestureAction:)];
        if (rotationGestureRecognizer) {
          [self addGestureRecognizer:rotationGestureRecognizer];
        }
        break;
      }
      case DPEventSignalPinch: {
        UIPinchGestureRecognizer *pinchGestureRecognizer =
        [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(gestureAction:)];
        if (pinchGestureRecognizer) {
          [self addGestureRecognizer:pinchGestureRecognizer];
        }
        break;
      }
    }
  }
}

- (void)gestureTipsAction:(UIGestureRecognizer *)gestureRecognizer {
  if (_maskViewModel.eventSignal == DPEventSignalPressDown) {
    [self gestureAction:gestureRecognizer];
  } else {
    NSString *errorMessage = nil;
    switch (_maskViewModel.eventSignal) {
      case DPEventSignalPressDown: {
        break;
      }
      case DPEventSignalLongPress: {
        errorMessage = NSLocalizedString(@"LongPress", @"");
        break;
      }
      case DPEventSignalSwipeLeft: {
        errorMessage = NSLocalizedString(@"SwipeLeft", @"");
        break;
      }
      case DPEventSignalSwipeUp: {
        errorMessage = NSLocalizedString(@"SwipeUp", @"");
        break;
      }
      case DPEventSignalSwipeRight: {
        errorMessage = NSLocalizedString(@"SwipeRight", @"");
        break;
      }
      case DPEventSignalSwipeDown: {
        errorMessage = NSLocalizedString(@"SwipeDown", @"");
        break;
      }
      case DPEventSignalRotate: {
        errorMessage = NSLocalizedString(@"Rotate", @"");
        break;
      }
      case DPEventSignalPinch: {
        errorMessage = NSLocalizedString(@"Pinch", @"");
        break;
      }
    }
    [SVProgressHUD showErrorWithStatus:errorMessage];
  }
}

- (void)gestureAction:(UIGestureRecognizer *)gestureRecognizer {
  if ([DPMainManager sharedDPMainManager].isDoingAnimation) {
    return;
  }
  if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
    UILongPressGestureRecognizer *longPressGestureRecognizer = (UILongPressGestureRecognizer *)gestureRecognizer;
    switch (longPressGestureRecognizer.state) {
      case UIGestureRecognizerStatePossible: {
        ;
        break;
      }
      case UIGestureRecognizerStateBegan: {
        if (self.actionCallBack) {
          [[DPMainManager sharedDPMainManager] enterAnimationMode];
          self.actionCallBack();
        }
        break;
      }
      case UIGestureRecognizerStateChanged: {
        ;
        break;
      }
      case UIGestureRecognizerStateEnded: {
        ;
        break;
      }
      case UIGestureRecognizerStateCancelled: {
        ;
        break;
      }
      case UIGestureRecognizerStateFailed: {
        ;
        break;
      }
    }
    return;
  }
  if (self.actionCallBack) {
    [[DPMainManager sharedDPMainManager] enterAnimationMode];
    self.actionCallBack();
  }
}

- (void)enterMovingMode {
  self.lastOriginPoint = CGPointMake(self.left, self.top);
  self.moving = YES;
}

- (void)exitMovingMode {
  self.lastOriginPoint = CGPointMake(self.left, self.top);
  self.moving = NO;
}

- (void)enterResizingMode {
  self.lastRectSize = CGSizeMake(self.width, self.height);
  self.resizing = YES;
}

- (void)exitResizingMode {
  self.lastRectSize = CGSizeMake(self.width, self.height);
  self.resizing = NO;
}

@end
