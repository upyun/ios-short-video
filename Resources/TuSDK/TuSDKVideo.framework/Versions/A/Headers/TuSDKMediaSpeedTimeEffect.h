//
//  TuSDKMediaSpeedTimeEffect.h
//  TuSDKVideo
//
//  Created by sprint on 27/08/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TuSDKMediaTimeEffect.h"

/**
 快慢速时间特效
 
 @since v3.0
 */
@interface TuSDKMediaSpeedTimeEffect : TuSDKMediaTimeEffect

/**
 速率调整 取值范围：> 0 && <=2. 默认：1 ( > 1 快速播放  < 1 慢速播放)
 @since  v3.0
 */
@property (nonatomic) CGFloat speedRate;

@end
