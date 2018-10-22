//
//  StickerTextStyleAdjustView.h
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright © 2018 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

typedef NS_ENUM(NSInteger, TuSDKPFEditTextStyleType)
{
    // 文字方向从左到右
    TuSDKPFEditTextStyleType_LeftToRight = 0,
    // 文字方向从右到左
    TuSDKPFEditTextStyleType_RightToLeft,
    // 文字有下划线
    TuSDKPFEditTextStyleType_Underline,
    // 文字左对齐
    TuSDKPFEditTextStyleType_AlignmentLeft,
    // 文字右对齐
    TuSDKPFEditTextStyleType_AlignmentRight,
    // 文字居中
    TuSDKPFEditTextStyleType_AlignmentCenter,
};

#pragma mark - TuSDKPFEditTextStyleAdjustDelegate

/**
 样式选择View代理
 @since     v2.2.0
 */
@protocol StickerTextStyleAdjustDelegate <NSObject>

@optional
/**
 选中某样式
 @param styleIndex 选中的样式下标
 @since     v2.2.0
 */
- (void)onSelectStyle:(TuSDKPFEditTextStyleType)styleType;

@end

#pragma mark - TuSDKPFEditTextStyleAdjustView

/**
 * 样式选择视图类
 * @since     v2.2.0
 */
@interface StickerTextStyleAdjustView : UIView

/**
 代理对象
 @since    v2.2.0
 */
@property (nonatomic, weak) id<StickerTextStyleAdjustDelegate> styleDelegate;

/**
 样式图标数组
 @since   v2.2.0
 */
@property (nonatomic, strong) NSArray<NSNumber *> *styleImageNames;
//

/**
 整体内边距设置 默认 (10,20,10,20)
 @since  v2.2.0
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end
