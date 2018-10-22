//
//  TuSDKVideoImageExtractor.h
//  TuSDKVideo
//
//  Created by gh.li on 17/3/13.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef void(^TuSDKVideoImageExtractorBlock)(NSArray<UIImage *> *);
typedef void(^TuSDKVideoImageExtractorStepImageBlock)(UIImage *image, NSUInteger index);

/**
 * 提取视频帧
 *
 */
@interface TuSDKVideoImageExtractor : NSObject

/**
 创建TuSDKVideoImageExtractor

 @return TuSDKVideoImageExtractor
 */
+ (TuSDKVideoImageExtractor *)createExtractor;

/**
 视频资源
 */
@property (nonatomic, strong) AVAsset *videoAsset;

/**
    视频地址
 */
@property (nonatomic, copy) NSURL *videoPath;

/**
 * 提取的视频帧数，自动根据视频长度均匀获取 (mExtractFrameCount 和 mExtractFrameInterval 都设置时 优先使用mExtractFrameCount)
 */
@property (nonatomic, assign) NSUInteger extractFrameCount;

/**
 * 提取帧的时间间隔 (单位：s) 张数不固定
 */
@property (nonatomic, assign) CGFloat extractFrameTimeInterval;

/**
 输出的图片尺寸，不设置则按视频宽高比例计算
 注意：要得到清晰图像，需要宽高分别乘以 [UIScreen mainScreen].scale。
 */
@property (nonatomic, assign) CGSize outputMaxImageSize;

/**
 是否需要精确时间帧获取图片, 默认NO
 @since 2.2.0
 */
@property (nonatomic, assign) BOOL isAccurate;

/**
 同步提取视频帧
 @return 视频帧数据列表
 */
- (NSArray<UIImage *> *)extractImageList;

/**
 *  异步获取视频帧
 */
- (void)asyncExtractImageList:(TuSDKVideoImageExtractorBlock)handler;
- (void)asyncExtractImageWithHandler:(TuSDKVideoImageExtractorStepImageBlock)handler;

/**
 同步获取指定时间的视频帧
 
 @param time 帧所在时间
 @return 视频帧
 */
- (UIImage *)frameImageAtTime:(CMTime)time;

@end
