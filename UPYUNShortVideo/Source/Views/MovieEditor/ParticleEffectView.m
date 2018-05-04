//
//  ParticleMagicView.m
//  TuSDKVideoDemo
//
//  Created by wen on 2018/1/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "ParticleEffectView.h"
#import "FilterItemView.h"
#import "TuSDKFramework.h"

@interface ParticleEffectView ()<FilterItemViewClickDelegate>
{
    // 数据源
    // 粒子特效code数组
    NSArray *_particleEffects;
    
    // 视图布局
    // 粒子特效滑动scroll
    UIScrollView *_effectScroll;
}

@end



@implementation ParticleEffectView

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initDefaultData];
    }
    return self;
}

- (void)initDefaultData;
{

}

#pragma mark - view method

- (void)createParticleEffectsWith:(NSArray *)effectsArr;
{
    _particleEffects = effectsArr;
    [self createParticleEffectsChooseView];
}

- (void)createParticleEffectsChooseView;
{
    _particleChooseView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:_particleChooseView];
    
    CGFloat particleItemHeight = 0.44*self.lsqGetSizeHeight;
    CGFloat particleItemWidth = particleItemHeight * 13/18;
    CGFloat offsetX = particleItemWidth + 10 + 7;
    CGFloat bottom = self.lsqGetSizeHeight/10;
    CGRect filterScrollFrame = CGRectMake(offsetX, self.lsqGetSizeHeight - particleItemHeight - bottom, self.bounds.size.width - offsetX, particleItemHeight);
    
    // 撤销特效按钮
    UIImage *btnImage = [UIImage imageNamed:@"style_default_2.0_edit_effect_back"];
    _removeEffectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, particleItemWidth, particleItemHeight)];
    _removeEffectBtn.center = CGPointMake(10 + particleItemWidth/2, filterScrollFrame.origin.y + filterScrollFrame.size.height/2);
    [_removeEffectBtn addTarget:self action:@selector(clickRemoveLastParticleEffectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_removeEffectBtn setImage:btnImage forState:UIControlStateNormal];
    [_removeEffectBtn setTitle:NSLocalizedString(@"lsq_movieEditor_effect_back", @"撤销") forState:UIControlStateNormal];
    _removeEffectBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_removeEffectBtn setTitleColor:lsqRGB(244, 161, 24) forState:UIControlStateNormal];
    [_removeEffectBtn setTitleColor:lsqRGBA(244, 161, 24, 0.6) forState:UIControlStateDisabled];
    _removeEffectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _removeEffectBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    CGFloat edgeTopY = (_removeEffectBtn.lsqGetSizeHeight - btnImage.size.height - 25)/2;
    _removeEffectBtn.imageEdgeInsets = UIEdgeInsetsMake(edgeTopY, (_removeEffectBtn.lsqGetSizeWidth - btnImage.size.width)/2, 0, 0);
    _removeEffectBtn.titleEdgeInsets = UIEdgeInsetsMake(edgeTopY + btnImage.size.height + 10, _removeEffectBtn.lsqGetSizeWidth/2 - btnImage.size.width - 13, 0, 0);
    _removeEffectBtn.enabled = NO;
    [_particleChooseView addSubview:_removeEffectBtn];
    
    // 创建滤镜scroll
    _effectScroll = [[UIScrollView alloc]initWithFrame:filterScrollFrame];
    _effectScroll.showsHorizontalScrollIndicator = false;
    _effectScroll.bounces = false;
    [_particleChooseView addSubview:_effectScroll];

    // 滤镜view配置参数
    CGFloat centerX = particleItemWidth/2;
    CGFloat centerY = _effectScroll.lsqGetSizeHeight/2;
    
    // 创建滤镜view
    NSInteger i = 200;
    CGFloat itemInterval = 12;
    for (NSString *name in _particleEffects) {
        FilterItemView *basicView = [FilterItemView new];
        basicView.frame = CGRectMake(0, 0, particleItemWidth, particleItemHeight);
        basicView.center = CGPointMake(centerX, centerY);
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@",name];
        NSString *imageName = [NSString stringWithFormat:@"lsq_filter_thumb_%@",name];
        [basicView setViewInfoWith:imageName title:NSLocalizedString(title, @"滤镜") titleFontSize:12];
        basicView.clickDelegate = self;
        basicView.viewDescription = name;
        basicView.tag = i;
        [_effectScroll addSubview:basicView];
        if (i == _currentParticleTag) {
            [basicView refreshClickColor:lsqRGB(244, 161, 24)];
        }
        centerX += particleItemWidth + itemInterval;
        i++;
    }
    _effectScroll.contentSize = CGSizeMake(centerX - particleItemWidth/2, _effectScroll.bounds.size.height);
}


#pragma mark - event method

// 移除上一个添加的粒子特效
- (void)clickRemoveLastParticleEffectBtn:(UIButton *)btn
{
    if ([self.particleEventDelegate respondsToSelector:@selector(particleViewRemoveLastParticleEffect)]) {
        [self.particleEventDelegate particleViewRemoveLastParticleEffect];
    }
}

/**
 刷新某个特效的选中状态
 
 @param newIndex 当前选中滤镜
 @param lastIndex 上一个选中的滤镜
 @param color 选中颜色
 */
- (void)refreshSelectedFilter:(NSInteger)newIndex lastFilterIndex:(NSInteger)lastIndex selectedColor:(UIColor *)color
{
    for (UIView *view in _effectScroll.subviews) {
        if ([view isMemberOfClass:[FilterItemView class]]) {
            if (view.tag == lastIndex) {
                // 修改上一个点击效果
                FilterItemView * theView = (FilterItemView *)view;
                [theView refreshClickColor:nil];
            }else if (view.tag == newIndex){
                // 更改当前点击控件效果
                FilterItemView * theView = (FilterItemView *)view;
                [theView refreshClickColor:color];
            }
        }
    }
}

#pragma mark - BasicDisplayViewClickDelegate

// 滤镜view点击的响应代理方法
- (void)clickBasicViewWith:(NSString *)viewDescription withBasicTag:(NSInteger)tag
{
    if (_currentParticleTag != tag) {
        [self refreshSelectedFilter:tag lastFilterIndex:_currentParticleTag selectedColor:lsqRGB(244, 161, 24)];
    }
    // 记录新值
    _currentParticleTag = tag;
    
    // 目前选择了某个粒子特效
    if ([self.particleEventDelegate respondsToSelector:@selector(particleViewSwitchEffectWithCode:)]) {
        [self.particleEventDelegate particleViewSwitchEffectWithCode:viewDescription];
    }
}


- (void)dealloc
{
    for (UIView *view in _effectScroll.subviews) {
        [view removeAllSubviews];
    }
    _effectScroll = nil;
}
@end
