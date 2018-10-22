//
//  TuSDKMediaTimelineAssetVideoExtractor.h
//  TuSDKVideo
//
//  Created by sprint on 05/08/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "TuSDKMediaTimelineAssetExtractor.h"

/**
 视频数据时间轴分离器
 
 @since v3.0
 */
@interface TuSDKMediaTimelineAssetVideoExtractor : TuSDKMediaTimelineAssetExtractor

/**
 初始化数据分离器
 
 @param asset 视频资产
 @param outputSettings 输出设置
 An NSDictionary of output settings to be used for sample output.  See AVAudioSettings.h for available output settings for audio tracks or AVVideoSettings.h for available output settings for video tracks and also for more information about how to construct an output settings dictionary.
 @return TuSDKMediaAssetVideoExtractor
 @since v3.0
 */
- (instancetype _Nullable )initWithAsset:(AVAsset *_Nonnull)asset outputSettings:(TuSDKMediaAssetExtractorSettings*_Nullable)outputSettings;

/**
 The value of the extractorFrameDuration property is set to a value short enough to accommodate the greatest nominal frame rate value among the asset’s video tracks, as indicated by the nominalFrameRate property of each track. If all of the asset tracks have a nominal frame rate of 0, a frame rate of 30 frames per second is used, with the frame duration set accordingly.
 extractorFrameDuration属性的值被设置为一个足够短的值，以容纳资产的视频轨道中最大的名义帧速率值，这是由每条轨道的名义上的属性所指示的。如果所有资产跟踪的名义帧速率为0，则使用每秒30帧的帧速率，并相应地设置帧持续时间。
  @since v3.0
 */
@property (nonatomic) CMTime extractorFrameDuration;

@end
