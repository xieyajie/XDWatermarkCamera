//
//  DXViewController.m
//  XDWatermarkDemo
//
//  Created by xieyajie on 13-7-26.
//  Copyright (c) 2013年 xieyajie. All rights reserved.
//

#import <ImageIO/ImageIO.h>

#import "DXViewController.h"

#import "GPUImage.h"

@interface DXViewController ()
{
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_captureInput;
    AVCaptureStillImageOutput *_captureOutput;
    AVCaptureVideoPreviewLayer *_preview;
    AVCaptureDevice *_device;
    
    UIImage *_finishImage;
}

@end

@implementation DXViewController

@synthesize cameraView = _cameraView;
@synthesize takePhotoButton = _takePhotoButton;
@synthesize watermarkScroll = _watermarkScroll;
@synthesize flashButton = _flashButton;
@synthesize positionButton = _positionButton;

@synthesize topView = _topView;
@synthesize bottomView = _bottomView;

@synthesize saveButton = _saveButton;
@synthesize cancelButton = _cancelButton;

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    CGSize size = [[UIScreen mainScreen] bounds].size;
//    self.topView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
//    self.bottomView.frame = CGRectMake(0, size.height - 65.0, self.view.frame.size.width, 65.0);
//    self.cameraView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, self.view.frame.size.width, size.height - self.topView.frame.size.height - self.bottomView.frame.size.height);

    [self layoutSubviews];
    [self initialize];
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession: _session];
    _preview.frame = CGRectMake(0, 0, self.cameraView.frame.size.width, self.cameraView.frame.size.height);
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.cameraView.layer addSublayer:_preview];
     [_session startRunning];
    
    [self initWaterScroll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self addHollowOpenToView:self.cameraView];
}

#pragma mark - private

- (void)layoutSubviews
{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _topView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_topView];
    
    _flashButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 70, _topView.frame.size.height)];
    _flashButton.contentMode = UIViewContentModeScaleAspectFit;
    [_flashButton setImage:[UIImage imageNamed:@"flash-auto.png"] forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(changeFlash:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_flashButton];
    
    _positionButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 70, 0, 70, _topView.frame.size.height)];
    _positionButton.contentMode = UIViewContentModeScaleAspectFit;
    [_positionButton setImage:[UIImage imageNamed:@"front-camera.png"] forState:UIControlStateNormal];
    [_positionButton addTarget:self action:@selector(positionCnange:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_positionButton];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 65.0, self.view.frame.size.width, 65.0)];
    _bottomView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_bottomView];
    
    _takePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, (_bottomView.frame.size.height - 40) / 2, 100, 40)];
    _takePhotoButton.contentMode = UIViewContentModeScaleAspectFit | UIViewContentModeCenter;
    [_takePhotoButton setImage:[UIImage imageNamed:@"camera-icon.png"] forState:UIControlStateNormal];
    [_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"camera-button.png"] forState:UIControlStateNormal];
    [_takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_takePhotoButton];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 70, _bottomView.frame.size.height)];
    _cancelButton.contentMode = UIViewContentModeScaleAspectFit;
    [_cancelButton setImage:[UIImage imageNamed:@"cancle.png"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.hidden = YES;
    [_bottomView addSubview:_cancelButton];
    
    _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 70, 0, 70, _bottomView.frame.size.height)];
    _saveButton.contentMode = UIViewContentModeScaleAspectFit;
    [_saveButton setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.hidden = YES;
    [_bottomView addSubview:_saveButton];
    
    _cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.topView.frame.size.height - self.bottomView.frame.size.height)];
    [self.view addSubview:_cameraView];
}

- (void) initialize
{
    //1.创建会话层
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPreset640x480];
    
    //2.创建、配置输入设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [_device lockForConfiguration:nil];
    if([_device flashMode] == AVCaptureFlashModeOff){
        [_flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
    }
    else if([_device flashMode] == AVCaptureFlashModeAuto){
        [_flashButton setImage:[UIImage imageNamed:@"flash-auto"] forState:UIControlStateNormal];
    }
    else{
        [_flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    }
    [_device unlockForConfiguration];

	NSError *error;
	_captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
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

- (void)addHollowOpenToView:(UIView *)view
{
//    CATransition *animation = [CATransition animation];
//    animation.duration = 0.5f;
//    animation.delegate = self;
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//    animation.fillMode = kCAFillModeForwards;
//    animation.type = @"cameraIrisHollowOpen";
//    [view.layer addAnimation:animation forKey:@"animation"];
}

- (void)addHollowCloseToView:(UIView *)view
{
//    CATransition *animation = [CATransition animation];//初始化动画
//    animation.duration = 0.5f;//间隔的时间
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//    animation.type = @"cameraIrisHollowClose";
//    
//    [view.layer addAnimation:animation forKey:@"HollowClose"];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}


#pragma mark - button

- (void)takePhoto:(id)sender
{
    [self addHollowCloseToView:self.cameraView];
    
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
         _saveButton.hidden = NO;
         _cancelButton.hidden = NO;
         [self addHollowCloseToView:self.cameraView];
         [_session stopRunning];
         [self addHollowOpenToView:self.cameraView];
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             // Do something with the attachments.
         }
         // Continue as appropriate.
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         _finishImage = [[UIImage alloc] initWithData:imageData] ;
     }];
}

- (void)changeFlash:(id)sender
{
    BOOL re=[_device hasFlash];
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && [_device hasFlash])
    {
        [_flashButton setEnabled:NO];
        [_device lockForConfiguration:nil];
        if([_device flashMode] == AVCaptureFlashModeOff)
        {
            [_device setFlashMode:AVCaptureFlashModeAuto];
            [_flashButton setImage:[UIImage imageNamed:@"flash-auto"] forState:UIControlStateNormal];
        }
        else if([_device flashMode] == AVCaptureFlashModeAuto)
        {
            [_device setFlashMode:AVCaptureFlashModeOn];
            [_flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
        }
        else{
            [_device setFlashMode:AVCaptureFlashModeOff];
            [_flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
        }
        [_device unlockForConfiguration];
        [_flashButton setEnabled:YES];
    }
}

- (void)positionCnange:(id)sender
{
    //添加动画
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = .8f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"oglFlip";
    if (_device.position == AVCaptureDevicePositionFront) {
        animation.subtype = kCATransitionFromRight;
    }
    else if(_device.position == AVCaptureDevicePositionBack){
        animation.subtype = kCATransitionFromLeft;
    }
    [_preview addAnimation:animation forKey:@"animation"];
    
    NSArray *inputs = _session.inputs;
    for ( AVCaptureDeviceInput *input in inputs )
    {
        AVCaptureDevice *device = input.device;
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            else
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            }
            _device = newCamera;
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [_session beginConfiguration];
            
            [_session removeInput:input];
            [_session addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [_session commitConfiguration];
            break;
        }
    }
}

- (void)saveAction:(id)sender
{
    UIImage *image = _finishImage;
    NSInteger index = self.watermarkScroll.contentOffset.x / 320;
    UIImage *waterImage = [UIImage imageNamed:@"1.jpg"];
    _finishImage = [self composeImage:waterImage toImage:image atFrame:CGRectMake(0, 95 * index, 320, 95)];
    
    UIImageWriteToSavedPhotosAlbum(_finishImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    _saveButton.hidden = YES;
    _cancelButton.hidden = YES;
    [_session startRunning];
}

- (void)cancelAction:(id)sender
{
    _saveButton.hidden = YES;
    _cancelButton.hidden = YES;
    [_session startRunning];
}


@end
