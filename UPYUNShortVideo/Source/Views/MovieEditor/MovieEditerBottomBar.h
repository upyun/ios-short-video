//
//  MovieEditerBottomBar.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/25.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
#import "FilterView.h"
#import "MVScrollView.h"
#import "DubScrollView.h"

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
 调整了bottom的整体的frame

 @param mvViewDisplayed MV视图展示
 @param lastFrame lastFrame description
 @param newFrame newFrame description
 */
- (void)movieEditorBottom_adjustFrameWithMVDisplayed:(BOOL)mvViewDisplayed lastFrame:(CGRect)lastFrame newFrame:(CGRect)newFrame;

/**
 切换MV

 @param mvData MV 数据
 */
- (void)movieEditorBottom_clickStickerMVWith:(TuSDKMVStickerAudioEffectData *)mvData;

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
// 滤镜view
@property (nonatomic, retain) FilterView *filterView;
// MV View
@property (nonatomic, retain) MVScrollView *mvView;
// 配音View
@property (nonatomic, retain) DubScrollView *dubView;
// 视频时长
@property (nonatomic, assign) CGFloat videoDuration;
// 底部 滤镜栏、贴纸栏、配音栏 的 背景view
@property (nonatomic, strong) UIView *contentBackView;


// 更新对应的参数列表
- (void)refreshFilterParameterViewWith:(NSString *)filterDescription filterArgs:(NSArray *)args;

@end
