//
//  HorizontalListItemView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HorizontalListItemView;

@protocol HorizontalListItemViewDelegate <NSObject>

@optional

/**
 按下回调
 */
- (void)itemViewDidTouchDown:(HorizontalListItemView *)itemView;

/**
 抬起回调
 */
- (void)itemViewDidTouchUp:(HorizontalListItemView *)itemView;

/**
 点击回调
 */
- (void)itemViewDidTap:(HorizontalListItemView *)itemView;

@end

/**
 水平方向列表项视图，标题在下方内侧
 */
@interface HorizontalListItemView : UIView

/**
 缩略图视图
 */
@property (nonatomic, strong) UIImageView *thumbnailView;

/**
 标题标签
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/**
 选中图片视图
 */
@property (nonatomic, strong, readonly) UIImageView *selectedImageView;

@property (nonatomic, strong, readonly) UIButton *touchButton;

/**
 点击次数
 */
@property (nonatomic, assign, readonly) NSInteger tapCount;

/**
 最大点击次数，默认为 1，tapCount 大于该值则切换对未选中状态，并归零 tapCount；若设置为 -1，则不归零 tapCount
 */
@property (nonatomic, assign) NSInteger maxTapCount;

/**
 禁止选中
 */
@property (nonatomic, assign) BOOL disableSelect;

/**
 选中状态
 */
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, weak) id<HorizontalListItemViewDelegate> delegate;

/**
 tapCount 与选中状态同步

 @param selected 是否选中
 */
- (void)setTapCountWithSelected:(BOOL)selected;

/**
 创建禁用列表项
 */
+ (instancetype)disableItemView;

/**
 便利创建对象

 @param image 缩略图
 @param title 标题
 @return HorizontalListItemView 对象
 */
+ (instancetype)itemViewWithImage:(UIImage *)image title:(NSString *)title;

#pragma mark - rewrite

- (void)commonInit;

@end
