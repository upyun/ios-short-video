//
//  SceneEffectListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/11.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"

@class SceneEffectListView;

@protocol SceneEffectListViewDelegate <NSObject>
@optional

/**
 点击回调

 @param listView 场景特效展示视图
 @param code 场景特效 code
 @param color 场景特效的控件展示颜色
 */
- (void)sceneEffectList:(SceneEffectListView *)listView didTapWithCode:(NSString *)code color:(UIColor *)color;

/**
 按下回调

 @param listView 场景特效展示视图
 @param code 场景特效 code
 @param color 场景特效的控件展示颜色
 */
- (void)sceneEffectList:(SceneEffectListView *)listView didTouchDownWithCode:(NSString *)code color:(UIColor *)color;

/**
 抬手回调

 @param listView 场景特效展示视图
 @param code 场景特效 code
 @param color 场景特效的控件展示颜色
 */
- (void)sceneEffectList:(SceneEffectListView *)listView didTouchUpWithCode:(NSString *)code color:(UIColor *)color;

@end

/**
 场景特效列表视图
 
 使用默认场景特效进行展示，点击交互通过代理回调
 */
@interface SceneEffectListView : HorizontalListView

@property (nonatomic, weak) IBOutlet id<SceneEffectListViewDelegate> delegate;

/**
 场景特效码与颜色对应表
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, UIColor *> *sceneEffectCodeColors;

@end
