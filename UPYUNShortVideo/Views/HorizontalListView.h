//
//  HorizontalListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/28.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalListItemView.h"

@class HorizontalListView;

// 横向视图项配置 Block
typedef void(^HorizontalListItemViewConfigBlock)(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *itemView);

/**
 横向滚动列表视图
 */
@interface HorizontalListView : UIView <HorizontalListItemViewDelegate>

/**
 是否可滚动
 */
@property (nonatomic, assign) BOOL scrollEnabled;

/**
 左右缩进
 */
@property (nonatomic, assign) CGFloat sideMargin;

/**
 列表项尺寸
 */
@property (nonatomic, assign) CGSize itemSize;

/**
 列表项自动尺寸，根据列表项的内容来计算宽高
 */
@property (nonatomic, assign) BOOL autoItemSize;

/**
 列表项间隔
 */
@property (nonatomic, assign) CGFloat itemSpacing;

/**
 选中索引
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 禁用自动选中
 */
@property (nonatomic, assign) BOOL disableAutoSelect;

/**
 列表项的类型
 */
+ (Class)listItemViewClass;

- (void)commonInit;

/**
 插入列表项

 @param itemView 列表项视图
 @param index 插入索引
 */
- (void)insertItemView:(HorizontalListItemView *)itemView atIndex:(NSInteger)index;

/**
 添加列表项

 @param itemCount 列表项数量
 @param configHandler 配置处理块
 */
- (void)addItemViewsWithCount:(NSInteger)itemCount config:(HorizontalListItemViewConfigBlock)configHandler;

/**
 获取给定列表项的索引

 @param itemView 列表项
 @return 列表项索引
 */
- (NSInteger)indexOfItemView:(HorizontalListItemView *)itemView;

/**
 获取给定索引的列表项

 @param index 列表项索引
 @return 列表项
 */
- (HorizontalListItemView *)itemViewAtIndex:(NSInteger)index;

@end
