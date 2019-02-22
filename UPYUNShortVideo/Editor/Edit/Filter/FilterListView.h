//
//  FilterListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/28.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"

@class FilterListView;

@protocol FilterListViewDelegate <NSObject>
@optional

/**
 滤镜码选中回调

 @param filterList 滤镜列表视图
 @param code 选中滤镜的 filterCode
 @param tapCount 点击的次数
 */
- (void)filterList:(FilterListView *)filterList didSelectedCode:(NSString *)code tapCount:(NSInteger)tapCount;

@end

/**
 滤镜列表视图
 */
@interface FilterListView : HorizontalListView

/**
 滤镜列表视图代理
 */
@property (nonatomic, weak) IBOutlet id<FilterListViewDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray *filterCodes;

/**
 根据给定的滤镜码选中滤镜列表项
 */
@property (nonatomic, copy) NSString *selectedFilterCode;

@end
