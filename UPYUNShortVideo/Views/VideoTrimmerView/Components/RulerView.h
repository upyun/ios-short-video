//
//  RulerView.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 标尺视图
 */
@interface RulerView : UIView

/**
 主题颜色
 */
@property (nonatomic, strong) UIColor *themeColor;

/**
 刻度单位间隔，单位秒，不设置则按照时长自动梯度递增
 */
@property (nonatomic, assign) NSTimeInterval scaleInterval;

/**
 左缩进
 */
@property (nonatomic, assign) CGFloat leftMargin;

/**
 右缩进
 */
@property (nonatomic, assign) CGFloat rightMargin;

/**
 时长
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end
