//
//  CameraControlMaskView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentButton.h"
#import "TextPageControl.h"
#import "MarkableProgressView.h"
#import "PhotoCaptureConfirmView.h"
#import "CameraMoreMenuView.h"
#import "CameraFilterPanelView.h"
#import "CameraBeautyPanelView.h"
#import "PropsPanelView.h"
#import "CameraSpeedSegmentButton.h"
#import "RecordButton.h"

@class CameraControlMaskView;

@protocol CameraControlMaskViewDelegate <NSObject>

@optional

/**
 滤镜面板出现回调，在此处更新滤镜参数列表

 @param controlMask 相机遮罩视图
 @param filterPanel 相机滤镜协议
 */
- (void)controlMask:(CameraControlMaskView *)controlMask didShowFilterPanel:(id<CameraFilterPanelProtocol>)filterPanel;

/**
 变焦操作回调，在该方法中实现对相机的变焦

 @param controlMask 相机遮罩视图
 @param zoomDelta 变焦倍数增量
 */
- (void)controlMask:(CameraControlMaskView *)controlMask didChangeZoomDelta:(CGFloat)zoomDelta;

@end

@interface CameraControlMaskView : UIView

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

/**
 顶部工具栏
 */
@property (nonatomic, weak) IBOutlet UIStackView *topToolBar;

/**
 底部左侧工具栏
 */
@property (nonatomic, weak) IBOutlet UIStackView *leftBottomToolBar;

/**
 底部右侧工具栏
 */
@property (nonatomic, weak) IBOutlet UIStackView *rightBottomToolBar;
#pragma clang diagnostic pop

/**
 返回按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *backButton;

/**
 切换摄像头按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *switchCameraButton;

/**
 美颜按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *beautyButton;

/**
 速率切换按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *speedButton;

/**
 更多按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *moreButton;

/**
 贴纸按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *stickerButton;

/**
 滤镜按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *filterButton;

/**
 录制按钮
 */
@property (nonatomic, weak) IBOutlet RecordButton *captureButton;

/**
 完成按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

/**
 回删按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *undoButton;

/**
 录制模式切换控件
 */
@property (weak, nonatomic) IBOutlet TextPageControl *captureModeControl;

/**
 可标记进度视图
 */
@property (weak, nonatomic) IBOutlet MarkableProgressView *markableProgressView;

/**
 滤镜名称标签
 */
@property (nonatomic, weak) IBOutlet UILabel *filterNameLabel;

/**
 更多菜单叠层视图
 */
@property (nonatomic, strong, readonly) CameraMoreMenuView *moreMenuView;

/**
 速率切换按钮
 */
@property (nonatomic, strong, readonly) CameraSpeedSegmentButton *speedSegmentButton;

/**
 滤镜面板叠层视图
 */
@property (nonatomic, strong, readonly) CameraFilterPanelView *filterPanelView;

/**
 美颜面板叠层视图
 */
@property (nonatomic, strong, readonly) CameraBeautyPanelView *beautyPanelView;

/**
 道具面板叠层视图
 */
@property (nonatomic, strong, readonly) PropsPanelView *propsItemPanelView;

/**
 显示的滤镜名称
 */
@property (nonatomic, copy) NSString *filterName;

/**
 相机遮罩视图代理
 */
@property (nonatomic, weak) IBOutlet id<CameraControlMaskViewDelegate> delegate;

/**
 相机折叠功能菜单代理
 */
@property (nonatomic, weak) IBOutlet id<CameraMoreMenuViewDelegate> moreMenuDelegate;

/**
 相机滤镜数据信息代理
 */
@property (nonatomic, weak) IBOutlet id<CameraFilterPanelDataSource> filterPanelDataSource;

/**
 相机滤镜代理
 */
@property (nonatomic, weak) IBOutlet id<CameraFilterPanelDelegate> filterPanelDelegate;

/**
 相机贴纸代理
 */
@property (nonatomic, weak) IBOutlet id<PropsPanelViewDelegate> stickerPaneldelegate;

/**
 隐藏视图方法
 */
- (void)hideViewsWhenRecording;

/**
 显示视图方法
 */
- (void)showViewsWhenPauseRecording;

/**
 更新录制确认控件的显示
 */
- (void)updateRecordConfrimViewsDisplay;

/**
 更新速率控件显示
 */
- (void)updateSpeedSegmentDisplay;

/**
 相机拍照确认

 @param confirmViewConfigHandler 确认操作的回调
 */
- (void)showPhotoCaptureConfirmViewWithConfig:(void (^)(PhotoCaptureConfirmView *confirmView))confirmViewConfigHandler;

/**
 隐藏视图方法
 */
- (void)hidePhotoCaptureConfirmView;

@end
