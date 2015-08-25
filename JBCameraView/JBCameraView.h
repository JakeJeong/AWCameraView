//
// 	JBCameraView.h
//  JBCameraView
//
//  Created by Markos Charatzas on 25/06/2013.
//  Copyright (c) 2015 Cuvva Limited
//  Copyright (c) 2013 www.verylargebox.com
//

#import <UIKit/UIKit.h>
#import <JBCameraView/JBCameraViewPosition.h>
#import <JBCameraView/JBCameraViewDelegate.h>

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
