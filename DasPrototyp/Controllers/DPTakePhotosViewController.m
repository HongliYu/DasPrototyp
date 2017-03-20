//
//  DPTakePhotosViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-3-14.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPTakePhotosViewController.h"
#import "AVCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "DPPhotoCollectViewController.h"
#import "DPTakePhotosViewController.h"
#import "DPPageViewModel.h"

static void *CapturingStillImageContext = &CapturingStillImageContext;
static void *RecordingContext = &RecordingContext;
static void *SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface DPTakePhotosViewController ()

// Components
@property(strong, nonatomic) IBOutlet UIButton *backButton;
@property(strong, nonatomic) IBOutlet UIButton *shutterButton;
@property(strong, nonatomic) IBOutlet AVCamPreviewView *previewView;

// Session management.
@property(nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other
@property(nonatomic) AVCaptureSession *session; // session objects on this queue.
@property(nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic) AVCaptureDeviceInput *videoDeviceInput;

// Utilities.
@property(nonatomic, getter=isDeviceAuthorized) BOOL deviceAuthorized;
@property(nonatomic, readonly, getter=isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property(nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation DPTakePhotosViewController

- (BOOL)isSessionRunningAndDeviceAuthorized {
  return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized {
  return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}


#pragma mark - Life Cycle
- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseUI];
  
  _session = [[AVCaptureSession alloc] init];
  _previewView.session = _session;
  [self checkDeviceAuthorizationStatus];

  _sessionQueue = dispatch_queue_create("hlyu.cn.camera.session.queue", DISPATCH_QUEUE_SERIAL);
  dispatch_async(_sessionQueue, ^{
    NSError *error = nil;
    AVCaptureDevice *videoDevice = [DPTakePhotosViewController deviceWithMediaType:AVMediaTypeVideo
                                                                preferringPosition:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                                   error:&error];
    if (error) {
      DLog(@"AVCaptureDeviceInput error: %@", error);
    }
    
    if ([_session canAddInput:videoDeviceInput]) {
      [_session addInput:videoDeviceInput];
      [self setVideoDeviceInput:videoDeviceInput];
      dispatch_async(dispatch_get_main_queue(), ^{
        [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection]
         setVideoOrientation:(AVCaptureVideoOrientation)
         [[UIApplication sharedApplication] statusBarOrientation]];
      });
    }
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([_session canAddOutput:stillImageOutput]) {
      [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
      [_session addOutput:stillImageOutput];
      [self setStillImageOutput:stillImageOutput];
    }
  });

  UITapGestureRecognizer *tapToFocus = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(focusAndExposeTap:)];
  tapToFocus.numberOfTapsRequired = 1;
  tapToFocus.numberOfTouchesRequired = 1;
  [self.previewView addGestureRecognizer:tapToFocus];

  [self.shutterButton addTarget:self
                         action:@selector(shutterAction:)
               forControlEvents:UIControlEventTouchUpInside];
}


- (void)configBaseUI {
  [self.shutterButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:40.f]];
  [self.shutterButton setTitle:@"\U0000ea56" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  dispatch_async(self.sessionQueue, ^{
    [self addObserver:self
           forKeyPath:@"sessionRunningAndDeviceAuthorized"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
              context:SessionRunningAndDeviceAuthorizedContext];
    [self addObserver:self
           forKeyPath:@"stillImageOutput.capturingStillImage"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
              context:CapturingStillImageContext];
    __weak typeof(self) weakSelf = self;
    self.runtimeErrorHandlingObserver = [[NSNotificationCenter defaultCenter]
                                         addObserverForName:AVCaptureSessionRuntimeErrorNotification
                                         object:self.session
                                         queue:nil
                                         usingBlock:^(NSNotification *note) {
                                           __strong typeof(self) strongSelf = weakSelf;
                                           dispatch_async(strongSelf.sessionQueue, ^{
                                             // Manually restarting the session since it must
                                             // have been stopped due to an error.
                                             [strongSelf.session startRunning];
                                           });
                                         }];
    [self.session startRunning];
  });
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  dispatch_async(self.sessionQueue, ^{
    [self.session stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
    
    [self removeObserver:self
              forKeyPath:@"sessionRunningAndDeviceAuthorized"
                 context:SessionRunningAndDeviceAuthorizedContext];
    [self removeObserver:self
              forKeyPath:@"stillImageOutput.capturingStillImage"
                 context:CapturingStillImageContext];
  });
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (context == CapturingStillImageContext) {
    BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
    if (isCapturingStillImage) {
      [self runStillImageCaptureAnimation];
    }
  } else if (context == SessionRunningAndDeviceAuthorizedContext) {
    BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.shutterButton.enabled = isRunning;
    });
  } else {
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
  }
}


#pragma mark Device Configuration
- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
  CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer]
                         captureDevicePointOfInterestForPoint:
                         [gestureRecognizer locationInView:[gestureRecognizer view]]];
  [self focusWithMode:AVCaptureFocusModeAutoFocus
       exposeWithMode:AVCaptureExposureModeAutoExpose
        atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode
       exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point
    monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
  dispatch_async([self sessionQueue], ^{
    AVCaptureDevice *device = [[self videoDeviceInput] device];
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
      if ([device isFocusPointOfInterestSupported]
          && [device isFocusModeSupported:focusMode]) {
        [device setFocusMode:focusMode];
        [device setFocusPointOfInterest:point];
      }
      if ([device isExposurePointOfInterestSupported]
          && [device isExposureModeSupported:exposureMode]) {
        [device setExposureMode:exposureMode];
        [device setExposurePointOfInterest:point];
      }
      [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
      [device unlockForConfiguration];
    } else {
      DLog(@"%@", error);
    }
  });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode
           forDevice:(AVCaptureDevice *)device {
  if ([device hasFlash]
      && [device isFlashModeSupported:flashMode]) {
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
      [device setFlashMode:flashMode];
      [device unlockForConfiguration];
    } else {
      DLog(@"%@", error);
    }
  }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType
                      preferringPosition:(AVCaptureDevicePosition)position {
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
  AVCaptureDevice *captureDevice = [devices firstObject];
  for (AVCaptureDevice *device in devices) {
    if ([device position] == position) {
      captureDevice = device;
      break;
    }
  }
  return captureDevice;
}

#pragma mark UI
- (void)runStillImageCaptureAnimation { // take photo animation
  dispatch_async(dispatch_get_main_queue(), ^{
    [[[self previewView] layer] setOpacity:0.0];
    [UIView animateWithDuration:.25f
                     animations:^{
                       [self.previewView.layer setOpacity:1.0];
                     }];
  });
}

- (void)checkDeviceAuthorizationStatus {
  NSString *mediaType = AVMediaTypeVideo;
  [AVCaptureDevice requestAccessForMediaType:mediaType
                           completionHandler:^(BOOL granted) {
                             if (granted) {
                               // User Granted access to mediaType
                               [self setDeviceAuthorized:YES];
                             } else {
                               // User Not granted access to mediaType
                               dispatch_async(dispatch_get_main_queue(), ^{
                                 [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                                             message:@"AVCam doesn't have permission to "
                                   @"use Camera, please change privacy "
                                   @"settings"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] show];
                                 
                                 [self setDeviceAuthorized:NO];
                               });
                             }
                           }];
}

#pragma mark Actions
- (IBAction)goBack:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shutterAction:(id)sender {
  [self.shutterButton setEnabled:NO]; // TODO: Code reuse
  [self.shutterButton setAlpha:0.6f];
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.sessionQueue, ^{
    __strong typeof(self) strongSelf = weakSelf;
    // auto flash
    [DPTakePhotosViewController setFlashMode:AVCaptureFlashModeAuto
                                   forDevice:[strongSelf.videoDeviceInput device]];
    // Capture a still image.
    [[strongSelf stillImageOutput]
     captureStillImageAsynchronouslyFromConnection:[strongSelf.stillImageOutput connectionWithMediaType:AVMediaTypeVideo]
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
       if (error) {
         DLog(@"%@", error);
         return;
       }
       if (imageDataSampleBuffer) {
         NSData *rawData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         NSData *compressedImageData = [DPImageUtils compressImage:[UIImage imageWithData:rawData]];
         if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateNormal) {
           [[DPMainManager sharedDPMainManager] createCacheOnDiskWithImageData:compressedImageData];
         }
         if ([DPMainManager sharedDPMainManager].collectState == DPCollectStateEdit) {
           DPPageViewModel *selectedPageViewModel = [DPMainManager sharedDPMainManager].selectedPageViewModelInEditMode;
           NSString *imageName = selectedPageViewModel.imageName;
           [[DPMainManager sharedDPMainManager] replaceCachedImageDataWithImageData:compressedImageData
                                                                          imageName:imageName];
         }
         if ([DPMainManager sharedDPMainManager].takePhotoActionCallBack) {
           [DPMainManager sharedDPMainManager].takePhotoActionCallBack();
           [self.shutterButton setEnabled:YES];
           [self.shutterButton setAlpha:1.f];
         }
       }
     }];
    });
}

@end
