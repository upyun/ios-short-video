//
//  VideoTrimmerView.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/22.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "VideoTrimmerView.h"
#import "TrimmerMaskView+Util.h"
#import "TrimmerMaskView.h"

static const CGFloat kCursorWidth = 3.0;

@interface VideoTrimmerView ()

@property (nonatomic, strong) VideoThumbnailsView *thumbnailsView;

@property (nonatomic, strong) TrimmerMaskView *trimmerMaskView;

/**
 游标
 */
@property (nonatomic, strong) UIView *cursorView;

/**
 拖拽中
 */
@property (nonatomic, assign) BOOL dragging;

@end

@implementation VideoTrimmerView

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    
    // 配置缩略图视图
    _thumbnailsView = [[VideoThumbnailsView alloc] initWithFrame:self.bounds];
    [self addSubview:_thumbnailsView];
    
    // 配置修整器遮罩
    _trimmerMaskView = [[TrimmerMaskView alloc] initWithFrame:self.bounds];
    [self addSubview:_trimmerMaskView];
    __weak typeof(self) weakSelf = self;
    _trimmerMaskView.startTrimmingHandler = ^(TrimmerMaskView *trimmerMask, UIView *touchControl) {
        weakSelf.dragging = YES;
        TrimmerTimeLocation location = [trimmerMask locationWithTouchControl:touchControl];
        if ([weakSelf.delegate respondsToSelector:@selector(trimmer:didStartAtLocation:)]) {
            [weakSelf.delegate trimmer:weakSelf didStartAtLocation:location];
        }
    };
    _trimmerMaskView.endTrimmingHandler = ^(TrimmerMaskView *trimmerMask, UIView *touchControl) {
        weakSelf.dragging = NO;
        TrimmerTimeLocation location = [trimmerMask locationWithTouchControl:touchControl];
        
        if ([weakSelf.delegate respondsToSelector:@selector(trimmer:didEndAtLocation:)]) {
            [weakSelf.delegate trimmer:weakSelf didEndAtLocation:location];
        }
    };
    _trimmerMaskView.trimmingHandler = ^(TrimmerMaskView *trimmerMask, UIView *touchControl, double progress) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        TrimmerTimeLocation location = [trimmerMask locationWithTouchControl:touchControl];
        
        if (location == TrimmerTimeLocationLeft) {
            strongSelf->_startProgress = progress;
        } else if (location == TrimmerTimeLocationRight) {
            strongSelf->_endProgress = progress;
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
	
    // 配置游标视图
	_cursorView = [[UIView alloc] initWithFrame:CGRectZero];
	_cursorView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
	_cursorView.layer.borderColor = [[UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f] CGColor];
	_cursorView.layer.borderWidth = 0.5;
	//_cursorView.userInteractionEnabled = NO;
	[self addSubview:_cursorView];
	
    // 配置滑动手势
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cursorPanAction:)];
	[self addGestureRecognizer:pan];
    
    // 初始化成员变量
    _maxIntervalProgress = 1;
    _minIntervalProgress = 0;
    _startProgress = 0;
    _endProgress = 1;
}

- (void)layoutSubviews {
    const CGSize size = self.bounds.size;
    const CGFloat thumbWidth = _trimmerMaskView.thumbWidth;
    const CGFloat borderWidth = _trimmerMaskView.borderWidth;
    const CGFloat thumbnailsWidth = size.width - thumbWidth * 2;
    
    _trimmerMaskView.maskMaxWidth = _maxIntervalProgress * thumbnailsWidth;
    _trimmerMaskView.maskMinWidth = _minIntervalProgress * thumbnailsWidth;
    
    _thumbnailsView.frame = CGRectMake(thumbWidth, borderWidth, thumbnailsWidth, size.height - borderWidth * 2.0);
    _trimmerMaskView.frame = self.bounds;
	
    const CGFloat cursorX = thumbWidth;
	const CGFloat cursorY = -1;
	CGFloat cursorHeight = size.height + cursorY * -2;
	_cursorView.frame = CGRectMake(cursorX, cursorY, kCursorWidth, cursorHeight);
}

/**
 更新游标布局

 @param touchLocation 触摸位置
 */
- (void)layoutCursorWithTouchLocation:(CGPoint)touchLocation {
	CGRect contentRect = CGRectInset(self.bounds, _trimmerMaskView.thumbWidth, 0);
	if (CGRectContainsPoint(_trimmerMaskView.leftThumb.frame, touchLocation) || CGRectContainsPoint(_trimmerMaskView.rightThumb.frame, touchLocation)) return;
	if (_trimmerMaskView.dragging) return;
	if (touchLocation.x < contentRect.origin.x) touchLocation.x = contentRect.origin.x;
	if (touchLocation.x > CGRectGetMaxX(contentRect)) touchLocation.x = CGRectGetMaxX(contentRect);
	
	CGPoint cursorCenter = _cursorView.center;
	cursorCenter.x = touchLocation.x + kCursorWidth / 2;
	_cursorView.center = cursorCenter;
	
    if ([self.delegate respondsToSelector:@selector(trimmer:updateProgress:atLocation:)]) {
        [self.delegate trimmer:self updateProgress:self.currentProgress atLocation:TrimmerTimeLocationCurrent];
    }
}

#pragma mark - property

- (void)setCurrentProgress:(double)currentProgress {
    if (self.dragging) return;
    
    CGPoint cursorCenter = _cursorView.center;
    cursorCenter.x = currentProgress * CGRectGetWidth(_thumbnailsView.bounds) + _trimmerMaskView.thumbWidth;
    _cursorView.center = cursorCenter;
}

- (double)currentProgress {
    double currentProgress = (CGRectGetMidX(_cursorView.frame) - _trimmerMaskView.thumbWidth) / CGRectGetWidth(_thumbnailsView.bounds);
    
    return currentProgress;
}

- (void)setStartProgress:(double)startProgress {
    _startProgress = startProgress;
    _trimmerMaskView.startProgress = startProgress;
}

- (void)setEndProgress:(double)endProgress {
    _endProgress = endProgress;
    _trimmerMaskView.endProgress = endProgress;
}

- (void)setMaxIntervalProgress:(double)maxIntervalProgress {
    _maxIntervalProgress = maxIntervalProgress;
    const CGFloat thumbnailsWidth = self.bounds.size.width - _trimmerMaskView.thumbWidth * 2;
    _trimmerMaskView.maskMaxWidth = maxIntervalProgress * thumbnailsWidth;
}

- (void)setMinIntervalProgress:(double)minIntervalProgress {
    _minIntervalProgress = minIntervalProgress;
    const CGFloat thumbnailsWidth = self.bounds.size.width - _trimmerMaskView.thumbWidth * 2;
    _trimmerMaskView.maskMinWidth = minIntervalProgress * thumbnailsWidth;
}

#pragma mark - touch

/**
 滑动手势事件

 @param sender 滑动手势
 */
- (void)cursorPanAction:(UIPanGestureRecognizer *)sender {
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:{
			_dragging = YES;
            if ([self.delegate respondsToSelector:@selector(trimmer:didStartAtLocation:)]) {
                [self.delegate trimmer:self didStartAtLocation:TrimmerTimeLocationCurrent];
            }
		} break;
		case UIGestureRecognizerStateEnded:{
			_dragging = NO;
            if ([self.delegate respondsToSelector:@selector(trimmer:didEndAtLocation:)]) {
                [self.delegate trimmer:self didEndAtLocation:TrimmerTimeLocationCurrent];
            }
		} break;
		default:{} break;
	}
	[self layoutCursorWithTouchLocation:[sender locationInView:self]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (touches.count > 1) return;
    [self layoutCursorWithTouchLocation:[touches.anyObject locationInView:self]];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (touches.count > 1) return;
    [self layoutCursorWithTouchLocation:[touches.anyObject locationInView:self]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 优先响应左右滑块
    CGPoint rightThumbPoint = [self convertPoint:point toView:_trimmerMaskView.rightThumb];
    if ([_trimmerMaskView.rightThumb pointInside:rightThumbPoint withEvent:event]) {
        return _trimmerMaskView.rightThumb;
    }
    CGPoint leftThumbPoint = [self convertPoint:point toView:_trimmerMaskView.leftThumb];
    if ([_trimmerMaskView.leftThumb pointInside:leftThumbPoint withEvent:event]) {
        return _trimmerMaskView.leftThumb;
    }
    return [super hitTest:point withEvent:event];
}

@end

@implementation VideoTrimmerView (Time)

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
    if (isnan(durationInterval) || durationInterval <= 0) return;
    if (CMTIMERANGE_IS_EMPTY(selectedTimeRange) || CMTIMERANGE_IS_INVALID(selectedTimeRange) || CMTIMERANGE_IS_INDEFINITE(selectedTimeRange)) return;
    
    // 更新布局
    self.startProgress = CMTimeGetSeconds(selectedTimeRange.start) / durationInterval;
    self.endProgress = CMTimeGetSeconds(CMTimeRangeGetEnd(selectedTimeRange)) / durationInterval;
    [self setNeedsLayout];
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
    
    // 计算当前进度
    CGFloat targetProgress = CMTimeGetSeconds(currentTime) / durationInterval;
    self.currentProgress = targetProgress;
}

@end
