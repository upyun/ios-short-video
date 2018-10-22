//
//  TuSDKPFEditTextFullView.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2018/6/25.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKPFEditTextView.h"
#import "TopNavBar.h"
#import "TuSDKPFEditTextColorAdjustView.h"
#import "TuSDKPFEditTextStyleAdjustView.h"
#import "MovieEditorClipView.h"


@class TuSDKPFEditTextFullView;

@protocol TuSDKPFEditTextFullViewDelegate <NSObject>
/**
 点击文字编辑播放  YES：开始播放   NO：暂停播放
 
 @param isStartPreview YES:开始预览
 */
-(void)textEditFullEditView_playVideoEvent:(BOOL)isStartPreview;

/**
 点击文字返回按钮
 */
- (void)textEditFullEditView_backViewEvent;

/**
 点击文字编辑完成
 */
-(void)textEditFullEditView_completeEvent;

/**
 文字缩略图 拖动到某位置处

 @param time 时间
 @param isStartStatus 状态
 */
-(void)movieEditor_textSlipThumbnailViewWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus;

/**
 文字缩略图 拖动结束的事件方法
 */
-(void)movieEditor_textSlipThumbnailViewSlipEndEvent;

/**
 文字缩略图 拖动开始的事件方法
 */
-(void)movieEditor_textSlipThumbnailViewSlipBeginEvent;


@end



@interface TuSDKPFEditTextFullView : UIView
//设置是为编辑状态
@property (nonatomic, assign) BOOL isEditTextStatus;
//底部view
@property (nonatomic, strong) TuSDKPFEditTextView * bottomView;

// 文字特效代理
@property (nonatomic, weak ) id<TuSDKPFEditTextFullViewDelegate> textEditDelegate;
// 播放按钮
@property (nonatomic, strong) UIButton *playBtn;
// 编辑页面顶部控制栏视图
@property (nonatomic, strong) TopNavBar *topBar;
// 是否播放
@property (nonatomic, assign) BOOL isVideoPlay;

/**
 *  文字初始化创建样式
 */
@property (nonatomic, strong) TuSDKPFEditTextViewOptions *textOptions;

/**
 *  默认样式视图 (如果覆盖 buildDefaultStyleView 方法，实现了自己的视图，defaultStyleView == nil)
 */
@property (nonatomic, readonly) TuSDKPFEditTextView *defaultStyleView;
// 选项栏目
@property (nonatomic,   strong) TuSDKPFEditAdjustOptionBar * optionBar;
// 文字视图
@property (nonatomic,   strong) TuSDKPFTextView * textView;
// 选项调节的背景View
@property (nonatomic,   strong) UIView *optionEnterBackView;
// 选项操作返回按钮
@property (nonatomic,   strong) UIButton *optionBackButton;
// 选项操作容器
@property (nonatomic,   strong) UIView *optionActionContainer;

// 颜色调节View
@property (nonatomic,   strong) TuSDKPFEditTextColorAdjustView *colorAdjustView;
// 样式调节View
@property (nonatomic,   strong) TuSDKPFEditTextStyleAdjustView *styleAdjustView;
// 输入框
@property (nonatomic,   strong) UITextView *textInputView;
// 旋转和裁剪 裁剪区域视图
@property (nonatomic,   strong) TuSDKICMaskRegionView *cutRegionView;
// 当切换为 文字 显示时，底部的缩略图View
@property (nonatomic,   strong) MovieEditorClipView *bottomThumbnailView;




@end
