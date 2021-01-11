//
//  TextColorMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TextColorMenuView;

@protocol TextColorMenuViewDelegate <NSObject>

@optional

/**
 颜色变更回调

 @param menu 文字菜单视图
 @param color 字体颜色
 */
- (void)menu:(TextColorMenuView *)menu didChangeTextColor:(UIColor *)color;

@end

/**
 文字颜色菜单视图
 */
@interface TextColorMenuView : UIView

@property (nonatomic, weak) id<TextColorMenuViewDelegate> delegate;

@property (nonatomic)CGFloat colorProgress;

@end
