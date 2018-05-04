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
    NSMutableArray *normalImages = [NSMutableArray arrayWithArray:@[@"style_default_2.0_btn_magic_unselected",
                                                                    @"style_default_1.11_btn_filter_unselected",
                                                                    @"style_default_1.11_edit_effect_default",
                                                                    @"style_default_1.11_btn_mv_unselected",
                                                                    @"style_default_1.11_sound_default"]];
    // iPad 中不显示滤镜栏
    if ([UIDevice lsqDevicePlatform] == TuSDKDevicePlatform_other) [normalImages removeObjectAtIndex:1];
    return normalImages;
}

/**
 初始化底部按钮normal状态下图片数组
 */
- (NSMutableArray *)getBottomSelectImages;
{
    NSMutableArray *selectImages = [NSMutableArray arrayWithArray:@[@"style_default_2.0_btn_magic",
                                                                    @"style_default_1.11_btn_filter",
                                                                    @"style_default_1.11_edit_effect_select",
                                                                    @"style_default_1.11_btn_mv",
                                                                    @"style_default_1.11_sound_selected"]];
    // iPad 中不显示滤镜栏
    if ([UIDevice lsqDevicePlatform] == TuSDKDevicePlatform_other) [selectImages removeObjectAtIndex:1];

    return selectImages;
}

/**
 初始化底部按钮显示title
 */
- (NSMutableArray *)getBottomTitles;
{
    NSMutableArray *titles = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"lsq_movieEditor_magicBtn", @"魔法"),
                                                              NSLocalizedString(@"lsq_movieEditor_filterBtn", @"滤镜"),
                                                              NSLocalizedString(@"lsq_movieEditor_effect", @"特效"),
                                                              NSLocalizedString(@"lsq_movieEditor_MVBtn", @"MV"),
                                                              NSLocalizedString(@"lsq_movieEditor_dubBtn", @"配音")]];
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
    // 默认不显示滤镜栏
    self.filterView.hidden = YES;

    _particleView = [[ParticleEffectView alloc]initWithFrame:self.filterView.frame];
    _particleView.currentParticleTag = 200;
    _particleView.particleEventDelegate = self;
    [self.contentBackView addSubview:_particleView];
}

/**
 底部按钮点击事件
 */
- (void)bottomButton:(BottomButtonView *)bottomButtonView clickIndex:(NSInteger)index;
{
    if (index == 0) {
        // 点击魔法
        _particleView.hidden = NO;
        self.effectsView.hidden = YES;
        self.filterView.hidden = YES;
        self.dubView.hidden = YES;
        self.mvView.hidden = YES;
        self.volumeBackView.hidden = YES;
        self.topThumbnailView.hidden = YES;
        
        if ([self.fullScreenBottomBarDelegate respondsToSelector:@selector(movieEditorFullScreenBottom_selectParticleView:)]) {
            [self.fullScreenBottomBarDelegate movieEditorFullScreenBottom_selectParticleView:YES];
        }
        [self adjustLayout];

    }else{
        _particleView.hidden = YES;
        [super bottomButton:bottomButtonView clickIndex:index - 1];
        if ([self.fullScreenBottomBarDelegate respondsToSelector:@selector(movieEditorFullScreenBottom_selectParticleView:)]) {
            [self.fullScreenBottomBarDelegate movieEditorFullScreenBottom_selectParticleView:NO];
        }
    }
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
