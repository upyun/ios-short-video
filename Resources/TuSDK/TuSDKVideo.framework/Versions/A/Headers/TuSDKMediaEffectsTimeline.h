//
//  TuSDKMediaEffectsTimeline.h
//  TuSDKVideo
//
//  Created by sprint on 17/05/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "TuSDKMediaEffectData.h"
#import "TuSDKMediaSceneEffectData.h"
#import "TuSDKMediaStickerEffectData.h"
#import "TuSDKMediaParticleEffectData.h"
#import "TuSDKMediaStickerAudioEffectData.h"
#import "TuSDKMediaAudioEffectData.h"
#import "TuSDKMediaFilterEffectData.h"

#import "TuSDKMediaEffectsTimelineProtocol.h"

@class TuSDKMediaEffectsTimeline;

/**
  特效事件委托
  @since      v2.2.0
 */
@protocol TuSDKMediaEffectsTimelineDelegate <NSObject>

@optional

/**
  特效被移除通知
 
 @param mediaEffectsTimeline TuSDKMediaEffectTimeline
 @param mediaEffects 被移除的特效列表
 @since      v2.2.0
 */
- (void)mediaEffectsTimeline:(TuSDKMediaEffectsTimeline *)mediaEffectsTimeline didRemoveMediaEffects:(NSArray<TuSDKMediaEffectData *> *) mediaEffects;

@end

/**
 特效数据分布时间轴
 @since      v2.2.0
 */
@interface TuSDKMediaEffectsTimeline : NSObject <TuSDKMediaEffectsTimelineProtocol>

/**
 特效信息时间委托
 */
@property (nonatomic,weak) id<TuSDKMediaEffectsTimelineDelegate> delegate;


@end


#pragma mark - 检索数据

@interface TuSDKMediaEffectsTimeline(Seek)

/**
 获取当前特效数据
 
 @return TuSDKMediaEffectsSearcherResult
 @since      v2.2.0
 */
- (TuSDKMediaEffectsSearcherResult)getResult;

/*
 获取当前取消的特效
 
 @return     NSArray<TuSDKMediaEffectData *> *
 @since      v2.2.0
 */
- (NSArray<TuSDKMediaEffectData *> *)getUndockResult;

@end


