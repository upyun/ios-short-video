//
//  VideoFixedSelectionRangeView.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/7/13.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoThumbnailsView.h"

@class VideoFixedSelectionRangeView;
@protocol VideoFixedSelectionRangeViewDelegate <NSObject>
@optional

/**
 选取范围开始进度更新回调

 @param selectionRangeView 选取视图
 @param rangeStartProgress 选取范围的开始进度
 */
- (void)selectionRangeView:(VideoFixedSelectionRangeView *)selectionRangeView updatingRangeStartProgress:(double)rangeStartProgress;

@end

/**
 固定选取长度的时间选取视图
 */
@interface VideoFixedSelectionRangeView : UIView

/**
 视频帧缩略图视图
 */
@property (nonatomic, strong, readonly) VideoThumbnailsView *thumbnailsView;

/**
 选取范围长度占比
 */
@property (nonatomic, assign) double rangeLengthProgress;

/**
 选取范围开始占比
 */
@property (nonatomic, assign) double rangeStartProgress;

@property (nonatomic, weak) IBOutlet id<VideoFixedSelectionRangeViewDelegate> delegate;

@end

#import <AVFoundation/AVFoundation.h>

@interface VideoFixedSelectionRangeView (Time)

/**
 配置固定的选取范围

 @param selectedRange 选取范围
 @param duration 时长
 */
- (void)setupWithSelectedRange:(CMTimeRange)selectedRange atDuration:(CMTime)duration;

@end
