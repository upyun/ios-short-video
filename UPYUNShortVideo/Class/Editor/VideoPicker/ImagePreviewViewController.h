//
//  ImagePreviewViewController.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/6/17.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "BaseNavigationViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PHAsset, AVAsset;

@interface ImagePreviewViewController : BaseNavigationViewController

/**
 播放的视频
 */
@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, strong) PHAsset *phAsset;

/**
 选中索引
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 禁止选中
 */
@property (nonatomic, assign) BOOL disableSelect;

/**
 添加按钮的事件回调
 */
@property (nonatomic, copy) void (^addButtonActionHandler)(ImagePreviewViewController *previewViewController, UIButton *sender);

@end

NS_ASSUME_NONNULL_END
