//
//  CameraNormalFilterListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/11/14.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"
#import "HorizontalListItemView.h"


@protocol CameraNormalFilterListViewDelegate <NSObject>

@optional
/**
 普通滤镜列表滑动到右侧
 */
- (void)tuCameraNormalViewScrollToViewRight;

/**
 普通滤镜列表滑动到左侧
 */
- (void)tuCameraNormalViewScrollToViewLeft;

@end

/**
 相机普通滤镜列表
 */
@interface CameraNormalFilterListView : HorizontalListView

@property (nonatomic, weak) id<CameraNormalFilterListViewDelegate> delegate;

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

