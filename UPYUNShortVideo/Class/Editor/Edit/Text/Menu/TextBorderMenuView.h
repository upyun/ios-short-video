//
//  TextBorderMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextBorderMenuView;

@protocol TextBorderMenuViewDelegate <NSObject>

@optional

/**
 颜色变更回调

 @param menu 菜单视图
 @param color 边框颜色
 */
- (void)menu:(TextBorderMenuView *)menu didChangeBorderColor:(UIColor *)color;

/**
 边框变更回调
 
 @param menu 菜单视图
 @param borderSize 边框大小
 */
- (void)menu:(TextBorderMenuView *)menu didChangeBorderSize:(CGFloat)borderSize;

@end

/**
 文字颜色菜单视图
 */
@interface TextBorderMenuView : UIView

@property (nonatomic, weak) id<TextBorderMenuViewDelegate> delegate;

/**
 文字边框宽度
 */
@property (nonatomic) CGFloat strokeWidth;

@end
