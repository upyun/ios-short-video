//
//  TuSDKMediaVideoRender.h
//  TuSDKVideo
//
//  Created by sprint on 19/06/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 视频渲染接口
 @since  v3.0
 */
@protocol TuSDKMediaVideoRender <NSObject>

@required

/**
 处理渲染完成后的图像格式
 支持： kCVPixelFormatType_420YpCbCr8BiPlanarFullRange | kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange kCVPixelFormatType_32BGRA
 @return OSType
 @since v3.0
 */
- (OSType)renderInputPixelFormatType;

/**
 图像方向，开发者需要根据方向信息自行纠正

 @param rotationMode GPUImageRotationMode
 @since v3.0
 */
- (void)renderImageRotationMode:(GPUImageRotationMode)rotationMode;

/**
 渲染一帧视频

 @param sampleBuffer  解码视频数据
 @param outputTime    输出视频时间
 @return 渲染后的音频数据
 @since v3.0
 */
- (CVPixelBufferRef)renderPixelBufferRef:(CVPixelBufferRef)pixelBufferRef outputTime:(CMTime) outputTime;

@end
