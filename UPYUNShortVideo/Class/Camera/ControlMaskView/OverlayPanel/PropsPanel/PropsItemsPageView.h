//
//  StickerCategoryPageView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PropsItemsPageView, PropsItemCollectionCell;


#pragma mark - StickerCategoryPageViewDataSource

@protocol PropsItemsPageViewDataSource <NSObject>

/**
 当前分类页面的道具个数

 @param pageView 道具分类展示视图
 @return 当前分类页面道具个数
 */
- (NSInteger)numberOfItemsInCategoryPageView:(PropsItemsPageView *)pageView;

/**
 配置当前分类下每个道具单元格

 @param pageView 道具分类展示视图
 @param cell 道具按钮
 @param index 按钮索引
 */
- (void)propsItemsPageView:(PropsItemsPageView *)pageView setupStickerCollectionCell:(PropsItemCollectionCell *)cell atIndex:(NSInteger)index;

@end

#pragma mark - StickerCategoryPageViewDelegate

@protocol PropsItemsPageViewDelegate <NSObject>
@optional

/**
 道具单元格单击选中回调

 @param pageView 道具分类展示视图
 @param cell 道具按钮
 @param index 按钮索引
 */
- (void)propsItemsPageView:(PropsItemsPageView *)pageView didSelectCell:(PropsItemCollectionCell *)cell atIndex:(NSInteger)index;

/**
 询问是否可以删除道具物品
 
 @param pageView 道具分类展示视图
 @param indexPath 按钮索引
 */
- (BOOL)propsItemsPageView:(PropsItemsPageView *)pageView canDeleteButtonAtIndex:(NSIndexPath *)indexPath;

/**
 道具单元格点击删除按钮回调

 @param pageView 道具分类展示视图
 @param index 按钮索引
 */
- (void)propsItemsPageView:(PropsItemsPageView *)pageView didTapDeleteButtonAtIndex:(NSInteger)index;

@end

#pragma mark - StickerCollectionCell

/**
 道具单元格
 */
@interface PropsItemCollectionCell : UICollectionViewCell

/**
 缩略图
 */
@property (nonatomic, strong, readonly) UIImageView *thumbnailView;

/**
 加载视图
 */
@property (nonatomic, strong, readonly) UIActivityIndicatorView *loadingView;

/**
 下载图标视图
 */
@property (nonatomic, strong, readonly) UIImageView *downloadIconView;

/**
 删除按钮
 */
@property (nonatomic, strong, readonly) UIButton *deleteButton;

/**
 是否为在线道具
 */
@property (nonatomic, assign) BOOL online;

/**
 切换至载入中状态
 */
- (void)startLoading;

/**
 结束载入中状态
 */
- (void)finishLoading;

@end

#pragma mark - StickerCategoryPageView

/**
 道具视图
 */
@interface PropsItemsPageView : UIView <UICollectionViewDataSource>

/**
 道具 CollectionView
 */
@property (nonatomic, strong, readonly) UICollectionView *itemCollectionView;

/**
 数据源委托
 */
@property (nonatomic, weak) id<PropsItemsPageViewDataSource> dataSource;

/**
 事件委托
 */
@property (nonatomic, weak) id<PropsItemsPageViewDelegate> delegate;

/**
 选中索引
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 当前页面索引
 */
@property (nonatomic, assign) NSInteger pageIndex;

/**
 隐藏删除按钮
 */
- (void)dismissDeleteButtons;

/**
 取消选中
 */
- (void)deselect;

@end
