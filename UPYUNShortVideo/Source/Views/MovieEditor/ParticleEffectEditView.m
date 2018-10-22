//
//  ParticleEffectEditView.m
//  TuSDKVideoDemo
//
//  Created by wen on 2018/1/30.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "ParticleEffectEditView.h"
#import "FilterParamItemView.h"

@interface ParticleEffectEditView ()<EffectsDisplayViewEventDelegate, FilterParamItemViewDelegate, TuSDKICSeekBarDelegate>{
    CGRect _originFrame;
    CGRect _editFrame;
    // 内容View (不包含缩略图)
    UIView *_contentBackView;
    // touchView
    UIView *_touchView;
    // 返回按钮
    UIButton *_backBtn;
    // 撤销按钮
    UIButton *_removeEffectBtn;
    // 大小调节滑动条
    FilterParamItemView *_sizeParamItemView;
    // 大小调节滑动条按钮
    UIButton *_sizeSeekBarBtn;
    // 颜色调节滑动条按钮
    UIButton *_colorSeekBarBtn;
    // 颜色调节条背景view
    UIView *_colorBackView;
    // 颜色调整滑动条
    TuSDKICSeekBar *_colorSeekBar;
    
    // 是否正在添加粒子特效 YES：正在添加
    BOOL _isAddingParticle;
}
    
@end


@implementation ParticleEffectEditView

#pragma mark - setter getter

- (void)setIsEditStatus:(BOOL)isEditStatus;
{
    _isEditStatus = isEditStatus;
    [self refreshContentView];
}


- (void)setVideoProgress:(CGFloat)videoProgress
{
    _videoProgress = videoProgress;
    _displayView.currentLocation = videoProgress;
    
    if (_isAddingParticle) {
         NSLog(@"setVideoProgress = %f",videoProgress);
        [_displayView updateLastSegmentViewWithProgress:videoProgress];
    }
}

#pragma mark - init method

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initContentView];
    }
    
    return self;
}

- (void)initContentView;
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    // 顶部缩略图展示栏
    _displayView = [[EffectsDisplayView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, 38)];
    _displayView.center = CGPointMake(self.lsqGetSizeWidth/2, 0.06*screenSize.height);
    _displayView.eventDelegate = self;
    [self addSubview:_displayView];
    _originFrame = self.frame;
    _editFrame = [UIScreen mainScreen].bounds;
    
    // 创建整体内容View （不包含缩略图）
    _contentBackView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self addSubview:_contentBackView];
    
    // 创建手势View
    _touchView = [[UIView alloc]initWithFrame:_contentBackView.bounds];
    [_contentBackView addSubview:_touchView];
    
    // touchView 上面添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTapGesture)];
    tap.cancelsTouchesInView = NO;
    [_touchView addGestureRecognizer:tap];
    
    // 播放按钮
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _playBtn.center = CGPointMake(_contentBackView.lsqGetSizeWidth - 35, _contentBackView.lsqGetSizeHeight - 100);
    [_playBtn addTarget:self action:@selector(clickPlayBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setImage:[UIImage imageNamed:@"style_default_2.0_moviEditor_stopPreview"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"style_default_2.0_moviEditor_startPreview"] forState:UIControlStateSelected];
    [_contentBackView addSubview:_playBtn];
    
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    // 返回按钮
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 2 + topY, 40, 40)];
    [_backBtn setImage:[UIImage imageNamed:@"style_default_2.0_back_default"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(clickBackBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_contentBackView addSubview:_backBtn];
    _contentBackView.hidden = YES;
    
    // 撤销按钮
    UIImage *btnImage = [UIImage imageNamed:@"style_default_2.0_edit_effect_back"];
    _removeEffectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 80)];
    _removeEffectBtn.center = CGPointMake(0.104 * screenSize.width, _contentBackView.lsqGetSizeHeight - 50 - (_contentBackView.lsqGetSizeHeight - 50)*0.11183);
    [_removeEffectBtn addTarget:self action:@selector(clickRemoveLastParticleEffectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_removeEffectBtn setImage:btnImage forState:UIControlStateNormal];
    [_removeEffectBtn setTitle:NSLocalizedString(@"lsq_movieEditor_effect_back", @"撤销") forState:UIControlStateNormal];
    _removeEffectBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_removeEffectBtn setTitleColor:lsqRGB(244, 161, 24) forState:UIControlStateNormal];
    [_removeEffectBtn setTitleColor:lsqRGBA(244, 161, 24, 0.6) forState:UIControlStateDisabled];
    _removeEffectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _removeEffectBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _removeEffectBtn.enabled = NO;
    CGFloat edgeTopY = (_removeEffectBtn.lsqGetSizeHeight - btnImage.size.height - 25)/2;
    _removeEffectBtn.imageEdgeInsets = UIEdgeInsetsMake(edgeTopY, (_removeEffectBtn.lsqGetSizeWidth - btnImage.size.width)/2, 0, 0);
    _removeEffectBtn.titleEdgeInsets = UIEdgeInsetsMake(edgeTopY + btnImage.size.height + 10, _removeEffectBtn.lsqGetSizeWidth/2 - btnImage.size.width - 13, 0, 0);
    [_contentBackView addSubview:_removeEffectBtn];
    
    // 尺寸调节按钮
    CGFloat btnInterval = screenSize.height * 0.085;
    _sizeSeekBarBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _sizeSeekBarBtn.center = CGPointMake(_playBtn.center.x, _playBtn.center.y - btnInterval);
    [_sizeSeekBarBtn addTarget:self action:@selector(clickSizeParamBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    [_sizeSeekBarBtn setImage:[UIImage imageNamed:@"style_default_2.0_moviEditor_changeSize"] forState:UIControlStateNormal];
    [_contentBackView addSubview:_sizeSeekBarBtn];

    // 大小调节滑动栏
    CGFloat paramWidthRate = 0.75;
    _sizeParamItemView = [[FilterParamItemView alloc] initWithFrame:CGRectMake(0, 0, _contentBackView.lsqGetSizeWidth * paramWidthRate, 32)];
    _sizeParamItemView.center = CGPointMake(_sizeSeekBarBtn.center.x - (_sizeParamItemView.lsqGetSizeWidth/2 - _sizeSeekBarBtn.lsqGetSizeWidth/2), _sizeSeekBarBtn.center.y);
    _sizeParamItemView.itemDelegate = self;
    _sizeParamItemView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    _sizeParamItemView.layer.cornerRadius = _sizeParamItemView.lsqGetSizeHeight/2;
    [_sizeParamItemView initParamViewWith:NSLocalizedString(@"lsq_movieEditor_effect_sizeTitle",@"大小") originProgress:0];
    _sizeParamItemView.hidden = YES;
    [_contentBackView addSubview: _sizeParamItemView];
    
    // 颜色调节栏
    // 颜色调节按钮
    _colorSeekBarBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _colorSeekBarBtn.center = CGPointMake(_sizeSeekBarBtn.center.x, _sizeSeekBarBtn.center.y - btnInterval);
    [_colorSeekBarBtn addTarget:self action:@selector(clickColorParamBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    [_colorSeekBarBtn setImage:[UIImage imageNamed:@"style_default_2.0_moviEditor_changeColor"] forState:UIControlStateNormal];
    [_contentBackView addSubview:_colorSeekBarBtn];

    _colorBackView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentBackView.lsqGetSizeWidth * paramWidthRate, 32)];
    _colorBackView.center = CGPointMake(_sizeParamItemView.center.x, _colorSeekBarBtn.center.y);
    _colorBackView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    _colorBackView.layer.cornerRadius = _colorBackView.lsqGetSizeHeight/2;
    _colorBackView.hidden = YES;
    [_contentBackView addSubview: _colorBackView];

    // 颜色调节滑动条
    CGFloat colorSeekBarX = 60;
    _colorSeekBar = [TuSDKICSeekBar initWithFrame:CGRectMake(colorSeekBarX, 0, _colorBackView.lsqGetSizeWidth - 20 - colorSeekBarX, _colorBackView.lsqGetSizeHeight)];
    _colorSeekBar.delegate = self;
    _colorSeekBar.progress = 0;
    _colorSeekBar.aboveView.backgroundColor = [UIColor clearColor];
    _colorSeekBar.dragView.backgroundColor = lsqRGBA(244, 161, 24, 0.7);
    [_colorBackView addSubview: _colorSeekBar];

    UIImageView *iv = [[UIImageView alloc]initWithFrame:_colorSeekBar.belowView.bounds];
    iv.image = [UIImage imageNamed:@"style_default_2.0_moviEditor_gradientColor"];
    [_colorSeekBar.belowView addSubview:iv];
    
    UILabel *colorTitlelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, colorSeekBarX, _colorBackView.lsqGetSizeHeight)];
    colorTitlelabel.text = NSLocalizedString(@"lsq_movieEditor_effect_colorTitle",@"颜色");
    colorTitlelabel.font = [UIFont systemFontOfSize:12];
    colorTitlelabel.textColor = _sizeParamItemView.mainColor;
    colorTitlelabel.textAlignment = NSTextAlignmentCenter;
    [_colorBackView addSubview:colorTitlelabel];
    
    
    _particleSize = 0;
    _particleColor = [self getColorFromGradientImageWithProgress:0];
    
}

/**
 修改视图的frame 用来隐藏和显示编辑视图
 */
- (void)refreshContentView;
{
    if (_isEditStatus && !CGRectEqualToRect(self.frame, _editFrame)) {
        _contentBackView.hidden = NO;
        self.frame = _editFrame;
    }else if (!_isEditStatus && !CGRectEqualToRect(self.frame, _originFrame)){
        _contentBackView.hidden = YES;
        self.frame = _originFrame;
    }
    
    _displayView.center = CGPointMake(self.lsqGetSizeWidth/2, self.lsqGetSizeHeight - 40);
}

#pragma mark - click event

// 点击手势的事件
- (void)clickTapGesture;
{
    BOOL paramFirst = NO;
    if (!_sizeParamItemView.hidden) {
        [self clickSizeParamBtnEvent];
        paramFirst = YES;
    }
    
    if (!_colorBackView.hidden) {
        [self clickColorParamBtnEvent];
        paramFirst = YES;
    }

    if (paramFirst) return;
    [self clickPlayBtnEvent:_playBtn];
}

- (void)clickPlayBtnEvent:(UIButton *)sender;
{
    // 注：selected 为YES 表示为播放状态    NO：暂停状态
    sender.selected = !sender.selected;
    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_playVideoEvent:)]) {
        [self.particleDelegate particleEffectEditView_playVideoEvent:sender.selected];
    }
}

- (void)clickSizeParamBtnEvent;
{
    _sizeSeekBarBtn.hidden = !_sizeSeekBarBtn.hidden;
    _sizeParamItemView.hidden = !_sizeParamItemView.hidden;
}

- (void)clickColorParamBtnEvent;
{
    _colorSeekBarBtn.hidden = !_colorSeekBarBtn.hidden;
    _colorBackView.hidden = !_colorBackView.hidden;
}

- (void)clickBackBtnEvent:(UIButton *)sender;
{
    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_backViewEvent)]) {
        [self.particleDelegate particleEffectEditView_backViewEvent];
    }
}

- (void)clickRemoveLastParticleEffectBtn:(UIButton *)sender;
{
    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_removeLastParticleEffect)]) {
        [self.particleDelegate particleEffectEditView_removeLastParticleEffect];
    }

    [self removeLastParticleEffect];
}

#pragma mark - public method

- (void)removeLastParticleEffect;
{
    [_displayView removeLastSegment];
    [self updateRemoveBtnEnableState];
}

#pragma mark - private method

// 更新位置
- (void)updatePoint:(CGPoint)newPoint;
{
    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_particleViewUpdatePoint:)]) {
        [self.particleDelegate particleEffectEditView_particleViewUpdatePoint:newPoint];
    }
}

// 开始添加
- (void)startParticleEffect;
{
    _playBtn.selected = YES;
    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_startParticleEffect)]) {
        [self.particleDelegate particleEffectEditView_startParticleEffect];
    }
    _isAddingParticle = YES;
    [_displayView addSegmentViewBeginWithProgress:_videoProgress WithColor:_selectColor];
}

// 结束添加
- (void)endCurrentParticleEffect;
{
    if (!_isAddingParticle) return;

    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_endParticleEffect)]) {
        [self.particleDelegate particleEffectEditView_endParticleEffect];
    }
}

/**
 停止编辑
 */
- (void)makeFinish;
{
    if (!_isAddingParticle) return;
    _isAddingParticle = NO;
    _playBtn.selected = NO;
    [_displayView makeFinish];
    [self updateRemoveBtnEnableState];
}

// 取消添加
- (void)cancleAddingParticleEffect;
{
 
    _isAddingParticle = NO;
    if (_displayView.isAdding) {
        [_displayView makeFinish];
        [_displayView removeLastSegment];
    }
    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_cancleParticleEffect)]) {
        [self.particleDelegate particleEffectEditView_cancleParticleEffect];
    }
}

// 更新粒子特效编辑视图中删除按钮的是否可点击状态
- (void)updateRemoveBtnEnableState;
{
    if (_displayView.segmentCount > 0) {
        _removeEffectBtn.enabled = YES;
    }else{
        _removeEffectBtn.enabled = NO;
    }
}

// 根据progress 取图片中对应点的位置
- (UIColor *)getColorFromGradientImageWithProgress:(CGFloat)progress;
{
    if (progress <= 0) return lsqRGBA(244, 161, 24, 0.7);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    UIImage *image = [UIImage imageNamed:@"style_default_2.0_moviEditor_gradientColor"];
    CGSize imageSize = image.size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 8,//bits per component
                                                 imageSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGRect drawRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    // 取对应点的像素值
    unsigned char* data = (unsigned char *)CGBitmapContextGetData(context);
    if (data == NULL) return nil;
    int offset = 4 * (int)(imageSize.width * progress);
    UIColor *resultColor = [UIColor colorWithRed:data[offset]/255.0 green:data[offset + 1]/255.0 blue:data[offset + 2]/255.0 alpha:1];
    CGContextRelease(context);

    return resultColor;
}

#pragma mark - touch method

// 因为要区分点击事件  故  不在touchesBegin 中开始操作
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    if (!touches || touches.count > 1)
    {
        lsqLError(@"Only single touch is supported");
        [self endCurrentParticleEffect];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_contentBackView];
    if (CGRectContainsPoint(_touchView.frame, point)) {
        CGPoint percentPosition = CGPointMake(point.x/self.lsqGetSizeWidth, point.y/self.lsqGetSizeHeight);
       
        if (!_isAddingParticle) {
            if (_videoProgress == 1.0) {
                _videoProgress = 0.0;
            }
            [self startParticleEffect];
        }
        [self updatePoint:percentPosition];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self endCurrentParticleEffect];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self cancleAddingParticleEffect];
}

#pragma mark - EffectsDisplayViewEventDelegate

// 手势移动缩略图的进度展示条
- (void)moveCurrentLocationView:(CGFloat)newLocation;
{
    // 在添加粒子特效的页面时，无法触发该手势
    if (!_contentBackView.hidden)  return;
    
    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_moveLocationWithProgress:)]) {
        [self.particleDelegate particleEffectEditView_moveLocationWithProgress:newLocation];
    }
}

#pragma mark - FilterParamItemViewDelegate

/**
 粒子大小调节栏参数改变时的回调
 */
- (void)filterParamItemView:(FilterParamItemView *)filterParamItemView changedProgress:(CGFloat)progress;
{
    if (filterParamItemView == _sizeParamItemView) {
        if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_particleViewUpdateSize:)]) {
            [self.particleDelegate particleEffectEditView_particleViewUpdateSize:progress];
            _particleSize = progress;
        }
    }
}

#pragma mark - TuSDKICSeekBarDelegate

// 颜色滑动条调整的响应方法
- (void)onTuSDKICSeekBar:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress
{
    UIColor *newColor = [self getColorFromGradientImageWithProgress:progress];;
    _colorSeekBar.dragView.backgroundColor = newColor;
    _particleColor = newColor;
    
    
    if ([self.particleDelegate respondsToSelector:@selector(particleEffectEditView_particleViewUpdateColor:)]) {
        [self.particleDelegate particleEffectEditView_particleViewUpdateColor:newColor];
    }

}

@end
