//
//  StickerPanelView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BasePropsPanelView.h"
#import "OverlayViewProtocol.h"
#import "PropsItemCategory.h"

@class PropsPanelView, TuSDKPFStickerGroup;

#pragma mark - PropsPanelViewDelegate
@protocol PropsPanelViewDelegate <NSObject>
@optional

/**
 道具选中回调，若为在线道具，则在下载结束后回调

 @param propsPanel 道具视图
 @param propsItem 道具
 */
- (void)propsPanel:(PropsPanelView *)propsPanel didSelectPropsItem:(__kindof PropsItem *)propsItem;

/**
 取消选择某个分类道具

 @param propsPanel 道具视图
 @param propsItemCategory 道具分类
 */
- (void)propsPanel:(PropsPanelView *)propsPanel unSelectPropsItemCategory:(__kindof PropsItemCategory *)propsItemCategory;

/**
 道具选中回调，若为在线道具，则在下载结束后回调
 
 @param propsPanel 道具视图
 @param propsItem 道具
 */
- (void)propsPanel:(PropsPanelView *)propsPanel didRemovePropsItem:(__kindof PropsItem *)propsItem;

@end

#pragma mark - PropsPanelView

/**
 道具面板，处理了道具数据显示、下载与选中回调
 */
@interface PropsPanelView : BasePropsPanelView <OverlayViewProtocol>

/**
分类列表
 */
@property (nonatomic, strong) NSArray<PropsItemCategory *> *categorys;

/**
 触发者
 */
@property (nonatomic, weak) UIControl *sender;

/**
 相机道具视图代理
 */
@property (nonatomic, weak) id<PropsPanelViewDelegate> delegate;

/**
 重新加载视图
 */
- (void)reloadPanelView:(TuSDKMediaEffectDataType)effectType;

@end
