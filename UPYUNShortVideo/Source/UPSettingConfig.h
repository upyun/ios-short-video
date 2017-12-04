//
//  UPSettingConfig.h
//  UPYUNShortVideo
//
//  Created by lingang on 2017/11/10.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UPSettingConfig : NSObject

/**
 *  采集尺寸
 */
@property (nonatomic, assign) CGSize captureSize;


/**
 *  输出画面分辨率，默认原始采样尺寸输出。
 *  如果设置了输出尺寸，则对画面进行等比例缩放，必要时进行裁剪，保证输出尺寸和预设尺寸一致。
 */
@property (nonatomic) CGSize outputSize;

/**
 *  录制视频的总时长. 达到指定时长后，自动停止录制 (默认0，如设置为 0，则需要手动终止)
 */
@property (nonatomic, assign) Float64 maxRecordingTime;

/**
 *  录制视频的最小时长
 */
@property (nonatomic, assign) Float64 minRecordingTime;


/**
 视频的帧率   注：仅影响视频编码时的内部设置，若设置录制的帧率，请通过 camera.frameRate 进行设置
 */
@property (nonatomic, assign) int32_t lsqEncodeVideoFrameRate;

/**
 视频的码率，单位是Kbps
 */
@property (nonatomic, assign) NSUInteger lsqVideoBitRate;

/**
 相机采集帧率，默认30帧, 期望值, 会根据设备设置一些参数，可以理解为 越好的设备 帧率越接近设定值
 */
@property (nonatomic, assign) int32_t frameRate;


/**
 水印位置
 */
@property (nonatomic, assign) int32_t watermarkPosition;

+ (UPSettingConfig *)defaultConfig;

@end
