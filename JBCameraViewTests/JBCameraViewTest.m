//
//  JBCameraViewTest.m
//  JBCameraView
//
//  Created by Markos Charatzas on 29/06/2013.
//  Copyright (c) 2013 www.verylargebox.com
//

#import <SenTestingKit/SenTestingKit.h>
#import <Kiwi/Kiwi.h>
#import <OCMock/OCMock.h>
#import <AVFoundation/AVFoundation.h>
#import "JBCameraView.h"

//testing
typedef void(^JBCaptureStillImageBlock)(CMSampleBufferRef imageDataSampleBuffer, NSError *error);

@interface JBCameraView (Test)
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property(nonatomic, strong) AVCaptureConnection *stillImageConnection;
@property(nonatomic, weak) UIImageView* preview;

-(JBCaptureStillImageBlock) didFinishTakingPicture:(AVCaptureSession*) session preview:(UIImageView*)preview videoPreviewLayer:(AVCaptureVideoPreviewLayer*) videoPreviewLayer;
@end

@interface JBCameraViewTestDelegate : NSObject <JBCameraViewDelegate>
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) NSDictionary *info;
@property(nonatomic, strong) NSDictionary *meta;
@end

@implementation JBCameraViewTestDelegate

-(void)cameraView:(JBCameraView *)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary *)info meta:(NSDictionary *)meta{
    self.image = image;
		self.info = info;
		self.meta = meta;
}

-(void)cameraView:(JBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error{
}

@end


@interface JBCameraViewTest : SenTestCase

@end

@implementation JBCameraViewTest

@end

SPEC_BEGIN(JBCameraSpec)

context(@"assert video preview will fill the camera view; given a new JBCameraView instance, AVCaptureVideoPreviewLayer", ^{
    it(@"should have videogravity of AVLayerVideoGravityResizeAspectFill", ^{
        JBCameraView *cameraView = [[JBCameraView alloc] initWithFrame:CGRectZero];

        [[cameraView.videoPreviewLayer.videoGravity should] equal:AVLayerVideoGravityResizeAspectFill];
    });
});

context(@"assert 'white flash' will be shown when photo is taken; given a new JBCameraView instance", ^{
    it(@"should have a flashview with superlayer of AVCaptureVideoPreviewLayer", ^{
        JBCameraView *cameraView = [[JBCameraView alloc] initWithFrame:CGRectZero];

        [[cameraView.flashView.layer.superlayer should] equal:cameraView.videoPreviewLayer];
        [[cameraView.flashView.backgroundColor should] equal:[UIColor whiteColor]];
        [[theValue(cameraView.preview.alpha) should] equal:theValue(0.0f)];
    });
});

context(@"assert delegate gets callbacks; given a new JBCameraView instance ", ^{
    it(@"should callback its delegate with AVCaptureVideoPreviewLayer when callbackOnDidCreateCaptureConnection is YES", ^{

        id mockedDelegate = [OCMockObject mockForProtocol:@protocol(JBCameraViewDelegate)];
        AVCaptureConnection *mockedCaptureConnection = [OCMockObject niceMockForClass:[AVCaptureConnection class]];

        JBCameraView *cameraView = [[JBCameraView alloc] initWithCoder:nil];
        cameraView.delegate = mockedDelegate;
        cameraView.callbackOnDidCreateCaptureConnection = YES;

        [[mockedDelegate expect] cameraView:cameraView didCreateCaptureConnection:mockedCaptureConnection];

        [cameraView cameraView:cameraView didCreateCaptureConnection:mockedCaptureConnection];

        [mockedDelegate verify];
    });
});

context(@"assert camera did finish taking picture of 8mpx image", ^{
    it(@"should have an image of specified size correctly orientated with meta", ^{
		JBCameraViewTestDelegate *delegate = [[JBCameraViewTestDelegate alloc] init];
        JBCameraView *cameraView = [[JBCameraView alloc] initWithFrame:CGRectZero];
		cameraView.delegate = delegate;
        id mockedCaptureVideoPreviewLayer = [OCMockObject niceMockForClass:[AVCaptureVideoPreviewLayer class]];
        NSData *imageData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"8mpximage" withExtension:@"png"]];
        UIImage *an8mpxImageAsTakenByCamera = [UIImage imageWithCGImage:[UIImage imageWithData:imageData].CGImage
                                                                  scale:1.0f
                                                            orientation:UIImageOrientationRight];
		CGPoint point = CGPointMake(0.124413,1);
		[[[mockedCaptureVideoPreviewLayer stub] andReturnValue:OCMOCK_VALUE(point)] captureDevicePointOfInterestForPoint:CGPointZero];
		cameraView.videoPreviewLayer = mockedCaptureVideoPreviewLayer;

        [cameraView cameraView:cameraView didFinishTakingPicture:an8mpxImageAsTakenByCamera withInfo:nil meta:nil];

        [[theValue(delegate.image.size) should] equal:theValue(CGSizeMake(2448, 2449))];
        [[theValue(delegate.image.imageOrientation) should] equal:theValue(UIImageOrientationRight)];
        [[[delegate.meta objectForKey:JBCameraViewMetaOriginalImage] should] equal:an8mpxImageAsTakenByCamera];
        BOOL haveEqualCrops = CGRectEqualToRect([[delegate.meta objectForKey:JBCameraViewMetaCrop]CGRectValue], CGRectMake(406.08398f, 0.0f, 2448.0f, 2857.916f));
        [[theValue(haveEqualCrops) should] equal:theValue(YES)];
    });
});

SPEC_END
