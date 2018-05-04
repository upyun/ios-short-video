//
//  ParticleMagicView.h
//  TuSDKVideoDemo
//
//  Created by wen on 2018/1/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

//粒子特效栏事件代理
@protocol ParticleMagicViewEventDelegate <NSObject>

/**
 点击选择新粒子特效
 
 @param filterCode 选中粒子的code
 */
- (void)particleViewSwitchEffectWithCode:(NSString *)particleCode;

/**
 点击撤销按钮
 */
- (void)particleViewRemoveLastParticleEffect;


@end


@interface ParticleEffectView : UIView
// 粒子特效事件的代理
@property (nonatomic, assign) id<ParticleMagicViewEventDelegate> particleEventDelegate;
// 滤镜选择 View
@property (nonatomic, strong) UIView *particleChooseView;
// 撤销按钮
@property (nonatomic, strong) UIButton *removeEffectBtn;
// 当前选中的滤镜的tag值 基于200
@property (nonatomic, assign) NSInteger currentParticleTag;

//根据滤镜数组创建滤镜view
- (void)createParticleEffectsWith:(NSArray *)effectsArr;

@end
