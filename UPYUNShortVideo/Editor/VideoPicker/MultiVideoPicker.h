//
//  MultiVideoPicker.h
//  MultiVideoPicker
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVURLAsset, PHAsset, MultiVideoPicker;

@protocol MultiVideoPickerDelegate <NSObject>
@optional

/**
 点击单元格事件回调

 @param picker 多视频选择器
 @param indexPath 点击的 NSIndexPath 对象
 @param phAsset 对应的 PHAsset 对象
 */
- (void)picker:(MultiVideoPicker *)picker didTapItemWithIndexPath:(NSIndexPath *)indexPath phAsset:(PHAsset *)phAsset;

/**
 目标项是否可选中
 
 @param picker 多视频选择器
 @param indexPath 目标 indexPath
 @return 目标项是否可选中
 */
- (BOOL)picker:(MultiVideoPicker *)picker shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 目标项是否可取消选中
 
 @param picker 多视频选择器
 @param indexPath 目标 indexPath
 @return 目标项是否可取消选中
 */
- (BOOL)picker:(MultiVideoPicker *)picker shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

@end


/**
 多视频选择器
 */
@interface MultiVideoPicker : UICollectionViewController

/**
 所有选中的视频
 */
@property (nonatomic, strong, readonly) NSArray<AVURLAsset *> *allSelectedAssets;

/**
 选中视频总时长
 */
@property (nonatomic, assign, readonly) NSTimeInterval selectedVideosDutation;

/**
 iCloud 请求中
 */
@property (nonatomic, assign, readonly) BOOL requesting;

/**
 是否禁止选择
 */
@property (nonatomic, assign, readonly) BOOL disableSelect;

/**
 是否禁止多选
 */
@property (nonatomic, assign) BOOL disableMultipleSelection;

@property (nonatomic, weak) id<MultiVideoPickerDelegate> delegate;

/**
 按索引获取 PHAsset
 
 @param indexPathItem 索引
 @return 索引对应的视频对象
 */
- (PHAsset *)phAssetAtIndexPathItem:(NSInteger)indexPathItem;

/**
 给定 indexPath 的选中索引，若该 indexPath 没有选中，则返回 -1

 @param indexPath 索引的路径
 @return 索引
 */
- (NSInteger)selectedIndexForIndexPath:(NSIndexPath *)indexPath;

/**
 设置给定的 phAsset、indexPath 选中状态

 @param phAsset 视频文件的对象
 @param indexPath 索引的路径
 @param selected 是否选择
 */
- (void)setPhAsset:(PHAsset *)phAsset indexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

+ (instancetype)picker;

@end
