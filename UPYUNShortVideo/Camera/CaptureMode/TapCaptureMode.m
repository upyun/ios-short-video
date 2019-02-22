//
//  TapCaptureMode.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TapCaptureMode.h"
#import "CameraControllerProtocol.h"
#import "RecordButton.h"

@interface TapCaptureMode ()<RecordButtonDelegate>

/**
 录制按钮
 */
@property (nonatomic, strong) RecordButton *recordButton;

@end

@implementation TapCaptureMode

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
    [captureButton switchStyle:RecordButtonStyleVideo2];
    captureButton.panEnable = NO;
    
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
            _recordButton.selected = NO;
            [self pauseRecordAction];
        } break;
        case lsqRecordStateRecording:{
            
        } break;
        case lsqRecordStateCanceled:{
            _recordButton.selected = NO;
            _cameraController.controlMaskView.moreMenuView.disableRatioSwitching = NO;
            [_cameraController.controlMaskView showViewsWhenPauseRecording];
        } break;
        case lsqRecordStateSaveingCompleted:
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

- (void)resetUI {
    [_cameraController.controlMaskView.markableProgressView reset];
    [_cameraController.controlMaskView updateRecordConfrimViewsDisplay];
}

#pragma mark - 按钮事件

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
    sender.selected = !sender.selected;
    _recordButton = sender;
    if (sender.selected) {
        [_cameraController startRecording];
        // 更新 UI
        [_cameraController.controlMaskView hideViewsWhenRecording];
    } else {
        [_cameraController pauseRecording];
    }
    _cameraController.controlMaskView.moreMenuView.disableRatioSwitching = YES;
}

@end
