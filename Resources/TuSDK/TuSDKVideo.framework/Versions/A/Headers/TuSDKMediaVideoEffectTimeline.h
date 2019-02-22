//
//  TuSDKMediaMovieEffectTimeline.h
//  TuSDKVideo
//
//  Created by sprint on 17/09/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "TuSDKMediaEffectTimeline.h"

/**
 特效时间轴.
 对特效数据进行管理
 
 @sicne v3.2.0
 */
@interface TuSDKMediaVideoEffectTimeline : NSObject <TuSDKMediaEffectTimeline>
{
    @protected
    NSMutableDictionary<NSNumber *,NSMutableArray<id<TuSDKMediaEffect>> *> *_allEffectsDic;
}

@end
