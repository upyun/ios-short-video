//
//  TextStyleMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextMenuView.h"

/**
 文字样式
 */
typedef NS_ENUM(NSInteger, TextMenuStyle) {
    // 左对齐
    TextMenuStyleAlignLeft = 0,
    // 居中对齐
    TextMenuStyleAlignCenter,
    // 右对齐
    TextMenuStyleAlignRight,
    // 下划线
    TextMenuStyleUnderLine,
    // 从左到右排列
    TextMenuStyleLeftToRight,
    // 从右到左排列
    TextMenuStyleRightToLeft
};

@class TextStyleMenuView;

@protocol TextStyleMenuViewDelegate <NSObject>
@optional

/**
 文字样式变更回调

 @param menu 文字菜单视图
 @param style 文字样式
 */
- (void)menu:(TextStyleMenuView *)menu didChangeStyle:(TextMenuStyle)style;

@end

/**
 文字样式视图
 */
@interface TextStyleMenuView : TextMenuView

@property (nonatomic, weak) id<TextStyleMenuViewDelegate> delegate;

@end
