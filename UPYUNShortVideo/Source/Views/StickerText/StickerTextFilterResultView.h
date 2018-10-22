//
//  StickerTextFilterResultView.h
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright (c) 2018年 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKFramework.h"

#pragma mark - TuSDKPFEditFilterBottomBar
/**
 *  文字贴纸底部动作栏
 *  @since     v2.2.0
 */
@interface StickerTextFilterBottomBar : UIView
{
    // 取消按钮
    UIButton *_cancelButton;
    // 完成按钮
    UIButton *_completeButton;
}

/**
 *  取消按钮
 *  @since     v2.2.0
 */
@property (nonatomic, readonly) UIButton *cancelButton;

/**
 *  完成按钮
 *  @since     v2.2.0
 */
@property (nonatomic, readonly) UIButton *completeButton;

/**
 *  标题视图
 *  @since     v2.2.0
 */
@property (nonatomic, readonly) UILabel *titleView;
@end

#pragma mark - TuSDKCPFilterResultView
/**
 *  滤镜处理结果控制器视图
 *  @since     v2.2.0
 */
@interface StickerTextFilterResultView : UIView<TuSDKCPFilterResultViewInterface>
{
    // 图片视图
    UIView<TuSDKICFilterImageViewInterface> *_imageView;
    // 参数配置视图
    UIView<TuSDKCPParameterConfigViewInterface> *_configView;
    // 底部动作栏
    StickerTextFilterBottomBar *_bottomBar;
}

/**
 *  图片视图
 *  @since     v2.2.0
 */
@property (nonatomic, readonly) UIView<TuSDKICFilterImageViewInterface> *imageView;

/**
 *  参数配置视图
 *  @since     v2.2.0
 */
@property (nonatomic, readonly) UIView<TuSDKCPParameterConfigViewInterface> *configView;

/**
 *  底部动作栏
 *  @since     v2.2.0
 */
@property (nonatomic, readonly) StickerTextFilterBottomBar *bottomBar;
@end

