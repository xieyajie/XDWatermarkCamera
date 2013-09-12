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

@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *positionButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIScrollView *watermarkScroll;

- (void)takePhoto:(id)sender;

- (void)changeFlash:(id)sender;

- (void)positionCnange:(id)sender;

- (void)saveAction:(id)sender;

- (void)cancelAction:(id)sender;

@end
