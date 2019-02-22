//
//  BaseNavigationViewController.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseViewController.h"
#import "TopNavigationBar.h"

/**
 拥有自定义顶部导航栏的视图控制器
 */
@interface BaseNavigationViewController : BaseViewController

/**
 顶部自定义导航栏
 */
@property (nonatomic, strong, readonly) TopNavigationBar *topNavigationBar;

/**
 页面内容顶部偏移，即为顶部自定义导航栏高度
 */
@property (nonatomic, assign, readonly) CGFloat topContentOffset;

/**
 导航栏右侧按钮事件回调
 */
@property (nonatomic, copy) void (^rightButtonActionHandler)(__kindof BaseNavigationViewController *controller, UIButton *sender);

/**
 导航栏右侧按钮事件

 @param sender 点击的按钮
 */
- (void)base_rightButtonAction:(UIButton *)sender;

@end
