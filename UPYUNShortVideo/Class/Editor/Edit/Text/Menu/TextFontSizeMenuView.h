//
//  TextFontSizeMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextFontSizeMenuView;

@protocol TextFontSizeMenuViewDelegate <NSObject>

@optional

/**
 字体大小变更回调

 @param menu 菜单视图
 @param fontSize 字体大小
 */
- (void)menu:(TextFontSizeMenuView *)menu didChangeFontSize:(CGFloat)fontSize;


@end

/**
 文字颜色菜单视图
 */
@interface TextFontSizeMenuView : UIView

/** 默认字体 默认：24 */
@property (nonatomic)CGFloat defaultFontSize;
@property (nonatomic)CGFloat maxFontSize;


/** 设置当前字体 */
@property (nonatomic)CGFloat fontSize;


@property (nonatomic, weak) id<TextFontSizeMenuViewDelegate> delegate;

@end
