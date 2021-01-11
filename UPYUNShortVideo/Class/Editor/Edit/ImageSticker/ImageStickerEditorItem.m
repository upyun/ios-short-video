//
//  ImageStickerEditorItem.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/4/22.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "ImageStickerEditorItem.h"
//#import "TuSDKFramework.h"

@interface ImageStickerEditorItem () <UIGestureRecognizerDelegate>
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

@implementation ImageStickerEditorItem
@synthesize stickerEditor = _stickerEditor;
@synthesize effect = _effect;
@synthesize tag = _tag;
@synthesize editable = _editable;
@synthesize selected = _selected;


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self lsqInitView];
    }
    return self;
}


/**
 初始化
 
 @param editor StickerEditor
 @return StickerEditorItem
 */
- (instancetype)initWithEditor:(StickerEditor *)editor
{
    NSAssert(!CGRectEqualToRect(editor.contentView.bounds, CGRectZero), @"无效的 contentView");
    
    if (self = [self initWithFrame:editor.contentView.bounds])
    {
        _stickerEditor = editor;
    }
    return self;
}

// 初始化视图
- (void)lsqInitView
{
    NSAssert(!_stickerEditor, @"无效的 stickerEditor");

    _editable = YES;

    // 默认缩放比例
    _mScale = 1.f;
    
    self.strokeColor = [UIColor whiteColor];
    self.strokeWidth = 2.0f;
    
    // 图片视图
    _imageView = [UIImageView initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.layer.allowsEdgeAntialiasing = YES;
    [self addSubview:_imageView];
    
    // 取消按钮
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [_cancelButton setImage:[UIImage imageNamed:@"edit_text_ic_close"] forState:UIControlStateNormal];
    [_cancelButton addTouchUpInsideTarget:self action:@selector(handleCancelButton)];
    [self addSubview:_cancelButton];
    _cancelButton.hidden = YES;
    
    // 旋转缩放按钮
    _turnButton = [[UIButton alloc] initWithFrame:CGRectMake(self.lsqGetSizeWidth - 36, self.lsqGetSizeHeight - 36, 36, 36)];
    [_turnButton setImage:[UIImage imageNamed:@"edit_text_ic_scale"] forState:UIControlStateNormal];
    [self addSubview:_turnButton];
    _turnButton.hidden = YES;
    
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
    
    // 手势
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

-(void)viewWillDestory
{
    [super viewWillDestory];
    
    [self removeGestureRecognizer:_panGesture];
    [self removeGestureRecognizer:_rotationGesture];
    [self removeGestureRecognizer:_pinchGesture];
}

- (void)dealloc
{
    [self viewWillDestory];
}

-(void)setEditable:(BOOL)editable
{
    self.userInteractionEnabled = editable;
    _editable = editable;
}

- (BOOL)canDisplay:(CMTime)time
{
    if (!self.effect)return NO;
    
    CMTimeRange timeRange = self.effect.atTimeRange.CMTimeRange;
    BOOL shouldShow = CMTIME_COMPARE_INLINE(time, >=, timeRange.start) && CMTIME_COMPARE_INLINE(time , <= ,CMTimeRangeGetEnd(timeRange));
    return shouldShow;
}

// 关闭贴纸
- (void)handleCancelButton;
{
    [_stickerEditor removeItem:self];
    
    __block NSUInteger index = 0;
    [_stickerEditor.items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if (item.effect.effectType == TuSDKMediaEffectDataTypeStickerImage)
        {
            item.tag = index++;
        }
    }];
}

/**
 *  重置视图大小
 */
- (void)resetViewsBounds
{
    CGSize size = self.bounds.size;
    [_imageView lsqSetSize:CGSizeMake(size.width - _mCMargin.width, size.height - _mCMargin.height)];
    [_turnButton lsqSetOrigin:CGPointMake(size.width - _turnButton.lsqGetSizeWidth, size.height - _turnButton.lsqGetSizeHeight)];
}

//  最小缩小比例(默认: 0.5f <= mMinScale <= 1)
- (CGFloat)minScale
{
    if (_minScale < 0.5f)
    {
        _minScale = 0.5f;
    }
    return _minScale;
}

// 选中状态
- (void)setSelected:(BOOL)selected
{
    if ((!selected && _hasTouched) || !_editable)
    {
        return;
    }
    
    if (selected == _selected)
    {
        return;
    }
        
    _selected = selected;
    [_imageView lsqSetBorderWidth:self.strokeWidth color:_selected ? self.strokeColor : [UIColor clearColor]];
    
    _cancelButton.hidden = !selected;
    _turnButton.hidden = !selected;

    if (selected)
    {
        [_stickerEditor.items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop)
        {
            if (item != self)
            {
                item.selected = NO;
            }
        }];
        
        [_stickerEditor.delegate imageStickerEditor:_stickerEditor didSelectedItem:self];
    }
    else
    {
        [_stickerEditor.delegate imageStickerEditor:_stickerEditor didCancelSelectedItem:self];
    }
}

/**
 设置图片贴纸
 
 @param stickerImageEffect 贴纸对象
 */
- (void)setEffect:(TuSDKMediaStickerImageEffect *)stickerImageEffect
{
    if (!stickerImageEffect)
    {
        return;
    }
    
    self.clipsToBounds = YES;
    
    _effect = stickerImageEffect;
    
    // stickerImageEffect.stickerImage.designScreenSize = _stickerEditor.contentView.bounds.size;
    

    // 内容视图长宽
    _mCSize = stickerImageEffect.stickerImage.image.size;
    _mScale = stickerImageEffect.stickerImage.imageSize.width / _mCSize.width;
    // 设置图片
    _imageView.image = stickerImageEffect.stickerImage.image;
    
    _mDegree = stickerImageEffect.stickerImage.degree;
    
    // 内容对角线长度
    _mCHypotenuse = [TuSDKTSMath distanceOfPointX1:0 y1:0 pointX2:_mCSize.width y2:_mCSize.height];
    // 默认视图长宽
    _mDefaultViewSize = CGSizeMake(_mCSize.width + _mCMargin.width, _mCSize.height + _mCMargin.height);
    // 最大缩放比例
    _mMaxScale = MIN((_stickerEditor.contentView.lsqGetSizeWidth - _mCMargin.width) / _mCSize.width,
                     (_stickerEditor.contentView.lsqGetSizeHeight - _mCMargin.height) / _mCSize.height);
    
    if (_mMaxScale < self.minScale)
    {
        _mMaxScale = self.minScale;
    }
    
    if (CGPointEqualToPoint(stickerImageEffect.stickerImage.centerPercent, CGPointZero))
    {
        [self lsqSetSize:_mDefaultViewSize];
        [self resetViewsBounds];
        
        CGPoint origin = self.lsqGetOrigin;
        origin.x = (_stickerEditor.contentView.lsqGetSizeWidth - _mDefaultViewSize.width) * 0.5f;
        origin.y = (_stickerEditor.contentView.lsqGetSizeHeight - _mDefaultViewSize.height) * 0.5f;
        
        [self lsqSetOrigin:origin];
    }
    else
    {
        [self lsqSetSize: CGSizeMake(stickerImageEffect.stickerImage.imageSize.width + _mCMargin.width,
                                     stickerImageEffect.stickerImage.imageSize.height + _mCMargin.height)];
        [self resetViewsBounds];
        
        // 初始位置
        CGPoint origin = self.lsqGetOrigin;
        
        CGPoint stickerCenterPercent = stickerImageEffect.stickerImage.centerPercent;
        CGSize stickerDesignScreenSize = stickerImageEffect.stickerImage.designScreenSize;

        origin.x = (stickerCenterPercent.x * stickerDesignScreenSize.width) - (self.lsqGetSize.width * 0.5f);
        origin.y = (stickerCenterPercent.y * stickerDesignScreenSize.height) - (self.lsqGetSize.height * 0.5f);
        
        [self lsqSetOrigin:origin];
        
        /** 设置旋转 */
        self.transform = CGAffineTransformMakeRotation([TuSDKTSMath radianFromDegrees:_mDegree]);
    }
}


#pragma mark - PanGesture
/**************************************************/
// 同时执行旋转缩放手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

// 拖动手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    _isInGesture = YES;
    
    CGPoint point = [recognizer locationInView:_stickerEditor.contentView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if (!_turnButton.hidden)
        {
            CGPoint selfPoint = [recognizer locationInView:self];
            // 是否为旋转缩放动作
            _isRotatScaleAction = CGRectContainsPoint(_turnButton.frame, selfPoint);
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (_isRotatScaleAction)
        {
            CGFloat preAngle = [TuSDKTSMath degreesWithPoint:_lastPotion center:self.center];
            CGFloat curAngle = [TuSDKTSMath degreesWithPoint:point center:self.center];
            
            _mDegree = fmodf(360 + _mDegree + (curAngle - preAngle), 360);
            [self rotationWithDegrees:_mDegree];

            CGFloat preDis = [TuSDKTSMath distanceOfEndPoint:self.center startPoint:_lastPotion];
            CGFloat curDis = [TuSDKTSMath distanceOfEndPoint:self.center startPoint:point];
            
            _mScale += 2 * (curDis - preDis) / _mCHypotenuse;
            _mScale = MAX(self.minScale, MIN(_mScale, _mMaxScale));
            
            CGSize size = CGSizeMake(floorf(_mCSize.width * _mScale + _mCMargin.width), floorf(_mCSize.height * _mScale + _mCMargin.height));
            
            // 修复移动范围
            CGPoint center = self.center;
            
            if (_stickerEditor.contentView)
            {
                center.x = (center.x < 0) ? 0 : center.x;
                center.x = (center.x > _stickerEditor.contentView.lsqGetSizeWidth) ? _stickerEditor.contentView.lsqGetSizeWidth : center.x;

                center.y = (center.y < 0) ? 0 : center.y;
                center.y = (center.y > _stickerEditor.contentView.lsqGetSizeHeight) ? _stickerEditor.contentView.lsqGetSizeHeight : center.y;
            }

            
            self.bounds = CGRectMake(0, 0, size.width, size.height);
            self.center = center;
            [self resetViewsBounds];
        }
        else
        {
            CGPoint center = self.center;
            center.x += point.x - _lastPotion.x;
            center.y += point.y - _lastPotion.y;
                       
            if (_stickerEditor.contentView)
            {
                center.x = (center.x < 0) ? 0 : center.x;
                center.x = (center.x > _stickerEditor.contentView.lsqGetSizeWidth) ? _stickerEditor.contentView.lsqGetSizeWidth : center.x;

                center.y = (center.y < 0) ? 0 : center.y;
                center.y = (center.y > _stickerEditor.contentView.lsqGetSizeHeight) ? _stickerEditor.contentView.lsqGetSizeHeight : center.y;
            }
            
            
            self.center = center;
        }
    }
    else
    {
        _hasTouched = NO;
    }
    _lastPotion = point;
}

// 旋转手势
- (void)handleRotationGesture:(UIRotationGestureRecognizer *)recognizer
{
    _isInGesture = YES;
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        _mDegree = fmodf(360 + _mDegree + [TuSDKTSMath degreesFromRadian:recognizer.rotation], 360);
        
        [self rotationWithDegrees:_mDegree];
    }
    else
    {
        _hasTouched = (recognizer.state == UIGestureRecognizerStateBegan);
    }
    recognizer.rotation = 0;
}

// 缩放手势
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    _isInGesture = YES;
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        _mScale += recognizer.scale - 1;
        _mScale = MAX(self.minScale, MIN(_mScale, _mMaxScale));
        
        CGSize size = CGSizeMake(floorf(_mCSize.width * _mScale + _mCMargin.width), floorf(_mCSize.height * _mScale + _mCMargin.height));
        
        // 修复移动范围
        CGPoint center = self.center;
        if (_stickerEditor.contentView)
        {
            center.x = (center.x < 0) ? 0 : center.x;
            center.x = (center.x > _stickerEditor.contentView.lsqGetSizeWidth) ? _stickerEditor.contentView.lsqGetSizeWidth : center.x;

            center.y = (center.y < 0) ? 0 : center.y;
            center.y = (center.y > _stickerEditor.contentView.lsqGetSizeHeight) ? _stickerEditor.contentView.lsqGetSizeHeight : center.y;
        }
        
        self.bounds = CGRectMake(0, 0, size.width, size.height);
        self.center = center;
        [self resetViewsBounds];
    }
    else
    {
        _hasTouched = (recognizer.state == UIGestureRecognizerStateBegan);
    }
    
    recognizer.scale = 1;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.editable)
    {
        return;
    }
    
    _isInGesture = NO;
    _hasTouched = YES;
    self.selected = YES;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _hasTouched = _isInGesture;
}




#pragma mark - rect


/**
 *  获取贴纸处理结果
 *
 *  @param regionRect 选区范围
 *
 *  @return 贴纸处理结果
 */
- (id<TuSDKMediaEffect>)resultWithRegionRect:(CGRect)regionRect;
{
    if (self.effect && !self.editable)
    {
        return self.effect;
    }
    
    CGRect rect;
    
    if (!_stickerEditor.contentView)
    {
        rect = regionRect;
    }
    else
    {
        // 中心点坐标
        CGPoint cPoint = self.center;

        if (CGRectIsEmpty(regionRect))
        {
            regionRect = _stickerEditor.contentView.bounds;
        }

        CGRect center = CGRectMake(cPoint.x, cPoint.y, _mCSize.width * _mScale, _mCSize.height * _mScale);

        // 减去选区外距离
        center = CGRectOffset(center, -regionRect.origin.x, -regionRect.origin.y);

        center.origin.x /= regionRect.size.width;
        center.origin.y /= regionRect.size.height;
        center.size.width /= regionRect.size.width;
        center.size.height /= regionRect.size.height;

        rect = center;
    }
    
    
    TuSDKMediaStickerImageEffect *stickerImageEffect = self.effect;
    stickerImageEffect.stickerImage.centerPercent = rect.origin;
    stickerImageEffect.stickerImage.imageSize = CGSizeMake(_mCSize.width * _mScale, _mCSize.height * _mScale);
    stickerImageEffect.stickerImage.degree = _mDegree;
    stickerImageEffect.stickerImage.designScreenSize = regionRect.size;
    
    printf("%f %f %f %f \n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    printf("%f %f \n", stickerImageEffect.stickerImage.imageSize.width, stickerImageEffect.stickerImage.imageSize.height);

    
    
    return stickerImageEffect;
}


@end

