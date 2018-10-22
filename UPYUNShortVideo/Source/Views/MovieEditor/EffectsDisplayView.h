//
//  EffectsDisplayView.h
//  TuSDKVideoDemo
//
//  Created by wen on 13/12/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
/**
 缩略图事件代理
 
 @param viewDescription 点击的basicView所对应的code(对于滤镜栏中即为filterCode)
 */
@protocol EffectsDisplayViewEventDelegate <NSObject>

/**
 移动当前时间view

 @param newLocation 新的location
 */
- (void)moveCurrentLocationView:(CGFloat)newLocation;

@end


@interface EffectsDisplayView : UIView
// 当前位置 0~1.0
@property (nonatomic, assign) CGFloat currentLocation;
// 视频路径URL
@property (nonatomic, strong) NSURL *videoURL;
// 添加的片段个数
@property (nonatomic, assign, readonly) NSInteger segmentCount;
// 是否正在添加片段
@property (nonatomic, assign, readonly) BOOL isAdding;
// 缩略图事件代理
@property (nonatomic, assign) id<EffectsDisplayViewEventDelegate> eventDelegate;

/**
 添加一个显示片段

 @param progress 开始进度 （0-1）
 @param color 片段显示的颜色
 @return 是否添加成功
 */
- (BOOL)addSegmentViewBeginWithProgress:(CGFloat)progress WithColor:(UIColor *)color;

/**
 当前正在添加的片段增加到某一位置
 
 @param progress 当前进度
 */
-(void)updateLastSegmentViewWithProgress:(CGFloat)progress;

/**
 结束正在添加的位置
 */
- (void)makeFinish;

/**
 移除上一个添加的片段
 */
- (void)removeLastSegment;

/**
 移除所有已添加的片段
 */
- (void)removeAllSegment;

@end
