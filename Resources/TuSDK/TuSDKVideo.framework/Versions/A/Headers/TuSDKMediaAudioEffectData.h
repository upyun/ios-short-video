//
//  TuSDKMediaAudioEffectData.h
//  TuSDKVideo
//
//  Created by wen on 06/07/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKMediaEffectData.h"

/** AudioVolumeChangedBlock */
typedef void(^TuSDKMediaAudioEffectVolumeChangedBlock)(CGFloat);

/**
 * 音乐特效
 */
@interface TuSDKMediaAudioEffectData : TuSDKMediaEffectData


/**
 初始化 TuSDKMediaAudioEffectData
 
 @param audioURL 音效地址
 @return TuSDKMediaAudioEffectData
 */
- (instancetype)initWithAudioURL:(NSURL *)audioURL;

/**
 初始化 TuSDKMediaAudioEffectData
 
 @param audioURL 音效地址
 @param timeRange 时间区间
 @return TuSDKMediaAudioEffectData
 */
- (instancetype)initWithAudioURL:(NSURL *)audioURL atTimeRange:(TuSDKTimeRange *)timeRange;

/**
 本地音频地址
*/
@property (nonatomic,readonly,copy) NSURL *audioURL;

/**
 设置音量大小 （0 - 1）
 @discussion 设置音效的音量大小
 */
@property (nonatomic, assign) CGFloat audioVolume;

/**
  监听音量大小
  @discussion 开发者不应使用该属性
 */
@property (nonatomic,strong) TuSDKMediaAudioEffectVolumeChangedBlock volumeChangedBlock;

@end
