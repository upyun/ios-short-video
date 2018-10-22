//
//  MovieEditorViewController.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/15.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "TuSDKFramework.h"
#import "TopNavBar.h"
#import "MovieEditerBottomBar.h"
#import "MovieEditorClipView.h"


/**
 视频编辑示例：对视频进行裁剪，添加滤镜，添加MV效果
 */
@interface MovieEditorViewController : UIViewController
                                                <
                                                    TuSDKMovieEditorLoadDelegate, // 加载委托
                                                    TuSDKMovieEditorPlayerDelegate , // 播放委托
                                                    TuSDKMovieEditorSaveDelegate, // 保存委托
                                                    TuSDKMovieEditorMediaEffectsDelegate, // 特效委托

                                                    TopNavBarDelegate,
                                                    MovieEditorBottomBarDelegate
                                                >

// 视频编辑对象
@property (nonatomic, strong) TuSDKMovieEditor *movieEditor;

// 开启编辑器控制器需要传入的参数
// 视频路径
@property (nonatomic, strong) NSURL *inputURL;

/**
 裁切时间区间
 */
@property (nonatomic)CMTimeRange cutTimeRange;

// 视频裁剪区域
@property (nonatomic, assign) CGRect cropRect;

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
@property (nonatomic, readonly) lsqMovieEditorStatus movieEditorStatus;
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
// 停止预览
- (void)stopPreview;
// 暂停预览
- (void)pausePreview;
// 开始预览
- (void)startPreview;
@end
