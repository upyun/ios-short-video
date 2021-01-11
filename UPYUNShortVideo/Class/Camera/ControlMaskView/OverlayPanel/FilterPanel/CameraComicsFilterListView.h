//
//  CameraComicsFilterListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/11/14.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"
#import "HorizontalListItemView.h"


@protocol CameraComicsFilterListViewDelegate <NSObject>

@optional
/**
 漫画滤镜列表滑动到右侧
 */
- (void)tuCameraComicsViewScrollToViewRight;

/**
 漫画滤镜列表滑动到左侧
 */
- (void)tuCameraComicsViewScrollToViewLeft;

@end

/**
 相机漫画滤镜列表
 */
@interface CameraComicsFilterListView : HorizontalListView

@property (nonatomic, weak) id<CameraComicsFilterListViewDelegate> delegate;

/**
 滤镜码
 */
@property (nonatomic, strong) NSArray *filterCodes;

/**
 选中的滤镜码
 */
@property (nonatomic, copy) NSString *selectedFilterCode;

/**
 滤镜项点击回调
 */
@property (nonatomic, copy) void (^itemViewTapActionHandler)(HorizontalListItemView *filterListView, HorizontalListItemView *selectedItemView, NSString *filterCode);

@end
