//
//  SegmentButton.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 分段按钮样式
 */
typedef NS_ENUM(NSInteger, SegmentButtonStyle) {
    // 普通矩形按钮
    SegmentButtonStylePlain,
    // 遮罩式按钮
    SegmentButtonStyleSlideMask
};

/**
 分段按钮
 */
@interface SegmentButton : UIControl


/**
 样式
 */
@property (nonatomic, assign) SegmentButtonStyle style;

/**
 标题
 */
@property (nonatomic, strong) NSArray<NSString *> *buttonTitles;

/**
 圆角半径
 */
@property (nonatomic, assign) CGFloat cornerRadius;


/**
 选中背景色
 */
@property (nonatomic, strong) UIColor *selectedBackgroundColor;

/**
 字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 选中索引
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 通用初始化配置
 */
- (void)commonInit;

/**
 设置标题颜色

 @param color 标题颜色
 @param state 控制状态
 */
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;

/**
 播放的速度: 0.5     0.7    1     1.5     2.0
 */
- (float)getSpeed;

@end
