//
//  TuSDKMediaStickerAudioEffectData+Equal.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/16.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TuSDKFramework.h"

@interface TuSDKMediaStickerAudioEffect (Equal)

/**
 判断其他 MV 特效对象与自身是否等同

 @param mvEffect 需要对比的 MV 特效对象
 @return 是否相等
 */
- (BOOL)isEqualToMvEffect:(TuSDKMediaStickerAudioEffect *)mvEffect;

@end
