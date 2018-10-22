//
//  TuSDKMediaEffectsTimelineProtocol.h
//  TuSDKVideo
//
//  Created by sprint on 30/07/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKMediaEffectData.h"
#import "TuSDKMediaSceneEffectData.h"
#import "TuSDKMediaStickerEffectData.h"
#import "TuSDKMediaParticleEffectData.h"
#import "TuSDKMediaStickerAudioEffectData.h"
#import "TuSDKMediaAudioEffectData.h"
#import "TuSDKMediaFilterEffectData.h"

typedef NSDictionary<NSNumber *,NSArray<TuSDKMediaEffectData *> *> * TuSDKMediaEffectsSearcherResult;

/**
 特效时间轴
 @since v3.0
 */
@protocol TuSDKMediaEffectsTimelineProtocol <NSObject>

/**
 添加音频特效数据
 
 @param mediaEffect TuSDKMediaEffectData
 @return true/false
 @since      v2.2.0
 */
- (BOOL)addMediaEffect:(TuSDKMediaEffectData *)mediaEffect;

/**
 移除特效数据
 
 @param mediaEffect TuSDKMediaEffectData
 @return true/false
 @since      v2.2.0
 */
- (BOOL)removeMediaEffect:(TuSDKMediaEffectData *)mediaEffect;

/**
 移除制定类型的特效信息
 
 @param mediaEffect 特效类型
 @since      v2.2.0
 */
- (void)removeMediaEffectsWithType:(TuSDKMediaEffectDataType)effectType;

/**
 获取指定类型的特效信息
 
 @param type TuSDKMediaEffectDataType
 @return TuSDKMediaEffectData
 @since      v2.2.0
 */
- (NSArray<id> *)mediaEffectsWithType:(TuSDKMediaEffectDataType)effectType;

/**
 获取指定类型的特效信息
 
 @return NSArray<TuSDKMediaEffectData *> *
 @since      v3.0
 */
- (NSArray<TuSDKMediaEffectData *> *)mediaEffects;

/**
 移除所有特效
 @since      v2.2.0
 */
- (void)removeAllMediaEffect;

/**
 重置所有特效
 @since      v2.2.0
 */
- (void)resetAllMediaEffects;

/**
 搜索指定特效 搜索后通过 getResult 获取
 
 @param time CMTime
 @since      v2.2.0
 */
- (void)seekTime:(CMTime)time;

/**
 销毁特效
 @since      v2.2.0
 */
- (void)destory;

@end

