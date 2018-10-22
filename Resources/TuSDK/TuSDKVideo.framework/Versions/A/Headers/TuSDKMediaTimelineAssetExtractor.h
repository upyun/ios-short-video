//
//  TuSDKMediaExtractor.h
//  TuSDKVideo
//
//  Created by sprint on 12/06/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "TuSDKMediaTimelineExtractor.h"
#import "TuSDKMediaExtractorSync.h"
#import "TuSDKMediaAssetTimeline.h"
#import "TuSDKMediaStatus.h"
#import "TuSDKMediaSettings.h"

/**
 AVAsset 媒体数据读取类
 @since      v3.0
 */
@interface TuSDKMediaTimelineAssetExtractor : TuSDKMediaAssetTimeline <TuSDKMediaTimelineExtractor>
{
    
@protected
    /**
      首选每次缓存的持续时间.
      改时间会根据当前轨道帧率信息计算出合适的步进值.
     */
    CMTime _preferredStepDurationTime;
    
    CMTime _extractStepDurationTime;
    CMTime _extractMaxStepDurationTime;
    CMTime _frameInterval;
    
@protected
    // 当前正在分离的媒体数据片段 @since v3.0
    TuSDKMediaTimeSliceEntity *_extractingSlice;
    // 当前正在输出的媒体数据片段 @since v3.0
    TuSDKMediaTimeSliceEntity *_outputSlice;
    
}

/**
 初始化数据分离器
 
 @param asset 媒体资产
 @param outputSettings 输出设置
 An NSDictionary of output settings to be used for sample output.  See AVAudioSettings.h for available output settings for audio tracks or AVVideoSettings.h for available output settings for video tracks and also for more information about how to construct an output settings dictionary.
 @return TuSDKMediaAssetExtractor
 */
- (instancetype _Nullable )initWithAsset:(AVAsset *_Nonnull)asset outputTrackMediaType:(AVMediaType _Nonnull )mediaType outputSettings:(TuSDKMediaAssetExtractorSettings*_Nullable)outputSettings;

/*!
 @property mediaSync
 分离同步器
 @since      v3.0
 */
@property (nonatomic, weak) id<TuSDKMediaExtractorSync> _Nullable mediaSync;

@end

#pragma mark - Detect Asset

@interface TuSDKMediaTimelineAssetExtractor (DetectAsset)

/**
 探测资产信息
 @since      v3.0
 */
- (void)detecAssetInfo;

@end

#pragma mark - Cache

@interface TuSDKMediaTimelineAssetExtractor (Cache)

/**
 缓存数据帧

 @return true/falses
 @since      v3.0
 */
- (BOOL)cacheSamplebuffers;

/**
 读取某段视频帧
 
 @param reverse 是否反转视频
 @since      v3.0
 */
- (CFMutableArrayRef _Nonnull)copySampleBuffers:(CMTimeRange)range reverse:(BOOL)reverse;

/**
 根据当前时间读取下一个时间范围
 
 @return 当前时间
 @since v3.0
 */
- (TuSDKMediaTimeSliceEntity *_Nonnull)firstExtractSlice;

/**
 请求下一个分离的媒体片段
 
 @return true : 请求成功 存在有效的媒体片段
 @since v3.0
 */
- (BOOL)nextExtractSlice;

/**
 根据选择的时间段创建一个媒体数据输出

 @param timeRange 读取的时间区间
 @return return AVAssetReaderOutput
 @since v3.0
 */
- (AVAssetReader *_Nonnull)readerWithTimeRange:(CMTimeRange)timeRange;

@end


