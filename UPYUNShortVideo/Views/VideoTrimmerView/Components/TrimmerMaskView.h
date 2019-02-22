//
//  TrimmerMaskView.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 修整蒙版视图
 */
@interface TrimmerMaskView : UIView

/**
 遮罩挖空的区域，即选取部分的区域
 */
@property (nonatomic, assign) CGRect maskRect;

/**
 选取区域最大宽度
 */
@property (nonatomic, assign) CGFloat maskMaxWidth;

/**
 选取区域最小宽度
 */
@property (nonatomic, assign) CGFloat maskMinWidth;

/**
 选取的开始进度
 */
@property (nonatomic, assign) double startProgress;

/**
 选取的结束进度
 */
@property (nonatomic, assign) double endProgress;

/**
 左滑块
 */
@property (nonatomic, strong, readonly) UIView *leftThumb;

/**
 右滑块
 */
@property (nonatomic, strong, readonly) UIView *rightThumb;

/**
 是否在拖拽中
 */
@property (nonatomic, assign, readonly) BOOL dragging;

/**
 滑块宽度
 */
@property (nonatomic, assign, readonly) CGFloat thumbWidth;

/**
 边框宽度
 */
@property (nonatomic, assign, readonly) CGFloat borderWidth;

/**
 开始修整回调，开始触摸时进行调用
 */
@property (nonatomic, copy) void (^startTrimmingHandler)(TrimmerMaskView *trimmerMask, UIView *touchControl);

/**
 结束修整回调，结束触摸时进行调用
 */
@property (nonatomic, copy) void (^endTrimmingHandler)(TrimmerMaskView *trimmerMask, UIView *touchControl);

/**
 修整中回调，触摸过程中进行调用
 */
@property (nonatomic, copy) void (^trimmingHandler)(TrimmerMaskView *trimmerMask, UIView *touchControl, double progress);

/**
 到达最小值回调
 */
@property (nonatomic, copy) void (^reachMaxHandler)(TrimmerMaskView *trimmerMask, UIView *touchControl);

/**
 到达最大值回调
 */
@property (nonatomic, copy) void (^reachMinHandler)(TrimmerMaskView *trimmerMask, UIView *touchControl);

@end
