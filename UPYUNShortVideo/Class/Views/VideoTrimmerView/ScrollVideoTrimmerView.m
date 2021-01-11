//
//  ScrollVideoTrimmerView.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/13.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "ScrollVideoTrimmerView.h"
#import "TrimmerMaskView+Util.h"
#import "TrimmerMaskView.h"
#import "MarkableView.h"

@interface ScrollVideoTrimmerView ()<UIScrollViewDelegate>

/**
 scrollView 的横坐标位移
 */
@property (nonatomic, assign) CGFloat contentOffsetX;

/**
 固定光标视图
 */
@property (nonatomic, strong) UIView *fixedCursorView;

/**
 滚动视图
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 缩略图视图
 */
@property (nonatomic, strong) VideoThumbnailsView *thumbnailsView;

/**
 修整器遮罩视图
 */
@property (nonatomic, strong) TrimmerMaskView *trimmerMaskView;

/**
 标记视图
 */
@property (nonatomic, strong, readonly) MarkableView *markView;

/**
 滚动中标记
 */
@property (nonatomic, assign) BOOL scrolling;

/**
 选中的标记图层
 */
@property (nonatomic, weak) CALayer *selectedMarkLayer;

@end

@implementation ScrollVideoTrimmerView
{
    double _currentProgress;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    __weak typeof(self) weakSelf = self;
    self.backgroundColor = [UIColor clearColor];

    // 配置滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_scrollView];
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.decelerationRate = 0;
    
    // 配置缩略图视图
    _thumbnailsView = [[VideoThumbnailsView alloc] initWithFrame:self.bounds];
    [_scrollView addSubview:_thumbnailsView];
    _thumbnailsView.thumbnailWidth = 32;
    _thumbnailsView.thumbnailsUpdateHandler = ^(VideoThumbnailsView *thumbnailsView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setNeedsLayout];
        });
    };
    
    // 配置缩略图视图
    _markView = [[MarkableView alloc] initWithFrame:CGRectZero];
    [_scrollView addSubview:_markView];
    _markView.tapActionHandler = ^(MarkableView *markableView, CALayer *markLayer, double startProgress, double lengthProgress) {
        [weakSelf updateWithMarkLayer:markLayer];
        if ([weakSelf.delegate respondsToSelector:@selector(trimmer:didSelectMarkWithIndex:)]) {
            [weakSelf.delegate trimmer:weakSelf didSelectMarkWithIndex:[markableView indexOfMarkLayer:markLayer]];
        }
        weakSelf.animatedNextUpdate = YES;
    };
    
    // 配置修整器遮罩
    _trimmerMaskView = [[TrimmerMaskView alloc] initWithFrame:self.bounds];
    [_scrollView addSubview:_trimmerMaskView];
    _trimmerMaskView.startTrimmingHandler = ^(TrimmerMaskView *trimmerMask, UIView *touchControl) {
        TrimmerTimeLocation location = [trimmerMask locationWithTouchControl:touchControl];
        if ([weakSelf.delegate respondsToSelector:@selector(trimmer:didStartAtLocation:)]) {
            [weakSelf.delegate trimmer:weakSelf didStartAtLocation:location];
        }
    };
    _trimmerMaskView.endTrimmingHandler = ^(TrimmerMaskView *trimmerMask, UIView *touchControl) {
        TrimmerTimeLocation location = [trimmerMask locationWithTouchControl:touchControl];
        if ([weakSelf.delegate respondsToSelector:@selector(trimmer:didEndAtLocation:)]) {
            [weakSelf.delegate trimmer:weakSelf didEndAtLocation:location];
        }
        weakSelf.animatedNextUpdate = YES;
    };
    _trimmerMaskView.trimmingHandler = ^(TrimmerMaskView *trimmerMask, UIView *touchControl, double progress) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        TrimmerTimeLocation location = [trimmerMask locationWithTouchControl:touchControl];
        if (location == TrimmerTimeLocationLeft) {
            strongSelf->_startProgress = progress;
            [strongSelf.markView updateMarkLayer:strongSelf.selectedMarkLayer startProgress:trimmerMask.startProgress lengthProgress:trimmerMask.endProgress - trimmerMask.startProgress];
        } else if (location == TrimmerTimeLocationRight) {
            strongSelf->_endProgress = progress;
            [strongSelf.markView updateMarkLayer:strongSelf.selectedMarkLayer startProgress:trimmerMask.startProgress lengthProgress:trimmerMask.endProgress - trimmerMask.startProgress];
        }
        if ([weakSelf.delegate respondsToSelector:@selector(trimmer:updateProgress:atLocation:)]) {
            [weakSelf.delegate trimmer:weakSelf updateProgress:progress atLocation:location];
        }
    };
    _trimmerMaskView.reachMaxHandler = ^(TrimmerMaskView *trimmerMask, UIView *touchControl) {
        if ([weakSelf.delegate respondsToSelector:@selector(trimmer:reachMaxIntervalProgress:reachMinIntervalProgress:)]) {
            [weakSelf.delegate trimmer:weakSelf reachMaxIntervalProgress:YES reachMinIntervalProgress:NO];
        }
    };
    _trimmerMaskView.reachMinHandler = ^(TrimmerMaskView *trimmerMask, UIView *touchControl) {
        if ([weakSelf.delegate respondsToSelector:@selector(trimmer:reachMaxIntervalProgress:reachMinIntervalProgress:)]) {
            [weakSelf.delegate trimmer:weakSelf reachMaxIntervalProgress:NO reachMinIntervalProgress:YES];
        }
    };
    
    // 配置固定游标视图
    _fixedCursorView = [[UIView alloc] initWithFrame:CGRectZero];
    _fixedCursorView.backgroundColor = [UIColor whiteColor];
    _fixedCursorView.layer.borderColor = [[UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f] CGColor];
    _fixedCursorView.layer.borderWidth = 0.5;
    _fixedCursorView.userInteractionEnabled = NO;
    [self addSubview:_fixedCursorView];
    
    // 成员变量初始化
    _contentOffsetX = -1;
    _maxIntervalProgress = 1;
    _minIntervalProgress = 0;
    _startProgress = 0;
    _endProgress = 1;
}

/**
 根据标记图层更新修整器布局

 @param markLayer 标记图层
 */
- (void)updateWithMarkLayer:(CALayer *)markLayer {
    _trimmerMaskView.hidden = !markLayer;
    self.selectedMarkLayer = markLayer;
    if (markLayer) {
        double startProgress = [_markView startProgressOfMarkLayer:markLayer];
        double lengthProgress = [_markView lengthProgressOfMarkLayer:markLayer];
        self.endProgress = startProgress + lengthProgress;
        self.startProgress = startProgress;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat borderWidth = _trimmerMaskView.borderWidth;
    const CGFloat overflowHeight = 1;
    const CGFloat contentOffsetX = self.contentOffsetX;
    _fixedCursorView.frame = CGRectMake(contentOffsetX, -overflowHeight, 3, self.bounds.size.height + 2*overflowHeight);
    
    const CGFloat thumbnailsWidth = _thumbnailsView.thumbnailsTotalWidth;
    const CGFloat contentWidth = thumbnailsWidth + CGRectGetWidth(self.bounds);
    _trimmerMaskView.maskMaxWidth = _maxIntervalProgress * thumbnailsWidth;
    _trimmerMaskView.maskMinWidth = _minIntervalProgress * thumbnailsWidth;
    
    _thumbnailsView.frame = CGRectMake(contentOffsetX, borderWidth, thumbnailsWidth, CGRectGetHeight(self.bounds) - borderWidth * 2);
    _markView.frame = _thumbnailsView.frame;
    _trimmerMaskView.frame = CGRectInset(_thumbnailsView.frame, -_trimmerMaskView.thumbWidth, -borderWidth);
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(contentWidth, CGRectGetHeight(self.bounds));
    _scrollView.contentOffset = CGPointMake(thumbnailsWidth * _currentProgress, 0);
}

#pragma mark - property

- (CGFloat)contentOffsetX {
    if (_contentOffsetX < 0 && self.superview) {
        CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));
        centerPoint = [self.superview convertPoint:centerPoint toView:self];
        return centerPoint.x;
    }
    return _contentOffsetX;
}

- (void)setCurrentProgress:(double)currentProgress {
    if (self.dragging) return;
    if (_animatedNextUpdate) {
        // 使用一次动画同步进度
        [self setCurrentProgress:currentProgress animated:YES];
        _animatedNextUpdate = NO;
        return;
    }
    CGFloat offsetX = _thumbnailsView.thumbnailsTotalWidth * currentProgress;
    _currentProgress = currentProgress;
    _scrollView.contentOffset = CGPointMake(offsetX, 0);
}
- (double)currentProgress {
    return _currentProgress;
}

- (void)setCurrentProgress:(double)currentProgress animated:(BOOL)animated {
    _currentProgress = currentProgress;
    
    CGFloat offsetX = _thumbnailsView.thumbnailsTotalWidth * currentProgress;
    [UIView animateWithDuration:.25 animations:^{
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setStartProgress:(double)startProgress {
    _startProgress = startProgress;
    _trimmerMaskView.startProgress = startProgress;
    
    [_trimmerMaskView setNeedsLayout];
}

- (void)setEndProgress:(double)endProgress {
    _endProgress = endProgress;
    _trimmerMaskView.endProgress = endProgress;
    
    [_trimmerMaskView setNeedsLayout];
}

- (void)setMaxIntervalProgress:(double)maxIntervalProgress {
    _maxIntervalProgress = maxIntervalProgress;
    
    const CGFloat thumbnailsWidth = _thumbnailsView.thumbnailsTotalWidth;
    _trimmerMaskView.maskMaxWidth = maxIntervalProgress * thumbnailsWidth;
}
- (void)setMinIntervalProgress:(double)minIntervalProgress {
    _minIntervalProgress = minIntervalProgress;
    
    const CGFloat thumbnailsWidth = _thumbnailsView.thumbnailsTotalWidth;
    _trimmerMaskView.maskMinWidth = minIntervalProgress * thumbnailsWidth;
}

- (BOOL)dragging {
    return _scrolling || _trimmerMaskView.dragging;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.dragging) {
        // 标记滚动中
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
        _scrolling = YES;
        
        // 更新当前进度，并进行进度回调
        _currentProgress = _scrollView.contentOffset.x / _thumbnailsView.thumbnailsTotalWidth * 1.0;
        if ([self.delegate respondsToSelector:@selector(trimmer:updateProgress:atLocation:)]) {
            [self.delegate trimmer:self updateProgress:self.currentProgress atLocation:TrimmerTimeLocationCurrent];
        }
    }
    
    // 更新标记视图
    [_markView updateWithCurrentProgress:self.currentProgress];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(trimmer:didStartAtLocation:)]) {
        [self.delegate trimmer:self didStartAtLocation:TrimmerTimeLocationCurrent];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate && [self.delegate respondsToSelector:@selector(trimmer:didEndAtLocation:)]) {
        [self.delegate trimmer:self didEndAtLocation:TrimmerTimeLocationCurrent];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(trimmer:didEndAtLocation:)]) {
        [self.delegate trimmer:self didEndAtLocation:TrimmerTimeLocationCurrent];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 标记结束滚动
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _scrolling = NO;
}

#pragma mark - gesture

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

@end


@implementation ScrollVideoTrimmerView (Markable)

- (BOOL)marking {
    return _markView.marking;
}

- (double)lastMaskProgress {
    return _markView.lastMaskProgress;
}

- (NSUInteger)selectedMarkIndex {
    return [_markView indexOfMarkLayer:_selectedMarkLayer];
}
- (void)setSelectedMarkIndex:(NSUInteger)selectedMarkIndex {
    [self selectMarkWithIndex:selectedMarkIndex];
}

- (BOOL)selectMarkWithIndex:(NSUInteger)markIndex {
    
    CALayer *markLayer = [_markView markLayerWithIndex:markIndex];
    [self updateWithMarkLayer:markLayer];
    
    if (!markLayer) return NO;
    self.animatedNextUpdate = YES;
    return YES;
}

- (NSInteger)markCount {
    return _markView.markCount;
}

- (void)startMarkWithColor:(UIColor *)color {
    [_markView startMarkWithColor:color];
}

- (void)endMark {
    [_markView endMark];
}

- (void)popMark {
    [_markView popMark];
}

- (NSUInteger)indexOfMarkLayer:(CALayer *)markLayer {
    return [_markView indexOfMarkLayer:markLayer];
}

- (void)removeMarkAtIndex:(NSUInteger)markIndex {
    [_markView removeMarkAtIndex:markIndex];
}

@end


@implementation ScrollVideoTrimmerView (Time)

- (CMTimeRange)selectedTimeRangeAtDuration:(CMTime)duration {
    NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    if (isnan(durationInterval) || durationInterval <= 0) return kCMTimeRangeInvalid;
    
    // 计算开始时间和结束时间
    NSTimeInterval startInterval = self.startProgress * durationInterval;
    NSTimeInterval endInterval = self.endProgress * durationInterval;
    
    return CMTimeRangeFromTimeToTime(CMTimeMakeWithSeconds(startInterval, duration.timescale), CMTimeMakeWithSeconds(endInterval, duration.timescale));
}

- (void)setSelectedTimeRange:(CMTimeRange)selectedTimeRange atDuration:(CMTime)duration {
    NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    if (isnan(durationInterval) || durationInterval <= 0){
        self.startProgress = 0;
        self.endProgress = 0;
        return;
    }
    if (CMTIMERANGE_IS_EMPTY(selectedTimeRange) || CMTIMERANGE_IS_INVALID(selectedTimeRange) || CMTIMERANGE_IS_INDEFINITE(selectedTimeRange)) return;
    
    // 更新布局
    self.startProgress = CMTimeGetSeconds(selectedTimeRange.start) / durationInterval;
    self.endProgress = CMTimeGetSeconds(CMTimeRangeGetEnd(selectedTimeRange)) / durationInterval;
}

- (CMTime)currentTimeAtDuration:(CMTime)duration {
    NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    if (isnan(durationInterval) || durationInterval <= 0) return kCMTimeInvalid;
    
    return CMTimeMakeWithSeconds(durationInterval * self.currentProgress, duration.timescale);
}
- (void)setCurrentTime:(CMTime)currentTime atDuration:(CMTime)duration {
    NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    if (isnan(durationInterval) || durationInterval <= 0) return;
    if (CMTIME_IS_INVALID(currentTime) || CMTIME_IS_INDEFINITE(currentTime)) return;
    
    self.currentProgress = CMTimeGetSeconds(currentTime) / durationInterval;
}

- (void)addMarksWithCount:(NSInteger)markCount totalDuration:(CMTime)totalDuration config:(MarkableViewConfigBlock)configHandler {
    [_markView addMarksWithCount:markCount totalDuration:totalDuration config:configHandler];
}

- (CALayer *)addMarkWithColor:(UIColor *)color timeRange:(CMTimeRange)timeRange atDuration:(CMTime)duration {
    CALayer *markLayer = [_markView addMarkWithColor:color timeRange:timeRange atDuration:duration];
    [self updateWithMarkLayer:markLayer];
    return markLayer;
}

@end
