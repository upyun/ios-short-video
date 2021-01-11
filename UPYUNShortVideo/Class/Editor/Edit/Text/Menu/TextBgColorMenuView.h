//
//  TextBgColorMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextBgColorMenuView;

@protocol TextBgColorMenuViewDelegate <NSObject>

@optional

/**
 背景颜色变更回调

 @param menu 背景菜单视图
 @param color 背景颜色
 */
- (void)menu:(TextBgColorMenuView *)menu didChangeBgColor:(UIColor *)color;

/**
 背景透明度变更回调
 
 @param menu 背景菜单视图
 @param alpha 透明度
 */
- (void)menu:(TextBgColorMenuView *)menu didChangeBgAlpha:(CGFloat)alpha;


@end

/**
 文字颜色菜单视图
 */
@interface TextBgColorMenuView : UIView


@property (nonatomic, weak) id<TextBgColorMenuViewDelegate> delegate;

@end
