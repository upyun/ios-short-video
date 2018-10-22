//
//  TuSDKAudioRecordConvert.h
//  TuSDKVideo
//
//  Created by tutu on 2018/7/26.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TuSDKAudioPitchEngine.h"
#import "TuSDKMediaAudioRecorder.h"

@protocol TuSDKMediaAssetAudioRecorderDelegate;

/**
 音频录制
 支持变声及快慢速调节
 @since v3.0
 */
@interface TuSDKMediaAssetAudioRecorder : NSObject <TuSDKMediaAudioRecorder>

/**
 录音代理
 @since v3.0
 */
@property (nonatomic, weak) id<TuSDKMediaAssetAudioRecorderDelegate> delegate;

/**
 录音音调类型, 设置音调后速度设置失效
 @since v3.0
 */
@property (nonatomic, assign) TuSDKSoundPitchType pitchType;

/**
 录音速度, 设置速度后音调设置失效
 @since v3.0
 */
@property (nonatomic, assign) float speed;

/**
 删除最后一个音频片段
 @since v3.0
 */
- (void)popAudioFragment;

@end

#pragma mark - TuSDKMediaAssetAudioRecorderDelegate

/**
 TuSDKMediaAssetAudioRecorder 委托
 @since v3.0
 */
@protocol TuSDKMediaAssetAudioRecorderDelegate <NSObject>

/**
 录制完成
 @param mediaAssetAudioRecorde 录制对象
 @param filePath 录制结果
 @since v3.0
 */
- (void)mediaAssetAudioRecorder:(TuSDKMediaAssetAudioRecorder *)mediaAssetAudioRecorde filePath:(NSString *)filePath;

@end
