//
//  ImageStickerEditor.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/4/22.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

@protocol StickerEditorItem;
@protocol StickerEditorDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 文字贴纸+图片贴纸编辑器容器
 */
@interface StickerEditor : NSObject

/**
 初始化

 @param holderView 持有者视图 
 @return ImageStickerEditor
 */
- (instancetype)initWithHolderView:(UIView *)holderView;

/**
 当前已被添加的贴纸项
 */
@property (nonatomic,readonly) NSArray<UIView<StickerEditorItem> *> *items;

/**
 委托事件
 */
@property (nonatomic, weak) id<StickerEditorDelegate> delegate;

/**
 内如区域
 */
@property (nonatomic,readonly)UIView *contentView;

/**
 添加一个Item

 @param item 贴纸项
 */
- (void)addItem:(UIView<StickerEditorItem> *)item;

/**
 移除一个Item
 
 @param item 贴纸项
 */
- (void)removeItem:(UIView<StickerEditorItem> *)item;

/**
 根据 tag 查找 item

 @param tag 标签
 @return UIView<StickerEditorItem> *
 */
- (UIView<StickerEditorItem> *)itemByTag:(NSInteger)tag;

/**
 移除所有贴纸项
 */
- (void)removeAllItems;


/**
 显示指定索引的贴纸

 @param index 贴纸索引
 */
- (void)selectWithIndex:(NSUInteger)index;

/**
 根据 time 显示匹配的item

 @param time 时间
 */
- (void)showItemByTime:(CMTime)time;

/**
 取消选中所有贴纸
 */
- (void)cancelSelectedAllItems;

/**
 *  获取贴纸处理结果
 *
 *  @param regionRect 图片选区范围
 *
 *  @return 贴纸处理结果
 */
- (NSArray<id<TuSDKMediaEffect>> *)resultsWithRegionRect:(CGRect)regionRect;


@end

#pragma mark - StickerEditorDelegate

@protocol StickerEditorDelegate <NSObject>

@required
/**
 一个贴纸项被添加
 
 @param editor 视频编辑器
 @param item 贴纸项
 */
- (void)imageStickerEditor:(StickerEditor *)editor didAddItem:(UIView<StickerEditorItem> *)item;

/**
 一个贴纸项被移除

 @param editor 视频编辑器
 @param item 贴纸项
 */
- (void)imageStickerEditor:(StickerEditor *)editor didRemoveItem:(UIView<StickerEditorItem> *)item;
    
/**
 一个贴纸项被选中 (触发编辑)
 
 @param editor 视频编辑器
 @param item 贴纸项
 */
- (void)imageStickerEditor:(StickerEditor *)editor didSelectedItem:(UIView<StickerEditorItem> *)item;

/**
 一个贴纸被取消选中 (触发编辑)
 
 @param editor 视频编辑器
 @param item 贴纸项
 */
- (void)imageStickerEditor:(StickerEditor *)editor didCancelSelectedItem:(UIView<StickerEditorItem> *)item;



/**
 一个帖纸的特效被更新 （需要外部移除，避免内存泄漏）

 @param editor 特效编辑器
 @param item 贴纸项
 */
- (void)imageStickerEditor:(StickerEditor *)editor updateEffectFromItem:(UIView<StickerEditorItem> *)item;

@end

#pragma mark - StickerEditorItem

/**
 贴纸编辑器Item
 每个 Item 表示为一个贴纸特效
 */
@protocol StickerEditorItem <NSObject>

/**
 初始化
 
 @param editor StickerEditor
 @return StickerEditorItem
 */
- (instancetype)initWithEditor:(StickerEditor *)editor;

/**
 *  图片视图
 */
@property (nonatomic,weak,readonly) StickerEditor *stickerEditor;

/**
 获取 StickerEditorItem 生成的 effect
 */
@property (nonatomic) id<TuSDKMediaEffect> effect;

/**
 获取当前 tag 默认：-1  外部自定义
 */
@property (nonatomic) NSInteger tag;

/**
 当前 item 是否可以被编辑 默认 YES
 */
@property (nonatomic) BOOL editable;

/**
 当前是否已选中
 */
@property (nonatomic) BOOL selected;

/* 当前是否进行了修改编辑，默认是YES */
@property (nonatomic, assign) BOOL isChanged;

/**
 隐藏或者显示
 */
@property (nonatomic) BOOL hidden;

/**
*  获取贴纸处理结果
*
*  @param regionRect 图片选区范围
*
*  @return 贴纸处理结果
*/
- (id<TuSDKMediaEffect>)resultWithRegionRect:(CGRect)regionRect;

/**
 判断是否可以显示该特效

 @param time 特效时间
 @return true 可以触发显示
 */
- (BOOL)canDisplay:(CMTime)time;

@end


NS_ASSUME_NONNULL_END
