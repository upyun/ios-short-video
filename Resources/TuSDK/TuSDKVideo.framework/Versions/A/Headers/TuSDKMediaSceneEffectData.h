//
//  TuSDKMediaSceneEffectData.h
//  TuSDKVideo
//
//  Created by wen on 27/12/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "TuSDKMediaEffectData.h"

/**
 场景特效
 */
@interface TuSDKMediaSceneEffectData : TuSDKMediaEffectData

/**
 构建场景特效实例
 
 @param effectCode 场景特效code
 @param timeRange 生效时间
 @return TuSDKMediaSceneEffectData
 */
- (instancetype)initWithEffectsCode:(NSString *)effectsCode atTimeRange:(TuSDKTimeRange *)timeRange;

/**
 构建场景特效实例
 
 @param effectCode 场景特效code
 @return TuSDKMediaSceneEffectData
 */
- (instancetype)initWithEffectsCode:(NSString *)effectsCode;

/**
 特效code
 */
@property (nonatomic, copy,readonly) NSString * effectsCode;

@end
