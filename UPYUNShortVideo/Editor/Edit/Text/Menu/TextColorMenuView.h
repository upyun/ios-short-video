//
//  TextColorMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 文字颜色位置
 */
typedef NS_ENUM(NSInteger, TextColorType) {
    // 文字字体颜色
    TextColorTypeText = 0,
    // 文字背景颜色
    TextColorTypeBackground,
    // 文字描边颜色
    TextColorTypeStroke,
};

@class TextColorMenuView;

@protocol TextColorMenuViewDelegate <NSObject>

@optional

/**
 颜色变更回调

 @param menu 文字菜单视图
 @param color 字体颜色
 @param type 文字样式颜色
 */
- (void)menu:(TextColorMenuView *)menu didChangeColor:(UIColor *)color forType:(TextColorType)type;

@end

/**
 文字颜色菜单视图
 */
@interface TextColorMenuView : UIView

@property (nonatomic, weak) id<TextColorMenuViewDelegate> delegate;

@end
