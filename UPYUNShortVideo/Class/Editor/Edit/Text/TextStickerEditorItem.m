//
//  TextItemTransformControl.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/6.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextStickerEditorItem.h"
#import "MediaTextEffect.h"


static const CGFloat kButtonWidth = 20;

@interface TextStickerEditorItem()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *scaleControl;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, assign) CGPoint panBeganPoint; // 开始滑动的记录点
@property (nonatomic, assign) CGFloat initialFontSize; //  初始字体大小

@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, assign) CGFloat beginRadius; // 开始半径
@property (nonatomic, assign) CGFloat beginAngle; // 开始角度
@property (nonatomic, assign) CGFloat panBeganScale; // 开始滑动记录的缩放值
@property (nonatomic, assign) CGFloat panBeganAngle; // 开始滑动记录的角度

@end

@implementation TextStickerEditorItem
@synthesize stickerEditor = _stickerEditor;
@synthesize effect = _effect;
@synthesize tag = _tag;
@synthesize editable = _editable;
@synthesize selected = _selected;
@synthesize isChanged = _isChanged;

-(instancetype)initWithEditor:(StickerEditor *)editor
{
    if (self = [self initWithFrame:CGRectZero])
    {
        _stickerEditor = editor;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
//    NSLog(@"dealloc: %@", self);
}

- (void)commonInit
{
    self.editable = YES;
    self.isChanged = YES;
    // 配置子视图
    _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_containerView];
    _containerView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_closeButton];
    [_closeButton setImage:[UIImage imageNamed:@"edit_text_ic_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.hidden = YES;
    
    
    _scaleControl = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_scaleControl];
    _scaleControl.layer.contents = (__bridge id)([UIImage imageNamed:@"edit_text_ic_scale"].CGImage);
    _scaleControl.layer.contentsGravity = kCAGravityResizeAspect;
    _scaleControl.hidden = YES;
    
    // 配置手势
    UIPanGestureRecognizer *translationPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(translationPanAction:)];
    [_containerView addGestureRecognizer:translationPan];
    
    UIPanGestureRecognizer *transformPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(transformPanAction:)];
    [_scaleControl addGestureRecognizer:transformPan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_containerView addGestureRecognizer:tap];
    
    [self addTarget:self action:@selector(controlTapAction:) forControlEvents:UIControlEventTouchUpInside];

    // 初始化成员变量
    _initialFontSize = [[AttributedLabel defaultLabel] font].pointSize;
    _scale = 1.0;
    _angle = 0;
}

-(void)setEditable:(BOOL)editable
{
    self.userInteractionEnabled = editable;
    _editable = editable;
}

- (BOOL)canDisplay:(CMTime)time
{
    CMTimeRange timeRange = self.textLabel.timeRange;
    BOOL shouldShow = CMTIME_COMPARE_INLINE(time, >=, timeRange.start) && CMTIME_COMPARE_INLINE(time , <= ,CMTimeRangeGetEnd(timeRange));
    return shouldShow;
}


/**
 计算最大缩放值

 @return 最大缩放值
 */
- (CGFloat)maxScale
{
    if (_maxScale > 0.0)
    {
        return _maxScale;
    }
    
    AttributedLabel *text = [AttributedLabel defaultLabel];
    NSString *fontName = _textLabel.font.fontName;
    text.font = [UIFont fontWithName:fontName size:text.font.pointSize];
    text.text = self.textLabel.text;
    text.edgeInsets = self.textLabel.edgeInsets;
    
    CGRect containerFrame = _containerView.frame;
    containerFrame.size = text.intrinsicContentSize;
    // 这里的3.0 取得是【UIScreen mainScreen】.scall 低端机型是2.0，但为了低端机型不要太大，统一3.0
    CGFloat max = 4000.0/3.0/CGRectGetWidth(containerFrame);
    return max;
}


/**
 文字项点击事件
 
 @param sender 点击的文字项
 */
- (void)controlTapAction:(TextStickerEditorItem *)sender
{
    self.selected = YES;
}

#pragma mark - property

- (void)setTextLabel:(AttributedLabel *)textLabel
{
    _isChanged = YES;
    _textLabel = textLabel;
    [_containerView addSubview:textLabel];
    textLabel.layer.allowsEdgeAntialiasing = YES;
    // 若是有布局信息，则应用到自身
    if (!CGPointEqualToPoint(CGPointZero, textLabel.center))
    {
        self.center = textLabel.center;
    }
    
    if (!CGAffineTransformIsIdentity(textLabel.transform))
    {
        self.transform = textLabel.transform;
        textLabel.transform = CGAffineTransformIdentity;
    }
//    _initialFontSize = textLabel.font.pointSize;
    CGSize contentSize = CGSizeEqualToSize(CGSizeZero, textLabel.frame.size) ? textLabel.intrinsicContentSize : textLabel.frame.size;
    [self updateLayoutWithContentSize:contentSize];
}

- (void)setSelected:(BOOL)selected
{
    if (!self.editable)
    {
        return;
    }
    
    BOOL valueChaned = self.isSelected;
    if (selected)
    {
        _containerView.layer.borderWidth = 1;
        _closeButton.hidden = _scaleControl.hidden = NO;
        
        if (valueChaned)
        {
            [_delegate shouldEditItem:self];
        }
    }
    else
    {
        _containerView.layer.borderWidth = 0;
        _closeButton.hidden = _scaleControl.hidden = YES;
    }
    
    if (_selected == selected)
    {
        return;
    }
    
    _selected = selected;
    [super setSelected:selected];
    
    if (selected)
    {
        [_stickerEditor.delegate imageStickerEditor:_stickerEditor didSelectedItem:self];
        [_stickerEditor.items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (item != self)
            {
                item.selected = NO;
            }
        }];
    }
    else
    {
        [_stickerEditor.delegate imageStickerEditor:_stickerEditor didCancelSelectedItem:self];
    }
}

#pragma mark - public

- (void)updateLayoutWithContentSize:(CGSize)contentSize
{
    _isChanged = YES;
    CGRect contentBounds = (CGRect){CGPointZero, contentSize};
    // frame.size 依赖于 contentSize，位置不变
    CGPoint center = self.center;
    self.bounds = CGRectMake(0, 0, contentSize.width + kButtonWidth, contentSize.height + kButtonWidth);;
    if (!CGPointEqualToPoint(CGPointZero, center))
        self.center = center;
    
    // containerView 大小依赖于 contentSize
    _containerView.bounds = contentBounds;
    _containerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // 内容与 containerView 重合
    _textLabel.frame = _containerView.bounds;
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // closeButton 大小固定，位置依赖于 containerView
    _closeButton.autoresizingMask = UIViewAutoresizingNone;
    _closeButton.bounds = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
    _closeButton.center = _containerView.frame.origin;
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    // closeButton 大小固定，位置依赖于 containerView
    _scaleControl.autoresizingMask = UIViewAutoresizingNone;
    _scaleControl.bounds = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
    _scaleControl.center = CGPointMake(CGRectGetMaxX(_containerView.frame), CGRectGetMaxY(_containerView.frame));
    _scaleControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    _scale =  _textLabel.font.pointSize / _initialFontSize;
}

#pragma mark - private

/**
 根据缩放与角度更新布局

 @param scale 缩放
 @param angle 角度
 */
- (void)setScale:(CGFloat)scale angle:(CGFloat)angle
{
    _isChanged = YES;
    
    if ([self maxScale] < scale * _scale)
    {
        scale = [self maxScale];
    }
    
    if (_initialFontSize * scale > kMaxFontSize)
    {
        return;
    }
    
    _textLabel.initialPercentCenter = CGPointZero;
    
    // 重置自身的变换
    self.transform = CGAffineTransformIdentity;
    
    // 应用缩放到 containerView
    NSString *fontName = _textLabel.font.fontName;
    _textLabel.font = [UIFont fontWithName:fontName size:_initialFontSize * scale];
    
    CGRect containerFrame = _containerView.frame;
    containerFrame.size = _textLabel.intrinsicContentSize;
    _containerView.frame = containerFrame;
    
    _scale = scale;
    _angle = angle;
    
    // 通过 _containerView size 计算出 self.frame
    CGRect frame = self.frame;
    CGSize contentSize = _containerView.frame.size;
    frame.origin.x += (frame.size.width - kButtonWidth - contentSize.width) / 2;
    frame.origin.y += (frame.size.height - kButtonWidth - contentSize.height) / 2;
    frame.size.width  = contentSize.width + kButtonWidth;
    frame.size.height = contentSize.height + kButtonWidth;
    self.frame = frame;
    
    // 校正位置
    _containerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // 应用旋转到 self
    self.transform = CGAffineTransformMakeRotation(angle);
}

#pragma mark - action

/**
 位移滑动事件

 @param sender 滑动手势
 */
- (void)translationPanAction:(UIPanGestureRecognizer *)sender
{
    _isChanged = YES;
    
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _panBeganPoint = self.center;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [sender translationInView:self.superview];
            
            BOOL canPanX = (CGRectGetMinX(self.frame) < 0 && translation.x > 0)
            || (CGRectGetMaxX(self.frame) > CGRectGetMaxX(self.superview.bounds) && translation.x < 0);
            BOOL canPanY = (CGRectGetMinY(self.frame) < 0 && translation.x > 0)
                            ||  (CGRectGetMaxY(self.frame) > CGRectGetMaxY(self.superview.bounds) && translation.x < 0);
            CGPoint resultCenter = CGPointMake(_panBeganPoint.x + translation.x, _panBeganPoint.y + translation.y);
    
            if (CGRectContainsPoint(self.superview.bounds, resultCenter))
            {
                self.center = resultCenter;
            }
            else if (canPanX || canPanY)
            {
                CGPoint resultCenter = CGPointMake( canPanX ?  (_panBeganPoint.x + translation.x) : self.center.x, canPanY ? (_panBeganPoint.y + translation.y) : self.center.y);
                self.center = resultCenter;
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

/**
 变形滑动事件

 @param sender 滑动手势
 */
- (void)transformPanAction:(UIPanGestureRecognizer *)sender
{
    _isChanged = YES;
    
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint location = [_scaleControl.superview convertPoint:_scaleControl.center toView:self.superview];
            CGPoint vectorToCenter = CGPointMake(location.x - self.center.x, location.y - self.center.y);
            _beginRadius = sqrt(pow(vectorToCenter.x, 2) + pow(vectorToCenter.y, 2));
            _beginAngle = atan2(vectorToCenter.y, vectorToCenter.x);
            
            _panBeganAngle = _angle;
            _panBeganScale = _scale;
        }
            break;
        
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [sender locationInView:self.superview];
            CGPoint vectorToCenter = CGPointMake(location.x - self.center.x, location.y - self.center.y);
            CGFloat radius = sqrt(pow(vectorToCenter.x, 2) + pow(vectorToCenter.y, 2));
            CGFloat angle = atan2(vectorToCenter.y, vectorToCenter.x);
            [self setScale:_panBeganScale * radius / _beginRadius
                     angle:_panBeganAngle + angle - _beginAngle];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

/**
 点击手势事件

 @param sender 点击手势
 */
- (void)tapAction:(UITapGestureRecognizer *)sender
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

/**
 关闭按钮事件

 @param sender 点击的按钮
 */
- (void)closeButtonAction:(UIButton *)sender
{
    [_stickerEditor removeItem:self];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_effect)
    {
        CGPoint centerPos = ((MediaTextEffect *)_effect).textStickerImage.centerPercent;
        CGSize viewSize = _stickerEditor.contentView.frame.size;
        
        self.center = CGPointMake(viewSize.width * centerPos.x, viewSize.height * centerPos.y);
    }
}

/**
 获取编辑后的特效数据

 @param regionRect 编辑区域
 @return id<TuSDKMediaEffect>
 */
- (id<TuSDKMediaEffect>)resultWithRegionRect:(CGRect)regionRect
{
    if (self.effect && !self.isChanged)
    {
        return self.effect;
    }
    
    CGSize videoSize = regionRect.size;
    
    AttributedLabel *textLabel = self.textLabel;
    CGRect textFrame = [textLabel.superview convertRect:textLabel.frame toView:_stickerEditor.contentView];
    // TODO 需要对齐视频的位置
    CGRect centerRect = [self centerRectWithTextFrame:textFrame];
    UIImage *image = [self textImageWithItemLabel:textLabel videoSize:videoSize];
    CGAffineTransform transform = self.transform;
    // 弧度
    double radian = atan2f(transform.b, transform.a);
    // 角度
    double degree = radian * (180 / M_PI);
    
    // 创建 text effect
    CMTimeRange timeRange = textLabel.timeRange;
    MediaTextEffect *textEffect = [[MediaTextEffect alloc] initWithStickerImage:image center:centerRect degree:degree designSize:videoSize];
    textEffect.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStart:timeRange.start duration:timeRange.duration];
    textEffect.edgeInsets = textLabel.edgeInsets;
    textEffect.backgroundColor = textLabel.backgroundColor;
    textEffect.text = textLabel.text;
    textEffect.textAttributes = textLabel.textAttributes;
    textEffect.textStrokeColorProgress = textLabel.textStrokeColorProgress;
    textEffect.textColorProgress = textLabel.textColorProgress;
    textEffect.bgColorProgress = textLabel.bgColorProgress;
    textEffect.textStickerImage.designScreenSize = regionRect.size;

    if (_effect && _stickerEditor.delegate && [_stickerEditor.delegate respondsToSelector:@selector(imageStickerEditor:updateEffectFromItem:)])
    {
        [_stickerEditor.delegate imageStickerEditor:_stickerEditor updateEffectFromItem:self];
        [_effect destory];
        _effect = nil;
    }
    NSLog(@"--textEffect:%@", textEffect);
    return textEffect;
}


- (void)setEffect:(id<TuSDKMediaEffect>)effect
{
    _effect = effect;
    MediaTextEffect *textEffect  = effect;
    AttributedLabel *textLabel = [AttributedLabel defaultLabel];
    textLabel.edgeInsets = textEffect.edgeInsets;
    textLabel.initialPercentCenter = textEffect.textStickerImage.centerPercent;
    textLabel.transform = CGAffineTransformMakeRotation(textEffect.textStickerImage.degree / 180 * M_PI);
    textLabel.backgroundColor = textEffect.backgroundColor;
    textLabel.text = textEffect.text;
    textLabel.textAttributes = textEffect.textAttributes;
    textLabel.timeRange = textEffect.atTimeRange.CMTimeRange;
    textLabel.textColorProgress = textEffect.textColorProgress;
    textLabel.textStrokeColorProgress = textEffect.textStrokeColorProgress;
    textLabel.bgColorProgress = textEffect.bgColorProgress;
    // 还原角度
    _angle = textEffect.textStickerImage.degree/180.0 * M_PI;
    
    self.center = CGPointMake(_stickerEditor.contentView.lsqGetSizeWidth * textEffect.textStickerImage.centerPercent.x,
                              _stickerEditor.contentView.lsqGetSizeHeight * textEffect.textStickerImage.centerPercent.y);

    // textLabel 信息设置完成后方可以设置
    self.textLabel = textLabel;
    
}

#pragma mark - util

/**
 由给定 texlLabel 矢量拉伸后生成图片
 
 @param textLabel 文字标签
 @return 图片
 */
- (UIImage *)textImageWithItemLabel:(AttributedLabel *)textLabel videoSize:(CGSize)videoSize
{
    CGRect originFrame = textLabel.frame;
    UIFont *originFont = textLabel.font;
    UIEdgeInsets originEdgeInsets = textLabel.edgeInsets;
    
    CGFloat textScale = videoSize.width / CGRectGetWidth(_stickerEditor.contentView.frame);
    
    textLabel.edgeInsets = UIEdgeInsetsMake(kTextEdgeInset * textScale, kTextEdgeInset * textScale, kTextEdgeInset * textScale, kTextEdgeInset * textScale);
    NSString *fontName = textLabel.font.fontName;
    textLabel.font = [UIFont fontWithName:fontName size:textLabel.font.pointSize * textScale];
    CGPoint center = textLabel.center;
    textLabel.center = center;
    
    
    UIGraphicsBeginImageContextWithOptions(textLabel.intrinsicContentSize, NO, .0);
    
    [textLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    textLabel.font = originFont;
    textLabel.edgeInsets = originEdgeInsets;
    textLabel.frame = originFrame;
    
    return image;
}


/**
 生成基于中点的百分比 frame
 
 @param textFrame 文字的 frame
 @return rect 尺寸比例
 */
- (CGRect)centerRectWithTextFrame:(CGRect)textFrame
{
    CGFloat x = CGRectGetMidX(textFrame);
    CGFloat y = CGRectGetMidY(textFrame);
    CGFloat w = CGRectGetWidth(textFrame);
    CGFloat h = CGRectGetHeight(textFrame);
    CGFloat width = CGRectGetWidth(_stickerEditor.contentView.bounds);
    CGFloat height = CGRectGetHeight(_stickerEditor.contentView.bounds);
    x /= width;
    y /= height;
    w /= width;
    h /= height;
    return CGRectMake(x, y, w, h);
}

/**
 生成文字中点
 
 @param centerRect 中心点 rect
 @param bounds 边框 frame
 @return 点坐标
 */
- (CGPoint)textCenterWithCenterRect:(CGRect)centerRect bounds:(CGRect)bounds
{
    CGFloat boundsWidth = CGRectGetWidth(bounds);
    CGFloat boundsHeight = CGRectGetHeight(bounds);
    CGFloat x = centerRect.origin.x * boundsWidth;
    CGFloat y = centerRect.origin.y * boundsHeight;
    return CGPointMake(x, y);
}


@end
