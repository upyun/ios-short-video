//
//  TransitionEffectListView.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/6/4.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"
#import "TuSDKFramework.h"

NS_ASSUME_NONNULL_BEGIN

@class TransitionEffectListView;


@protocol TransitionEffectListViewDelegate <NSObject>
@optional

/**
 点击回调
 
 @param listView 场景特效展示视图
 @param transitionType 场景特效 code
 @param color 场景特效的控件展示颜色
 */
- (void)transitionEffectList:(TransitionEffectListView *)listView didTapWithType:(TuSDKMediaTransitionType)transitionType color:(UIColor *)color;


@end


@interface TransitionEffectListView : HorizontalListView

@property (nonatomic, weak) IBOutlet id<TransitionEffectListViewDelegate> delegate;


/**
 场景特效码与颜色对应表
 */
@property (nonatomic, strong, readonly) NSDictionary<NSNumber *, UIColor *> *transitionEffectCodeColors;

@end

NS_ASSUME_NONNULL_END
