//
//  MovieRecordViewController.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
#import "StickerScrollView.h"
#import "RecordVideoBottomBar.h"
#import "TopNavBar.h"
#import "FilterBottomButtonView.h"

/**
 *  视频录制示例：支持断点续拍，正常模式(模式的切换需要更改相关代码)
 */
@interface MovieRecordViewController : UIViewController <TopNavBarDelegate, BottomBarDelegate, TuSDKRecordVideoCameraDelegate, FilterViewEventDelegate, StickerViewClickDelegate>


// 事件处理队列
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

/**
 *  录制模式 默认:lsqRecordModeNormal (lsqRecordModeNormal: 正常模式, lsqRecordModeKeep: 续拍模式,支持断点续拍）
 */
@property (nonatomic, assign) lsqRecordMode inputRecordMode;

// 录制相机对象
@property (nonatomic, strong) TuSDKRecordVideoCamera  *camera;
// 当前获取的滤镜对象
@property (nonatomic, strong) TuSDKFilterWrap *currentFilter;
// 滤镜code 数组
@property (nonatomic, strong) NSArray *videoFilters;
@property (nonatomic, assign) int videoFilterIndex;
// 当前的flash选择的index
@property (nonatomic, assign) int flashModeIndex;

// 滤镜栏
@property (nonatomic, strong) UIView *bottomBackView;
@property (nonatomic, strong) FilterBottomButtonView *filterBottomView;
// 贴纸栏
@property (nonatomic, strong) StickerScrollView *stickerView;
// 录制相机顶部控制栏视图
@property (nonatomic, strong) TopNavBar *topBar;
// 录制相机底部功能栏视图
@property (nonatomic, strong) RecordVideoBottomBar *bottomBar;

// cameraView
@property (nonatomic, strong) UIView *cameraView;
// cameraTapView 用于处理滤镜栏和贴纸栏的显示和隐藏
@property (nonatomic, strong) UIView *tapView;
// 记录时间条view
@property (nonatomic, strong) UIView *aboveView;
@property (nonatomic, strong) UIView *underView;
@property (nonatomic, strong) UIView *minSecondView;
// 记录中间的时间节点的x坐标信息
@property (nonatomic, strong) NSMutableArray<NSNumber *> *nodesLocation;
// 记录视频最近节点对应的进度值
@property (nonatomic, assign) CGFloat newProgressLocation;
// 记录视频录制进度
@property (nonatomic, assign) CGFloat recoderProgress;
// 相冊选择
@property (nonatomic, strong) UIImagePickerController *ipc;

// 开始录制
- (void)startRecording;
// 暂停录制
- (void)pauseRecording;
// 结束录制
- (void)finishRecording;
// 取消录制
- (void)cancelRecording;
// 进入后台
- (void)enterBackFromFront;
// 后台到前台
- (void)enterFrontFromBack;
// 重置闪光灯状态
- (void)resetFlashBtnStatusWithBtnEnabled:(BOOL)enabled;
// 根据value值获得对应的flash类型
- (AVCaptureFlashMode)getFlashModeByValue:(NSInteger)value;
// 断点续拍增减中间节点
- (void)changeNodeViewWithLocation:(CGFloat)noteX;
// 切换相机预览视图显示状态
- (void)cameraTapEvent;
// 初始化贴纸栏
- (void)createStikerView;
// 初始化顶部栏和底部栏
- (void)initRecorderView;
// 初始化进度烂
- (void)initProgressView;
// 初始化滤镜栏
- (void)createFilterView;

// 销毁对象
- (void)destroyCamera;
- (void)dealloc;
@end
