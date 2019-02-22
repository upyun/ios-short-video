//
//  MarkableView.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/7/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "MarkableView.h"

// 标记开始进度键
static NSString * const kMarkItemStartProgressKey = @"start";
// 标记长度键
static NSString * const kMarkItemLengthProgressKey = @"length";
// 标记图层键
static NSString * const kMarkItemLayerKey = @"layer";

@interface MarkableView ()

/**
 标记图层，用于布局各个标记项的子图层
 */
@property (nonatomic, strong) CALayer *markLayer;

/**
 开始标记的进度
 */
@property (nonatomic, assign) double markedProgress;

/**
 当前进度
 */
@property (nonatomic, assign) double currentProgress;

/**
 是否是向前（顺序）更新进度
 */
@property (nonatomic, assign) NSNumber *forward;

/**
 出现逆向点进度
 */
@property (nonatomic, assign) double reverseProgress;

/**
 标记信息
 */
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *markInfos;

@end

@implementation MarkableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _markLayer = [CALayer layer];
        [self.layer addSublayer:_markLayer];
        _markInfos = [NSMutableArray array];
        _reverseProgress = -1;
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    _markLayer.frame = self.bounds;
    CGSize size = self.bounds.size;
    for (int i = 0; i < _markInfos.count; i++) {
        NSDictionary *info = _markInfos[i];
        CALayer *mark = info[kMarkItemLayerKey];
        NSTimeInterval startProgress = [info[kMarkItemStartProgressKey] doubleValue];
        NSTimeInterval lengthProgress = [info[kMarkItemLengthProgressKey] doubleValue];
        mark.frame = CGRectMake(startProgress * size.width, 0,
                                lengthProgress * size.width, size.height);
    }
}

/**
 更新当前标记项的布局
 */
- (void)updateLastMarkItemLayout {
    CGSize size = _markLayer.bounds.size;
    CALayer *mark = _markLayer.sublayers.lastObject;
    CGRect markFrame = mark.frame;
    const CGFloat width = ABS(_currentProgress - _markedProgress) * size.width;
    if (_currentProgress < _markedProgress) {
        markFrame.origin.x = _markedProgress * size.width - width;
    }
    markFrame.size.width = width;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    mark.frame = markFrame;
    [CATransaction commit];
}

#pragma mark - action

/**
 点击事件

 @param sender 点击手势
 */
- (void)tapAction:(UITapGestureRecognizer *)sender {
    if (!_markInfos.count) return;
    
    // 遍历寻找点击的标记，并进行回调
    __block BOOL hitMark = NO;
    [_markInfos enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        CALayer *markLayer = info[kMarkItemLayerKey];
        if (CGRectContainsPoint(markLayer.frame, [sender locationInView:self])) {
            NSTimeInterval startProgress = [info[kMarkItemStartProgressKey] doubleValue];
            NSTimeInterval lengthProgress = [info[kMarkItemLengthProgressKey] doubleValue];
            //NSLog(@"layer: %@, start: %f, length: %f", markLayer, startProgress, lengthProgress);
            if (self.tapActionHandler) self.tapActionHandler(self, markLayer, startProgress, lengthProgress);
            *stop = YES;
            hitMark = YES;
        }
    }];
    // 没找到点击的标记
    if (!hitMark) {
        if (self.tapActionHandler) self.tapActionHandler(self, nil, -1, -1);
    }
}

#pragma mark - public

- (CALayer *)markLayerWithIndex:(NSUInteger)markIndex {
    if (markIndex >= _markLayer.sublayers.count) return nil;
    return _markLayer.sublayers[markIndex];
}

- (NSUInteger)indexOfMarkLayer:(CALayer *)markLayer {
    return [_markLayer.sublayers indexOfObject:markLayer];
}

- (double)startProgressOfMarkLayer:(CALayer *)markLayer {
    NSUInteger index = [self indexOfMarkLayer:markLayer];
    if (index >= _markInfos.count) return NAN;
    NSDictionary *info = _markInfos[index];
    if (markLayer != info[kMarkItemLayerKey]) return NAN;
    return [info[kMarkItemStartProgressKey] doubleValue];
}

- (double)lengthProgressOfMarkLayer:(CALayer *)markLayer {
    NSUInteger index = [self indexOfMarkLayer:markLayer];
    if (index >= _markInfos.count) return NAN;
    NSDictionary *info = _markInfos[index];
    if (markLayer != info[kMarkItemLayerKey]) return NAN;
    return [info[kMarkItemLengthProgressKey] doubleValue];
}

- (void)updateMarkLayer:(CALayer *)markLayer startProgress:(double)startProgress lengthProgress:(double)lengthProgress {
    if (![_markLayer.sublayers containsObject:markLayer]) return;
    
    NSUInteger index = [self indexOfMarkLayer:markLayer];
    if (_markInfos[index][kMarkItemLayerKey] == markLayer) {
        NSDictionary *info =
        @{
          kMarkItemLayerKey: markLayer,
          kMarkItemStartProgressKey: @(startProgress),
          kMarkItemLengthProgressKey: @(lengthProgress)
          };
        [_markInfos replaceObjectAtIndex:index withObject:info];
    }
    CGSize size = _markLayer.bounds.size;
    CGRect markFrame = markLayer.frame;
    markFrame.origin.x = size.width * startProgress;
    markFrame.size.width = size.width * lengthProgress;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    markLayer.frame = markFrame;
    [CATransaction commit];
}

- (void)updateWithCurrentProgress:(double)currentProgress {
    double previousProgress = _currentProgress;
    _currentProgress = currentProgress;
    if (_marking) {
        if (!_forward) _forward = @(currentProgress > _markedProgress);
        BOOL shouldUpdateLastMark = YES;
        
        if (_forward.boolValue) { // 正向
            // 确定逆向点进度
            if (_reverseProgress < 0 && currentProgress < previousProgress) _reverseProgress = previousProgress;
            if (_reverseProgress >= 0) {
                shouldUpdateLastMark = NO;
                if (currentProgress > _reverseProgress) { // 越过逆向点进度则继续更新标记
                    shouldUpdateLastMark = YES;
                    _reverseProgress = -1;
                }
            }
        }
        if (shouldUpdateLastMark) [self updateLastMarkItemLayout];
    }
}

- (void)startMarkWithColor:(UIColor *)color {
    CALayer *mark = [CALayer layer];
    [_markLayer addSublayer:mark];
    mark.backgroundColor = color.CGColor;
    CGSize size = _markLayer.bounds.size;
    mark.frame = CGRectMake(size.width * _currentProgress, 0, 0, size.height);
    _lastMaskProgress = _markedProgress = _currentProgress;
    _marking = YES;
}

- (void)endMark {
    // 结束一个标记后重置记录的信息
    _marking = NO;
    _reverseProgress = -1;
    _forward = nil;
    
    // 记录标记
    if (!_markLayer.sublayers.count) return;
    NSDictionary *markInfo =
    @{
      kMarkItemLayerKey: _markLayer.sublayers.lastObject,
      kMarkItemStartProgressKey: @(_markedProgress),
      kMarkItemLengthProgressKey: @(_currentProgress - _markedProgress)
      };
    [_markInfos addObject:markInfo];
}

- (void)popMark {
    NSDictionary *lastInfo = _markInfos.lastObject;
    [_markInfos removeLastObject];
    CALayer *mark = _markLayer.sublayers.lastObject;
    [mark removeFromSuperlayer];
    if (lastInfo) {
        double lastMarkStartProgress = [lastInfo[kMarkItemStartProgressKey] doubleValue];
        _lastMaskProgress = lastMarkStartProgress;
    }
}

- (void)removeMarkAtIndex:(NSUInteger)markIndex {
    if (markIndex >= _markInfos.count) return;
    [_markInfos removeObjectAtIndex:markIndex];
    [_markLayer.sublayers[markIndex] removeFromSuperlayer];
}

- (NSInteger)markCount {
    return _markInfos.count;
}

@end

@implementation MarkableView (Time)

- (void)addMarksWithCount:(NSInteger)markCount totalDuration:(CMTime)totalDuration config:(MarkableViewConfigBlock)configHandler {
    const NSTimeInterval durationInterval = CMTimeGetSeconds(totalDuration);
    NSMutableArray *markInfos = [NSMutableArray array];
    for (int i = 0; i < markCount; i++) {
        configHandler(i, ^(CMTimeRange markItemTimeRange, UIColor *color) {
            if (CMTIMERANGE_IS_INVALID(markItemTimeRange)) {
                return;
            }
            //CMTimeRangeShow(markItemTimeRange);
            CALayer *mark = [CALayer layer];
            [self.markLayer addSublayer:mark];
            mark.backgroundColor = color.CGColor;
            const double itemStartTime = CMTimeGetSeconds(markItemTimeRange.start);
            const double itemDuration = CMTimeGetSeconds(markItemTimeRange.duration);
            NSDictionary *markInfo =
            @{
              kMarkItemLayerKey: mark,
              kMarkItemStartProgressKey: @(itemStartTime / durationInterval),
              kMarkItemLengthProgressKey: @(itemDuration / durationInterval)
              };
            [markInfos addObject:markInfo];
        });
    }
    [_markInfos addObjectsFromArray:markInfos];
    [self setNeedsLayout];
}

- (CALayer *)addMarkWithColor:(UIColor *)color timeRange:(CMTimeRange)timeRange atDuration:(CMTime)duration {
    const NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    CALayer *mark = [CALayer layer];
    [_markLayer addSublayer:mark];
    mark.backgroundColor = color.CGColor;
    const double itemStartTime = CMTimeGetSeconds(timeRange.start);
    const double itemDuration = CMTimeGetSeconds(timeRange.duration);
    NSDictionary *markInfo =
    @{
      kMarkItemLayerKey: mark,
      kMarkItemStartProgressKey: @(itemStartTime / durationInterval),
      kMarkItemLengthProgressKey: @(itemDuration / durationInterval)
      };
    [_markInfos addObject:markInfo];
    [self setNeedsLayout];
    return mark;
}

@end
