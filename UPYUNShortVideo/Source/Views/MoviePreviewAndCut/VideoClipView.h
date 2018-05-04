//
//  VideoClipView.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/13.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordVideoBottomBar.h"

#define kCustomYellowColor [UIColor colorWithRed:244/255.0f green:161/255.0f blue:26/255.0f alpha:1]


#pragma mark - enum 滑动条当前滑动的view类型
typedef enum : NSUInteger {
    lsqClipViewStyleLeft = 10,
    lsqClipViewStyleRight,
    lsqClipViewStyleCurrent,
} lsqClipViewStyle;

#pragma mark - protocol VideoClipViewDelegate
/**
 裁剪页面中，裁剪滑动条控件的相关代理
 */
@protocol VideoClipViewDelegate <NSObject>

/**
 拖动到某位置处

 @param time 拖动的当前位置所代表的时间节点
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 */
- (void)chooseTimeWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus;

/**
 拖动结束的事件方法
 */
- (void)slipEndEvent;

/**
 拖动开始的事件方法
 */
- (void)slipBeginEvent;

@end

#pragma mark - class VideoClipView
/**
 裁剪页面中，裁剪滑动条控件
 */
@interface VideoClipView : UIView

// 总时间，用来后续计算
@property (nonatomic, assign) CGFloat timeInterval;
// 当前时间，用来设置白色时间条位置
@property (nonatomic, assign) CGFloat currentTime;
// 最小剪切时间，用来控制两端的间隔
@property (nonatomic, assign) CGFloat minCutTime;
// 事件代理
@property (nonatomic, assign) id<VideoClipViewDelegate> clipDelegate;
// 缩略图数组
@property (nonatomic, strong) NSArray<UIImage*> *thumbnails;

@end
