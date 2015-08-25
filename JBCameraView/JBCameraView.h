//
// 	JBCameraView.h
//  JBCameraView
//
//  Created by Markos Charatzas on 25/06/2013.
//  Copyright (c) 2015 Cuvva Limited
//  Copyright (c) 2013 www.verylargebox.com
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, JBCameraViewPosition)
{
  JBCameraViewPositionBack = 0,
  JBCameraViewPositionFront
};

@class JBCameraView;

@protocol JBCameraViewDelegate <NSObject>

/// Called after the picture is captured if an error didn't occur
- (void)cameraView:(JBCameraView *)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary *)info;

/// Called if an error occurs while picture is being captured
- (void)cameraView:(JBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error;

@optional

/// Called to allow customization of the underlying AVCaptureConnection
- (void)cameraView:(JBCameraView *)cameraView didCreateCaptureConnection:(AVCaptureConnection *)captureConnection;

@end

/// UIView to show the camera, take a picture, preview it, return UIImage
@interface JBCameraView : UIView

/// Delegate for receiving events
@property (weak, nonatomic) IBOutlet id <JBCameraViewDelegate> delegate;

/// The camera being used - front or back; defaults to back
@property (assign, nonatomic) JBCameraViewPosition position;

/// Takes a still image of the current frame from the video feed
- (void)takePicture;

/// Restart the session
- (void)retakePicture;

@end
