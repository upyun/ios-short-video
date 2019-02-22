//
//  APIAudioPitchEngineRecorder.h
//  TuSDKVideo
//
//  Created by sprint on 2018/11/28.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "APIAudioPitchEngineRecorder.h"
#import "TuSDKFramework.h"

@protocol APIAudioPitchEngineRecorderDelegate;

/**
 音频录制
 支持变声及快慢速调节
 @since v3.0
 */
@interface APIAudioPitchEngineRecorder : NSObject

/**
 录音代理
 @since v3.0
 */
@property (nonatomic, weak) id<APIAudioPitchEngineRecorderDelegate> delegate;

/**
 录音音调类型, 设置音调后速度设置失效
 @since v3.0
 */
@property (nonatomic, assign) TuSDKSoundPitchType pitchType;

/**
 临时写入文件
 @since v3.0
 */
@property (nonatomic, copy) NSString *outputFilePath;

/**
 是否在录音
 @since v3.0
 */
@property (nonatomic, assign) BOOL isRecording;


/**
 开始录音
 @since  v3.0
 */
- (void)startRecord;

/**
 停止录音
 @since  v3.0
 */
- (void)stopRecord;

/**
 取消录音
 @since  v3.0
 */
- (void)cancelRecord;

@end

#pragma mark - TuSDKMediaAssetAudioRecorderDelegate

/**
 TuSDKMediaAssetAudioRecorder 委托
 @since v3.0
 */
@protocol APIAudioPitchEngineRecorderDelegate <NSObject>

@required
/**
 录制完成
 @param mediaAssetAudioRecorde 录制对象
 @param filePath 录制结果
 @since v3.0
 */
- (void)mediaAssetAudioRecorder:(APIAudioPitchEngineRecorder *)mediaAssetAudioRecorde filePath:(NSString *)filePath;

@end
