//
//  StickerTextEditTextView.h
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

#import "MovieEditorFullScreenController.h"

#import "TopNavBar.h"
#import "StickerTextColorAdjustView.h"
#import "StickerTextStyleAdjustView.h"
#import "MovieEditorClipView.h"
#import "StickerTextEditTextViewOptions.h"
#import "StickerTextEditAdjustView.h"
#import "StickerTextEditorPanel.h"

/**
 *  文字贴纸视图
 *  @since   v2.2.0
 */
@interface StickerTextEditor : UIView


/**
 *  文字贴纸视图初始化

 *  @param frame 视图默认大小
 *  @param movieEditorFull 视频编辑类
 *  @return     UIView
 *  @since      v2.2.0
 */
-(instancetype)initWithFrame:(CGRect)frame WithMovieEditor:(MovieEditorFullScreenController *)movieEditorFull;

// 总时间，用来后续计算 单位：秒
@property (nonatomic, assign) CGFloat totalDuration;

/**
 *  设置是为编辑状态
 *  @since       v2.2.0
 */
@property (nonatomic, assign) BOOL isEditTextStatus;

/**
 *  播放按钮
 *  @since       v2.2.0
 */
@property (nonatomic, strong) UIButton *playBtn;

/**
 *  编辑页面顶部控制栏视图
 *  @since       v2.2.0
 */
@property (nonatomic, strong) TopNavBar *topBar;

/**
 *  是否播放
 *  @since       v2.2.0
 */
@property (nonatomic, assign) BOOL isVideoPlay;

/**
 *  文字初始化创建样式
 *  @since       v2.2.0
 */
@property (nonatomic, strong) StickerTextEditTextViewOptions *textOptions;

/**
 * 选项栏目
 * @since       v2.2.0
 */
@property (nonatomic, strong) StickerTextEditAdjustOptionBar   *optionBar;

/**
 * 文字视图
 * @since       v2.2.0
 */
@property (nonatomic, strong) StickerTextEditorPanel *editorPanel;

/**
 * 选项调节的背景View
 * @since       v2.2.0
 */
@property (nonatomic, strong) UIView *optionEnterBackView;

/**
 * 选项操作返回按钮
 * @since       v2.2.0
 */
@property (nonatomic, strong) UIButton *optionBackButton;

/**
 * 选项操作容器
 * @since       v2.2.0
 */
@property (nonatomic, strong) UIView *optionActionContainer;

/**
 * 颜色调节View
 * @since       v2.2.0
 */
@property (nonatomic, strong) StickerTextColorAdjustView *colorAdjustView;

/**
 * 样式调节View
 * @since       v2.2.0
 */
@property (nonatomic, strong) StickerTextStyleAdjustView *styleAdjustView;

/**
 * 输入框
 * @since       v2.2.0
 */
@property (nonatomic, strong) UITextView *textInputView;

/**
 * 旋转和裁剪 裁剪区域视图
 * @since       v2.2.0
 */
@property (nonatomic, strong) TuSDKICMaskRegionView *cutRegionView;

/**
 * 当切换为 文字 显示时，底部的缩略图View
 * @since       v2.2.0
 */
@property (nonatomic, strong) MovieEditorClipView *bottomThumbnailView;

/**
 * 当前特效
 * @since       v2.2.0
 */
@property (nonatomic, strong) TuSDKMediaEffectData *currentMediaEffect;

/**
 * 预览界面位置信息
 * @since       v2.2.0
 */
@property (nonatomic, assign, readonly) CGRect preViewFrame;

@end
