//
//  ScrollVideoTrimmerView.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/13.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoTrimmerViewProtocol.h"

@class ScrollVideoTrimmerView;

@protocol ScrollVideoTrimmerViewDelegate <VideoTrimmerViewDelegate>
@optional

/**
 标记选中回调

 @param trimmer 时间轴
 @param markIndex 选中遮罩的索引
 */
- (void)trimmer:(ScrollVideoTrimmerView *)trimmer didSelectMarkWithIndex:(NSUInteger)markIndex;

@end

/**
 可滚动的时间修正器
 */
@interface ScrollVideoTrimmerView : UIView <VideoTrimmerViewProtocol>

/**
 视频帧缩略图视图
 */
@property (nonatomic, strong, readonly) VideoThumbnailsView *thumbnailsView;

/**
 区间选择视图
 */
@property (nonatomic, strong, readonly) UIView *trimmerMaskView;

/**
 当前进度，设置该属性则会更新 UI
 */
@property (nonatomic, assign) double currentProgress;
- (void)setCurrentProgress:(double)currentProgress animated:(BOOL)animated;

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

/**
 下一次进度更新使用动画
 */
@property (nonatomic, assign) BOOL animatedNextUpdate;

@property (nonatomic, weak) IBOutlet id<ScrollVideoTrimmerViewDelegate> delegate;

@end


@interface ScrollVideoTrimmerView (Markable)

/**
 标记中，当 `-startMarkWithColor:` 调用时则为 YES，`-endMark` 时则为 NO
 */
@property (nonatomic, assign, readonly) BOOL marking;

/**
 最后一个标记的结束时间
 */
@property (nonatomic, assign, readonly) double lastMaskProgress;

/**
 选中的标记索引
 */
@property (nonatomic, assign) NSUInteger selectedMarkIndex;


- (BOOL)selectMarkWithIndex:(NSUInteger)markIndex;

/**
 标记个数
 */
@property (nonatomic, assign, readonly) NSInteger markCount;

/**
 开始标记的展示颜色

 @param color 控件展示的颜色
 */
- (void)startMarkWithColor:(UIColor *)color;

/**
 停止标记
 */
- (void)endMark;

/**
 出栈标记，删除最后一个标记
 */
- (void)popMark;

/**
 获取标记索引

 @param markLayer 标记视图层级
 @return 视图层级索引
 */
- (NSUInteger)indexOfMarkLayer:(CALayer *)markLayer;

/**
 移除指定索引的标记

 @param markIndex 视图层级索引
 */
- (void)removeMarkAtIndex:(NSUInteger)markIndex;

@end


#import <AVFoundation/AVFoundation.h>
// 标记视图配置 Block
typedef void(^MarkableViewConfigBlock)(NSUInteger index, void (^markItemConfig)(CMTimeRange markItemTimeRange, UIColor *color));

@interface ScrollVideoTrimmerView (Time)

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

/**
 一次添加多个标记，用于初始化页面布局时的恢复标记

 @param markCount 标记数量
 @param totalDuration 总时长
 @param configHandler 完成后回调
 */
- (void)addMarksWithCount:(NSInteger)markCount totalDuration:(CMTime)totalDuration config:(MarkableViewConfigBlock)configHandler;

/**
 添加一个标记，用于页面布局结束后的动态添加标记

 @param color 控件展示的颜色
 @param timeRange 时间范围
 @param duration 范围的时长
 @return 视图层级
 */
- (CALayer *)addMarkWithColor:(UIColor *)color timeRange:(CMTimeRange)timeRange atDuration:(CMTime)duration;

@end
