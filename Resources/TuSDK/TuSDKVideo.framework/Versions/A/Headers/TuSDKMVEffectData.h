//
//  TuSDKMVEffectData.h
//  TuSDKVideo
//
//  Created by gh.li on 2017/5/2.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TuSDKTimeRange.h"

/**
 * MV效果类型
 */
typedef enum
{
    lsqMVEffectDataTypeStickerAudio
    
} lsqMVEffectDataType;




@interface TuSDKMVEffectData : NSObject
{
    lsqMVEffectDataType _effectType;
}


/**
 * 开始时间
 */
@property (nonatomic,assign) CGFloat startTime;

/**
 * 结束时间
 */
@property (nonatomic,assign) CGFloat endTime;

/**
 * MV效果类型
 */
@property (nonatomic,assign,readonly) lsqMVEffectDataType effectType;


- (instancetype)initEffectInfoWithStart:(CGFloat)startTime end:(CGFloat)endTime type:(lsqMVEffectDataType)effectType;
@end
