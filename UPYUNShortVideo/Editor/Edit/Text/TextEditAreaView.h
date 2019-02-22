//
//  TextEditAreaView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/6.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributedLabel.h"

@class TextEditAreaView;

@protocol TextEditAreaViewDelegate <NSObject>
@optional

/**
 文字项变更回调

 @param textEditAreaView 文字编辑视图
 @param itemLabel 文本 label
 @param itemIndex 元素索引
 @param added 是否添加
 @param removed 是否移除
 */
- (void)textEditAreaView:(TextEditAreaView *)textEditAreaView didUpdateItem:(AttributedLabel *)itemLabel itemIndex:(NSInteger)itemIndex added:(BOOL)added removed:(BOOL)removed;

/**
 选中文字项回调

 @param textEditAreaView 文字编辑视图
 @param selectedIndex 选中索引
 @param itemLabel 文本 label
 */
- (void)textEditAreaView:(TextEditAreaView *)textEditAreaView didSelectIndex:(NSInteger)selectedIndex itemLabel:(AttributedLabel *)itemLabel;

/**
 文字项编辑回调

 @param textEditAreaView 文字编辑区域
 @param itemLabel 文字 label
 */
- (void)textEditAreaView:(TextEditAreaView *)textEditAreaView shouldEditItem:(AttributedLabel *)itemLabel;

@end

/**
 文字编辑区域视图
 */
@interface TextEditAreaView : UIView

@property (nonatomic, weak) id<TextEditAreaViewDelegate> delegate;

/**
 选中索引
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 文字项数量
 */
@property (nonatomic, assign, readonly) NSInteger textEditItemCount;

/**
 视频原始展示与编辑文字界面大小比例
 */
@property (nonatomic, assign) CGFloat textScale;

/**
 添加默认文字项
 */
- (void)addDefaultTextEditItem;

/**
 添加文本 label

 @param textLabel 文本标签
 */
- (void)addTextEditItem:(AttributedLabel *)textLabel;

/**
 显示/隐藏给定索引对应的文字项

 @param index 索引
 @param hidden  显示/隐藏状态
 @param animated 是否动画更新
 */
- (void)setTextItemAtIndex:(NSInteger)index hidden:(BOOL)hidden animated:(BOOL)animated;

/**
 根据给定的时间显示或隐藏给定索引的文字项

 @param time 时间
 @param index 文字项索引
 @param animated 是否动画更新
 */
- (void)showTextItemAtTime:(CMTime)time index:(NSInteger)index animated:(BOOL)animated;

/**
 获取指定索引的文字

 @param index 文字项索引
 @return 文本标签
 */
- (AttributedLabel *)itemLabelAtIndex:(NSInteger)index;

/**
 隐藏所有文字项
 */
- (void)hideAllTextItems;

@end
