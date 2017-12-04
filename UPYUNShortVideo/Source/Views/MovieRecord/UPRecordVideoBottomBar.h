//
//  UPRecordVideoBottomBar.h
//  UPYUNShortVideo
//
//  Created by lingang on 2017/11/15.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

#pragma mark - UPBottomBarDelegate
/**
 点击 底部栏 按钮时，抛出的按钮事件代理方法
 */
@protocol UPBottomBarDelegate <NSObject>

/**
 按钮点击的代理方法
 
 @param btn 按钮
 */
- (void)onBottomBtnClicked:(UIButton*)btn;

/**
 
 按下录制按钮
 
 @param btn 按钮
 */
- (void)onRecordBtnPressStart:(UIButton*)btn;

/**
 
 松开录制按钮
 
 @param btn 按钮
 */
- (void)onRecordBtnPressEnd:(UIButton*)btn;

@end


#pragma mark - RecordVideoBottomBar

/**
 录制页面底部栏视图
 */

@interface UPRecordVideoBottomBar : UIView

// 代理对象
@property (nonatomic, assign) id<UPBottomBarDelegate> bottomBarDelegate;

// 录制按钮
@property (nonatomic, readonly) UIButton *recordButton;

// 滤镜按钮
@property (nonatomic, readonly) UIButton *filterButton;

// 贴纸按钮
@property (nonatomic, readonly) UIButton *stickerButton;

// 确认按钮
@property (nonatomic, readonly) UIButton *completeButton;

// 撤销按钮
@property (nonatomic, readonly) UIButton *cancelButton;

// 滤镜按钮 Label
@property (nonatomic, readonly) UILabel *filterLabel;

// 贴纸按钮 Label
@property (nonatomic, readonly) UILabel *stickerLabel;

// 相册按钮 Label
@property (nonatomic, readonly) UILabel *albumLabel;

// 录制模式
@property (nonatomic, assign) lsqRecordMode recordMode;

- (void)enabledOtherBtn:(BOOL)enabled;

- (void)enabledBtnWithCancle:(BOOL)enabledCancle;

- (void)enabledBtnWithComplete:(BOOL)enabledComplete;

- (void)recordBtnIsRecordingStatu:(BOOL)isRecording;

- (void)reFrameViews:(BOOL)enabledCancle;

@end
