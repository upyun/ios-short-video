//
//  APIImageVideoPickerViewController.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/5/29.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, APIImageVideoPickerSelectedAssetType) {
    // 图片
    APIImageVideoPickerSelectedAssetTypeImage,
    // 视频
    APIImageVideoPickerSelectedAssetTypeVideo,
    // 图片视频
    APIImageVideoPickerSelectedAssetTypeMix,
};


@interface APIImageVideoPickerViewController : BaseNavigationViewController


/**
 最大选取个数，默认9
 */
@property (nonatomic, assign) NSUInteger maxSelectedCount;

/**
 最小选取个数，默认1
 */
@property (nonatomic, assign) NSUInteger minSelectedCount;

/**
 最大选取图片个数，没设置取minSelectedCount 的
 */
@property (nonatomic, assign) NSUInteger maxSelectedImageCount;

/**
 最小选取图片个数
 */
@property (nonatomic, assign) NSUInteger minSelectedImageCount;

/**
 最大选取视频个数
 */
@property (nonatomic, assign) NSUInteger maxSelectedVideoCount;

/**
 最小选取视频个数
 */
@property (nonatomic, assign) NSUInteger minSelectedVideoCount;


/**
 所有选取的视频
 
 @return 选中的所有视频文件的对象存放的数组
 */
- (NSArray<AVURLAsset *> *)allSelectedAssets;

/**
 选中的 PHAsset
 */
@property (nonatomic, readonly) NSArray<PHAsset *> *allSelectedPhAssets;

/**
 选择的资源是什么
 */
@property (nonatomic, assign) APIImageVideoPickerSelectedAssetType selectedAssetType;

@end

NS_ASSUME_NONNULL_END
