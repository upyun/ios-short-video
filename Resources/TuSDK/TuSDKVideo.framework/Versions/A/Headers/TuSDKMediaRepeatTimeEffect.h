//
//  TuSDKMediaRepeatTimeEffect.h
//  TuSDKVideo
//
//  Created by sprint on 27/08/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKMediaTimeEffect.h"

/**
 反复特效
 
 @since v3.0
 */
@interface TuSDKMediaRepeatTimeEffect : TuSDKMediaTimeEffect

/**
 反复次数 > 0  默认 : 1
 
 @since v3.0
 */
@property (nonatomic) NSUInteger repeatCount;


@end
