//
//  MovieEditorClipView.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/26.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditorClipView.h"

@interface MovieEditorClipView (){
    // 数据源
    // 拖拽控件的宽度
    CGFloat _intervalWidth;
    // 可见视图的左右边距(留够触摸范围)
    CGFloat _edgeInterval;
    
    // 视图布局
    // 左侧显示开始的view, 以其右边界表示0
    UIView *_leftView;
    // 左侧手势响应view
    UIView *_leftTouchView;
    // 左侧显示开始的view, 以其左边界表示最大
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
    UIView *_backView;
    // 顶部选中遮罩层view
    UIView *_shadowView;
    
    // 当前拖动的是否为起始控件
    BOOL _isSlipEndBtn;
    // 最小间隔间距
    CGFloat _minCutRectWidth;
}

@end

@implementation MovieEditorClipView

#pragma mark - setter getter方法；
- (void)setCurrentTime:(CGFloat)currentTime
{
    // 设置当前时间，同时调整当前时间条(白色条)的位置
    _currentTime = currentTime;
    if (!_isSlipEndBtn) {
        [_currentTimeView lsqSetOriginX:_leftTouchView.lsqGetSizeWidth + (self.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth*2)*_currentTime/_timeInterval];
    }
}

- (void)setThumbnails:(NSArray<UIImage *> *)thumbnails
{
    _thumbnails = thumbnails;
    [self addThumbnails];
}

- (void)setTimeInterval:(CGFloat)timeInterval
{
    _timeInterval = timeInterval;
    _minCutRectWidth = _backView.lsqGetSizeWidth * (_minCutTime/timeInterval);
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
    _intervalWidth = 0;
    _edgeInterval = (30 - _intervalWidth*2);
    
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, self.lsqGetSizeHeight)];
    _backView.clipsToBounds = true;
    _backView.backgroundColor = lsqRGB(240, 240, 240);
    [self addSubview:_backView];
    
    // 当前时间进度条
    _currentTimeView = [[UIView alloc]initWithFrame:CGRectMake(30, 0, 2, _backView.lsqGetSizeHeight)];
    _currentTimeView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_currentTimeView];
    
    // 左侧手势范围view + 左侧边界view
    _leftTouchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, self.lsqGetSizeHeight)];
    [self addSubview:_leftTouchView];
    
    _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _leftTouchView.lsqGetSizeWidth, self.lsqGetSizeHeight)];
    _leftView.backgroundColor = kCustomYellowColor;
    [_leftTouchView addSubview:_leftView];
    
    UIImageView *leftIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _leftView.lsqGetSizeWidth/2, _leftView.lsqGetSizeWidth/2)];
    leftIV.center = CGPointMake(_leftView.lsqGetSizeWidth/2, _leftView.lsqGetSizeHeight/2);
    leftIV.image = [UIImage imageNamed:@"video_style_default_crop_btn_triangle"];
    leftIV.contentMode = UIViewContentModeScaleAspectFit;
    [_leftView addSubview:leftIV];
    
    // 右侧手势范围view + 右侧边界view
    _rightTouchView = [[UIView alloc]initWithFrame:CGRectMake(self.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth, 0, _leftTouchView.lsqGetSizeWidth, self.lsqGetSizeHeight)];
    [self addSubview:_rightTouchView];
    
    _rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _rightTouchView.lsqGetSizeWidth, self.lsqGetSizeHeight)];
    _rightView.backgroundColor = kCustomYellowColor;
    _leftView.contentMode = UIViewContentModeScaleAspectFill;
    [_rightTouchView addSubview:_rightView];
    
    UIImageView *rightIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _leftView.lsqGetSizeWidth/2, _leftView.lsqGetSizeWidth/2)];
    rightIV.center = CGPointMake(_rightView.lsqGetSizeWidth/2, _rightView.lsqGetSizeHeight/2);
    rightIV.contentMode = UIViewContentModeScaleAspectFit;
    rightIV.image = [UIImage imageNamed:@"video_style_default_crop_btn_triangle_right"];
    [_rightView addSubview:rightIV];
    
    // 上侧边界view
    _upLine = [[UIView alloc] initWithFrame:CGRectMake(_edgeInterval, 0, _backView.lsqGetSizeWidth, 4)];
    _upLine.backgroundColor = kCustomYellowColor;
    [self addSubview:_upLine];
    
    // 下侧边界view
    _downLine = [[UIView alloc] initWithFrame:CGRectMake(_edgeInterval, self.lsqGetSizeHeight - 4, _backView.lsqGetSizeWidth, 4)];
    _downLine.backgroundColor = kCustomYellowColor;
    [self addSubview:_downLine];
    
    // 顶部阴影遮罩view
    _shadowView = [[UIView alloc]initWithFrame:CGRectMake(_leftTouchView.lsqGetOriginX + _leftTouchView.lsqGetSizeWidth, _upLine.lsqGetOriginY + 4, _rightTouchView.lsqGetOriginX - _leftTouchView.lsqGetOriginX - _leftTouchView.lsqGetSizeWidth, self.lsqGetSizeHeight - 8)];
    _shadowView.backgroundColor = lsqRGBA(35, 24, 21, 0.6);
    [self addSubview:_shadowView];
}

// 添加缩略图
- (void)addThumbnails
{
    for (int i = 0; i < _thumbnails.count; i++) {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i * (self.lsqGetSizeHeight *3/5), 0, self.lsqGetSizeHeight * 3/5, self.lsqGetSizeHeight)];
        iv.image = _thumbnails[i];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = true;
        [_backView addSubview:iv];
    }
}

#pragma mark - 拖动手势方法 touches method
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_leftTouchView.frame, point)) {
        // 1 0 表示选中左边调节view
        _leftTouchView.tag = 1;
        _rightTouchView.tag = 0;
        if ([self.clipDelegate respondsToSelector:@selector(slipBeginEvent)]) {
            [self.clipDelegate slipBeginEvent];
        }
    }else if (CGRectContainsPoint(_rightTouchView.frame, point)) {
        // 0 1 表示选中右边调节view
        _rightTouchView.tag = 1;
        _leftTouchView.tag = 0;
        _isSlipEndBtn = true;
        if ([self.clipDelegate respondsToSelector:@selector(slipBeginEvent)]) {
            [self.clipDelegate slipBeginEvent];
        }
    }else if (CGRectContainsPoint(_backView.frame, point)){
        // 1 1 表示进行调节中间白条
        _rightTouchView.tag = 1;
        _leftTouchView.tag = 1;
        [self refreshLeftOrRightViewLocationWithMovePoint:point];
    }else{
        // 0 0 表示不进行任何调节
        _rightTouchView.tag = 0;
        _leftTouchView.tag = 0;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_backView.frame, point)) {
        [self refreshLeftOrRightViewLocationWithMovePoint:point];
    }else{
        if ((_rightTouchView.tag == 1 && _leftTouchView.tag == 0) || (_rightTouchView.tag == 0 && _leftTouchView.tag == 1) ) {
            if ([self.clipDelegate respondsToSelector:@selector(slipEndEvent)]) {
                [self.clipDelegate slipEndEvent];
            }
        }
        _isSlipEndBtn = false;
        _leftTouchView.tag = 0;
        _rightTouchView.tag = 0;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ((_rightTouchView.tag == 1 && _leftTouchView.tag == 0) || (_rightTouchView.tag == 0 && _leftTouchView.tag == 1) ) {
        if ([self.clipDelegate respondsToSelector:@selector(slipEndEvent)]) {
            [self.clipDelegate slipEndEvent];
        }
    }
    _isSlipEndBtn = false;
    _leftTouchView.tag = 0;
    _rightTouchView.tag = 0;
}


/**
 根据当前手势响应的point，调整左右边界view显示的位置
 
 @param point 手势响应的 point
 */
- (void)refreshLeftOrRightViewLocationWithMovePoint:(CGPoint)point
{
    CGFloat touchViewWidth = _leftTouchView.lsqGetSizeWidth;
    if (_leftTouchView.tag == 1 && _rightTouchView.tag == 0) {
        if (point.x >= _edgeInterval/2 && point.x <= _rightTouchView.center.x - touchViewWidth - _minCutRectWidth) {
            _leftTouchView.center = CGPointMake(point.x, _leftTouchView.center.y);
        }else if (point.x < _edgeInterval/2) {
            _leftTouchView.center = CGPointMake(_leftTouchView.lsqGetSizeWidth/2, _leftTouchView.center.y);
        }else {
            _leftTouchView.center = CGPointMake(_rightTouchView.center.x - touchViewWidth - _minCutRectWidth, _leftTouchView.center.y);
        }
        [self chooseChangedWith:_leftTouchView.lsqGetOriginX + _leftTouchView.lsqGetSizeWidth withState:lsqClipViewStyleLeft];
        [self setUpDownLine];
        
    }else if (_rightTouchView.tag == 1 && _leftTouchView.tag == 0) {
        if (point.x <= self.lsqGetSizeWidth - _edgeInterval/2 && point.x >= _leftTouchView.center.x + touchViewWidth + _minCutRectWidth) {
            _rightTouchView.center = CGPointMake(point.x, _rightTouchView.center.y);
        }else if (point.x > self.lsqGetSizeWidth - _edgeInterval/2) {
            _rightTouchView.center = CGPointMake(self.lsqGetSizeWidth - touchViewWidth/2, _rightTouchView.center.y);
        }else {
            _rightTouchView.center = CGPointMake(_leftTouchView.center.x + touchViewWidth + _minCutRectWidth, _rightTouchView.center.y);
        }
        [self chooseChangedWith:_rightTouchView.lsqGetOriginX withState:lsqClipViewStyleRight];
        [self setUpDownLine];
    }else if (_rightTouchView.tag == 1 && _leftTouchView.tag == 1){
        CGFloat time = _timeInterval * (point.x - _leftTouchView.lsqGetSizeWidth)/(self.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth*2);
        self.currentTime = time;
        if ([self.clipDelegate respondsToSelector:@selector(chooseTimeWith:withState:)]) {
            [self.clipDelegate chooseTimeWith:time withState:lsqClipViewStyleCurrent];
        }
    }
}


#pragma mark - 事件响应方法

/**
 拖动过程中设置上下边界frame
 */
- (void)setUpDownLine
{
    _upLine.frame = CGRectMake(_leftTouchView.lsqGetOriginX + _leftTouchView.lsqGetSizeWidth, 0, _rightTouchView.lsqGetOriginX - _leftTouchView.lsqGetOriginX - _leftTouchView.lsqGetSizeWidth, 4);
    _downLine.frame = CGRectMake(_upLine.lsqGetOriginX, self.lsqGetSizeHeight - 4, _upLine.lsqGetSizeWidth, 4);
    _shadowView.frame = CGRectMake(_leftTouchView.lsqGetOriginX + _leftTouchView.lsqGetSizeWidth, _upLine.lsqGetOriginY + 4, _rightTouchView.lsqGetOriginX - _leftTouchView.lsqGetOriginX - _leftTouchView.lsqGetSizeWidth, self.lsqGetSizeHeight - 8);
}


/**
 拖动过程中的方法调用
 
 @param currentX 当前位置x
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 */
- (void)chooseChangedWith:(CGFloat)currentX withState:(lsqClipViewStyle)isStartStatus
{
    CGFloat time = _timeInterval * (currentX - _leftTouchView.lsqGetSizeWidth)/(self.lsqGetSizeWidth - _leftTouchView.lsqGetSizeWidth*2);
    
    if (time < 0) {
        time = 0;
    }else if (time > _timeInterval){
        time = _timeInterval;
    }
    if (isStartStatus) {
        self.currentTime = time;
    }
    
    if ([self.clipDelegate respondsToSelector:@selector(chooseTimeWith:withState:)]) {
        [self.clipDelegate chooseTimeWith:time withState:isStartStatus];
    }
}

@end
