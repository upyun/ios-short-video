//
//  TopNavBar.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/27.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordVideoBottomBar.h"
#import "TuSDKFramework.h"


#define lsqLeftTopBtnFirst 0
#define lsqLeftTopBtnSecond 1

#define lsqRightTopBtnFirst 10
#define lsqRightTopBtnSecond 11

#pragma mark - TopNavBarDelegate

@class TopNavBar;
/**
 点击 底部栏 按钮时，抛出的按钮事件代理方法
 */
@protocol TopNavBarDelegate <NSObject>

@optional
/**
 左侧按钮点击事件

 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onLeftButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;

/**
 右侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onRightButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;

@end


#pragma mark - TopNavBar

@interface TopNavBar : UIView

// 点击代理
@property (nonatomic, weak) id<TopNavBarDelegate> topBarDelegate;
// title label
@property (nonatomic, strong) UILabel *centerTitleLabel;

/**
 向view添加 title、左侧系列按钮、右侧系列按钮
 
 @param title 中间显示的 title
 @param leftButtons 左侧系列按钮，参数为字符串，若为图片，请在图片名后添加图片后缀(.png或.jpg)，若无固定后缀，则显示传入的字符串
 @param rightButtons 右侧系列按钮，参数同上
 */
- (void)addTopBarInfoWithTitle:(NSString *)title leftButtonInfo:(NSArray<NSString *> *)leftButtons rightButtonInfo:(NSArray<NSString *> *)rightButtons;

/**
 改变某个按钮的是否可点击状态，以及图片
 
 @param index 是第几个按钮 左侧系列按钮依次为 0、1、2、...； 右侧按钮依次为 ...、12、11、10
 @param isLeftBtn 是否为左侧系列按钮
 @param changeImage 新的按钮图片，为 nil，则不改变图片
 @param enabled 是否可点击，YES：表示可响应点击
 */
- (void)changeBtnStateWithIndex:(NSInteger)index isLeftbtn:(BOOL)isLeftBtn withImage:(UIImage*)changeImage withEnabled:(BOOL)enabled;

@end
