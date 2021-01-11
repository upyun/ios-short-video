//
//  ParticleEffectEditAreaView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/13.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ParticleEffectEditAreaView;

@protocol ParticleEffectEditAreaViewDelegate <NSObject>
@optional

/**
 触摸开始回调

 @param particleEditAreaView 特效添加区域
 */
- (void)particleEditAreaViewDidBeginEditing:(ParticleEffectEditAreaView *)particleEditAreaView;

/**
 触摸结束回调

 @param particleEditAreaView 特效添加区域
 */
- (void)particleEditAreaViewDidEndEditing:(ParticleEffectEditAreaView *)particleEditAreaView;

/**
 触摸位移回调，以点在屏幕宽高比率值回调

 @param particleEditAreaView  特效添加区域
 @param percentPoint 更新添加区域坐标
 */
- (void)particleEditAreaView:(ParticleEffectEditAreaView *)particleEditAreaView didUpdatePercentPoint:(CGPoint)percentPoint;

@end

/**
 魔法特效手势位置记录与回调视图
 
 该视图需与视频内容在屏幕中的大小保持一致
 */
@interface ParticleEffectEditAreaView : UIView

@property (nonatomic, weak) id<ParticleEffectEditAreaViewDelegate> delegate;

@end
