//
//  TextFontMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextMenuView.h"

@class TextFontMenuView;

@protocol TextFontMenuViewDelegate <NSObject>
@optional

/**
 选中字体变更回调

 @param menu 文字菜单视图
 @param font 字体
 */
- (void)menu:(TextFontMenuView *)menu didChangeFont:(UIFont *)font;

@end

/**
 字体菜单视图
 */
@interface TextFontMenuView : TextMenuView

@property (nonatomic, weak) id<TextFontMenuViewDelegate> delegate;

/**
 字体大小
 */
@property (nonatomic, assign) CGFloat fontSize;

@end
