//
//  DXViewController.m
//  XDWatermarkDemo
//
//  Created by xieyajie on 13-7-26.
//  Copyright (c) 2013年 xieyajie. All rights reserved.
//

#import "DXViewController.h"

@interface DXViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_captureInput;
    AVCaptureVideoDataOutput *_captureOutput;
    AVCaptureVideoPreviewLayer *_preview;
}

@end

@implementation DXViewController

@synthesize cameraView = _cameraView;
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

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
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
    _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [_captureOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA],(id)kCVPixelBufferPixelFormatTypeKey,nil];
    [_captureOutput setVideoSettings:outputSettings];
	[_session addOutput:_captureOutput];
    
    [_session startRunning];
}

- (void)initWaterScroll
{
    _watermarkScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    _watermarkScroll.contentSize = CGSizeMake(320 * 3, _watermarkScroll.frame.size.height);
    _watermarkScroll.backgroundColor = [UIColor clearColor];
    CGFloat width = 320;
    for (int i = 0; i < 3; i++) {
        NSString *imgName = [NSString stringWithFormat:@"%i.jpg", (i + 1)];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        imgView.frame = CGRectMake(i * width, 95 * i, width, 95);
        [_watermarkScroll addSubview:imgView];
    }
    [self.cameraView.layer addSublayer:_watermarkScroll.layer];
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace)
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
                                                              NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    // Create and return an image object representing the specified Quartz image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}



@end
