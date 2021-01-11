//
//  CaptureModeProtocol.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKFramework.h"

@protocol CameraControllerProtocol;

/**
 拍摄模式协议
 */
@protocol CaptureModeProtocol <NSObject>

/**
 相机控制器
 */
@property (nonatomic, weak) id<CameraControllerProtocol> cameraController;

/**
 初始化

 @param cameraController 录制相机控制器
 @return 相机控制器
 */
- (instancetype)initWithCameraController:(id<CameraControllerProtocol>)cameraController;

/**
 更新拍摄模式界面
 */
- (void)updateModeUI;

/**
 恢复初始状态 UI
 */
- (void)resetUI;

@optional
#pragma mark 同步相机回调

/**
 录制进度

 @param progress 进度百分比
 */
- (void)recordProgressDidChange:(double)progress;

/**
 录制状态

 @param state 相机的录制状态
 */
- (void)recordStateDidChange:(lsqRecordState)state;

- (void)recordButtonDidTouchDown:(UIButton *)sender;

@end
