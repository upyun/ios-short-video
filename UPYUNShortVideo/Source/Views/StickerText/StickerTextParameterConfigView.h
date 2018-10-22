//
//  StickerTextParameterConfigView.h
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright (c) 2018年 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

/**
 参数配置视图
 @since 2.2.0
 */
@interface StickerTextParameterConfigView : UIView<TuSDKICSeekBarDelegate, TuSDKCPParameterConfigViewInterface>
{
    // 参数选项视图
    UIView *_paramsView;
    // 重置按钮
    UIButton *_restButton;
    // 数字显示视图
    UILabel *_numberView;
    // 百分比控制条
    TuSDKICSeekBar *_seekBar;
}

/**
 *  参数配置视图委托
 @since 2.2.0
 */
@property (nonatomic, weak) id<TuSDKCPParameterConfigDelegate> delegate;

/**
 *  参数选项视图
 @since 2.2.0
 */
@property (nonatomic, readonly) UIView *paramsView;

/**
 *  重置按钮
 @since 2.2.0
 */
@property (nonatomic, readonly) UIButton *restButton;

/**
 *  数字显示视图
 @since 2.2.0
 */
@property (nonatomic, readonly) UILabel *numberView;

/**
 *  百分比控制条
 @since 2.2.0
 */
@property (nonatomic, readonly) TuSDKICSeekBar *seekBar;

/**
 *  跳到指定百分比
 *  @param progress 百分比进度
 @since 2.2.0
 */
- (void)seekWithProgress:(CGFloat)progress;

/**
 *   设置参数列表
 *  @param params 参数列表
 *  @param index  选中索引
 @since 2.2.0
 */
- (void)setParams:(NSArray *)params selectedIndex:(NSUInteger)index;
@end
