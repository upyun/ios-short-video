//
//  TextPageControl.h
//  ControllerSlider
//
//  Created by bqlin on 2018/6/14.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>

// 动画时长
static const NSTimeInterval kAnimationDuration = 0.25;

/**
 页面切换控件
 */
@interface TextPageControl : UIControl

/**
 标题数组
 */
@property (nonatomic, strong) NSArray *titles;

/**
 标题字体
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 常态颜色
 */
@property (nonatomic, strong) UIColor *normalColor;

/**
 选中颜色
 */
@property (nonatomic, strong) UIColor *selectedColor;

/**
 标题间隔
 */
@property (nonatomic, assign) CGFloat titleSpacing;

/**
 选中索引
 */
@property (nonatomic, assign) NSInteger selectedIndex;

@end
