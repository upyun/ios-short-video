//
//  MarkableView.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/7/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 色块标记视图
 */
@interface MarkableView : UIView

/**
 标记中，当 `-startMarkWithColor:` 调用时则为 YES，`-endMark` 时则为 NO
 */
@property (nonatomic, assign, readonly) BOOL marking;

/**
 最后一个标记的结束时间
 */
@property (nonatomic, assign, readonly) double lastMaskProgress;

/**
 标记个数
 */
@property (nonatomic, assign, readonly) NSInteger markCount;

/**
 点击回调
 */
@property (nonatomic, copy) void (^tapActionHandler)(MarkableView *markableView, CALayer *markLayer, double startProgress, double lengthProgress);

#pragma mark - 获取标记信息

/**
 通过索引获取标记图层

 @param markIndex 标记索引
 @return 图层信息
 */
- (CALayer *)markLayerWithIndex:(NSUInteger)markIndex;

/**
 获取标记索引

 @param markLayer 标记的图层
 @return 图层索引
 */
- (NSUInteger)indexOfMarkLayer:(CALayer *)markLayer;

/**
 获取给定标记的开始进度

 @param markLayer 标记图层
 @return 对应的开始进度
 */
- (double)startProgressOfMarkLayer:(CALayer *)markLayer;

/**
 获取戈丁标记的时长进度

 @param markLayer 标记图层
 @return 对应的时长进度
 */
- (double)lengthProgressOfMarkLayer:(CALayer *)markLayer;

#pragma mark - 操作

/**
 更新标记

 @param markLayer 标记的图层
 @param startProgress 开始的进度
 @param lengthProgress 进度长度
 */
- (void)updateMarkLayer:(CALayer *)markLayer startProgress:(double)startProgress lengthProgress:(double)lengthProgress;

/**
 出栈标记，删除最后一个标记
 */
- (void)popMark;

/**
 移除指定索引的标记

 @param markIndex 指定索引
 */
- (void)removeMarkAtIndex:(NSUInteger)markIndex;

#pragma mark 长按添加标记操作

/**
 同步当前进度以更新内部控件

 @param currentProgress 当前的进度
 */
- (void)updateWithCurrentProgress:(double)currentProgress;

/**
 开始标记时展示的颜色

 @param color 颜色
 */
- (void)startMarkWithColor:(UIColor *)color;

/**
 停止标记
 */
- (void)endMark;

@end


#import <AVFoundation/AVFoundation.h>
// 标记视图配置 Block
typedef void(^MarkableViewConfigBlock)(NSUInteger index, void (^markItemConfig)(CMTimeRange markItemTimeRange, UIColor *color));

@interface MarkableView (Time)

/**
 一次添加多个标记，用于恢复标记

 @param markCount 标记数量
 @param totalDuration 总时长
 @param configHandler 配置之后回调
 */
- (void)addMarksWithCount:(NSInteger)markCount totalDuration:(CMTime)totalDuration config:(MarkableViewConfigBlock)configHandler;

/**
 图层添加标记颜色

 @param color 标记颜色
 @param timeRange 时间范围
 @param duration 添加特效范围的时长
 @return 处理的图层
 */
- (CALayer *)addMarkWithColor:(UIColor *)color timeRange:(CMTimeRange)timeRange atDuration:(CMTime)duration;

@end
