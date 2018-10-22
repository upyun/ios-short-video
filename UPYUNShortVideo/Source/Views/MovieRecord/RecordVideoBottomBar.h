//
//  RecordVideoBottomBar.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

#pragma mark - BottomBarDelegate

/**
 点击 底部栏 按钮时，抛出的按钮事件代理方法
 */
@protocol BottomBarDelegate <NSObject>

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
@interface RecordVideoBottomBar : UIView

// 代理对象
@property (nonatomic, weak) id<BottomBarDelegate> bottomBarDelegate;

// 录制按钮
@property (nonatomic, readonly) UIButton *recordButton;

// 滤镜按钮
@property (nonatomic, readonly) UIButton *filterButton;

// 贴纸按钮
@property (nonatomic, readonly) UIButton *stickerButton;

// 相册按钮
@property (nonatomic, readonly) UIButton *albumButton;

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

// 确认 label
@property (nonatomic, readonly) UILabel *completeLabel;

// 撤销 label
@property (nonatomic, readonly) UILabel *cancelLabel;

// 录制按钮事件响应区域
@property (nonatomic, readonly) UIView *touchView;

// 录制模式
@property (nonatomic, assign) lsqRecordMode recordMode;

- (void)enabledBtnWithCancle:(BOOL)enabledCancle;

- (void)enabledBtnWithComplete:(BOOL)enabledComplete;

- (void)recordBtnIsRecordingStatu:(BOOL)isRecording;
@end




