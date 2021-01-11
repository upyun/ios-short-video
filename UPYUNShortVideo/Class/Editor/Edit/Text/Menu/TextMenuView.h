//
//  TextMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 文字菜单项控件
 */
@interface MenuItemControl : UIControl

/**
 缩略图视图
 */
@property (nonatomic, strong) UIView *iconView;

/**
 文字标签
 */
@property (nonatomic, strong, readonly) UILabel *textLabel;

/**
 缩略图与文字标签间隔
 */
@property (nonatomic, assign) CGFloat spacing;

@end

/**
 文字菜单视图基类
 */
@interface TextMenuView : UIView

/**
  菜单项大小
 */
@property (nonatomic, assign) CGSize itemSize;

/**
 菜单间距
 */
@property (nonatomic, assign) CGFloat itemSpacing;

/**
 滚动视图
 */
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

/**
 菜单项视图数组
 */
@property (nonatomic, strong) NSArray<UIView *> *menuItemViews;

/**
 选中索引
 */
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)commonInit;

@end
