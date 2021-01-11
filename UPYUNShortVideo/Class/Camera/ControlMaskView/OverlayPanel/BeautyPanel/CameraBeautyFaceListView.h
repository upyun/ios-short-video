//
//  CameraBeautyFaceListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/9/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"
#import "HorizontalListItemView.h"

/**
 微整形列表视图
 */
@interface CameraBeautyFaceListView : HorizontalListView

/**
 微整形配置项
 */
@property (nonatomic, strong, readonly) NSArray<NSString *> *faceFeatures;

/**
 选中的微整形配置项
 */
@property (nonatomic, copy) NSString *selectedFaceFeature;

/**
 配置项点击回调
 */
@property (nonatomic, copy) void (^itemViewTapActionHandler)(CameraBeautyFaceListView *listView, HorizontalListItemView *selectedItemView, NSString *faceFeature);

@end
