//
//  MovieEditorViewController.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/15.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
#import "TopNavBar.h"
#import "MovieEditerBottomBar.h"
#import "MovieEditorClipView.h"

/**
 视频编辑示例：对视频进行裁剪，添加滤镜，添加MV效果
 */
@interface MovieEditorViewController : UIViewController<TuSDKMovieEditorDelegate, TopNavBarDelegate, MovieEditorBottomBarDelegate>

// 开启编辑器控制器需要传入的参数
// 视频路径
@property (nonatomic, strong) NSURL *inputURL;
// 开始时间
@property (nonatomic, assign) CGFloat startTime;
// 结束时间
@property (nonatomic, assign) CGFloat endTime;
// 视频裁剪区域
@property (nonatomic, assign) CGRect cropRect;

// 以下参数供继承调用
// 视频编辑对象
@property (nonatomic, strong) TuSDKMovieEditor *movieEditor;
// 滤镜数组
@property (nonatomic, strong) NSArray<NSString *> *videoFilterCodes;
// 特效数组
@property (nonatomic, strong) NSArray<NSString *> *videoEffectCodes;

// 当前的滤镜
@property (nonatomic, strong) TuSDKFilterWrap *currentFilter;

// 视图布局
// 视频预览的背景scroll
@property (nonatomic, strong) UIView *previewView;
// 视频预览view
@property (nonatomic, strong) UIView *videoView;
// 视频暂停播放按钮
@property (nonatomic, strong) UIButton *playBtn;
// 视频暂停按钮图片
@property (nonatomic, strong) UIImageView *playBtnIcon;
// 底部栏
@property (nonatomic, strong) MovieEditerBottomBar *bottomBar;
// 编辑页面顶部控制栏视图
@property (nonatomic, strong) TopNavBar *topBar;

// MV 相关
// 此时movieEditor的状态(预览、裁剪)
@property (nonatomic, assign) lsqMovieEditorStatus movieEditorStatus;
// 记录MV的开始时间，基于已时长裁剪后的视频长度
@property (nonatomic, assign) CGFloat mvStartTime;
// 记录MV的结束时间，基于已时长裁剪后的视频长度
@property (nonatomic, assign) CGFloat mvEndTime;

// 当前选中的特效时间范围
@property (nonatomic, strong) TuSDKTimeRange *mediaEffectTimeRange;
// 当前的特效对象
@property (nonatomic, strong) TuSDKMediaEffectData *currentMediaEffect;
// 当前的 MV\配音 音量
@property (nonatomic, assign) CGFloat dubAudioVolume;

// 点击 播放/暂停 按钮事件
- (void)clickPlayerBtn:(UIButton *)sender;
// 暂停预览
- (void)stopPreview;
// 开始预览
- (void)startPreview;
@end
