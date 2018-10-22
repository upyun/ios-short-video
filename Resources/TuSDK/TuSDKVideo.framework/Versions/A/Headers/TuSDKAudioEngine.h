//
//  TuSdkAudioEngine.h
//  TuSDKVideo
//
//  Created by tutu on 2018/7/30.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TuSDKAudioInfo.h"

/**
 音频特效处理引擎
 @since v3.0
 */
@protocol TuSDKAudioEngine <NSObject>

/**
 入列缓存
 @param inputBuffer 输入缓存 （PCM）
 @return 是否已处理
 @since v3.0
 */
- (BOOL)processInputBuffer:(CMSampleBufferRef)inputBuffer;

/**
 入列缓存结束调用
 @return 是否已处理
 @since v3.0
 */
- (BOOL)processInputBufferEnd;

/**
 音频数据处理完成
 @param outputBuffer 应用特效后的音频数据 （PCM）
 @since v3.0
 */
- (void)processOutputBuffer:(CMSampleBufferRef)outputBuffer;

/** 改变输入采样格式
 * @param inputInfo 输入信息
 * @since v3.0
 */
- (void)changeInputAudioInfo:(TuSDKAudioTrackInfo *)inputInfo;

/**
 释放重采样器
 @since v3.0
 */
- (void)destory;

/**
 重置时间戳
 @since v3.0
 */
- (void)reset;

/**
 刷新数据
 @since v3.0
 */
- (void)flush;

@end
