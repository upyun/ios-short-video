//
//  TuSDKMediaTimelineAssetMoviePlayer.h
//  TuSDKVideo
//
//  Created by sprint on 31/05/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKMediaAssetInfo.h"
#import "TuSDKMediaVideoRender.h"
#import "TuSDKMediaAudioRender.h"
#import "TuSDKMediaPlayer.h"
#import "TuSDKMediaAssetTimeline.h"
#import "TuSDKMediaStatus.h"
#import "TuSDKMediaTimeSliceEntity.h"

@protocol TuSDKMediaTimelineAssetMoviePlayerDelegate;

/**
 视频播放器
 @since     v3.0
 */
@interface TuSDKMediaTimelineAssetMoviePlayer : NSObject <TuSDKMediaPlayer,TuSDKMediaTimeline>

/**
 构建一个视频播放器

 @param asset 资产信息
 @param preview 预览视图
 @return TuSDKMediaAssetMoviePlayer
 @since      v3.0
 */
- (instancetype _Nullable)initWithAsset:(AVAsset *_Nonnull)asset preview:(UIView *_Nonnull)preview;

/**
 TuSDKAssetVideoPlayer
 @since      v3.0
 */
@property (strong,readonly) AVAsset* _Nonnull asset;

/**
 是否播放音频 默认：YES
 @since v3.0
 */
@property (nonatomic) BOOL enableAudioSound;

/**
  视频覆盖区域颜色 (默认：[UIColor blackColor])
  @since v3.0
 */
@property (nonatomic, retain) UIColor * _Nullable regionViewColor;

/**
 @property processQueue
 @abstract
 
 @discussion
 Decoding run queue
 @since      v3.0
 */
@property (nonatomic) dispatch_queue_t _Nullable processQueue;

/**
 当前视频播放器状态
 @since v3.0
 */
@property (nonatomic,readonly) TuSDKMediaPlayerStatus status;

/**
 获取视频信息，视频加载完成后可用
 @since      v3.0
 */
@property (nonatomic,readonly)TuSDKMediaAssetInfo * _Nullable inputAssetInfo;

/**
 视频外部渲染接口
 @since      v3.0
 */
@property (nonatomic,weak) id<TuSDKMediaVideoRender> _Nullable videoRender;

/**
 音频外部渲染接口
 @since     v3.0
 */
@property (nonatomic,weak) id<TuSDKMediaAudioRender> _Nullable audioRender;

/**
 Player 进度委托
 @since     v3.0
 */
@property (nonatomic,weak) id<TuSDKMediaTimelineAssetMoviePlayerDelegate> _Nullable delegate;

/**
 更新预览View
 
 @param frame 设定的frame
 @since     v3.0
 */
- (void)updatePreViewFrame:(CGRect)frame;

@end

#pragma mark - MediaTimelineSlice

@interface TuSDKMediaTimelineAssetMoviePlayer (MediaTimelineSlice)

/**
 当前正在播放的媒体数据片段
 
 @since      v3.0
 */
- (TuSDKMediaTimeSliceEntity *_Nullable) playingSlice;

@end

#pragma mark - Processing

@interface TuSDKMediaTimelineAssetMoviePlayer (Processing)

/**
 处理视频像素数据
 @param pixelBufferRef CVPixelBufferRef
 @param outputTime 输出时间
 */
- (void)processVideoPixelBuffer:(CVPixelBufferRef _Nonnull )pixelBufferRef outputTime:(CMTime)outputTime;

/**
 处理视频像素数据
 @param sampleBufferRef CMSampleBufferRef
 @param outputTime 输出时间
 @since v3.0
 */
- (void)processVideoSampleBufferRef:(CMSampleBufferRef _Nonnull )sampleBufferRef outputTime:(CMTime)outputTime;

/**
 处理音频数据
 @param sampleBufferRef CMSampleBufferRef
 @param outputTime 输出时间
 @since v3.0
 */
- (void)processAudioSampleBufferRef:(CMSampleBufferRef _Nonnull )sampleBufferRef outputTime:(CMTime)outputTime;

@end

#pragma mark TuSDKMediaAssetMoviePlayerDelegate

@protocol TuSDKMediaTimelineAssetMoviePlayerDelegate <NSObject>

@required

/**
 进度改变事件

 @param player 当前播放器
 @param percent (0 - 1)
 @param outputTime 当前帧所在持续时间
 @param outputSlice 当前正在输出的切片信息
 @since      v3.0
 */
- (void)mediaTimelineAssetMoviePlayer:(TuSDKMediaTimelineAssetMoviePlayer *_Nonnull)player progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime outputSlice:(TuSDKMediaTimelineSlice * _Nonnull)outputSlice;

/**
播放器状态改变事件
 
 @param player 当前播放器
 @param status 当前播放器状态
 @since      v3.0
 */
- (void)mediaTimelineAssetMoviePlayer:(TuSDKMediaTimelineAssetMoviePlayer *_Nonnull)player statusChanged:(TuSDKMediaPlayerStatus)status;

@end
