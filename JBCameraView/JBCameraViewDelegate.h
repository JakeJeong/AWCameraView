//
// 	JBCameraViewDelegate.h
//  JBCameraView
//
//  Created by James Billingham on 25/08/2015.
//  Copyright (c) 2015 Cuvva Limited
//  Copyright (c) 2013 www.verylargebox.com
//

#import <Foundation/Foundation.h>

@class JBCameraView;
@class AVCaptureConnection;
@class UIImage;

@protocol JBCameraViewDelegate <NSObject>

/// Called after the picture is captured if an error didn't occur
- (void)cameraView:(JBCameraView *)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary *)info;

/// Called if an error occurs while picture is being captured
- (void)cameraView:(JBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error;

@optional

/// Called to allow customization of the underlying AVCaptureConnection
- (void)cameraView:(JBCameraView *)cameraView didCreateCaptureConnection:(AVCaptureConnection *)captureConnection;

@end
