//
//  TuSDKFace.h
//  TuSDKFace
//
//  Created by Clear Hu on 16/3/10.
//  Copyright © 2016年 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <CoreMedia/CoreMedia.h>
#import "TuSDKFaceImport.h"

#pragma mark - FaceAligment
/** 人脸对齐信息 (归一百分比) */
@interface TuSDKFaceAligment : NSObject
/** 人脸区域 */
@property (nonatomic) CGRect rect;
/** 对齐信息 */
@property (nonatomic, retain) NSArray<NSValue *> *marks;

@property (nonatomic) CGFloat yaw;

@property (nonatomic) CGFloat pitch;

@property (nonatomic) CGFloat roll;
@end


#pragma mark - TuSDKFace
/**
 *  人脸检测
 */
@interface TuSDKFace : NSObject

// 人脸检测
+ (TuSDKFace *)shared;

/**
 *  检测人脸并识别
 *
 *  @param image 输入图片
 *
 *  @return 返回查找到的人脸
 */
+ (NSArray<TuSDKFaceAligment *> *)markFaceWithImage:(UIImage *)image;

/**
 *  根据人脸特征点获取三维角度
 *
 *  @param faceAligment 人脸特征
 *  @param previewSize  视图大小
 *
 *  @return 返回三维角度
 */
+ (NSDictionary *)calcFaceAngle:(TuSDKFaceAligment *)faceAligment
                           previewSize:(CGSize)previewSize;


/**
 对相机采集的帧数据检测人脸并识别

 @param yBuffer 灰度图
 @param width 宽度
 @param height 高度
 @param ori 朝向
 @param angle 设备旋转角度
 @param flip 是否水平翻转
 
 @return 返回查找到的人脸
 */
+ (NSArray<TuSDKFaceAligment *> *)markFaceWithGrayBuffer:(uint8_t *)yBuffer
                                                   width:(int)width
                                                  height:(int)height
                                                     ori:(float)ori
                                                   angle:(float)angle
                                                    flip:(BOOL)flip;
@end
