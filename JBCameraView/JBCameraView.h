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

/**
 Key to get a CGRect object, the rectangle in which the full resolution image was cropped at.
 */
extern NSString * const JBCameraViewMetaCrop;

/**
 Key to get a UIImage object, the full resolution image as taken by the camera.
 */
extern NSString * const JBCameraViewMetaOriginalImage;

@class JBCameraView;

@protocol JBCameraViewDelegate <NSObject>

/**
 Implement to get a callback on the main thread with the image on JBCameraView#takePicture: only if an error didn't
 occur.

 @param cameraView the JBCameraView intance that this delegate is assigned to
 @param image the square cropped image in JPG format using, its size is the maximum used to capture it, its orientation is preserved from the camera.
 @param info
 @param meta
 @see JBCameraViewMeta
 */
- (void)cameraView:(JBCameraView *)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary*)info meta:(NSDictionary *)meta;

/**
 Implement to get a callaback on the main thread if an error occurs on JBCameraView#takePicture:

 @param cameraView the JBCameraView intance that this delegate is assigned to
 @param error the error as returned by AVCaptureSession#captureStillImageAsynchronouslyFromConnection:completionHandler:
 */
- (void)cameraView:(JBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error;

@optional
/**
 Implement if JBCameraView.callbackOnDidCreateCaptureConnection is set to YES.

 Will get a callback to customise the underlying AVCaptureConnection when created.

 AVCaptureConnection has the following properties already set:

    videoOrientation = AVCaptureVideoOrientationPortrait;

 @param cameraView the JBCameraView instance this delegate is assigned to
 @param captureConnection the AVCaptureConnection instance that will be used to capture the image
 @see AVCaptureSession#captureStillImageAsynchronouslyFromConnection:completionHandler:
 */
- (void)cameraView:(JBCameraView *)cameraView didCreateCaptureConnection:(AVCaptureConnection *)captureConnection;

/**
 Implement if JBCameraView.allowPictureRetake is set to YES.

 Will get a callaback with the image as returned by the last call to #cameraView:didFinishTakingPicture:info:meta

 @param cameraView the JBCameraView intance that this delegate is assigned to.
 @param image current image currently previewing.
 */
- (void)cameraView:(JBCameraView *)cameraView willRetakePicture:(UIImage *)image;

/**
 Implement if JBCameraView.writeToCameraRoll is set to YES.

 Will get a callback before writing the image to the camera roll as taken in full resolution by the camera.

 @param cameraView the JBCameraView instance this delegate is assigned to
 @param metadata the metadata instance that will be used to capture the image
 */
- (void)cameraView:(JBCameraView *)cameraView willWriteToCameraRollWithMetadata:(NSDictionary *)metadata;

@end

/**
 A UIView that displays a live feed of AVMediaTypeVideo and can capture a still image from it.



 The view controller that has JBCameraView in its hierarchy should set the image from cameraView:didFinishTakingPicture:editingInfo #preview.image on #viewWillAppear

 Portrait, iPhone only orientation
 @see
 */
@interface JBCameraView : UIView

/**
 Set to true to allow the user to retake a photo by tapping on the preview

 @precondition have delegate set
 @precondition have cameraView:didCreateCaptureConnection: implemented
 */
@property (assign, nonatomic) BOOL allowPictureRetake;


///
@property (assign, nonatomic) BOOL writeToCameraRoll;


/**

 */
@property (assign, nonatomic) IBOutlet id <JBCameraViewDelegate> delegate;


/**
 Set backgroundColor to a custom one

    backgroundColor = [UIColor whiteColor];

 */
@property (strong, nonatomic) UIView *flashView;


/**
 Takes a still image of the current frame from the video feed.

 Does not block.

 @callback on the main thread at JBCameraViewDelegate#cameraview:didFinishTakingPicture:editingInfo once the still image is processed.
 */
- (void)takePicture;

/**

 Restart the take picture session as if the user had tapped on the view with the JBCameraView#allowPictureRetake property set to YES.

 Does not block.

 @callback on the main thread at JBCameraViewDelegate#cameraView:willRetakePicture:
 */
- (void)retakePicture;

@end
