//
//  BottomButtonView.h
//  TuSDKVideoDemo
//
//  Created by wen on 21/08/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - BottomButtonViewDelegate

@class BottomButtonView;

/**
 BottomButtonView 事件代理
 */
@protocol BottomButtonViewDelegate <NSObject>

// 点击事件的回调
- (void)bottomButton:(BottomButtonView *)bottomButtonView clickIndex:(NSInteger)index;

@end


#pragma mark - BottomButtonView

/**
 底部按钮统一控件
 */
@interface BottomButtonView : UIButton

@property (nonatomic, weak) id<BottomButtonViewDelegate> clickDelegate;

// 选中时的 title 颜色
@property (nonatomic, strong) UIColor *selectedTitleColor;
// 未选中时 title 颜色
@property (nonatomic, strong) UIColor *normalTitleColor;
// 是否均匀排列
@property (nonatomic, assign) BOOL isEquallyDisplay;

// 创建底部按钮视图
- (void)initButtonWith:(NSArray *)normalImageNames  selectImageNames:(NSArray *)selectImageNames  With:(NSArray *)titles;

@end
