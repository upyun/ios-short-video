//
//  PitchSegmentButton.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/9/26.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "SegmentButton.h"
#import "TuSDKFramework.h"

/**
 变声分段按钮
 */
@interface PitchSegmentButton : SegmentButton

/**
 变声音效的类型
 */
@property (nonatomic, assign) TuSDKSoundPitchType pitchType;

@end
