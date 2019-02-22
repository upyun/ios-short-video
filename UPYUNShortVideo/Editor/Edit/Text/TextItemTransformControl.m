//
//  TextItemTransformControl.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/6.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextItemTransformControl.h"

// 按钮宽度
static const CGFloat kButtonWidth = 20;

@interface TextItemTransformControl ()

/**
 内容容器
 */
@property (nonatomic, strong) UIView *containerView;

/**
 拉伸旋转按钮
 */
@property (nonatomic, strong) UIView *scaleControl;

/**
 关闭按钮
 */
@property (nonatomic, strong) UIButton *closeButton;

/**
 开始滑动的记录点
 */
@property (nonatomic, assign) CGPoint panBeganPoint;

/**
 初始字体大小
 */
@property (nonatomic, assign) CGFloat initialFontSize;

/**
 缩放
 */
@property (nonatomic, assign) CGFloat scale;

/**
 角度
 */
@property (nonatomic, assign) CGFloat angle;

/**
 开始半径
 */
@property (nonatomic, assign) CGFloat beginRadius;

/**
 开始角度
 */
@property (nonatomic, assign) CGFloat beginAngle;

/**
 开始滑动记录的缩放值
 */
@property (nonatomic, assign) CGFloat panBeganScale;

/**
 开始滑动记录的角度
 */
@property (nonatomic, assign) CGFloat panBeganAngle;

@end

@implementation TextItemTransformControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // 配置子视图
    _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_containerView];
    _containerView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_closeButton];
    [_closeButton setImage:[UIImage imageNamed:@"edit_text_ic_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _scaleControl = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_scaleControl];
    _scaleControl.layer.contents = (__bridge id)([UIImage imageNamed:@"edit_text_ic_scale"].CGImage);
    _scaleControl.layer.contentsGravity = kCAGravityResizeAspect;
    
    // 配置手势
    UIPanGestureRecognizer *translationPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(translationPanAction:)];
    [_containerView addGestureRecognizer:translationPan];
    
    UIPanGestureRecognizer *transformPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(transformPanAction:)];
    [_scaleControl addGestureRecognizer:transformPan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_containerView addGestureRecognizer:tap];
    
    // 初始化成员变量
    _scale = 1.0;
    _angle = 0;
    self.selected = YES;
}

#pragma mark - property

- (void)setTextLabel:(AttributedLabel *)textLabel {
    _textLabel = textLabel;
    [_containerView addSubview:textLabel];
    textLabel.layer.allowsEdgeAntialiasing = YES;
    // 若是有布局信息，则应用到自身
    if (!CGPointEqualToPoint(CGPointZero, textLabel.center)) {
        self.center = textLabel.center;
    }
    
    if (!CGAffineTransformIsIdentity(textLabel.transform)) {
        self.transform = textLabel.transform;
        textLabel.transform = CGAffineTransformIdentity;
    }
    _initialFontSize = textLabel.font.pointSize;
    CGSize contentSize = CGSizeEqualToSize(CGSizeZero, textLabel.frame.size) ? textLabel.intrinsicContentSize : textLabel.frame.size;
    [self updateLayoutWithContentSize:contentSize];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _containerView.layer.borderWidth = 1;
        _closeButton.hidden = _scaleControl.hidden = NO;
    } else {
        _containerView.layer.borderWidth = 0;
        _closeButton.hidden = _scaleControl.hidden = YES;
    }
}

#pragma mark - public

- (void)updateLayoutWithContentSize:(CGSize)contentSize {
    CGRect contentBounds = (CGRect){CGPointZero, contentSize};
    // frame.size 依赖于 contentSize，位置不变
    CGPoint center = self.center;
    self.bounds = CGRectMake(0, 0, contentSize.width + kButtonWidth, contentSize.height + kButtonWidth);;
    if (!CGPointEqualToPoint(CGPointZero, center)) self.center = center;
    
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
}

#pragma mark - private

/**
 根据缩放与角度更新布局

 @param scale 缩放
 @param angle 角度
 */
- (void)setScale:(CGFloat)scale angle:(CGFloat)angle {
    
    if (scale >= 4) return;
    
    _scale = scale;
    _angle = angle;
    _textLabel.initialPercentCenter = CGPointZero;
    
    // 重置自身的变换
    self.transform = CGAffineTransformIdentity;
    
    // 应用缩放到 containerView
    NSString *fontName = _textLabel.font.fontName;
    _textLabel.font = [UIFont fontWithName:fontName size:_initialFontSize * scale];
    
    CGRect containerFrame = _containerView.frame;
    containerFrame.size = _textLabel.intrinsicContentSize;
    _containerView.frame = containerFrame;
    
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
- (void)translationPanAction:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            
            _panBeganPoint = self.center;
        } break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [sender translationInView:self.superview];
            
            BOOL canPanX = (CGRectGetMinX(self.frame) < 0 && translation.x > 0)
            || (CGRectGetMaxX(self.frame) > CGRectGetMaxX(self.superview.bounds) && translation.x < 0);
            BOOL canPanY = (CGRectGetMinY(self.frame) < 0 && translation.x > 0)
                            ||  (CGRectGetMaxY(self.frame) > CGRectGetMaxY(self.superview.bounds) && translation.x < 0);
            CGPoint resultCenter = CGPointMake(_panBeganPoint.x + translation.x, _panBeganPoint.y + translation.y);
    
            if (CGRectContainsPoint(self.superview.bounds, resultCenter)) {
                self.center = resultCenter;
            }else if (canPanX || canPanY) {
                CGPoint resultCenter = CGPointMake( canPanX ?  (_panBeganPoint.x + translation.x) : self.center.x, canPanY ? (_panBeganPoint.y + translation.y) : self.center.y);
                self.center = resultCenter;

            }

        } break;
        case UIGestureRecognizerStateEnded:{
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        } break;
        case UIGestureRecognizerStateCancelled:{} break;
        case UIGestureRecognizerStatePossible:{} break;
        case UIGestureRecognizerStateFailed:{} break;
    }
}

/**
 变形滑动事件

 @param sender 滑动手势
 */
- (void)transformPanAction:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            CGPoint location = [_scaleControl.superview convertPoint:_scaleControl.center toView:self.superview];
            CGPoint vectorToCenter = CGPointMake(location.x - self.center.x, location.y - self.center.y);
            _beginRadius = sqrt(pow(vectorToCenter.x, 2) + pow(vectorToCenter.y, 2));
            _beginAngle = atan2(vectorToCenter.y, vectorToCenter.x);
            
            _panBeganAngle = _angle;
            _panBeganScale = _scale;
        } break;
        case UIGestureRecognizerStateChanged:{
            CGPoint location = [sender locationInView:self.superview];
            CGPoint vectorToCenter = CGPointMake(location.x - self.center.x, location.y - self.center.y);
            CGFloat radius = sqrt(pow(vectorToCenter.x, 2) + pow(vectorToCenter.y, 2));
            CGFloat angle = atan2(vectorToCenter.y, vectorToCenter.x);
            
            [self setScale:_panBeganScale * radius / _beginRadius
                     angle:_panBeganAngle + angle - _beginAngle];
        } break;
        case UIGestureRecognizerStateEnded:{} break;
        case UIGestureRecognizerStateCancelled:{} break;
        case UIGestureRecognizerStatePossible:{} break;
        case UIGestureRecognizerStateFailed:{} break;
    }
}

/**
 点击手势事件

 @param sender 点击手势
 */
- (void)tapAction:(UITapGestureRecognizer *)sender {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

/**
 关闭按钮事件

 @param sender 点击的按钮
 */
- (void)closeButtonAction:(UIButton *)sender {
    if (self.closeButtonActionHandler) self.closeButtonActionHandler(self, sender);
}

@end
