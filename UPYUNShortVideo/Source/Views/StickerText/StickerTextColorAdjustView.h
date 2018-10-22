//
//  StickerTextColorAdjustView.h
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright © 2018 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

/**
 颜色选择视图类
 @since   v2.2.0
 */
#pragma mark - enum ColorType

typedef NS_ENUM(NSUInteger,TuSDKPFEditTextColorType)
{
    // 贴纸字体颜色
    TuSDKPFEditTextColorType_TextColor = 101,
    // 贴纸背景颜色
    TuSDKPFEditTextColorType_BackgroudColor,
    // 贴纸字体边框颜色
    TuSDKPFEditTextColorType_StrokeColor
};

#pragma mark - TuSDKPFEditTextColorAdjustDelegate

/**
 颜色选择View代理
 @since   v2.2.0
 */
@protocol StickerTextColorAdjustDelegate <NSObject>

@optional
/**
 选中某一颜色
 @param color 选中的颜色对象
 @since       v2.2.0
 */
- (void)onSelectColorWith:(UIColor *)color styleType:(NSUInteger)styleType;

@end

#pragma mark - TuSDKPFEditTextColorAdjustView

/**
 颜色选择器视图
 @since   v2.2.0
 */
@interface StickerTextColorAdjustView : UIView

/**
 代理对象
 @since   v2.2.0
 */
@property (nonatomic, weak) id<StickerTextColorAdjustDelegate> colorDelegate;

/**
 颜色数组
 @since   v2.2.0
 */
@property (nonatomic, strong) NSArray<NSString *> *hexColors;

/**
 边距设置 默认 (10,20,10,20)
 @since   v2.2.0
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 是否默认第一个为 clearColor
 @since   v2.2.0
 */
@property (nonatomic, assign) BOOL defaultClearColor;

/**
 颜色类别
 @since   v2.2.0
 */
@property (nonatomic, strong) NSArray<NSNumber *> *styleArr;

/**
 类别选中时的显示颜色
 @since   v2.2.0
 */
@property (nonatomic, strong) UIColor *styleSelectedColor;

/**
 类别非选中时的显示颜色
 @since   v2.2.0
 */
@property (nonatomic, strong) UIColor *styleNormalColor;

@end
