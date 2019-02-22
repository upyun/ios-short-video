//
//  ThumbView.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanControl.h"

/**
 滑块视图
 */
@interface ThumbView : PanControl

/**
 主题颜色
 */
@property (nonatomic, strong) UIColor *themeColor;

/**
 是否是左滑块，否则是右滑块
 */
@property (nonatomic, assign) BOOL left;

/**
 装饰图像
 */
@property (nonatomic, strong) UIImageView *decoratingImageView;

/**
 圆角大小
 */
@property (nonatomic, assign) CGSize cornerRadii;

@end
