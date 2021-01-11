//
//  ColorSlider.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 颜色 slider
 */
@interface ColorSlider : UIControl

/**
 当前的颜色
 */
@property (nonatomic, strong) UIColor *color;

/**
 进度
 */
@property (nonatomic, assign) IBInspectable double progress;

@end
