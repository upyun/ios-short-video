//
//  VideoTrimmerViewProtocol.h
//  VideoTrimmerExp
//
//  Created by bqlin on 2018/6/29.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoThumbnailsView.h"

/**
 修整时间位置
 */
typedef NS_ENUM(NSInteger, TrimmerTimeLocation) {
    // 未知
    TrimmerTimeLocationUnknown,
    // 在左侧修整时间
    TrimmerTimeLocationLeft,
    // 在右侧修整时间
    TrimmerTimeLocationRight,
    // 修整当前时间
    TrimmerTimeLocationCurrent
};

@protocol VideoTrimmerViewProtocol;

@protocol VideoTrimmerViewDelegate <NSObject>

@optional

/**
 时间轴开始滑动回调

 @param trimmer 时间轴
 @param location 时间轴上的位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didStartAtLocation:(TrimmerTimeLocation)location;

/**
 时间轴结束滑动回调

 @param trimmer 时间轴
 @param location 时间轴上的位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didEndAtLocation:(TrimmerTimeLocation)location;

/**
 时间轴进度更新回调，仅在用户交互时回调

 @param trimmer 时间轴
 @param progress 时间轴进度
 @param location 时间轴上的位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer updateProgress:(double)progress atLocation:(TrimmerTimeLocation)location;

/**
 时间轴到达临界值回调，仅在用户交互时回调

 @param trimmer 时间轴
 @param reachMaxIntervalProgress 时间轴上最大进度
 @param reachMinIntervalProgress 时间轴上最小进度
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer reachMaxIntervalProgress:(BOOL)reachMaxIntervalProgress reachMinIntervalProgress:(BOOL)reachMinIntervalProgress;

@end


/**
 视频修整控件一般协议
 */
@protocol VideoTrimmerViewProtocol <NSObject>

/**
 视频帧缩略图视图
 */
@property (nonatomic, strong, readonly) VideoThumbnailsView *thumbnailsView;

/**
 当前进度
 */
@property (nonatomic, assign) double currentProgress;

/**
 最大选取占比
 */
@property (nonatomic, assign) double maxIntervalProgress;

/**
 最小选取占比
 */
@property (nonatomic, assign) double minIntervalProgress;

/**
 选取区间开始进度
 */
@property (nonatomic, assign) double startProgress;

/**
 选取区间结束进度
 */
@property (nonatomic, assign) double endProgress;

/**
 拖拽中
 */
@property (nonatomic, assign, readonly) BOOL dragging;

/**
 时间轴视图代理
 */
@property (nonatomic, weak) IBOutlet id<VideoTrimmerViewDelegate> delegate;

@end
