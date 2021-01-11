//
//  PhotoCaptureMode.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "PhotoCaptureMode.h"
#import "CameraControllerProtocol.h"
#import "RecordButton.h"
#import "TuSDKFramework.h"

@interface PhotoCaptureMode ()<RecordButtonDelegate>

/**
 拍照结果
 */
@property (nonatomic, strong) UIImage *capturedImage;

@end

@implementation PhotoCaptureMode

/**
 初始化相机控制器
 
 @param cameraController 相机控制器
 @return 相机控制器
 */
- (instancetype)initWithCameraController:(id<CameraControllerProtocol>)cameraController {
    if (self = [super init]) {
        _cameraController = cameraController;
        [self commonInit];
    }
    return self;
}

/**
 创建按钮
 */
- (void)commonInit {
    RecordButton *captureButton = _cameraController.controlMaskView.captureButton;
    [captureButton addDelegate:self];
}

/**
 更新界面
 */
- (void)updateModeUI {
    RecordButton *captureButton = _cameraController.controlMaskView.captureButton;
    [captureButton switchStyle:RecordButtonStylePhoto];
    captureButton.panEnable = NO;
    
    _cameraController.controlMaskView.moreMenuView.pitchHidden = YES;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.cameraController.controlMaskView.speedButton.hidden = YES;
        [self.cameraController.controlMaskView updateSpeedSegmentDisplay];
        self.cameraController.controlMaskView.markableProgressView.hidden = YES;
    } completion:^(BOOL finished) {
        
    }];
}

/**
 重置
 */
- (void)resetUI {}

#pragma mark - 按钮事件

/**
 完成按钮事件

 @param sender 录制按钮（拍照功能）
 */
- (void)doneButtonAction:(UIButton *)sender {

    // 保存到相册
    [TuSDKTSAssetsManager saveWithImage:_capturedImage compress:0 metadata: nil toAblum:nil completionBlock:^(id<TuSDKTSAssetInterface> asset, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.capturedImage = nil;
                [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_保存成功", @"VideoDemo", @"保存成功")];
            });
        }
    } ablumCompletionBlock:nil];
    [_cameraController.controlMaskView hidePhotoCaptureConfirmView];
}

/**
 返回按钮事件

 @param sender 录制按钮（拍照功能）
 */
- (void)backButtonAction:(UIButton *)sender {
    [_cameraController.controlMaskView hidePhotoCaptureConfirmView];
}

#pragma mark - RecordButtonDelegate

/**
 录制按钮按下回调
 */
- (void)recordButtonDidTouchDown:(RecordButton *)sender {
    sender.selected = YES;
}

/**
 录制按钮抬起或结束触摸回调
 */
- (void)recordButtonDidTouchEnd:(RecordButton *)sender {
    sender.selected = NO;
    
    [self.cameraController capturePhotoAsImageCompletionHandler:^(UIImage * capturedImage, NSError * error) {
        
        if (error) return;
        
        self.capturedImage = capturedImage;

        CGFloat ratio = self.cameraController.ratio;
        [self->_cameraController.controlMaskView showPhotoCaptureConfirmViewWithConfig:^(PhotoCaptureConfirmView *confirmView) {

            confirmView.photoView.image = capturedImage;
            [confirmView.doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [confirmView.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            confirmView.photoRatio = ratio;
        }];
        
    }];;
    
}

@end
