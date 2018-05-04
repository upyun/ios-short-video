//
//  MovieEditerFullScreenBottomBar.h
//  TuSDKVideoDemo
//
//  Created by wen on 2018/1/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MovieEditerBottomBar.h"
#import "ParticleEffectView.h"

/**
 全屏编辑页面，底部栏控件代理
 */
@protocol MovieEditorFullScreenBottomBarDelegate <NSObject>

/**
 切换粒子特效
 
 @param filterCode 粒子特效code
 */
- (void)movieEditorFullScreenBottom_particleViewSwitchEffectWithCode:(NSString *)particleEffectCode;

/**
 点击撤销按钮
 */
- (void)movieEditorFullScreenBottom_removeLastParticleEffect;

/**
 是否选中粒子特效展示栏
 */
- (void)movieEditorFullScreenBottom_selectParticleView:(BOOL)isParticle;


@end



/**
 全屏编辑页面，底部栏控件
 */
@interface MovieEditerFullScreenBottomBar : MovieEditerBottomBar

// fullScreeen中使用的底部栏代理
@property (nonatomic, assign) id<MovieEditorFullScreenBottomBarDelegate> fullScreenBottomBarDelegate;
// 粒子特效view
@property (nonatomic, strong) ParticleEffectView *particleView;

@end
