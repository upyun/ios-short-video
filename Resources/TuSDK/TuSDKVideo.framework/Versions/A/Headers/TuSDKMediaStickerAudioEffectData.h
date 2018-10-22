//
//  TuSDKMediaStickerAudioEffectData.h
//  TuSDKVideo
//
//  Created by wen on 06/07/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKVideoImport.h"
#import "TuSDKMediaEffectData.h"
#import "TuSDKMediaStickerEffectData.h"
#import "TuSDKMediaAudioEffectData.h"

/**
 video MV 特效
 */
@interface TuSDKMediaStickerAudioEffectData : TuSDKMediaEffectData

/**
 初始化MV特效
 
 @param audioURL 音效地址
 @param stickerGroup 贴纸组
 @return TuSDKMediaStickerAudioEffectData
 */
- (instancetype)initWithAudioURL:(NSURL *)audioURL stickerGroup:(TuSDKPFStickerGroup *)stickerGroup;

/**
 初始化MV特效
 
 @param audioURL 音效地址
 @param stickerGroup 贴纸组
 @param timeRange 时间区间
 @return TuSDKMediaStickerAudioEffectData
 */
- (instancetype)initWithAudioURL:(NSURL *)audioURL stickerGroup:(TuSDKPFStickerGroup *)stickerGroup atTimeRange:(TuSDKTimeRange *)timeRange;


/**
 本地音频地址
*/
@property (nonatomic,readonly) TuSDKMediaAudioEffectData *audioEffect;

/**
 贴纸数据
 */
@property (nonatomic,strong,readonly) TuSDKMediaStickerEffectData *stickerEffect;

/**
 音频音量
 */
@property (nonatomic, assign) CGFloat audioVolume;


@end
