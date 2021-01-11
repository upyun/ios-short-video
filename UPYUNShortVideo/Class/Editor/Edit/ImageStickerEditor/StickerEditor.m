//
//  ImageStickerEditor.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/4/22.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "StickerEditor.h"

@interface StickerEditor()
{
    UIView *_holderView;
    UIView *_contentView;
}
@end

@implementation StickerEditor

/**
 初始化
 
 @param holderView 持有者视图
 @return ImageStickerEditor
 */
- (instancetype)initWithHolderView:(UIView *)holderView;{
    if (self = [self init]) {
        NSAssert(holderView != nil, @"请设置一个有效的 holder view");
        _holderView = holderView;
        _contentView = [[UIView alloc] initWithFrame:holderView.bounds];
        [holderView addSubview:_contentView];
        _contentView.clipsToBounds = YES;
    }
    return self;
}


- (NSArray<UIView<StickerEditorItem> *> *)items;{
    return _contentView.subviews;
}

/**
 添加一个Item
 
 @param item 贴纸项
 */
- (void)addItem:(UIView<StickerEditorItem> *)item; {
      if (!item) return;
    [_contentView addSubview:item];
    [_delegate imageStickerEditor:self didAddItem:item];

}

/**
 移除一个Item
 
 @param item 贴纸项
 */
- (void)removeItem:(UIView<StickerEditorItem> *)item; {
    if (!item) return;
    [item removeFromSuperview];
    [_delegate imageStickerEditor:self didRemoveItem:item];
}

/**
 移除所有贴纸项
 */
- (void)removeAllItems;{
    [self.items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item removeFromSuperview];
        [self->_delegate imageStickerEditor:self didRemoveItem:item];

    }];
}

/**
 根据 tag 查找 item
 
 @param tag
 @return UIView<StickerEditorItem> *
 */
- (UIView<StickerEditorItem> *)itemByTag:(NSInteger)tag;{
    
    NSArray<UIView<StickerEditorItem> *> *items = self.items;
    __block UIView<StickerEditorItem> *foundItem = nil;
    
    [items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.tag == tag){
            foundItem = item;
            *stop = YES;
        }
    }];
    
    return foundItem;
}

/**
 根据 time 显示匹配的item
 
 @param time 时间
 */
- (void)showItemByTime:(CMTime)time; {
    
    NSArray<UIView<StickerEditorItem> *> * items = self.items;

    [items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.hidden = ![item canDisplay:time];
    }];
    
}

/**
 显示指定索引的贴纸
 
 @param index 贴纸索引
 */
- (void)selectWithIndex:(NSUInteger)index;{
    NSArray<UIView<StickerEditorItem> *> * items = self.items;
    [items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.selected && index != item.tag){
            item.selected = NO;
            [self->_delegate imageStickerEditor:self didCancelSelectedItem:item];
        }else if(!item.selected && item.tag == index){
            item.selected = YES;
            [self->_delegate imageStickerEditor:self didSelectedItem:item];
        }
    }];
}


/**
 取消选中所有贴纸
 */
- (void)cancelSelectedAllItems;{

    NSArray<UIView<StickerEditorItem> *> * items = self.items;
    [items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.selected) {
            item.selected = NO;
            [self->_delegate imageStickerEditor:self didCancelSelectedItem:item];
        }
    }];
}

/**
 *  获取贴纸处理结果
 *
 *  @param regionRect 图片选区范围
 *
 *  @return 贴纸处理结果
 */
- (NSArray<id<TuSDKMediaEffect>> *)resultsWithRegionRect:(CGRect)regionRect;{
    
    NSArray<UIView<StickerEditorItem> *> * items = self.items;
    NSMutableArray<id<TuSDKMediaEffect>> *effects = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        id<TuSDKMediaEffect> effect = [item resultWithRegionRect:regionRect];
        if (effect)
            [effects addObject:effect];
    }];
    
    return effects;
}

- (void)dealloc {
//    NSLog(@"dealloc: %@", self);
    [self clearItems];
}

- (void)clearItems {
    [self.items enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item removeFromSuperview];
    }];
}

@end
