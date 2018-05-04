//
//  EffectsItemView.h
//  TuSDKVideoDemo
//
//  Created by wen on 13/12/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 触摸事件的代理
 
 @param viewDescription 点击的basicView所对应的code(对于滤镜栏中即为filterCode)
 */
@protocol EffectsItemViewEventDelegate <NSObject>

/**
 开始选中特效

 @param effectCode 特效code
 */
- (void)touchBeginWithSelectCode:(NSString *)effectCode;

/**
 结束当前选中的特效

 @param effectCode 特效code
 */
- (void)touchEndWithSelectCode:(NSString *)effectCode;

@end


@interface EffectsItemView : UIView
// 该对象所对应的code
@property (nonatomic,copy) NSString * effectCode;
// 点击事件的代理
@property (nonatomic,assign) id<EffectsItemViewEventDelegate> eventDelegate;
// 选中时的颜色显示
@property (nonatomic,strong) UIColor *selectColor;

/**
 根据参数内容初始化控件
 
 @param imageName 图片名
 @param title title名
 @param fontSize 字号
 */
- (void)setViewInfoWith:(NSString *)imageName title:(NSString *)title  titleFontSize:(CGFloat)fontSize;

// 改变选中阴影色
- (void)refreshShadowColor:(UIColor *)color;

@end
