//
//  DXViewController.h
//  XDWatermarkDemo
//
//  Created by xieyajie on 13-7-26.
//  Copyright (c) 2013年 xieyajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@interface DXViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *cameraView;
@property (nonatomic, strong) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, strong) IBOutlet UIButton *flashButton;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) UIScrollView *watermarkScroll;

- (IBAction)takePhoto:(id)sender;

- (IBAction)changeFlash:(id)sender;

- (IBAction)saveAction:(id)sender;

- (IBAction)cancelAction:(id)sender;

@end
