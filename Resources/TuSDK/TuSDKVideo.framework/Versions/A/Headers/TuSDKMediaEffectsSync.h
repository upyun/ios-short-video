//
//  TuSDKMediaEffectsSync.h
//  TuSDKVideo
//
//  Created by sprint on 30/07/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TuSDKMediaEffectData.h"

/**
 特效数据同步器
 @since v3.0
 */
@protocol TuSDKMediaEffectsSync <NSObject>

/**
 播放指定位置的特效
 
 @param time 帧时间
 @since v3.0
 */
- (void)seekTime:(CMTime)time;

/**
 暂停特效
 @since v3.0
 */
- (void)pause;

/**
 验证是否支持该特性类型
 @since v3.0
 @param mediaEffectType 特效类型
 @return true/false
 */
- (BOOL)isSupportedMediaEffectType:(TuSDKMediaEffectDataType)mediaEffectType;

@end
