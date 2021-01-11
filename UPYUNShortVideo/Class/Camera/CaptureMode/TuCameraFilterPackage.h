//
//  TuCameraFilterPackage.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/8/28.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuCameraFilterPackage : NSObject

/**
 *  相机滤镜配置
 *
 *  @return 相机滤镜配置
 */
+ (instancetype)sharePackage;

/**
 *  滤镜标题数组
 *  @return 滤镜标题数组
 */
- (NSArray *)titleGroupsWithComics:(BOOL)isComics;

- (NSArray *)filterGroups;
/**
 *  获取滤镜组
 *
 *  @return group 滤镜列表
 */
- (NSArray *)filterOptionsGroups;

/**
 *  获取滤镜codes组
 *
 *  @return group 滤镜codes列表
 */
- (NSArray *)filterCodesGroups;

@end

NS_ASSUME_NONNULL_END
