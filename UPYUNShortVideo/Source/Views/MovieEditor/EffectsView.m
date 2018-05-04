//
//  EffectsView.m
//  TuSDKVideoDemo
//
//  Created by wen on 13/12/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "EffectsView.h"
#import "EffectsItemView.h"
#import "TuSDKFramework.h"

@interface EffectsView()<EffectsItemViewEventDelegate, EffectsDisplayViewEventDelegate> {
    // 视图布局
    // 滤镜滑动scroll
    UIScrollView *_effectsScroll;
    // 撤销按钮
    UIButton *_backBtn;
}
@end

@implementation EffectsView

#pragma mark - setter getter

- (void)setVideoURL:(NSURL *)videoURL;
{
    _videoURL = videoURL;
    _displayView.videoURL = _videoURL;
}

- (void)setProgress:(CGFloat)progress;
{
    _progress = progress;
    _displayView.currentLocation = _progress;
}

- (void)setEffectsCode:(NSArray<NSString *> *)effectsCode;
{
    _effectsCode = effectsCode;
    [self createEffectsItemView];
}

#pragma mark - 视图布局

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
    CGFloat effectItemHeight = 0.44*self.lsqGetSizeHeight;
    CGFloat effectItemWidth = effectItemHeight * 13/18;
    CGFloat offsetX = effectItemWidth + 10 + 7;
    CGFloat bottom = self.lsqGetSizeHeight/15;
    CGRect effectsScrollFrame = CGRectMake(offsetX, self.lsqGetSizeHeight - effectItemHeight - bottom, self.bounds.size.width - offsetX, effectItemHeight);
    
    // 顶部缩略图展示栏
    _displayView = [[EffectsDisplayView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, 38)];
    _displayView.center = CGPointMake(self.lsqGetSizeWidth/2, 40);
    _displayView.eventDelegate = self;
    [self addSubview:_displayView];
    
    // 撤销特效按钮
    UIImage *btnImage = [UIImage imageNamed:@"style_default_2.0_edit_effect_back"];
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, effectItemWidth, effectItemHeight)];
    _backBtn.center = CGPointMake(10 + effectItemWidth/2, effectsScrollFrame.origin.y + effectsScrollFrame.size.height/2);
    [_backBtn addTarget:self action:@selector(clickBackEffectsBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setImage:btnImage forState:UIControlStateNormal];
    [_backBtn setTitle:NSLocalizedString(@"lsq_movieEditor_effect_back", @"撤销") forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_backBtn setTitleColor:lsqRGB(244, 161, 24) forState:UIControlStateNormal];
    [_backBtn setTitleColor:lsqRGBA(244, 161, 24, 0.6) forState:UIControlStateDisabled];
    _backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _backBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    CGFloat edgeTopY = (_backBtn.lsqGetSizeHeight - btnImage.size.height - 25)/2;
    _backBtn.imageEdgeInsets = UIEdgeInsetsMake(edgeTopY, (_backBtn.lsqGetSizeWidth - btnImage.size.width)/2, 0, 0);
    _backBtn.titleEdgeInsets = UIEdgeInsetsMake(edgeTopY + btnImage.size.height + 10, _backBtn.lsqGetSizeWidth/2 - btnImage.size.width - 13, 0, 0);
    _backBtn.enabled = NO;
    [self addSubview:_backBtn];

    // 创建滤镜scroll
    _effectsScroll = [[UIScrollView alloc]initWithFrame:effectsScrollFrame];
    _effectsScroll.showsHorizontalScrollIndicator = false;
    _effectsScroll.bounces = false;
    [self addSubview:_effectsScroll];
}

- (void)createEffectsItemView;
{
    // 创建滤镜view
    [_effectsScroll.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    // 滤镜view配置参数
    CGFloat effectItemHeight = _effectsScroll.lsqGetSizeHeight;
    CGFloat effectItemWidth = effectItemHeight * 13/18;
    CGFloat centerX = effectItemWidth/2;
    CGFloat centerY = _effectsScroll.lsqGetSizeHeight/2;
    CGFloat itemInterval = 12;
    NSArray<UIColor *> *colorArr = @[lsqRGBA(250, 118, 82, 0.7), lsqRGBA(244, 161, 26, 0.7), lsqRGBA(255, 253, 80, 0.7),lsqRGBA(91, 242, 84, 0.7), lsqRGBA(22, 206, 252, 0.7), lsqRGBA(110, 160, 242, 0.7)];
    
    for (int i = 0; i < _effectsCode.count; i++) {
        EffectsItemView *basicView = [EffectsItemView new];
        basicView.frame = CGRectMake(0, 0, effectItemWidth, effectItemHeight);
        basicView.center = CGPointMake(centerX, centerY);
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", _effectsCode[i]];
        NSString *imageName = [NSString stringWithFormat:@"lsq_filter_thumb_%@",_effectsCode[i]];
        [basicView setViewInfoWith:imageName title:NSLocalizedString(title,@"特效") titleFontSize:12];
        basicView.eventDelegate = self;
        basicView.effectCode = _effectsCode[i];
        basicView.selectColor = i<colorArr.count ? colorArr[i] : colorArr.lastObject;
        [_effectsScroll addSubview:basicView];
        
        centerX += effectItemWidth + itemInterval;
    }
    
    _effectsScroll.contentSize = CGSizeMake(centerX - effectItemWidth/2, _effectsScroll.bounds.size.height);
}

- (void)clickBackEffectsBtn:(UIButton *)sender;
{
    [_displayView removeLastSegment];
    if ([self.effectEventDelegate respondsToSelector:@selector(effectsBackEvent)]) {
        [self.effectEventDelegate effectsBackEvent];
    }
}

/**
 设置撤销按钮是否可点击
 
 @param isEnable YES:可点击
 */
- (void)backBtnEnabled:(BOOL)isEnable;
{
    if (_backBtn.enabled == isEnable) return;
    _backBtn.enabled = isEnable;
}

#pragma mark - EffectsItemViewEventDelegate

- (void)touchBeginWithSelectCode:(NSString *)effectCode;
{
    _effectsScroll.scrollEnabled = NO;
    if ([self.effectEventDelegate respondsToSelector:@selector(effectsSelectedWithCode:)]) {
        [self.effectEventDelegate effectsSelectedWithCode:effectCode];
    }
}

- (void)touchEndWithSelectCode:(NSString *)effectCode;
{
    _effectsScroll.scrollEnabled = YES;
    if ([self.effectEventDelegate respondsToSelector:@selector(effectsEndWithCode:)]) {
        [self.effectEventDelegate effectsEndWithCode:effectCode];
    }
}

#pragma mark - EffectsDisplayViewEventDelegate
- (void)moveCurrentLocationView:(CGFloat)newLocation;
{
    if ([self.effectEventDelegate respondsToSelector:@selector(effectsMoveVideoProgress:)]) {
        [self.effectEventDelegate effectsMoveVideoProgress:newLocation];
    }
}

@end


