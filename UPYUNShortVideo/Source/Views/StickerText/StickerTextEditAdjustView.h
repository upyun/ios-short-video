//
//  StickerTextEditAdjustView.h
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright (c) 2018年 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerTextFilterResultView.h"

#pragma mark - TuSDKPFEditAdjustOptionBar

/**
 *  文字贴纸选项栏目
 *  @since     v2.2.0
 */
@interface StickerTextEditAdjustOptionBar : UIView
{
    // 横向滚动视图
    UIScrollView *_wrapView;
    // 模块按钮列表
    NSMutableArray *_buttons;
}

/**
 *  横向滚动视图
 *  @since     v2.2.0
 */
@property (nonatomic, readonly) UIScrollView *wrapView;

/**
 *  绑定功能模块
 *  @param modules 功能模块列表
 *  @param target  绑定事件对象
 *  @param action  绑定事件
 *  @since         v2.2.0
 */
- (void)bindModules:(NSArray *)modules target:(id)target action:(SEL)action;

/**
 *  创建动作按钮
 *  @param module  图片编辑动作类型
 *  @param count   按钮总数
 *  @return button 动作按钮
 *  @since         v2.2.0
 */
- (UIButton *)buildButtonWithActionType:(NSString *)module moduleCount:(NSUInteger)count;

/**
 *  更新按钮布局
 *  @since         v2.2.0
 */
- (void)needUpdateLayout;

@end

#pragma mark - TuSDKPFEditAdjustView

/**
 *  调整控制器视图
 *  @since         v2.2.0
 */
@interface StickerTextEditAdjustView : StickerTextFilterResultView
{
    @protected
    // 选项栏目
    StickerTextEditAdjustOptionBar *_optionBar;
    // 参数配置视图完成按钮
    UIButton *_configCompleteButton;
    // 参数配置视图取消按钮
    UIButton *_configCancalButton;
    // 参数配置容器
    UIView *_configActionContainer;
}

/**
 *  选项栏目
 *  @since         v2.2.0
 */
@property (nonatomic, readonly) StickerTextEditAdjustOptionBar *optionBar;

/**
 *  参数配置视图完成按钮
 *  @since         v2.2.0
 */
@property (nonatomic, readonly) UIButton *configCompleteButton;

/**
 *  参数配置视图取消按钮
 *  @since         v2.2.0
 */
@property (nonatomic, readonly) UIButton *configCancalButton;

/**
 *  设置配置视图隐藏状态
 *  @param isHidden 是否隐藏
 *  @since          v2.2.0
 */
- (void)setConfigViewHiddenState:(BOOL)isHidden;

@end
