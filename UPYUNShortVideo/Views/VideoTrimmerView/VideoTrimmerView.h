//
//  VideoTrimmerView.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/22.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoTrimmerViewProtocol.h"

/**
 视频时间修整器
 */
@interface VideoTrimmerView : UIView <VideoTrimmerViewProtocol>

/**
 视频帧缩略图视图
 */
@property (nonatomic, strong, readonly) VideoThumbnailsView *thumbnailsView;

/**
 区间选择视图
 */
@property (nonatomic, strong, readonly) UIView *trimmerMaskView;

/**
 当前进度
 */
@property (nonatomic, assign) double currentProgress;

/**
 最大选取占比
 */
@property (nonatomic, assign) double maxIntervalProgress;

/**
 最小选取占比
 */
@property (nonatomic, assign) double minIntervalProgress;

/**
 选取区间开始进度
 */
@property (nonatomic, assign) double startProgress;

/**
 选取区间结束进度
 */
@property (nonatomic, assign) double endProgress;

/**
 拖拽中
 */
@property (nonatomic, assign, readonly) BOOL dragging;

@property (nonatomic, weak) IBOutlet id<VideoTrimmerViewDelegate> delegate;

@end

#import <AVFoundation/AVFoundation.h>

@interface VideoTrimmerView (Time)

/**
 获取选取的时间范围
 
 @param duration 用于计算时间范围的时长
 @return 选取的时间范围
 */
- (CMTimeRange)selectedTimeRangeAtDuration:(CMTime)duration;

/**
 设置选取的时间范围
 
 @param selectedTimeRange 选取的时间范围
 @param duration 用于计算时间范围的时长
 */
- (void)setSelectedTimeRange:(CMTimeRange)selectedTimeRange atDuration:(CMTime)duration;

/**
 获取修整器当前进度对应的时间
 
 @param duration 用于计算时间范围的时长
 @return 控件上的当前时间
 */
- (CMTime)currentTimeAtDuration:(CMTime)duration;

/**
 同步当前时间到修整器
 
 @param currentTime 当前时间
 @param duration 用于计算时间范围的时长
 */
- (void)setCurrentTime:(CMTime)currentTime atDuration:(CMTime)duration;

@end
