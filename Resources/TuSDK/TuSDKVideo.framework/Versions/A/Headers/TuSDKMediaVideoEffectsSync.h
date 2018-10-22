//
//  TuSDKMediaVideoEffectsSync.h
//  TuSDKVideo
//
//  Created by sprint on 30/07/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKMediaEffectsSync.h"
#import "TuSDKVideoImport.h"
#import "TuSDKMediaEffectsTimeline.h"
#import "TuSDKComboFilterWrapChain.h"

@protocol TuSDKMediaVideoEffectsSyncDelegate;

/**
 视频特效同步器
 @sinc v3.0
 */
@interface TuSDKMediaVideoEffectsSync : NSObject <TuSDKMediaEffectsSync,TuSDKMediaEffectsTimelineProtocol>

/**
 根据特效乐谱演奏特效
 
 @param timeline 时间轴
 @return TuSDKMediaVideoEffectsSync
 @sinc v3.0
 */
- (instancetype)initWithTimeline:(id<TuSDKMediaEffectsTimelineProtocol>)timeline playground:(TuSDKComboFilterWrapChain *)playground;

/**
 TuSDKMediaVideoEffectsSync 委托
 @sinc v3.0
 */
@property (nonatomic,weak) id<TuSDKMediaVideoEffectsSyncDelegate> delegate;

/**
 特效数据分布时间线
 @sinc v3.0
 */
@property (nonatomic,readonly) TuSDKMediaEffectsTimeline *mediaEffectsTimeline;

/**
 预览的分辨率
 @sinc v3.0
 */
@property (nonatomic)CGSize outputSize;

/**
 预览时裁剪范围
 @sinc v3.0
 */
@property (nonatomic,assign) CGRect cropRect;

/**
 通知正在应用的特效
 
 @param mediaEffectData 特效信息
 @sinc v3.0
 */
- (void)notifyApplyingMediaEffect:(TuSDKMediaEffectData *)mediaEffectData;

/**
 通知正在应用的特效
 
 @param mediaEffects 特效信息
 @sinc v3.0
 */
- (void)notifyDidRemoveMediaEffects:(NSArray<TuSDKMediaEffectData *> *) mediaEffects;

@end

/**
 TuSDKMediaVideoEffectsSyncDelegate
 @sinc v3.0
 */
@protocol TuSDKMediaVideoEffectsSyncDelegate <NSObject,TuSDKMediaEffectsTimelineDelegate>

@optional

/**
 当前正在应用的特效
 
 @param composition 合成器
 @param applyingMediaEffectData 正在预览特效
 @since v2.2.0
 */
- (void)mediaEffectsSync:(TuSDKMediaVideoEffectsSync *)composition didApplyingMediaEffect:(TuSDKMediaEffectData *)mediaEffectData;

@end

