//
//  DPTakePhotosViewController.m
//  DasPrototyp
//
//  Created by HongliYu on 14-3-14.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#import "DPTakePhotosViewController.h"
#import "DPImageUtils.h"
#import "DPPageViewModel.h"
#import <AVFoundation/AVFoundation.h>

@interface DPTakePhotosViewController () <AVCapturePhotoCaptureDelegate>

@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureDeviceInput *input;
@property (nonatomic, retain) AVCaptureDevice *device;
@property (nonatomic, retain) AVCapturePhotoOutput *imageOutput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, retain) AVCapturePhotoSettings *outputSettings;

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *shutterButton;

@end

@implementation DPTakePhotosViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
  [super viewDidLoad];
  [self configBaseUI];
}

- (void)configBaseUI {
  [self.shutterButton.titleLabel setFont:[UIFont fontWithName:@"dp_iconfont" size:40.f]];
  [self.shutterButton setTitle:@"\U0000ea56" forState:UIControlStateNormal];
  [self createCameraInPosition:YES];
}

- (void)createCameraInPosition:(BOOL)isBack {
  self.session = [AVCaptureSession new];
  [self.session setSessionPreset:AVCaptureSessionPresetHigh];
  
  AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession
  = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                           mediaType:AVMediaTypeVideo
                                                            position:AVCaptureDevicePositionBack];
  NSArray *devices = [captureDeviceDiscoverySession devices];
  
  for (AVCaptureDevice *device in devices) {
    if (isBack) {
      if ([device position] == AVCaptureDevicePositionBack) {
        _device = device;
        break;
      }
    } else {
      if ([device position] == AVCaptureDevicePositionFront) {
        _device = device;
        break;
      }
    }
  }
  
  NSError *error;
  
  self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
  if ([self.session canAddInput:self.input]) {
    [self.session addInput:self.input];
  }
  
  self.imageOutput = [[AVCapturePhotoOutput alloc] init];
  NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
  _outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
  [self.imageOutput setPhotoSettingsForSceneMonitoring:_outputSettings];
  [self.session addOutput:self.imageOutput];
  self.preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
  [self.preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  [self.preview setFrame:CGRectMake(0, 0,
                                    UIScreen.mainScreen.bounds.size.width,
                                    UIScreen.mainScreen.bounds.size.height)];
  [self.view.layer insertSublayer:self.preview atIndex:0];
  [self.session startRunning];
}

- (IBAction)takePhoto:(id)sender {
  NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
  AVCapturePhotoSettings *outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
  [self.imageOutput capturePhotoWithSettings:outputSettings delegate:self];
}

- (IBAction)backAction:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
  NSData *rawData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
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

- (void)startRunning {
  [_session startRunning];
}

- (void)stopRunning {
  [_session stopRunning];
}

@end
