//
//  TuSDKFilterProcessor.h
//  TuSDK
//
//  Created by Yanlin Qiu on 26/06/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import "TuSDKVideoImport.h"
#import "TuSDKVideoCameraBase.h"

#pragma mark - TuSDKFilterProcessorDelegate

@class TuSDKFilterProcessor;
/**
 *  视频处理事件委托
 */
@protocol TuSDKFilterProcessorDelegate <NSObject>
/**
 *  滤镜改变 (如需操作UI线程， 请检查当前线程是否为主线程)
 *
 *  @param processor 视频处理对象
 *  @param newFilter 新的滤镜对象
 */
- (void)onVideoProcessor:(TuSDKFilterProcessor *)processor filterChanged:(TuSDKFilterWrap *)newFilter;

@end

#pragma mark - TuSDKFilterProcessor

/**
 滤镜引擎，实时处理帧数据，并返回处理的结果
 */
@interface TuSDKFilterProcessor : TuSDKFilterProcessorBase

/**
 *  处理器事件委托
 */
@property (nonatomic, weak) id<TuSDKFilterProcessorDelegate> delegate;

/**
 *  输出 PixelBuffer 格式，可选: lsqFormatTypeBGRA | lsqFormatTypeYUV420F | lsqFormatTypeRawData
 *  默认:lsqFormatTypeBGRA
 */
@property (nonatomic) lsqFrameFormatType outputPixelFormatType;

/**
 Process a video sample and return result soon
 
 @param sampleBuffer sampleBuffer sampleBuffer Buffer to process
 @return Video PixelBuffer
 */
- (CVPixelBufferRef)syncProcessVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 Process pixelBuffer and return result soon
 
 @param pixelBuffer pixelBuffer
 @return PixelBuffer
 */
- (CVPixelBufferRef)syncProcessPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/**
 手动销毁帧数据
 */
- (void)destroyFrameData;

/**
 *  切换滤镜
 *
 *  @param code 滤镜代号
 *
 *  @return 是否成功切换滤镜
 */
- (BOOL)switchFilterWithCode:(NSString *)code;

@end
