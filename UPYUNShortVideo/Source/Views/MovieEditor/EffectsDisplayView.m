//
//  EffectsDisplayView.m
//  TuSDKVideoDemo
//
//  Created by wen on 13/12/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "EffectsDisplayView.h"
#import "TuSDKFramework.h"

@interface EffectsDisplayView (){
    // 当前位置View
    UIView *_currentLocationView;
    // 缩略图背景view
    UIView *_backView;
    // 阴影背景view
    UIView *_shadowBackView;
    
    // 记录阴影view 的 tag 数值的basic
    NSInteger _basicTag;
    // 最后一段添加的view的 tag 值
    NSInteger _lastViewTag;
    // 最后添加的view
    UIView *_lastView;
    // 开始拖动手势
    BOOL _touchBegin;
}
@end

@implementation EffectsDisplayView
// 0 ~ 1.0
- (void)setCurrentLocation:(CGFloat)currentLocation
{
    // 设置当前位置
    if (currentLocation < 0) currentLocation = 0;
    if (currentLocation > 1) currentLocation = 1;
    
    if (_currentLocation != currentLocation) {
        _currentLocationView.center = CGPointMake(_backView.lsqGetOriginX + currentLocation*_backView.lsqGetSizeWidth, _currentLocationView.center.y);
    }
    _currentLocation = currentLocation;

}

- (void)setVideoURL:(NSURL *)videoURL
{
    if (videoURL) {
        _videoURL = videoURL;
        // 获取视频缩略图
        __weak EffectsDisplayView * wSelf = self;
        TuSDKVideoImageExtractor *imageExtractor = [TuSDKVideoImageExtractor createExtractor];
        imageExtractor.videoPath = _videoURL;
        // 缩略图个数结合滑动栏宽高计算，若需求不同，可另外更改
        int num = (int)ceilf(_backView.lsqGetSizeWidth/(_backView.lsqGetSizeHeight*3/5));
        imageExtractor.extractFrameCount = num + 2;
        [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
            [wSelf addThumbnails:images];
        }];
    }
}

- (NSInteger)segmentCount;
{
    return _lastViewTag - _basicTag;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createCustomView];
        [self initData];
    }
    return self;
}

- (void)initData;
{
    _basicTag = 400;
    _lastViewTag = _basicTag;
}

- (void)createCustomView
{
    // 缩略图背景View
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 6, self.lsqGetSizeWidth, self.lsqGetSizeHeight - 12)];
    _backView.clipsToBounds = true;
    [self addSubview:_backView];
    
    // 缩略图遮罩层
    UIView *shadeView = [[UIView alloc]initWithFrame:_backView.frame];
    shadeView.backgroundColor = lsqRGBA(255, 255, 255, 0.6);
    shadeView.layer.borderWidth = 2;
    shadeView.layer.borderColor = lsqRGB(244, 161, 24).CGColor;
    [self addSubview:shadeView];
    
    // 顶部阴影View
    _shadowBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 4, self.lsqGetSizeWidth, self.lsqGetSizeHeight - 8)];
    [self addSubview:_shadowBackView];
    
    // 当前时间进度条
    _currentLocationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 3, self.lsqGetSizeHeight)];
    _currentLocationView.center = CGPointMake(_backView.lsqGetOriginX, self.lsqGetSizeHeight/2);
    _currentLocationView.backgroundColor = lsqRGB(244, 161, 24);
    _currentLocationView.layer.cornerRadius = 1.5;
    [self addSubview:_currentLocationView];
    
}

// 添加缩略图
- (void)addThumbnails:(NSArray<UIImage *> *)thumbnails
{
    [_backView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    for (int i = 0; i < thumbnails.count; i++) {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i * (_backView.lsqGetSizeHeight *3/5), 0, _backView.lsqGetSizeHeight * 3/5, _backView.lsqGetSizeHeight)];
        iv.image = thumbnails[i];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = true;
        [_backView addSubview:iv];
    }
}

- (void)refreshCurrentLocationWithPoint:(CGPoint)point;
{
    CGFloat newLocation = point.x / _shadowBackView.lsqGetSizeWidth;
    self.currentLocation = newLocation;
    if ([self.eventDelegate respondsToSelector:@selector(moveCurrentLocationView:)]) {
        [self.eventDelegate moveCurrentLocationView:_currentLocation];
    }
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, point)) {
        _touchBegin = YES;
        [self refreshCurrentLocationWithPoint:point];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (_touchBegin) {
        [self refreshCurrentLocationWithPoint:point];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (_touchBegin) {
        [self refreshCurrentLocationWithPoint:point];
    }
}



#pragma mark - segment method

/**
 添加一个显示片段
 
 @param progress 当前进度
 @param color 片段显示的颜色
 @return 是否添加成功
 */
- (BOOL)addSegmentViewBeginWithProgress:(CGFloat)progress WithColor:(UIColor *)color;
{
    if (progress >= 1 || progress < 0) {
        lsqLError(@"addSegmentViewBeginWithProgress failed  progress : %f",progress);
        return NO;
    }
    
    _isAdding = YES;
    _lastViewTag ++;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake((_shadowBackView.lsqGetSizeWidth)*progress, 0, 1, _shadowBackView.lsqGetSizeHeight)];
    view.tag = _lastViewTag;
    view.backgroundColor = color;
    [_shadowBackView addSubview:view];
    _lastView = view;
    return YES;
}

/**
 结束正在添加的位置
 */
- (void)makeFinish;
{
    _isAdding = NO;
    _lastView = nil;
}

/**
 当前正在添加的片段增加到某一位置
 
 @param progress 截止位置
 */
-(void)updateLastSegmentViewWithProgress:(CGFloat)progress
{
    if (!_lastView) return;
 
    [_lastView lsqSetSizeWidth:progress*_backView.lsqGetSizeWidth - _lastView.lsqGetOriginX];
}

/**
 移除所有已添加的片段
 */
- (void)removeAllSegment;
{
    [_shadowBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag > _basicTag) {
            [obj removeFromSuperview];
        }
    }];
    _lastViewTag = _basicTag;
}

/**
 移除上一个添加的片段
 */
- (void)removeLastSegment;
{
    if (_lastViewTag <= _basicTag) return;
    [_shadowBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == _lastViewTag) {
            [obj removeFromSuperview];
            _lastViewTag --;
        }
    }];
}

@end
