//
//  ParticleEffectEditView.h
//  TuSDKVideoDemo
//
//  Created by wen on 2018/1/30.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
#import "EffectsDisplayView.h"


@class ParticleEffectEditView;

#pragma mark - ParticleEffectEditViewDelegate

/**
 编辑页面，底部栏控件代理
 */
@protocol ParticleEffectEditViewDelegate <NSObject>

/**
 开始当前的特效
 */
- (void)particleEffectEditView_startParticleEffect;

/**
 结束当前的特效
 */
- (void)particleEffectEditView_endParticleEffect;

/**
 取消当前正在添加的特效
 */
- (void)particleEffectEditView_cancleParticleEffect;

/**
 更新粒子轨迹位置
 
 @param newPoint 粒子轨迹的点
 */
- (void)particleEffectEditView_particleViewUpdatePoint:(CGPoint)newPoint;

/**
 更新粒子大小size
 
 @param newSize 粒子大小
 */
- (void)particleEffectEditView_particleViewUpdateSize:(CGFloat)newSize;

/**
 更新粒子颜色
 
 @param newColor 粒子颜色
 */
- (void)particleEffectEditView_particleViewUpdateColor:(UIColor *)newColor;

/**
 点击播放按钮  YES：开始播放   NO：暂停播放
 
 @param isStartPreview YES:开始预览
 */
- (void)particleEffectEditView_playVideoEvent:(BOOL)isStartPreview;

/**
 点击返回按钮
 */
- (void)particleEffectEditView_backViewEvent;

/**
 移除上一个粒子特效
 */
- (void)particleEffectEditView_removeLastParticleEffect;

/**
 手势移动缩略图的进度展示条
 
 @param progress 移动到某一 progress
 */
- (void)particleEffectEditView_moveLocationWithProgress:(CGFloat)progress;

@end

#pragma mark - ParticleEffectEditView

/**
 粒子特效编辑View
 */
@interface ParticleEffectEditView : UIView

// 设置是否为编辑状态   注：编辑状态中显示播放、撤销等  有手势触摸  非编辑状态中仅用进度条展示粒子特效的历史添加结果
@property (nonatomic, assign) BOOL isEditStatus;
// 粒子特效代理
@property (nonatomic, assign) id<ParticleEffectEditViewDelegate> particleDelegate;
// 缩略图展示view
@property (nonatomic, strong) EffectsDisplayView *displayView;
// 播放按钮
@property (nonatomic, readonly) UIButton *playBtn;
// 添加特效时的展示图颜色
@property (nonatomic, strong) UIColor *selectColor;
// 视频 progress
@property (nonatomic, assign,readonly) CGFloat videoProgress;

// 粒子特效大小
@property (nonatomic, assign,readonly) CGFloat particleSize;
// 粒子特效颜色
@property (nonatomic, strong,readonly) UIColor *particleColor;


/**
 停止编辑
 */
- (void)makeFinish;

/**
 设置当前进度
 @param videoProgress 视频进度
 @param playMode 当前播放模式
 */
-(void)setVideoProgress:(CGFloat)videoProgress;

/**
 移除上一个添加的粒子特效
 */
- (void)removeLastParticleEffect;


@end
