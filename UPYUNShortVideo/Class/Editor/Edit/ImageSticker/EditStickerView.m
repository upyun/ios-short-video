//
//  EditStickerView.m
//  TuSDK
//
//

#import "EditStickerView.h"

#pragma mark - EditStickerViewItemView

/**
 *  贴纸元件视图
 */
@interface EditStickerViewItemView()<UIGestureRecognizerDelegate>
{
    // 图片视图边缘距离
    UIEdgeInsets _mImageEdge;
    // 内容视图长宽
    CGSize _mCSize;
    // 内容视图边缘距离
    CGSize _mCMargin;
    // 最大缩放比例
    CGFloat _mMaxScale;
    // 默认视图长宽
    CGSize _mDefaultViewSize;
    // 内容对角线长度
    CGFloat _mCHypotenuse;
    
    // 缩放比例
    CGFloat _mScale;
    // 旋转度数
    CGFloat _mDegree;
    // 是否为旋转缩放动作
    BOOL _isRotatScaleAction;
    // 拖动手势
    UIPanGestureRecognizer *_panGesture;
    // 旋转手势
    UIRotationGestureRecognizer *_rotationGesture;
    // 缩放手势
    UIPinchGestureRecognizer *_pinchGesture;
    // 最后的触摸点
    CGPoint _lastPotion;
    // 是否正在操作
    BOOL _hasTouched;
    // 是否为手势动作
    BOOL _isInGesture;
}
@end

@implementation EditStickerViewItemView

@synthesize stickerImageEffect = _stickerImageEffect;

- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

// 初始化视图
- (void)lsqInitView;
{
    // 默认缩放比例
    _mScale = 1.f;
    
    // 图片视图
    _imageView = [UIImageView initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    // IOS7 边缘抗锯齿
    _imageView.layer.allowsEdgeAntialiasing = YES;
    [self addSubview:_imageView];
    
    // 取消按钮

    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [_cancelButton setImage:[UIImage imageNamed:@"edit_text_ic_close"] forState:UIControlStateNormal];
    [_cancelButton addTouchUpInsideTarget:self action:@selector(handleCancelButton)];
    [self addSubview:_cancelButton];
    
    // 旋转缩放按钮
    _turnButton = [[UIButton alloc] initWithFrame:CGRectMake(self.lsqGetSizeWidth - 36, self.lsqGetSizeHeight - 36, 36, 36)];
    [_turnButton setImage:[UIImage imageNamed:@"edit_text_ic_scale"] forState:UIControlStateNormal];
    [self addSubview:_turnButton];
    
    [self resetImageEdge];
    // 添加手势
    [self appendGestureRecognizer];
    
    
}

- (void)display:(BOOL)isDisplay animated:(BOOL)animated;{
    self.hidden = !isDisplay;
}

// 添加手势
- (void)appendGestureRecognizer;
{
    // 拖动手势
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    _panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_panGesture];
    // 旋转手势
    _rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotationGesture:)];
    _rotationGesture.delegate = self;
    [self addGestureRecognizer:_rotationGesture];

    // 缩放手势
    _pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];
    _pinchGesture.delegate = self;
    [self addGestureRecognizer:_pinchGesture];
}

// 同时执行旋转缩放手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    return YES;
}

// 删除手势
- (void)removeGestureRecognizer;
{
    [self removeGestureRecognizer:_panGesture];
    [self removeGestureRecognizer:_rotationGesture];
    [self removeGestureRecognizer:_pinchGesture];
}

-(void)viewWillDestory;
{
    [super viewWillDestory];
    [self removeGestureRecognizer];
}

- (void)dealloc
{
    [self viewWillDestory];
}

// 关闭贴纸
- (void)handleCancelButton;
{
    self.sticker = nil;
    if ([self.delegate respondsToSelector:@selector(onClosedStickerItemView:)])
    {
        [self.delegate onClosedStickerItemView:self];
    }
}

/**
 *  重置图片视图边缘距离
 */
- (void)resetImageEdge;
{
    // 图片视图边缘距离
    _mImageEdge.left = ceilf(_cancelButton.lsqGetSizeWidth * 0.5f);
    _mImageEdge.right = ceilf(_turnButton.lsqGetSizeWidth * 0.5f);
    _mImageEdge.top = ceilf(_cancelButton.lsqGetSizeHeight * 0.5f);
    _mImageEdge.bottom = ceilf(_turnButton.lsqGetSizeHeight * 0.5f);
    
    // 内容视图边缘距离
    _mCMargin.width = _mImageEdge.left + _mImageEdge.right;
    _mCMargin.height = _mImageEdge.top + _mImageEdge.bottom;
    [_imageView lsqSetOrigin:CGPointMake(_mImageEdge.left, _mImageEdge.top)];
    [self lsqSetSize:self.lsqGetSize];
    // 重置视图大小
    [self resetViewsBounds];
}

/**
 *  重置视图大小
 */
- (void)resetViewsBounds;
{
    CGSize size = self.bounds.size;
    [_imageView lsqSetSize:CGSizeMake(size.width - _mCMargin.width,
                                   size.height - _mCMargin.height)];
    
    [_turnButton lsqSetOrigin:CGPointMake(size.width - _turnButton.lsqGetSizeWidth, size.height - _turnButton.lsqGetSizeHeight)];
}

//  最小缩小比例(默认: 0.5f <= mMinScale <= 1)
- (CGFloat)minScale;
{
    if (_minScale < 0.5f) {
        _minScale = 0.5f;
    }
    return _minScale;
}

// 选中状态
- (void)setSelected:(BOOL)selected;
{
    if (!selected && _hasTouched){
        return;
    }
    _selected = selected;
    [_imageView lsqSetBorderWidth:self.strokeWidth color:_selected ? self.strokeColor : [UIColor clearColor]];
    
    _cancelButton.hidden = !selected;
    _turnButton.hidden = !selected;

}

/**
 设置图片贴纸

 @param stickerImageEffect 贴纸对象
 */
- (void)setStickerImageEffect:(TuSDKMediaStickerImageEffect *)stickerImageEffect; {
    
    if (!stickerImageEffect) return;
    
    _stickerImageEffect = stickerImageEffect;
    
    // 文字贴纸不允许缩放旋转
    _turnButton.hidden = NO;
    // 内容视图长宽
    _mCSize = stickerImageEffect.stickerImage.image.size;
    _mScale = _stickerImageEffect.stickerImage.imageSize.width / _mCSize.width;
    // 设置图片
    _imageView.image = stickerImageEffect.stickerImage.image;
    
    _mDegree = stickerImageEffect.stickerImage.degree;
    
    // 内容对角线长度
    _mCHypotenuse = [TuSDKTSMath distanceOfPointX1:0 y1:0 pointX2:_mCSize.width y2:_mCSize.height];
    // 默认视图长宽
    _mDefaultViewSize = CGSizeMake(_mCSize.width + _mCMargin.width, _mCSize.height + _mCMargin.width);
    // 最大缩放比例
    _mMaxScale = MIN((self.superview.lsqGetSizeWidth - _mCMargin.width) / _mCSize.width,
                     (self.superview.lsqGetSizeHeight - _mCMargin.height) / _mCSize.height);
    
    if (_mMaxScale < self.minScale) _mMaxScale = self.minScale;
    
    if (!CGPointEqualToPoint(_stickerImageEffect.stickerImage.centerPercent, CGPointZero))
        [self updateStickerPositionByImageEffect:_stickerImageEffect];
    else
        [self updateStickerPositionByDefault];
    
}

/**
 更新贴纸位置 默认居中显示
 */
- (void)updateStickerPositionByDefault;{
   
    [self lsqSetSize:_mDefaultViewSize];
    // 重置视图大小
    [self resetViewsBounds];
    
    // 初始位置
    CGPoint origin = self.lsqGetOrigin;
    
    origin.x = (self.superview.lsqGetSizeWidth - _mDefaultViewSize.width) * 0.5f;
    origin.y = (self.superview.lsqGetSizeHeight - _mDefaultViewSize.height) * 0.5f;
    
    // 设置居中
    [self lsqSetOrigin:origin];
}

/**
 根据图片贴纸特效更新位置
 
 @param stickerImageEffect 图片贴纸特效
 */
- (void)updateStickerPositionByImageEffect:(TuSDKMediaStickerImageEffect *)stickerImageEffect;{
    
    [self lsqSetSize: CGSizeMake(_stickerImageEffect.stickerImage.imageSize.width + _mCMargin.width, _stickerImageEffect.stickerImage.imageSize.height + _mCMargin.width)];
    // 重置视图大小
    [self resetViewsBounds];
    
    // 初始位置
    CGPoint origin = self.lsqGetOrigin;
    
    origin.x =
    (_stickerImageEffect.stickerImage.centerPercent.x * _stickerImageEffect.stickerImage.designScreenSize.width) - (self.lsqGetSize.width * 0.5f);
    
    origin.y = (_stickerImageEffect.stickerImage.centerPercent.y * _stickerImageEffect.stickerImage.designScreenSize.height) - (self.lsqGetSize.height * 0.5f);
    
    // 设置居中
    [self lsqSetOrigin:origin];
    
    /** 设置旋转 */
    self.transform = CGAffineTransformMakeRotation([TuSDKTSMath radianFromDegrees:_mDegree]);
}

#pragma mark - PanGesture
// 拖动手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
{
    _isInGesture = YES;
    CGPoint point = [recognizer locationInView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if (!_turnButton.hidden) {
            CGPoint selfPoint = [recognizer locationInView:self];
            // 是否为旋转缩放动作
            _isRotatScaleAction = CGRectContainsPoint(_turnButton.frame, selfPoint);
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (_isRotatScaleAction) {
            [self handlePanGestureRotatScaleAction:point];
        }
        else{
            [self handlePanGestureTransAction:point];
        }
    }
    else {
        _hasTouched = NO;
    }
    _lastPotion = point;
}

// 旋转手势
- (void)handleRotationGesture:(UIRotationGestureRecognizer *)recognizer;
{
    _isInGesture = YES;
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // 旋转度数
        _mDegree = [TuSDKTSMath numberFloat:_mDegree + 360 + [TuSDKTSMath degreesFromRadian:recognizer.rotation] modulus:360];
        
        [self rotationWithDegrees:_mDegree];
    }
    else{
        _hasTouched = (recognizer.state == UIGestureRecognizerStateBegan);
    }
    recognizer.rotation = 0;
}

// 缩放手势
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer;
{
    _isInGesture = YES;
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self computerScaleWithScale:recognizer.scale - 1 center:self.center];
    }
    else{
        _hasTouched = (recognizer.state == UIGestureRecognizerStateBegan);
    }
    recognizer.scale = 1;
}
#pragma mark - touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    _isInGesture = NO;
    _hasTouched = YES;
    if (self.delegate) {
        [self.delegate onSelectedStickerItemView:self];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    _hasTouched = _isInGesture;
}

#pragma mart - handleTransAction
// 处理移动位置
- (void)handlePanGestureTransAction:(CGPoint)nowPoint;
{
    CGPoint center = self.center;
    center.x += nowPoint.x - _lastPotion.x;
    center.y += nowPoint.y - _lastPotion.y;
    
    // 修复移动范围
    center = [self fixedCenterPoint:center];
    self.center = center;
}

#pragma mart - handleRotatScaleAction
// 处理旋转和缩放
- (void)handlePanGestureRotatScaleAction:(CGPoint)nowPoint;
{
    // 中心点
    CGPoint cPoint = self.center;
    
    // 计算旋转角度
    [self computerAngleWithPoint:nowPoint lastPoint:_lastPotion center:cPoint];
    
    // 计算缩放
    [self computerScaleWithPoint:nowPoint lastPoint:_lastPotion center:cPoint];
}

- (void)loginfo:(NSString *)tag;
{
    lsqLDebug(@"loginfo:%@ \rframe: %@ | \rbounds: %@ | \rcenter: %@ | \rlayer.frame:%@ |\rlayer.bounds:%@ | \rlayer.position: %@ | \rlayer.anchorPoint: %@",
              tag,
              NSStringFromCGRect(self.frame),
              NSStringFromCGRect(self.bounds),
              NSStringFromCGPoint(self.center),
              NSStringFromCGRect(self.layer.frame),
              NSStringFromCGRect(self.layer.bounds),
              NSStringFromCGPoint(self.layer.position),
              NSStringFromCGPoint(self.layer.anchorPoint));
}

/**
 * 计算旋转角度
 *
 * @param point
 *            当前坐标点
 * @param lastPoint
 *            最后坐标点
 * @param cPoint
 *            中心点坐标
 */
- (void)computerAngleWithPoint:(CGPoint)point
                     lastPoint:(CGPoint)lastPoint
                        center:(CGPoint)cPoint;
{
    // 开始角度
    CGFloat sAngle = [TuSDKTSMath degreesWithPoint:lastPoint center:cPoint];
    // 结束角度
    CGFloat eAngle = [TuSDKTSMath degreesWithPoint:point center:cPoint];

    // 旋转度数
    _mDegree = [TuSDKTSMath numberFloat:_mDegree + 360 + (eAngle - sAngle) modulus:360];
    
    [self rotationWithDegrees:_mDegree];
}

/**
 * 计算缩放
 *
 * @param point
 *            当前坐标点
 * @param lastPoint
 *            最后坐标点
 * @param cPoint
 *            中心点坐标
 */
- (void)computerScaleWithPoint:(CGPoint)point
                     lastPoint:(CGPoint)lastPoint
                        center:(CGPoint)cPoint;
{
    // 开始距离中心点距离
    CGFloat sDistance = [TuSDKTSMath distanceOfEndPoint:cPoint startPoint:lastPoint];
    
    // 当前距离中心点距离
    CGFloat cDistance = [TuSDKTSMath distanceOfEndPoint:cPoint startPoint:point];
    // 缩放距离
    CGFloat distance = cDistance - sDistance;
    if (distance == 0) return;
    
    // 计算缩放偏移
    [self computerScaleWithScale:distance / _mCHypotenuse center:cPoint];
}

/**
 *  计算缩放
 *
 *  @param scale  缩放倍数
 *  @param cPoint 中心点坐标
 */
- (void)computerScaleWithScale:(CGFloat)scale center:(CGPoint)cPoint;
{
    // 计算缩放偏移
    CGFloat offsetScale = scale * 2;
    // 缩放比例
    _mScale += offsetScale;
    _mScale = MAX(self.minScale, MIN(_mScale, _mMaxScale));
    
    CGSize size = CGSizeMake(floorf(_mCSize.width * _mScale + _mCMargin.width),
                             floorf(_mCSize.height * _mScale + _mCMargin.height));
    
    // 修复移动范围
    CGPoint center = [self fixedCenterPoint:cPoint];
    
    self.bounds = CGRectMake(0, 0, size.width, size.height);
    self.center = center;
    [self resetViewsBounds];
}

#pragma mark - rect
/**
 *  修复移动范围
 *
 *  @param center 当前中心点
 *
 *  @return 移动的中心坐标
 */
- (CGPoint)fixedCenterPoint:(CGPoint)center;
{
    if (!self.superview) return center;
    
    if (center.x < 0) {
        center.x = 0;
    }else if (center.x > self.superview.lsqGetSizeWidth){
        center.x = self.superview.lsqGetSizeWidth;
    }
    
    if (center.y < 0) {
        center.y = 0;
    }else if (center.y > self.superview.lsqGetSizeHeight){
        center.y = self.superview.lsqGetSizeHeight;
    }
    return center;
}

/**
 *  获取贴纸处理结果
 *
 *  @param regionRect 选区范围
 *
 *  @return 贴纸处理结果
 */
- (TuSDKMediaStickerImageEffect *)resultWithRegionRect:(CGRect)regionRect;
{
    CGRect rect = [self centerOfParentRegin:regionRect];
    

    _stickerImageEffect.stickerImage.centerPercent = rect.origin;
    _stickerImageEffect.stickerImage.imageSize = CGSizeMake(_mCSize.width * _mScale, _mCSize.height * _mScale);
    _stickerImageEffect.stickerImage.degree = _mDegree;
    _stickerImageEffect.stickerImage.designScreenSize = regionRect.size;
    
    return _stickerImageEffect;
}



/**
 *  获取相对于父亲视图选区中心百分比信息
 *
 *  @param regionRect 选区范围
 *
 *  @return 相对于父亲视图选区中心百分比信息
 */
- (CGRect)centerOfParentRegin:(CGRect)regionRect;
{
    if (!self.superview) return regionRect;
    
    // 中心点坐标
    CGPoint cPoint = self.center;
    
    if (CGRectIsEmpty(regionRect)) {
        regionRect = self.superview.bounds;
    }
    
    CGRect center = CGRectMake(cPoint.x, cPoint.y, _mCSize.width * _mScale, _mCSize.height * _mScale);
    
    // 减去选区外距离
    center = CGRectOffset(center, -regionRect.origin.x, -regionRect.origin.y);
    
    center.origin.x /= regionRect.size.width;
    center.origin.y /= regionRect.size.height;
    
    center.size.width /= regionRect.size.width;
    center.size.height /= regionRect.size.height;
    
    return center;
}
@end

#pragma mark - EditStickerView
/**
 *  贴纸视图
 */
@interface EditStickerView(){
    // 贴纸列表
    NSMutableArray<EditStickerViewItemView *> *_stickers;
}
@end


@implementation EditStickerView

- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

// 初始化视图
- (void)lsqInitView;
{
    _stickers = [NSMutableArray array];
    self.clipsToBounds = YES;
}

/**
 *  当前已使用贴纸总数
 *
 *  @return 当前已使用贴纸总数
 */
- (NSUInteger)stickerCount;
{
    return _stickers.count;
}

- (void)selectStickerWithIndex:(NSUInteger)index;{
    if (index > _stickers.count - 1)
        return;
    
    [self onSelectedStickerItemView:[_stickers objectAtIndex:index]];
}

- (void)showStickerItemAtTime:(CMTime)time animated:(BOOL)animated {
    [_stickers enumerateObjectsUsingBlock:^(EditStickerViewItemView*  _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CMTimeRange timeRange = itemView.stickerImageEffect.atTimeRange.CMTimeRange;
        BOOL shouldShow = CMTIME_COMPARE_INLINE(time, >=, timeRange.start) && CMTIME_COMPARE_INLINE(time , <= ,CMTimeRangeGetEnd(timeRange));
        
        [itemView display:shouldShow animated:animated];
    }];
    
}


/**
 添加贴纸特效
 @param stickerImageEffect 贴纸特效
 */
- (void)appendStickerImageEffect:(TuSDKMediaStickerImageEffect *)stickerImageEffect autoSelect:(BOOL)select;
{
    if (!stickerImageEffect) {
        [TuSDKProgressHUD showMainThreadErrorWithStatus:LSQString(@"lsq_sticker_load_unexsit", @"贴纸不存在，请换一个试试")];
        return;
    }
    
    // 画布会切换比例，每次显示贴纸时需要设置设计尺寸
    stickerImageEffect.stickerImage.designScreenSize = self.bounds.size;
    
    EditStickerViewItemView *view = [self buildStickerView:stickerImageEffect];
    view.selected = NO;

    
    if (select)
        [self onSelectedStickerItemView:view];
}

// 创建贴纸视图
- (EditStickerViewItemView *)buildStickerView:(TuSDKMediaStickerImageEffect *)stickerImageEffect;
{
    EditStickerViewItemView *view = [[EditStickerViewItemView alloc] initWithFrame:self.bounds];
    view.delegate = self;
    view.index = _stickers.count;

    [self addSubview:view];
    [_stickers addObject:view];
    
    view.strokeColor = [UIColor whiteColor];
    view.strokeWidth = 2.0f;
    view.stickerImageEffect = stickerImageEffect;
    return view;
}

/**
 *  获取贴纸处理结果
 *
 *  @param regionRect 图片选区范围
 *
 *  @return 贴纸处理结果
 */
- (NSArray<TuSDKMediaStickerImageEffect *> *)resultsWithRegionRect:(CGRect)regionRect;
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:_stickers.count];
    for (EditStickerViewItemView *item in _stickers) {
        [results addObject:[item resultWithRegionRect:regionRect]];
    }
    return results;
}

// 取消所有贴纸选中状态
- (void)cancelAllSelected;
{
    for (EditStickerViewItemView *item in _stickers) {
        if (item.selected)
            [_delegate onDidCancelSelecteStickerItemView:item];
        item.selected = NO;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount > 1) return;
    [self cancelAllSelected];
}

#pragma mark - TuSDKPFStickerItemViewDelegate
/**
 *  贴纸元件关闭
 *
 *  @param view 贴纸元件视图
 */
- (void)onClosedStickerItemView:(EditStickerViewItemView *)view;
{
    if (!view) return;
    
    [_stickers removeObject:view];
    [view removeFromSuperview];
    [_delegate onClosedStickerItemView:view];
    
    /** 重置索引 */
    [_stickers enumerateObjectsUsingBlock:^(EditStickerViewItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        itemView.index = idx;
    }];
}

/**
 *  选中贴纸元件
 *
 *  @param view 贴纸元件视图
 */
- (void)onSelectedStickerItemView:(EditStickerViewItemView *)view;
{
    if (!view) return;
    for (EditStickerViewItemView *item in _stickers) {
        item.selected = [item isEqual:view];
    }
    
    [_delegate onSelectedStickerItemView:view];
}


@end
