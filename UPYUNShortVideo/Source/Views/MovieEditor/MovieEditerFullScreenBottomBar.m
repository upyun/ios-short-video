//
//  MovieEditerFullScreenBottomBar.m
//  TuSDKVideoDemo
//
//  Created by wen on 2018/1/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MovieEditerFullScreenBottomBar.h"

@interface MovieEditerFullScreenBottomBar()<ParticleMagicViewEventDelegate>
@end

@implementation MovieEditerFullScreenBottomBar

#pragma mark - override method

/**
 初始化底部按钮normal状态下图片数组
 */
- (NSMutableArray *)getBottomNormalImages;
{
    NSMutableArray *normalImages =
    @[
      @"tab_ic_time_g",
      @"style_default_2.0_btn_magic_unselected",
      @"style_default_1.11_btn_filter_unselected",
      @"style_default_1.11_edit_effect_default",
      @"tab_ic_text_normal",
      @"style_default_1.11_btn_mv_unselected",
      @"style_default_1.11_sound_default",
      ].mutableCopy;
    
    // iPad 中不显示滤镜栏
    if ([UIDevice lsqDevicePlatform] == TuSDKDevicePlatform_other) [normalImages removeObjectAtIndex:1];
    return normalImages;
}

/**
 初始化底部按钮normal状态下图片数组
 */
- (NSMutableArray *)getBottomSelectImages;
{
    NSMutableArray *selectImages =
    @[
      @"tab_ic_time_y",
      @"style_default_2.0_btn_magic",
      @"style_default_1.11_btn_filter",
      @"style_default_1.11_edit_effect_select",
      @"tab_ic_text_selected",
      @"style_default_1.11_btn_mv",
      @"style_default_1.11_sound_selected",
      ].mutableCopy;
    // iPad 中不显示滤镜栏
    if ([UIDevice lsqDevicePlatform] == TuSDKDevicePlatform_other) [selectImages removeObjectAtIndex:1];

    return selectImages;
}

/**
 初始化底部按钮显示title
 */
- (NSMutableArray *)getBottomTitles;
{
    NSMutableArray *titles =
    @[
      NSLocalizedString(@"lsq_movieEditor_timeBtn", @"时光"),
      NSLocalizedString(@"lsq_movieEditor_magicBtn", @"魔法"),
      NSLocalizedString(@"lsq_movieEditor_filterBtn", @"滤镜"),
      NSLocalizedString(@"lsq_movieEditor_effect", @"特效"),
      NSLocalizedString(@"lsq_movieEditor_text",  "文字"),
      NSLocalizedString(@"lsq_movieEditor_MVBtn", @"MV"),
      NSLocalizedString(@"lsq_movieEditor_dubBtn", @"配音"),
      ].mutableCopy;
    // iPad 中不显示滤镜栏
    if ([UIDevice lsqDevicePlatform] == TuSDKDevicePlatform_other) [titles removeObjectAtIndex:1];
    return titles;
}

/**
 初始化视图调节内容
 */
- (void)initContentView;
{
    [super initContentView];

    _particleView = [[ParticleEffectView alloc]initWithFrame:self.filterView.frame];
    _particleView.currentParticleTag = 200;
    _particleView.particleEventDelegate = self;
    [self.contentBackView addSubview:_particleView];
    
    [self bottomButton:nil clickIndex:0];
    
    self.contentBackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.bottomDisplayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
}

/**
 底部按钮点击事件
 */
- (void)bottomButton:(BottomButtonView *)bottomButtonView clickIndex:(NSInteger)index;
{
    self.contentBackView.hidden = NO;
    // 点击魔法
    self.particleView.hidden = index != 1;
    if ([self.fullScreenBottomBarDelegate respondsToSelector:@selector(movieEditorFullScreenBottom_selectParticleView:)]) {
        [self.fullScreenBottomBarDelegate movieEditorFullScreenBottom_selectParticleView:index == 1];
    }
    
    // 点击文字
    if (index == 4 && [self.fullScreenBottomBarDelegate respondsToSelector:@selector(movieEditorFullScreenBottom_addTextEffect)]) {
        [self.fullScreenBottomBarDelegate movieEditorFullScreenBottom_addTextEffect];
    }
    
    [super bottomButton:bottomButtonView clickIndex:index];
}

#pragma mark - ParticleMagicViewEventDelegate

/**
 点击选择新粒子特效
 
 @param filterCode 选中粒子的code
 */
- (void)particleViewSwitchEffectWithCode:(NSString *)particleCode;
{
    if ([self.fullScreenBottomBarDelegate respondsToSelector:@selector(movieEditorFullScreenBottom_particleViewSwitchEffectWithCode:)]) {
        [self.fullScreenBottomBarDelegate movieEditorFullScreenBottom_particleViewSwitchEffectWithCode:particleCode];
    }
}

/**
 点击撤销按钮
 */
- (void)particleViewRemoveLastParticleEffect;
{
    if ([self.fullScreenBottomBarDelegate respondsToSelector:@selector(movieEditorFullScreenBottom_removeLastParticleEffect)]) {
        [self.fullScreenBottomBarDelegate movieEditorFullScreenBottom_removeLastParticleEffect];
    }
}

@end
