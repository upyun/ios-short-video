//
//  VideoFixedSelectionRangeView.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/7/13.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "VideoFixedSelectionRangeView.h"
#import "MaskLayer.h"

// 边框宽度
static const CGFloat kBorderWidth = 2;

@interface VideoFixedSelectionRangeView ()

/**
 视频缩略图视图
 */
@property (nonatomic, strong) VideoThumbnailsView *thumbnailsView;

/**
 选取范围图层
 */
@property (nonatomic, strong) CALayer *rangeLayer;

/**
 遮罩图层
 */
@property (nonatomic, strong) MaskLayer *maskLayer;

/**
 选取范围宽度
 */
@property (nonatomic, assign) CGFloat rangeWidth;

/**
 范围中点 X 值
 */
@property (nonatomic, assign) CGFloat rangeCenterX;

/**
 是否在拖拽中
 */
@property (nonatomic, assign) CGFloat dragging;

@end

@implementation VideoFixedSelectionRangeView

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
    
    _thumbnailsView = [[VideoThumbnailsView alloc] initWithFrame:self.bounds];
    [self addSubview:_thumbnailsView];
    
    _maskLayer = [[MaskLayer alloc] init];
    [self.layer addSublayer:_maskLayer];
    
    _rangeLayer = [[BorderLayer alloc] init];
    [self.layer addSublayer:_rangeLayer];
    _rangeLayer.borderWidth = kBorderWidth;
    _rangeLayer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor;
    
    _rangeWidth = 0;
    _rangeCenterX = _rangeWidth / 2;
    _rangeLengthProgress = -1;
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    CGFloat rangeX = 0;
    
    if (_rangeLengthProgress > 0) {
        _rangeWidth = _rangeLengthProgress * size.width;
        rangeX = _rangeStartProgress * size.width;
    }
    
    _rangeLayer.frame = CGRectMake(rangeX, -kBorderWidth, _rangeWidth, size.height + kBorderWidth * 2);
    _thumbnailsView.frame = self.bounds;
    _maskLayer.frame = self.bounds;
    _maskLayer.maskRect = CGRectInset(_rangeLayer.frame, kBorderWidth, kBorderWidth);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (touches.count > 1) return;
    [self updateRangePositionWithTouch:touches.anyObject];
    _dragging = YES;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (touches.count > 1) return;
    [self updateRangePositionWithTouch:touches.anyObject];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (touches.count > 1) return;
    [self updateRangePositionWithTouch:touches.anyObject];
    _dragging = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (touches.count > 1) return;
    [self updateRangePositionWithTouch:touches.anyObject];
    _dragging = NO;
}

#pragma mark - private

- (void)updateRangePositionWithTouch:(UITouch *)touch {
    CGRect insetRect = CGRectInset(self.bounds, _rangeWidth / 2, 0);
    CGPoint location = [touch locationInView:self];
    
    if (location.x < insetRect.origin.x) location.x = insetRect.origin.x;
    if (location.x > CGRectGetMaxX(insetRect)) location.x = CGRectGetMaxX(insetRect);
    
    self.rangeCenterX = location.x;
}

#pragma mark - property

- (void)setRangeCenterX:(CGFloat)rangeCenterX {
    if (rangeCenterX == _rangeCenterX) return;
    _rangeCenterX = rangeCenterX;
    
    // 更新布局
    CGPoint center = _rangeLayer.position;
    center.x = rangeCenterX;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _rangeLayer.position = center;
    _maskLayer.maskRect = CGRectInset(_rangeLayer.frame, kBorderWidth, kBorderWidth);
    [CATransaction commit];
    
    _rangeStartProgress = CGRectGetMidX(_rangeLayer.frame) / CGRectGetWidth(self.bounds);
    if ([self.delegate respondsToSelector:@selector(selectionRangeView:updatingRangeStartProgress:)]) {
        [self.delegate selectionRangeView:self updatingRangeStartProgress:_rangeStartProgress];
    }
}

- (void)setRangeLengthProgress:(double)rangeLengthProgress {
    _rangeLengthProgress = rangeLengthProgress;
    [self setNeedsLayout];
}

- (void)setRangeStartProgress:(double)rangeStartProgress {
    _rangeStartProgress = rangeStartProgress;
    
    if (!_dragging) {
        self.rangeCenterX = _rangeStartProgress * CGRectGetWidth(self.bounds) + CGRectGetWidth(_rangeLayer.frame) / 2;
    }
}

@end

@implementation VideoFixedSelectionRangeView (Time)

- (void)setupWithSelectedRange:(CMTimeRange)selectedRange atDuration:(CMTime)duration {
    NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    NSTimeInterval rangeStartInterval = CMTimeGetSeconds(selectedRange.start);
    NSTimeInterval rangeDurationInterval = CMTimeGetSeconds(selectedRange.duration);
    
    self.rangeStartProgress = rangeStartInterval / durationInterval;
    self.rangeLengthProgress = rangeDurationInterval / durationInterval;
}

@end
