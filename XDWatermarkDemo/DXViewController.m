//
//  DXViewController.m
//  XDWatermarkDemo
//
//  Created by xieyajie on 13-7-26.
//  Copyright (c) 2013年 xieyajie. All rights reserved.
//

#import <ImageIO/ImageIO.h>

#import "DXViewController.h"

@interface DXViewController ()
{
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_captureInput;
    AVCaptureStillImageOutput *_captureOutput;
    AVCaptureVideoPreviewLayer *_preview;
    UIImageOrientation g_orientation_;
}

@end

@implementation DXViewController

@synthesize cameraView = _cameraView;
@synthesize takePhotoButton = _takePhotoButton;
@synthesize watermarkScroll = _watermarkScroll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession: _session];
    _preview.frame = self.cameraView.frame;
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.cameraView.layer addSublayer: _preview];
    
    [self initWaterScroll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void) initialize
{
    //1.创建会话层
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPreset640x480];
    
    //2.创建、配置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSError *error;
	_captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!_captureInput)
	{
		NSLog(@"Error: %@", error);
		return;
	}
    [_session addInput:_captureInput];
    
    
    //3.创建、配置输出
    _captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [_captureOutput setOutputSettings:outputSettings];
	[_session addOutput:_captureOutput];
    
    [_session startRunning];
}

- (void)initWaterScroll
{
    _watermarkScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.cameraView.frame.size.height)];
    _watermarkScroll.contentSize = CGSizeMake(320 * 3, _watermarkScroll.frame.size.height);
    _watermarkScroll.pagingEnabled = YES;
    _watermarkScroll.backgroundColor = [UIColor clearColor];
    CGFloat width = 320;
    for (int i = 0; i < 3; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];
        imgView.frame = CGRectMake(i * width, 95 * i, width, 95);
        [_watermarkScroll addSubview:imgView];
    }
    [self.cameraView.layer addSublayer:_watermarkScroll.layer];
}

- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [CATransaction begin];
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        g_orientation_ = UIImageOrientationLeft;
        _preview.orientation = AVCaptureVideoOrientationLandscapeRight;
        
    }else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        g_orientation_ = UIImageOrientationRight;
        _preview.orientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    [CATransaction commit];
}

- (IBAction)takePhoto:(id)sender
{
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    [_captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         CFDictionaryRef exifAttachments =
         CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             // Do something with the attachments.
         }
         // Continue as appropriate.
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData] ;

         CGPoint point = self.watermarkScroll.contentOffset;
         NSInteger index = self.watermarkScroll.contentOffset.x / 320;
         UIImage *waterImage = [UIImage imageNamed:@"1.jpg"];
         UIImage *finishImage = [self composeImage:waterImage toImage:image atFrame:CGRectMake(0, 95 * index, 320, 95)];
         UIImageWriteToSavedPhotosAlbum(finishImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
     }];
}

- (UIImage *)composeImage:(UIImage *)subImage toImage:(UIImage *)superImage atFrame:(CGRect)frame
{
    CGSize superSize = superImage.size;
    CGFloat widthScale = frame.size.width / self.cameraView.frame.size.width;
    CGFloat heightScale = frame.size.height / self.cameraView.frame.size.height;
    CGFloat xScale = frame.origin.x / self.cameraView.frame.size.width;
    CGFloat yScale = frame.origin.y / self.cameraView.frame.size.height;
    CGRect subFrame = CGRectMake(xScale * superSize.width, yScale * superSize.height, widthScale * superSize.width, heightScale * superSize.height);
    
    UIGraphicsBeginImageContext(superSize);
    [superImage drawInRect:CGRectMake(0, 0, superSize.width, superSize.height)];
    [subImage drawInRect:subFrame];
    __autoreleasing UIImage *finish = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finish;
}

-(void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message…
        NSLog(@"save error");
        
    }
    else  // No errors
    {
        // Show message image successfully saved
         NSLog(@"save success");
    }
}



@end
