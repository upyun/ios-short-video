//
//  TuSDKMediaAssetTimeline.h
//  TuSDKVideo
//
//  Created by sprint on 26/06/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKMediaTimeline.h"
#import "TuSDKMediaTimeSliceEntity.h"

/**
 操作 Asset 时间轴
 @since      v3.0
 */
@interface TuSDKMediaAssetTimeline : NSObject <TuSDKMediaTimeline>

/**
 计算后的时间片段
 @since  v3.0
 */
@property (nonatomic,readonly) NSArray<TuSDKMediaTimeSliceEntity *> *finalSlices;

/**
 根据原始时间切片查找切片计算实体对象
 
 @param timeSlice 时间切片
 @return TuSDKMediaTimeSliceEntity
 
 @since      v3.0
 */
- (TuSDKMediaTimeSliceEntity *)sliceEntityWithSlice:(TuSDKMediaTimeSliceEntity *)timeSlice;

/**
 根据实际输出时间查找 TuSDKMediaTimeSliceEntity
 
 @param outputTime 输出时间
 @return TuSDKMediaTimeSliceEntity
 @since      v3.0
 */
- (TuSDKMediaTimeSliceEntity *)sliceEntityWithOutputTime:(CMTime)outputTime;

/**
 根据时间切片创建实体计算对象

 @param timeSlice 切片信息
 @return TuSDKMediaTimeSliceEntity
 @since      v3.0
 */
- (TuSDKMediaTimeSliceEntity *)createTimeSliceEngtityWithTimeSlice:(TuSDKMediaTimelineSlice *)timeSlice;

@end
