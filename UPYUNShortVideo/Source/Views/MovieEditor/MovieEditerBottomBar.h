//
//  MovieEditerBottomBar.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/25.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
#import "TimeScrollView.h"
#import "FilterView.h"
#import "MVScrollView.h"
#import "DubScrollView.h"
#import "MovieEditorClipView.h"
#import "EffectsView.h"
#import "RecorderView.h"
#import "BottomButtonView.h"

// 编辑页面 底部按钮类型枚举
typedef NS_ENUM (NSUInteger,MovieEditorBottomButtonType)
{
    MovieEditorBottomButtonType_Filter = 10,
    MovieEditorBottomButtonType_MV = 11,
    MovieEditorBottomButtonType_Dub = 12,
};


#pragma mark - protocol MovieEditorBottomBarDelegate

/**
 编辑页面，底部栏控件代理
 */
@protocol MovieEditorBottomBarDelegate <NSObject>

/**
 滤镜栏参数改变
 */
- (void)movieEditorBottom_filterViewParamChanged;

/**
 滤镜栏切换滤镜

 @param filterCode 滤镜的代号 filterCode
 */
- (void)movieEditorBottom_filterViewSwitchFilterWithCode:(NSString *)filterCode;

/**
 切换MV

 @param mvData MV 数据
 */
- (void)movieEditorBottom_clickStickerMVWith:(TuSDKMediaStickerAudioEffectData *)mvData;

/**
 切换 配音音乐
 
 @param mvData MV 数据
 */
- (void)movieEditorBottom_clickAudioWith:(TuSDKMediaAudioEffectData *)mvData;


/**
 改变音量调节栏参数

 @param volume 音量值
 @param index 调节栏的index
 */
- (void)movieEditorBottom_changeVolumeLevel:(CGFloat)volume  index:(NSInteger)index;

/**
 mv、配音缩略图 拖动到某位置处
 
 @param time 拖动的当前位置所代表的时间节点
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 */
- (void)movieEditorBottom_slipThumbnailViewWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus;

/**
 mv、配音缩略图 拖动结束的事件方法
 */
- (void)movieEditorBottom_slipThumbnailViewSlipEndEvent;

/**
 mv、配音缩略图 拖动开始的事件方法
 */
- (void)movieEditorBottom_slipThumbnailViewSlipBeginEvent;

/**
选中特效
 */
- (void)movieEditorBottom_effectsSelectedWithCode:(NSString *)effectCode;

/**
 结束选中的特效
 */
- (void)movieEditorBottom_effectsEndWithCode:(NSString *)effectCode;

/**
 显示特效栏
 */
- (void)movieEditorBottom_effectsViewDisplay;

/**
 回删添加的特效
 */
- (void)movieEditorBottom_effectsBackEvent;

/**
 移动视频的播放进度条
 */
- (void)movieEditorBottom_effectsMoveVideoProgress:(CGFloat)newProgress;

/**
 时间特效选中回调

 @param index 特效索引
 */
- (void)movieEditorBottom_timeEffectSelectedWithIndex:(NSInteger)index;

/**
 时间特效面板显示回调
 */
- (void)movieEditorBottom_timeEffectViewDisplay;

@end

#pragma mark - class MovieEditerBottomBar

/**
 编辑页面，底部栏控件
 */
@interface MovieEditerBottomBar : UIView

// 滤镜数组
@property (nonatomic, strong) NSArray<NSString *> *videoFilters;
// 底部栏代理
@property (nonatomic, assign) id<MovieEditorBottomBarDelegate> bottomBarDelegate;
// 视频URL
@property (nonatomic, strong) NSURL *videoURL;
// 时间特效列表
@property (nonatomic, strong) TimeScrollView *timeView;
// 滤镜view
@property (nonatomic, retain) FilterView *filterView;
// MV View
@property (nonatomic, retain) MVScrollView *mvView;
// 配音View
@property (nonatomic, retain) DubScrollView *dubView;
// 音量调节 View
@property (nonatomic, retain) UIView *volumeBackView;
// 当切换为 MV、配音 显示时，顶部的缩略图View
@property (nonatomic, strong) MovieEditorClipView *topThumbnailView;
// 时间特效顶部缩略图时码线
@property (nonatomic, strong) MovieEditorClipView *timeEffectThumbnailView;
// 特效View
@property (nonatomic, retain) EffectsView *effectsView;
// 视频时长
@property (nonatomic, assign) CGFloat videoDuration;
// 底部 滤镜栏、贴纸栏、配音栏 的 背景view
@property (nonatomic, strong) UIView *contentBackView;
// 底部按钮以及分割线的父视图
@property (nonatomic, strong) UIView *bottomDisplayView;

// 更新对应的参数列表
- (void)refreshFilterParameterViewWith:(NSString *)filterDescription filterArgs:(NSArray *)args;


// 子类中需要重写的方法 与外部调用功能无关
/**
 初始化底部按钮normal状态下图片数组
*/
- (NSArray *)getBottomNormalImages;

/**
 初始化底部按钮normal状态下图片数组
 */
- (NSArray *)getBottomSelectImages;

/**
 初始化底部按钮显示title
*/
- (NSArray *)getBottomTitles;

/**
 底部按钮点击事件
*/
- (void)bottomButton:(BottomButtonView *)bottomButtonView clickIndex:(NSInteger)index;

/**
 初始化视图调节内容
*/
- (void)initContentView;

/**
 切换底部按钮时 调整底部栏整体布局
*/
- (void)adjustLayout;


@end
