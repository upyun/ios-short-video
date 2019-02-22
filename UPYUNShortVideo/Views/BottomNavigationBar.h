//
//  BottomNavigationBar.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 底部自定义导航栏
 */
@interface BottomNavigationBar : UIView

/**
 左侧按钮
 */
@property (nonatomic, strong, readonly) UIButton *leftButton;

/**
 右侧按钮
 */
@property (nonatomic, strong, readonly) UIButton *rightButton;

/**
 标题视图
 */
@property (nonatomic, strong) UIView *titleView;

/**
 标题
 */
@property (nonatomic, copy) NSString *title;

@end
