//
// 	JBCameraView.m
//  JBCameraView
//
//  Created by Markos Charatzas on 25/06/2013.
//  Copyright (c) 2015 Cuvva Limited
//  Copyright (c) 2013 www.verylargebox.com
//

#import "JBCameraView.h"
#import <AVFoundation/AVFoundation.h>

@interface JBCameraView () <UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureConnection *stillImageConnection;
@property (nonatomic, strong) UIImageView *preview;

@end

@implementation JBCameraView

- (void)commonInit
{
  self.session = [AVCaptureSession new];
  self.session.sessionPreset = AVCaptureSessionPresetPhoto;

  self.stillImageOutput = [AVCaptureStillImageOutput new];
  self.stillImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
  [self.session addOutput:self.stillImageOutput];

  self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
  self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (id)initWithFrame:(CGRect)frame
{
  if (!(self = [super initWithFrame:frame]))
    return nil;

  [self commonInit];

  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if (!(self = [super initWithCoder:aDecoder]))
    return nil;

  [self commonInit];

  return self;
}

- (void)awakeFromNib
{
  [super awakeFromNib];

  self.position = JBCameraViewPositionBack;

  [self.session startRunning];
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

  self.preview = [[UIImageView alloc] initWithFrame:frame];
  [self addSubview:self.preview];

  self.videoPreviewLayer.frame = frame;
  [self.layer addSublayer:self.videoPreviewLayer];
}

- (void)takePicture
{
  __weak JBCameraView *weakSelf = self;

  [self.stillImageOutput
   captureStillImageAsynchronouslyFromConnection:self.stillImageConnection
   completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
    [weakSelf.session stopRunning];

    if (error)
    {
      [self.delegate cameraView:weakSelf didErrorOnTakePicture:error];
      return;
    }

    NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
    UIImage *image = [UIImage imageWithData:data];
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *info = CFBridgingRelease(attachments);

    [self.delegate cameraView:weakSelf didFinishTakingPicture:image withInfo:info];

    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.preview.image = image;
    });
  }];
}

- (void)retakePicture
{
  dispatch_async(dispatch_get_main_queue(), ^{
    self.preview.image = nil;
    [self.session startRunning];
  });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == alertView.cancelButtonIndex)
    [self setPosition:_position];

  if (buttonIndex == alertView.firstOtherButtonIndex)
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)setPosition:(JBCameraViewPosition)position
{
  _position = position;

  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

  if (status == AVAuthorizationStatusNotDetermined)
  {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
      [self setPosition:_position];
    }];
    return;
  }

  if (status != AVAuthorizationStatusAuthorized)
  {
    [[[UIAlertView alloc]
      initWithTitle:@"Camera Required"
      message:@"To continue, you must allow access to the camera."
      delegate:self
      cancelButtonTitle:@"Try Again"
      otherButtonTitles:@"Settings", nil]
     show];
    return;
  }

  AVCaptureDevice *device = [self getCameraWithPosition:self.position];

  if (!device)
    [NSException raise:@"CameraUnavailable" format:@"Failed to get a capture device"];

  if ([device lockForConfiguration:nil])
  {
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
      device.focusMode = AVCaptureFocusModeContinuousAutoFocus;

    if ([device isFlashModeSupported:AVCaptureFlashModeAuto])
      device.flashMode = AVCaptureFlashModeAuto;

    [device unlockForConfiguration];
  }

  NSError *error;
  AVCaptureDeviceInput *deviceInput;
  if (!(deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error]))
  {
    NSString *str = [NSString stringWithFormat:@"Failed with error %d", (int)error.code];
    [NSException raise:str format:@"%@", error.localizedDescription];
  }

  for (AVCaptureDeviceInput *input in self.session.inputs)
    [self.session removeInput:input];

  [self.session addInput:deviceInput];

  self.stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
  self.stillImageConnection.videoOrientation = AVCaptureVideoOrientationPortrait;

  if ([self.delegate respondsToSelector:@selector(cameraView:didCreateCaptureConnection:)])
    [self.delegate cameraView:self didCreateCaptureConnection:self.stillImageConnection];
}

- (AVCaptureDevice *)getCameraWithPosition:(JBCameraViewPosition)position
{
  AVCaptureDevicePosition avPosition = [self avPositionForPosition:position];
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

  for (AVCaptureDevice *device in devices)
  {
    if (device.position == avPosition)
      return device;
  }

  return devices.firstObject;
}

- (AVCaptureDevicePosition)avPositionForPosition:(JBCameraViewPosition)position
{
  switch (position)
  {
    case JBCameraViewPositionBack: return AVCaptureDevicePositionBack;
    case JBCameraViewPositionFront: return AVCaptureDevicePositionFront;
    default: [NSException raise:@"InvalidPosition" format:@"Invalid position"];
  }
}

@end
