//
//  ParticleEffectListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/11.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"

@class ParticleEffectListView;

@protocol ParticleEffectListViewDelegate <NSObject>
@optional

/**
 魔法特效列表选中回调

 @param listView 魔法特效展示视图
 @param code 魔法特效 code
 @param color 魔法特效视图控件展示的颜色
 @param tapCount 点击次数
 */
- (void)particleEffectList:(ParticleEffectListView *)listView didTapWithCode:(NSString *)code color:(UIColor *)color tapCount:(NSInteger)tapCount;

@end

/**
 魔法特效列表视图
 
 展示默认魔法特效列表，点击交互通过代理回调
 */
@interface ParticleEffectListView : HorizontalListView

@property (nonatomic, weak) IBOutlet id<ParticleEffectListViewDelegate> delegate;

/**
 魔法特效 code 的颜色对应表
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, UIColor *> *particleEffectCodeColors;

/**
 选中的魔法特效的 code
 */
@property (nonatomic, copy, readonly) NSString *selectedCode;

@end
