//
//  LongPressCaptureMode.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CaptureModeProtocol.h"

/**
 长按录制模式
 */
@interface LongPressCaptureMode : NSObject<CaptureModeProtocol>

/**
 录制相机控制器
 */
@property (nonatomic, weak) id<CameraControllerProtocol> cameraController;

@end
