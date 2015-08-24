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
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^JBCaptureStillImageBlock)(CMSampleBufferRef imageDataSampleBuffer, NSError *error);
typedef void (^JBCameraViewInit)(JBCameraView *cameraView);

NSString * const JBCameraViewMetaCrop = @"JBCameraViewMetaCrop";
NSString * const JBCameraViewMetaOriginalImage = @"JBCameraViewMetaOriginalImage";

@interface JBCameraView ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureConnection *stillImageConnection;
@property (nonatomic, strong) UIImageView *preview;

@end

@implementation JBCameraView

- (void)commonSetup
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSArray *views = [bundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
  [self addSubview:views[0]];

  self.session = [AVCaptureSession new];
  self.session.sessionPreset = AVCaptureSessionPresetPhoto;

  self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
  self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  self.videoPreviewLayer.frame = self.layer.bounds;

  self.flashView = [[UIView alloc] initWithFrame:self.preview.bounds];
  self.flashView.backgroundColor = [UIColor whiteColor];
  self.flashView.alpha = 0.0f;
  [self.videoPreviewLayer addSublayer:self.flashView.layer];
}

- (id)initWithFrame:(CGRect)frame
{
  if (!(self = [super initWithFrame:frame]))
    return nil;

  [self commonSetup];

  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if (!(self = [super initWithCoder:aDecoder]))
    return nil;

  [self commonSetup];

  return self;
}

- (void)awakeFromNib
{
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

  if ([device lockForConfiguration:nil])
  {
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
      device.focusMode = AVCaptureFocusModeContinuousAutoFocus;

    if ([device isFlashModeSupported:AVCaptureFlashModeAuto])
      device.flashMode = AVCaptureFlashModeAuto;

    [device unlockForConfiguration];
  }

  NSError *error = nil;
  AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

  if (error)
    [NSException raise:[NSString stringWithFormat:@"Failed with error %d", (int)error.code] format:error.localizedDescription, nil];

  [self.session addInput:deviceInput];

  self.stillImageOutput = [AVCaptureStillImageOutput new];
  [self.session addOutput:self.stillImageOutput];

  [self.layer addSublayer:self.videoPreviewLayer];

  [self.session startRunning];

  self.stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
  self.stillImageConnection.videoOrientation = AVCaptureVideoOrientationPortrait;

  if ([self.delegate respondsToSelector:@selector(cameraView:didCreateCaptureConnection:)])
    [self.delegate cameraView:self didCreateCaptureConnection:self.stillImageConnection];
}

- (void)takePicture
{
  [UIView animateWithDuration:0.4f animations:^{ self.flashView.alpha = 1.0f; } completion:^(BOOL finished) { self.flashView.alpha = 0.0f; }];

  // set the appropriate pixel format / image type output setting depending on if we'll need an uncompressed image for
  // the possiblity of drawing the red square over top or if we're just writing a jpeg to the camera roll which is the trival case
  [self.stillImageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];

  __weak JBCameraView *wself = self;

  [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:self.stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    [wself.session stopRunning];

    if (error)
    {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate cameraView:wself didErrorOnTakePicture:error];
      });

      return;
    }

    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    UIImage *image = [UIImage imageWithData:imageData];
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *info = (__bridge NSDictionary *)attachments;

    if (wself.writeToCameraRoll)
    {
      if ([wself.delegate respondsToSelector:@selector(cameraView:willWriteToCameraRollWithMetadata:)])
        [wself.delegate cameraView:wself willWriteToCameraRollWithMetadata:info];

      ALAssetsLibrary *library = [ALAssetsLibrary new];
      [library writeImageDataToSavedPhotosAlbum:imageData metadata:info completionBlock:nil];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      wself.preview.image = image;

      // point is in range 0..1
      CGPoint point = [self.videoPreviewLayer captureDevicePointOfInterestForPoint:CGPointZero];

      // point is calculated with camera in landscape but crop is in portrait
      CGRect crop = CGRectMake(image.size.height - (image.size.height * (1.0f - point.x)), 0, image.size.width, image.size.height * (1.0f - point.x));

      CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], crop);
      UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:image.imageOrientation]; //preserve camera orientation
      CGImageRelease(imageRef);

      NSDictionary *meta = @{JBCameraViewMetaCrop:[NSValue valueWithCGRect:crop], JBCameraViewMetaOriginalImage:image};
      [self.delegate cameraView:wself didFinishTakingPicture:newImage withInfo:info meta:meta];

      CFRelease(attachments);
    });
  }];

  if (self.allowPictureRetake)
  {
    UITapGestureRecognizer *tapToRetakeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retakePicture)];
    [self.preview addGestureRecognizer:tapToRetakeGesture];
  }
}

- (void)retakePicture
{
  if ([self.delegate respondsToSelector:@selector(cameraView:willRetakePicture:)])
    [self.delegate cameraView:self willRetakePicture:self.preview.image];
  
  self.preview.image = nil;
  [self.session startRunning];
}

@end
