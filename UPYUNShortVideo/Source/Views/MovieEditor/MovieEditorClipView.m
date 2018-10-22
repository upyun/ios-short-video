//
//  MovieEditorClipView.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/26.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditorClipView.h"

/// 左右手势view 宽度
static const CGFloat kThumbWidth = 20;
/// 顶部边距线高度
static const CGFloat kBorderHeight = 2;

@interface MovieEditorClipView (){
    // 数据源
    // 拖拽控件的宽度
    CGFloat _intervalWidth;
    // 可见视图的左右边距(留够触摸范围)
    CGFloat _edgeInterval;
    
    // 视图布局
    // 整体内容背景view
    UIView *_contentView;
    // 左侧显示开始的view, 以其右边界表示0点
    UIView *_leftView;
    // 左侧手势响应view
    UIView *_leftTouchView;
    // 左侧显示开始的view, 以其左边界表示最大时间
    UIView *_rightView;
    // 右侧手势响应view
    UIView *_rightTouchView;
    // 上方边界
    UIView *_upLine;
    // 下方边界
    UIView *_downLine;
    // 显示间隔时间view
    UIView *_currentTimeView;
    // 缩略图背景view
    UIView *_thumbnailsView;
    // 顶部选中遮罩层view
    UIView *_shadowView;
    // 独立白色滑块，与左右滑块互斥
    UIView *_blockTouchView;
    
    // 当前拖动的是否为时间控件
    BOOL _isSlipEndBtn;
    // 最小间隔间距
    CGFloat _minCutRectWidth;
    // 开始触摸的视图
    UIView *_touchBeginView;
}

@end

@implementation MovieEditorClipView

#pragma mark - property

// 设置光标进度
- (void)setCurrentTime:(CGFloat)currentTime
{
    // 设置当前时间，同时调整当前时间条(白色条)的位置
    _currentTime = currentTime;
    if (!_isSlipEndBtn) {
        [_currentTimeView lsqSetOriginX:_leftTouchView.lsqGetSizeWidth + (self.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth*2)*_currentTime/_duration];
    }
}

- (void)setVideoURL:(NSURL *)videoURL
{
    if (videoURL) {
        _videoURL = videoURL;
        // 获取视频缩略图
        __weak MovieEditorClipView * wSelf = self;
        TuSDKVideoImageExtractor *imageExtractor = [TuSDKVideoImageExtractor createExtractor];
        imageExtractor.videoPath = _videoURL;
        imageExtractor.outputMaxImageSize = CGSizeMake(40, 40);
        // 缩略图个数结合滑动栏宽高计算，若需求不同，可另外更改
        int num = (int)ceilf(_thumbnailsView.lsqGetSizeWidth/(_thumbnailsView.lsqGetSizeHeight*3/5));
        imageExtractor.extractFrameCount = num + 2;
        [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
            [wSelf addThumbnails:images];
        }];
    }
}

- (void)setDuration:(CGFloat)totalDuration
{
    if (isnan(totalDuration)) return;
    
    _duration = totalDuration;
    if (_minCutTime) {
        _minCutRectWidth = _thumbnailsView.lsqGetSizeWidth * (_minCutTime/totalDuration);
    }
    if (CMTIMERANGE_IS_EMPTY(_clipTimeRange)) {
        _clipTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(totalDuration, USEC_PER_SEC));
    }
    [self updateLayoutWithDuration:totalDuration];
}

- (void)setMinCutTime:(CGFloat)minCutTime
{
     if (isnan(minCutTime)) return;
    
    _minCutTime = minCutTime;
    if (_duration) {
        _minCutRectWidth = _thumbnailsView.lsqGetSizeWidth * (_minCutTime/_duration);
    }
}

- (void)setClipTimeRange:(CMTimeRange)clipRange {
    _clipTimeRange = clipRange;
    
    [self updateLayoutWithDuration:_duration];
}

/// 根据给定的视频时长与选择区间成员变量重新布局
- (void)updateLayoutWithDuration:(CGFloat)duration {

   if (isnan(duration) || duration <= 0) return;

    //[self hideLeftRightTouchView:NO];
    CGFloat rangeStart = CMTimeGetSeconds(_clipTimeRange.start);
    CGFloat rangeDuration = CMTimeGetSeconds(_clipTimeRange.duration);
    
    CGFloat leftX =  rangeStart/_duration*(_contentView.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth*2) + _leftTouchView.lsqGetSizeWidth/2;
    CGFloat rightX = (rangeStart + rangeDuration )/_duration*(_contentView.lsqGetSizeWidth - _rightTouchView.lsqGetSizeWidth*2) + _rightTouchView.lsqGetSizeWidth/2 + _leftTouchView.lsqGetSizeWidth;
    
    CGFloat y = _leftTouchView.center.y;
    [self updateClipRangeLeftViewPoint:CGPointMake(leftX, y) rightX:rightX];
    [self updateClipRangeRightViewPoint:CGPointMake(rightX, y)];
    
    CGRect blockFrame = _blockTouchView.frame;
    blockFrame.size.width = CMTimeGetSeconds(_clipTimeRange.duration) / _duration * CGRectGetWidth(_thumbnailsView.frame);
    blockFrame.origin.x = CMTimeGetSeconds(_clipTimeRange.start) / _duration * CGRectGetWidth(_thumbnailsView.frame) + CGRectGetMinX(_thumbnailsView.frame);
    _blockTouchView.frame = blockFrame;
}

#pragma mark - 视图布局方法；
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createCustomView];
    }
    return self;
}

- (void)createCustomView
{
    _clipTimeRange = kCMTimeRangeZero;
    _intervalWidth = 0;
    _edgeInterval = (kThumbWidth - _intervalWidth*2);

    // 内容背景view
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 4, self.lsqGetSizeWidth, self.lsqGetSizeHeight - 8)];
    [self addSubview:_contentView];

    // 缩略图背景View
    _thumbnailsView = [[UIView alloc] initWithFrame:CGRectMake(kThumbWidth, 0, _contentView.lsqGetSizeWidth - kThumbWidth*2, _contentView.lsqGetSizeHeight)];
    _thumbnailsView.clipsToBounds = true;
    _thumbnailsView.backgroundColor = lsqRGB(240, 240, 240);
    [_contentView addSubview:_thumbnailsView];
    
    // 左侧手势范围view + 左侧边界view
    _leftTouchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kThumbWidth, _contentView.lsqGetSizeHeight)];
    [_contentView addSubview:_leftTouchView];
    
    _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _leftTouchView.lsqGetSizeWidth, _contentView.lsqGetSizeHeight)];
    _leftView.backgroundColor = kCustomYellowColor;
    [_leftTouchView addSubview:_leftView];
    
    UIImageView *leftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _leftView.lsqGetSizeWidth/2, _leftView.lsqGetSizeWidth/2)];
    leftIV.center = CGPointMake(_leftView.lsqGetSizeWidth/2, _leftView.lsqGetSizeHeight/2);
    leftIV.image = [UIImage imageNamed:@"video_style_default_crop_btn_triangle"];
    leftIV.contentMode = UIViewContentModeScaleAspectFit;
    [_leftView addSubview:leftIV];
    
    // 右侧手势范围view + 右侧边界view
    _rightTouchView = [[UIView alloc] initWithFrame:CGRectMake(_contentView.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth, 0, kThumbWidth, _contentView.lsqGetSizeHeight)];
    [_contentView addSubview:_rightTouchView];
    
    _rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rightTouchView.lsqGetSizeWidth, _contentView.lsqGetSizeHeight)];
    _rightView.backgroundColor = kCustomYellowColor;
    _leftView.contentMode = UIViewContentModeScaleAspectFill;
    [_rightTouchView addSubview:_rightView];
    
    UIImageView *rightIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _leftView.lsqGetSizeWidth/2, _leftView.lsqGetSizeWidth/2)];
    rightIV.center = CGPointMake(_rightView.lsqGetSizeWidth/2, _rightView.lsqGetSizeHeight/2);
    rightIV.contentMode = UIViewContentModeScaleAspectFit;
    rightIV.image = [UIImage imageNamed:@"video_style_default_crop_btn_triangle_right"];
    [_rightView addSubview:rightIV];
    
    // 上侧边界view
    _upLine = [[UIView alloc] initWithFrame:CGRectMake(kThumbWidth, 0, _thumbnailsView.lsqGetSizeWidth, kBorderHeight)];
    _upLine.backgroundColor = kCustomYellowColor;
    [_contentView addSubview:_upLine];
    
    // 下侧边界view
    _downLine = [[UIView alloc] initWithFrame:CGRectMake(kThumbWidth, _contentView.lsqGetSizeHeight - kBorderHeight, _thumbnailsView.lsqGetSizeWidth, kBorderHeight)];
    _downLine.backgroundColor = kCustomYellowColor;
    [_contentView addSubview:_downLine];
    
    // 顶部阴影遮罩view
    _shadowView = [[UIView alloc] initWithFrame:CGRectMake(_leftTouchView.lsqGetOriginX + _leftTouchView.lsqGetSizeWidth, _upLine.lsqGetOriginY + kBorderHeight, _rightTouchView.lsqGetOriginX - _leftTouchView.lsqGetOriginX - _leftTouchView.lsqGetSizeWidth, _contentView.lsqGetSizeHeight - kBorderHeight*2)];
    _shadowView.backgroundColor = lsqRGBA(255, 255, 255, 0.6);
    [_contentView addSubview:_shadowView];
    
    // 当前时间进度条
    _currentTimeView = [[UIView alloc] initWithFrame:CGRectMake(kThumbWidth, -4, 3, self.lsqGetSizeHeight)];
    _currentTimeView.backgroundColor = kCustomYellowColor;
    _currentTimeView.layer.cornerRadius = 1.5;
    [_contentView addSubview:_currentTimeView];
    
    // 独立滑块
    _blockTouchView = [[UIView alloc] initWithFrame:CGRectMake(kThumbWidth, 0, kThumbWidth, _contentView.lsqGetSizeHeight)];
    [_contentView addSubview:_blockTouchView];
    _blockTouchView.backgroundColor = lsqRGBA(255, 255, 255, 0.6);
    _blockTouchView.layer.borderWidth = kBorderHeight;
    _blockTouchView.layer.borderColor = kCustomYellowColor.CGColor;
    _blockTouchView.hidden = YES;
}

// 添加缩略图
- (void)addThumbnails:(NSArray<UIImage *> *)images
{
    [_thumbnailsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];

    for (int i = 0; i < images.count; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * (_contentView.lsqGetSizeHeight *3/5), 0, _contentView.lsqGetSizeHeight * 3/5, _contentView.lsqGetSizeHeight)];
        iv.image = images[i];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = true;
        [_thumbnailsView addSubview:iv];
    }
}

- (void)hideLeftRightTouchView:(BOOL)isHidden{
    _leftTouchView.hidden = isHidden;
    _rightTouchView.hidden = isHidden;
    _shadowView.hidden = isHidden;
}

- (void)setBlockTouchViewHidden:(BOOL)hidden {
    _blockTouchView.hidden = hidden;
}

#pragma mark - 拖动手势方法 touches method
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(_leftTouchView.frame, point) &&  !_leftTouchView.hidden) {
        _isSlipEndBtn = true;
        _leftTouchView.tag = 1;
        _rightTouchView.tag = 0;
        if ([self.clipDelegate respondsToSelector:@selector(slipBeginEvent)]) {
            [self.clipDelegate slipBeginEvent];
        }
        _touchBeginView = _leftTouchView;
    } else if (CGRectContainsPoint(_rightTouchView.frame, point) && !_rightTouchView.hidden) {
        _rightTouchView.tag = 1;
        _leftTouchView.tag = 0;
        _isSlipEndBtn = true;
        if ([self.clipDelegate respondsToSelector:@selector(slipBeginEvent)]) {
            [self.clipDelegate slipBeginEvent];
        }
        _touchBeginView = _rightTouchView;
    } else if (CGRectContainsPoint(_blockTouchView.frame, point) && !_blockTouchView.hidden) {
        _touchBeginView = _blockTouchView;
        if ([self.clipDelegate respondsToSelector:@selector(slipBeginEvent)]) {
            [self.clipDelegate slipBeginEvent];
        }
    } else {
        _touchBeginView = _currentTimeView;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (_touchBeginView == _leftTouchView) {
        [self updateTimeWithClipRangeLeftViewPoint:point rightX:0];
        _isSlipEndBtn = YES;
    } else if (_touchBeginView == _rightTouchView) {
        [self updateTimeWithClipRangeRightViewPoint:point];
        _isSlipEndBtn = YES;
    } else if (_touchBeginView == _blockTouchView) {
        [self updateBlockTouchViewPositionWithTouchPoint:point];
    } else if (_touchBeginView == _currentTimeView) {
        [self updateCurrentProgressViewPoint:point];
        _isSlipEndBtn = NO;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ((_rightTouchView.tag == 1 && _leftTouchView.tag == 0) || (_rightTouchView.tag == 0 && _leftTouchView.tag == 1) ) {
        if ([self.clipDelegate respondsToSelector:@selector(slipEndEvent)]) {
            [self.clipDelegate slipEndEvent];
        }
    }
    _isSlipEndBtn = NO;
    _leftTouchView.tag = 0;
    _rightTouchView.tag = 0;
}

- (void)updateTimeWithClipRangeLeftViewPoint:(CGPoint)point rightX:(CGFloat)rightX;
{
    [self updateClipRangeLeftViewPoint:point rightX:rightX];
    [self chooseChangedWith:_leftTouchView.lsqGetOriginX + _leftTouchView.lsqGetSizeWidth withState:lsqClipViewStyleLeft];
}

- (void)updateClipRangeLeftViewPoint:(CGPoint)point rightX:(CGFloat)rightX{
    CGFloat touchViewWidth = _leftTouchView.lsqGetSizeWidth;
    if (rightX) {
        _rightTouchView.center = CGPointMake(rightX, _rightTouchView.center.y);
    }
    if (point.x >= _edgeInterval/2 && point.x <= _rightTouchView.center.x - touchViewWidth - _minCutRectWidth) {
        _leftTouchView.center = CGPointMake(point.x, _leftTouchView.center.y);
    }else if (point.x < _edgeInterval/2) {
        _leftTouchView.center = CGPointMake(_leftTouchView.lsqGetSizeWidth/2, _leftTouchView.center.y);
    }else {
        _leftTouchView.center = CGPointMake(_rightTouchView.center.x - touchViewWidth - _minCutRectWidth, _leftTouchView.center.y);
    }
    [self setUpDownLine];
}

- (void)updateTimeWithClipRangeRightViewPoint:(CGPoint)point;
{
    [self updateClipRangeRightViewPoint:point];
    [self chooseChangedWith:_rightTouchView.lsqGetOriginX withState:lsqClipViewStyleRight];
}

- (void)updateClipRangeRightViewPoint:(CGPoint)point{
    CGFloat touchViewWidth = _leftTouchView.lsqGetSizeWidth;
    if (point.x <= _contentView.lsqGetSizeWidth - _edgeInterval/2 && point.x >= _leftTouchView.center.x + touchViewWidth + _minCutRectWidth) {
        _rightTouchView.center = CGPointMake(point.x, _rightTouchView.center.y);
    }else if (point.x > _contentView.lsqGetSizeWidth - _edgeInterval/2) {
        _rightTouchView.center = CGPointMake(_contentView.lsqGetSizeWidth - touchViewWidth/2, _rightTouchView.center.y);
    }else {
        _rightTouchView.center = CGPointMake(_leftTouchView.center.x + touchViewWidth + _minCutRectWidth, _rightTouchView.center.y);
    }
    [self setUpDownLine];
}

- (void)updateCurrentProgressViewPoint:(CGPoint)point;
{
    if (_duration <= 0) return;
    
    CGFloat time = _duration * (point.x - _leftTouchView.lsqGetSizeWidth)/(_contentView.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth*2);
    if (time < 0) {
        time = 0;
    }else if (time > _duration){
        time = _duration;
    }
    self.currentTime = time;
    if ([self.clipDelegate respondsToSelector:@selector(chooseTimeWith:withState:)]) {
        [self.clipDelegate chooseTimeWith:time withState:lsqClipViewStyleCurrent];
    }
}

- (void)updateBlockTouchViewPositionWithTouchPoint:(CGPoint)point {
    if (_blockTouchView.hidden) return;
    
    CGFloat touchX = point.x;
    CGRect touchBounds = [_thumbnailsView.superview convertRect:_thumbnailsView.frame toView:self];
    CGFloat maxTouchX = CGRectGetMaxX(touchBounds) - _blockTouchView.lsqGetSizeWidth / 2;
    CGFloat minTouchX = CGRectGetMinX(touchBounds) + _blockTouchView.lsqGetSizeWidth / 2;
    if (touchX > maxTouchX) touchX = maxTouchX;
    if (touchX < minTouchX) touchX = minTouchX;
    
    CGPoint center = _blockTouchView.center;
    center.x = touchX;
    _blockTouchView.center = center;
    
    CGRect blcokTouchRect = [_blockTouchView.superview convertRect:_blockTouchView.frame toView:_thumbnailsView];
    CGFloat startSeconds = CGRectGetMinX(blcokTouchRect) / CGRectGetWidth(_thumbnailsView.frame) * _duration;
    //CGFloat rangeDurationSeconds = CGRectGetWidth(blcokTouchRect) / CGRectGetWidth(_thumbnailsView.frame) * _duration;
    _clipTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(startSeconds, USEC_PER_SEC), _clipTimeRange.duration);
    
    if ([self.clipDelegate respondsToSelector:@selector(chooseTimeWith:withState:)]) {
        [self.clipDelegate chooseTimeWith:startSeconds withState:lsqClipViewStyleCurrent];
    }
}

#pragma mark - 事件响应方法

/**
 拖动过程中设置上下边界frame
 */
- (void)setUpDownLine
{
//    _upLine.frame = CGRectMake(_leftTouchView.lsqGetOriginX + _leftTouchView.lsqGetSizeWidth, 0, _rightTouchView.lsqGetOriginX - _leftTouchView.lsqGetOriginX - _leftTouchView.lsqGetSizeWidth, kBorderHeight);
//    _downLine.frame = CGRectMake(_upLine.lsqGetOriginX, _contentView.lsqGetSizeHeight - kBorderHeight, _upLine.lsqGetSizeWidth, kBorderHeight);
    _shadowView.frame = CGRectMake(_leftTouchView.lsqGetOriginX + _leftTouchView.lsqGetSizeWidth, _upLine.lsqGetOriginY + kBorderHeight, _rightTouchView.lsqGetOriginX - _leftTouchView.lsqGetOriginX - _leftTouchView.lsqGetSizeWidth, _contentView.lsqGetSizeHeight - kBorderHeight*2);
}


/**
 拖动过程中的方法调用
 
 @param currentX 当前位置x
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 */
- (void)chooseChangedWith:(CGFloat)currentX withState:(lsqClipViewStyle)viewStyle
{
    CGFloat time = _duration * (currentX - _leftTouchView.lsqGetSizeWidth)/(_contentView.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth*2);
   
    if (time < 0) {
        time = 0;
    }else if (time > _duration){
        time = _duration;
    }
    
    switch (viewStyle) {
        case lsqClipViewStyleLeft:{
            _clipTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(time, USEC_PER_SEC), _clipTimeRange.duration);
        } break;
        case lsqClipViewStyleRight:{
            _clipTimeRange = CMTimeRangeFromTimeToTime(_clipTimeRange.start, CMTimeMakeWithSeconds(time, USEC_PER_SEC));
        } break;
        case lsqClipViewStyleCurrent:{
            
        } break;
    }
    
    
    if ([self.clipDelegate respondsToSelector:@selector(chooseTimeWith:withState:)]) {
        [self.clipDelegate chooseTimeWith:time withState:viewStyle];
    }
}

@end
