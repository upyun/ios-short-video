//
//  LongPressCaptureMode.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "LongPressCaptureMode.h"
#import "RecordButton.h"
#import "CameraControllerProtocol.h"

@interface LongPressCaptureMode ()<RecordButtonDelegate>

@end

@implementation LongPressCaptureMode

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
    
    [_cameraController.controlMaskView.doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraController.controlMaskView.undoButton addTarget:self action:@selector(undoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 更新界面
 */
- (void)updateModeUI {
    RecordButton *captureButton = _cameraController.controlMaskView.captureButton;
    [captureButton switchStyle:RecordButtonStyleVideo1];
    captureButton.panEnable = YES;
    
    _cameraController.controlMaskView.moreMenuView.pitchHidden = NO;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.cameraController.controlMaskView.speedButton.hidden = NO;
        [self.cameraController.controlMaskView updateSpeedSegmentDisplay];
        self.cameraController.controlMaskView.markableProgressView.hidden = NO;
    } completion:^(BOOL finished) {
        
    }];
}

/**
 相机录制状态

 @param state 相机录制状态
 */
- (void)recordStateDidChange:(lsqRecordState)state {
    switch (state) {
        case lsqRecordStatePaused:{
            [self pauseRecordAction];
        } break;
        case lsqRecordStateRecording:{
            
        } break;
        case lsqRecordStateSaveingCompleted:
        case lsqRecordStateCanceled:
            _cameraController.controlMaskView.moreMenuView.disableRatioSwitching = NO;
            break;
        default:{} break;
    }
}

/**
 录制进度

 @param progress 进度百分比
 */
- (void)recordProgressDidChange:(double)progress {
    _cameraController.controlMaskView.markableProgressView.progress = progress;
}

/**
 重置状态
 */
- (void)resetUI {
    [_cameraController.controlMaskView.markableProgressView reset];
    [_cameraController.controlMaskView updateRecordConfrimViewsDisplay];
}

#pragma mark - action

/**
 完成录制事件

 @param sender 录制按钮
 */
- (void)doneButtonAction:(UIButton *)sender {
    [_cameraController finishRecording];
}

/**
 撤销上一段事件

 @param sender 录制按钮
 */
- (void)undoButtonAction:(UIButton *)sender {
    [_cameraController undoLastRecordedFragment];
    // 更新 UI
    [_cameraController.controlMaskView.markableProgressView popMark];
    [_cameraController.controlMaskView updateRecordConfrimViewsDisplay];
}

#pragma mark - private

/**
 暂停录制动作
 */
- (void)pauseRecordAction {
    [_cameraController.controlMaskView.markableProgressView pushMark];
    [_cameraController.controlMaskView showViewsWhenPauseRecording];
}

#pragma mark - RecordButtonDelegate

/**
 录制按钮按下回调
 */
- (void)recordButtonDidTouchDown:(RecordButton *)sender {
    [_cameraController startRecording];
    // 更新 UI
    sender.selected = YES;
    [_cameraController.controlMaskView hideViewsWhenRecording];
    _cameraController.controlMaskView.moreMenuView.disableRatioSwitching = YES;
}

/**
 录制按钮抬起或结束触摸回调
 */
- (void)recordButtonDidTouchEnd:(RecordButton *)sender {
    [_cameraController pauseRecording];
    sender.selected = NO;
}

@end
