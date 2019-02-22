//
//  TimeEffectListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/11.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"

/**
 Demo 处理的特效类型
 */
typedef NS_ENUM(NSInteger, TimeEffectType) {
    // 无时间特效
    TimeEffectTypeNone = 0,
    // 反复时间特效
    TimeEffectTypeRepeat,
    // 慢动作时间特效
    TimeEffectTypeSlow,
    // 倒序时间特效
    TimeEffectTypeReverse
};

@class TimeEffectListView;

@protocol TimeEffectListViewDelegate <NSObject>
@optional

/**
 时间特效列表选中回调

 @param listView 时间特效展示视图
 @param type 时间特效类型
 */
- (void)timeEffectList:(TimeEffectListView *)listView didSelectType:(TimeEffectType)type;

@end

/**
 时间特效列表视图
 
 展示时间特效列表，点击交互通过代理回调
 */
@interface TimeEffectListView : HorizontalListView

/**
 选中的时间特效类型
 */
@property (nonatomic, assign) TimeEffectType selectedType;

@property (nonatomic, weak) IBOutlet id<TimeEffectListViewDelegate> delegate;

@end
