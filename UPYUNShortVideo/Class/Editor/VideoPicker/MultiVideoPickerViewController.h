//
//  MultiVideoPickerViewController.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import <Photos/Photos.h>

/**
 多视频选择器页面
 */
@interface MultiVideoPickerViewController : BaseNavigationViewController

/**
 提取的媒体类型 目前只支持图象和视频. 默认只有视频 （PHAssetMediaTypeVideo）
 PHAssetMediaTypeImage   = 1,
 PHAssetMediaTypeVideo   = 2,
 */
@property (nonatomic)NSArray<NSNumber *> *fetchMediaTypes;

/**
 最大选取个数
 */
@property (nonatomic, assign) NSUInteger maxSelectedCount;

/**
 最小选取个数
 */
@property (nonatomic, assign) NSUInteger minSelectedCount;

/**
 所有选取的视频

 @return 选中的所有视频文件的对象存放的数组
 */
- (NSArray<AVURLAsset *> *)allSelectedAssets;

/**
 选中的 PHAsset
 */
@property (nonatomic, readonly) NSArray<PHAsset *> *allSelectedPhAssets;



@end
