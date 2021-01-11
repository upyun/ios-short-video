//
//  CameraViewController.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseViewController.h"
#import "CameraControllerProtocol.h"

/**
 录制相机视图控制器
 */
@interface CameraViewController : BaseViewController <CameraControllerProtocol>

/**
 相机模式
 */
@property (nonatomic, strong) id<CaptureModeProtocol> captureMode;

/**
 相机页面遮罩视图
 */
@property (weak, nonatomic) IBOutlet CameraControlMaskView *controlMaskView;

/**
 相机控制器

 @return 控制器
 */
+ (instancetype)recordController;

/**
 应用默认美颜特效
 */
- (void)applySkinFaceEffect;

@end
