//
//  MoviePreviewAndCutViewController.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/27.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TuSDKFramework.h"
#import "MovieEditorViewController.h"
#import "CutVideoBottomView.h"
#import "TopNavBar.h"

/**
 视频时间选取示例：视频预览，选取裁剪时间范围
 */
@interface MoviePreviewAndCutViewController : UIViewController<TopNavBarDelegate>

// 视频URL
@property (nonatomic, strong) NSURL *inputURL;
// 播放按钮iv
@property (nonatomic, strong) UIImageView *playerIV;
// 视频播放player的视图layer
@property (nonatomic, strong) AVPlayerLayer *layer;
// 展示的scrollView
@property (nonatomic, strong) UIScrollView *videoScroll;
// 视频播放view
@property (nonatomic, strong) UIView *videoView;
// 记录视频的宽高比
@property (nonatomic, assign) CGFloat ratioWH;

// 编辑页面顶部控制栏视图
@property (nonatomic, strong) TopNavBar *configBar;
// 底部裁剪view
@property (nonatomic, strong) CutVideoBottomView *cutVideoView;
// 视频播放player
@property (nonatomic, strong) AVPlayer *player;
// 视频播放item
@property (nonatomic, strong) AVPlayerItem *item;
// 记录开始时间
@property (nonatomic, assign) CGFloat startTime;
// 记录结束时间
@property (nonatomic, assign) CGFloat endTime;
// 当前时间
@property (nonatomic, assign) CGFloat currentTime;
// 播放点击记录，若点击播放，为YES，再点击暂定，为NO
@property (nonatomic, assign) BOOL playSelected;

// 播放视频
- (void)playTheVideo;
// 暂停播放
- (void)pauseTheVideo;

// 播放结束的通知
- (void)playerEnd:(AVPlayerItem *)playerItem;

// 销毁播放器
- (void)destroyPlayer;

@end
