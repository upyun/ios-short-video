//
//  TrimmerMaskView.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "TrimmerMaskView.h"
#import "ThumbView.h"
#import "MaskLayer.h"

@interface TrimmerMaskView ()<PanConrolDelegate>

/**
 左滑块
 */
@property (nonatomic, strong) ThumbView *leftThumb;

/**
 右滑块
 */
@property (nonatomic, strong) ThumbView *rightThumb;

/**
 边框图层
 */
@property (nonatomic, strong) BorderLayer *borderLayer;

/**
 遮罩图层
 */
@property (nonatomic, strong) MaskLayer *maskLayer;

/**
 滑动初始遮罩挖空矩形
 */
@property (nonatomic, assign) CGRect panBeganMaskRect;

@end

@implementation TrimmerMaskView
{
    CGRect _maskRect;
}

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
    _borderWidth = 2.0;
    _thumbWidth = 12.0;
    _maskMinWidth = 1;
    _maskMaxWidth = -1;
    _startProgress = 0;
    _endProgress = 1;
    
    _maskLayer = [[MaskLayer alloc] init];
    [self.layer addSublayer:_maskLayer];
	
    _borderLayer = [[BorderLayer alloc] init];
    _borderLayer.masksToBounds = YES;
    _borderLayer.lineWidth = _borderWidth;
    [self.layer addSublayer:_borderLayer];
	
    _leftThumb = [[ThumbView alloc] initWithFrame:CGRectZero];
    [self addSubview:_leftThumb];
    _leftThumb.left = YES;
    _leftThumb.decoratingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_ic_arrow_left"]];
    _leftThumb.delegate = self;
    
    _rightThumb = [[ThumbView alloc] initWithFrame:CGRectZero];
    [self addSubview:_rightThumb];
    _rightThumb.left = NO;
    _rightThumb.decoratingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_ic_arrow_right"]];
    _rightThumb.delegate = self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	BOOL isHit = [super pointInside:point withEvent:event];
	if (!isHit) {
		return CGRectContainsPoint(_leftThumb.frame, point) || CGRectContainsPoint(_rightThumb.frame, point);
	}
	return isHit;
}

#pragma mark - layout

- (void)layoutSubviews {
    
    BOOL inValid = self.endProgress <= self.startProgress;
    _leftThumb.hidden = inValid;
    _rightThumb.hidden = inValid;
    _maskLayer.hidden  = inValid;
    _borderLayer.hidden = inValid;
    
    CGFloat height = CGRectGetHeight(self.bounds);
    CGRect insideRect = CGRectInset(self.bounds, _thumbWidth, _borderWidth);
	
    _maskLayer.frame = insideRect;
    _borderLayer.frame = CGRectInset(self.bounds, _thumbWidth, 0);
    CGRect maskRect = self.maskRect;
    
	_leftThumb.frame = CGRectMake(CGRectGetMinX(maskRect) - _thumbWidth, 0, _thumbWidth, height);
	_rightThumb.frame = CGRectMake(CGRectGetMaxX(maskRect), 0, _thumbWidth, height);
	
	if (_startProgress >= 0 && _startProgress <= 1 && _endProgress >= 0 && _endProgress <= 1) {
		CGFloat maskX = _startProgress * CGRectGetWidth(insideRect) + _thumbWidth;
		CGFloat maskWidth = (_endProgress - _startProgress) * CGRectGetWidth(insideRect);
		self.maskRect = CGRectMake(maskX, CGRectGetMinY(insideRect), maskWidth, CGRectGetHeight(insideRect));
	}
}

- (void)layoutWithMaskRect:(CGRect)maskRect {
	_maskLayer.maskRect = [self.layer convertRect:maskRect toLayer:_maskLayer];
    _borderLayer.borderRect = [self.layer convertRect:maskRect toLayer:_borderLayer];

	
	CGPoint leftThumbCenter = _leftThumb.center;
	leftThumbCenter.x = CGRectGetMinX(maskRect) - _thumbWidth / 2;
    
    if (CGRectGetMinX(maskRect) >= 0)
        _leftThumb.center = leftThumbCenter;
	
	CGPoint rightThumbCenter = _rightThumb.center;
	rightThumbCenter.x = CGRectGetMaxX(maskRect) + _thumbWidth / 2;
    
    if (CGRectGetMaxX(maskRect) <= CGRectGetMaxX(self.bounds))
        _rightThumb.center = rightThumbCenter;
}

#pragma mark - property

- (void)setMaskRect:(CGRect)maskRect {
    // 更新 maskRect 同时，布局与其相关的视图
    if (CGRectEqualToRect(_maskRect, maskRect)) return;
    _maskRect = maskRect;
	[self layoutWithMaskRect:maskRect];
}

- (CGRect)maskRect {
    if (CGRectIsNull(_maskRect)) {
        return CGRectInset(self.bounds, _thumbWidth, _borderWidth);
    } else {
        return _maskRect;
    }
}

- (CGFloat)maskMaxWidth {
    // 若 mask max width 未赋值或不合法，则使用 _maskLayer 的宽度
    if (_maskMaxWidth <= 0 || isinf(_maskMaxWidth)) {
        return CGRectGetWidth(_maskLayer.bounds);
    }
    return _maskMaxWidth;
}

#pragma mark -

- (CGRect)maskRectWithThumb:(PanControl *)thumb {
	CGRect transformMaskRect = self.maskRect;
	
	if (thumb == _leftThumb) {
		transformMaskRect = CGRectMake(CGRectGetMinX(_panBeganMaskRect) + thumb.translation.x,
									   CGRectGetMinY(_panBeganMaskRect),
									   CGRectGetWidth(_panBeganMaskRect) - thumb.translation.x,
									   CGRectGetHeight(_panBeganMaskRect));
	} else if (thumb == _rightThumb) {
		transformMaskRect = CGRectMake(CGRectGetMinX(_panBeganMaskRect),
									   CGRectGetMinY(_panBeganMaskRect),
									   CGRectGetWidth(_panBeganMaskRect) + thumb.translation.x,
									   CGRectGetHeight(_panBeganMaskRect));
	}
	
	const CGFloat maskMaxWidth = self.maskMaxWidth;
	const CGFloat maskMinWidth = _maskMinWidth;
	CGFloat rectWidth = transformMaskRect.size.width;
	if (thumb == _leftThumb) {
		CGFloat diff = 0;
        if (rectWidth < maskMinWidth) { // 小于最小值
			diff = rectWidth - maskMinWidth;
            if (self.reachMinHandler) self.reachMinHandler(self, thumb);
		} else if (rectWidth > maskMaxWidth) { // 大于最大值
			diff = rectWidth - maskMaxWidth;
            if (self.reachMaxHandler) self.reachMaxHandler(self, thumb);
		}
        if (transformMaskRect.origin.x < _thumbWidth && rectWidth < maskMaxWidth) {
            diff = _thumbWidth - transformMaskRect.origin.x;
        }
		transformMaskRect.origin.x += diff;
		transformMaskRect.size.width -= diff;
	} else if (thumb == _rightThumb) {
		CGFloat diff = 0;
		CGFloat edgeY = CGRectGetWidth(self.bounds) - _thumbWidth;
		CGFloat rectMaxX = CGRectGetMaxX(transformMaskRect);
		if (rectWidth > maskMaxWidth) { // 大于最大值
			diff = rectWidth - maskMaxWidth;
            if (self.reachMaxHandler) self.reachMaxHandler(self, thumb);
		} else if (rectMaxX > edgeY) {
			diff = rectMaxX - edgeY;
		} else if (rectWidth < maskMinWidth) { // 小于最小值
			diff = rectWidth - maskMinWidth;
            if (self.reachMinHandler) self.reachMinHandler(self, thumb);
		}
		transformMaskRect.size.width -= diff;
	}
    if (transformMaskRect.size.width < 0) {
        transformMaskRect.size.width = 0;
    }
	//rect = CGRectMake(ceil(rect.origin.x), ceil(rect.origin.y), ceil(rect.size.width), ceil(rect.size.height));
	return transformMaskRect;
}

#pragma mark - ResizeConrolDelegate

- (void)controlDidBeginPan:(PanControl *)control {
    [self bringSubviewToFront:control];
    
	_panBeganMaskRect = self.maskRect;
    _dragging = YES;
    
    if (_startTrimmingHandler) _startTrimmingHandler(self, control);
}

- (void)controlPaning:(PanControl *)control {
	double progress = 0;
	const CGFloat contentWidth = CGRectGetWidth(_maskLayer.bounds);
	const CGRect controlFrameOnMaskLayer = [control.layer.superlayer convertRect:control.frame toLayer:_maskLayer];
    
    if (control == _leftThumb) {
		progress = MAX(0, CGRectGetMaxX(controlFrameOnMaskLayer) / contentWidth);
		_startProgress = progress;
    } else if (control == _rightThumb) {
		progress = MIN(1, CGRectGetMinX(controlFrameOnMaskLayer) / contentWidth);
		_endProgress = progress;
    }
	self.maskRect = [self maskRectWithThumb:control];
	
    if (_trimmingHandler) _trimmingHandler(self, control, progress);
}

- (void)controlDidEndPan:(PanControl *)control {
	[self controlPaning:control];
    _dragging = NO;
    
    if (_endTrimmingHandler) _endTrimmingHandler(self, control);
}

#pragma mark - touch

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01 || ![self pointInside:point withEvent:event]) return nil;
    UIView *hitView = [super hitTest:point withEvent:event];
    // 响应子视图
    if (hitView != self) {
        return hitView;
    }
    return nil;
}

@end
