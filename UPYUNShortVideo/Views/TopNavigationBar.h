//
//  TopNavigationBar.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自定义顶部导航栏
 */
@interface TopNavigationBar : UIView

/**
 返回按钮
 */
@property (nonatomic, strong, readonly) UIButton *backButton;

/**
 右侧按钮
 */
@property (nonatomic, strong, readonly) UIButton *rightButton;

@end
