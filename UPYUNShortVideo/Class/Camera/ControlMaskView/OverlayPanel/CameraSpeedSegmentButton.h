//
//  CameraSpeedSegmentButton.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/24.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "SegmentButton.h"
#import "OverlayViewProtocol.h"

@interface CameraSpeedSegmentButton : SegmentButton <OverlayViewProtocol>

/**
 触发者
 */
@property (nonatomic, weak) UIControl *sender;

@end
