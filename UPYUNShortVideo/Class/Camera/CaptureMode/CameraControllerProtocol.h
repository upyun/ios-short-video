//
//  CameraControllerProtocol.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "CaptureModeProtocol.h"
#import "CameraControlMaskView.h"

/**
 拍摄模式对象能访问的相机接口
 */
@protocol CameraControllerProtocol <NSObject>

/**
 相机功能状态协议
 */
@property (nonatomic, strong) id<CaptureModeProtocol> captureMode;

/**
 相机遮罩视图
 */
@property (weak, nonatomic, readonly) CameraControlMaskView *controlMaskView;


/**
 相机预览视图比例
 */
@property (nonatomic, assign, readonly) CGFloat ratio;

/**
 开始录制
 */
- (void)startRecording;

/**
 暂停录制
 */
- (void)pauseRecording;

/**
 结束录制
 */
- (void)finishRecording;

/**
 撤销上一段录制片段
 */
- (void)undoLastRecordedFragment;

/**
 拍摄一张图片

 @param block 完成回调
 */
- (void)capturePhotoAsImageCompletionHandler:(void (^)(UIImage * _Nullable, NSError * _Nullable))block;


@end
