//
//  MultipleCameraViewController.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/23.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "StickerScrollView.h"
#import "ClickPressBottomBar.h"
#import "TopNavBar.h"
#import "FilterBottomButtonView.h"

/**
 多功能相机示例，点击拍照，长按录制
 */
@interface MultipleCameraViewController : UIViewController<TopNavBarDelegate, BottomBarDelegate, TuSDKRecordVideoCameraDelegate, FilterViewEventDelegate, StickerViewClickDelegate>

// 事件处理队列
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

// 录制相机对象
@property (nonatomic, strong) TuSDKRecordVideoCamera  *camera;
// 当前获取的滤镜对象
@property (nonatomic, strong) TuSDKFilterWrap *currentFilter;

@property (nonatomic, strong) NSArray *videoFilters;
@property (nonatomic, assign) int videoFilterIndex;
// 当前的flash选择的index
@property (nonatomic, assign) int flashModeIndex;

// 滤镜栏
@property (nonatomic, strong) FilterBottomButtonView *filterButtonView;
// 贴纸栏
@property (nonatomic, strong) StickerScrollView *stickerView;
// 录制相机顶部控制栏视图
@property (nonatomic, strong) TopNavBar *configBar;
// 录制相机底部功能栏视图
@property (nonatomic, strong) ClickPressBottomBar *bottomBar;

// cameraView
@property (nonatomic, strong) UIView *cameraView;
// 拍照或录制结束后的预览view
@property (nonatomic, strong) UIView *preView;
// cameraTapView 用于处理滤镜栏和贴纸栏的显示和隐藏
@property (nonatomic, strong) UIView *tapView;
// 拍照展示IV
@property (nonatomic, strong) UIImageView *takePictureIV;
// 视频的临时文件路径
@property (nonatomic, strong) NSString *videoPath;
// 播放视频使用的 AVPlayerItem
@property (nonatomic, strong) AVPlayerItem *videoItem;
// 播放视频使用的 AVPlayer
@property (nonatomic, strong) AVPlayer *videoPlayer;
// 播放视频使用的 Layer
@property (nonatomic, strong) AVPlayerLayer *videoLayer;
// 设置当前的录制进度
@property (nonatomic, assign) CGFloat recordProgress;
// 保存图片或视频
- (void)savePictureOrVideo;
// 销毁player相关对象
- (void)destroyVideoPlayer;
@end
