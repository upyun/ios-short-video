//
//  BaseEditComponentViewController.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseViewController.h"
#import "TuSDKFramework.h"

#import "BottomNavigationBar.h"
#import "EditComponentNavigator.h"

/**
 视频编辑子页面视图控制器
 */
@interface BaseEditComponentViewController : BaseViewController<EditComponentNavigationProtocol>

#pragma mark - EditComponentNavigationProtocol

/**
 页面导航管理器
 */
@property (nonatomic, strong) EditComponentNavigator *componentNavigator;

#pragma mark - UI

/**
 底部自定义导航栏
 */
@property (nonatomic, strong, readonly) BottomNavigationBar *bottomNavigationBar;

/**
 底部内容缩进
 */
+ (CGFloat)bottomContentOffset;

/**
 预览区域底部缩进
 */
+ (CGFloat)bottomPreviewOffset;

/**
 底部导航栏取消按钮事件

 @param sender 点击的按钮
 */
- (void)cancelButtonAction:(UIButton *)sender;

/**
 底部导航栏完成按钮事件

 @param sender 点击的按钮
 */
- (void)doneButtonAction:(UIButton *)sender;

#pragma mark - editor info

/**
 初始特效，用于取消时恢复
 */
@property (nonatomic, strong) NSArray *initialEffects;

/**
 初始记录的信息，用于取消时恢复
 */
@property (nonatomic, strong) NSDictionary *initialInfo;

/**
 视频编辑器
 */
@property (nonatomic, weak) TuSDKMovieEditor *movieEditor;

/**
 当前播放进度
 */
@property (nonatomic, assign) double playbackProgress;

/**
 同步当前播放状态
 */
@property (nonatomic, assign) BOOL playing;

/**
 缩略图数组
 */
@property (nonatomic, strong) NSArray<UIImage *> *thumbnails;

@end
