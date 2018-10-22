//
//  FilterParamItemView.h
//  TuSDKVideoDemo
//
//  Created by wen on 22/08/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterParamItemView;

/**
 FilterParamItemView 代理方法
 */
@protocol FilterParamItemViewDelegate <NSObject>

/**
 参数改变时的回调
 */
- (void)filterParamItemView:(FilterParamItemView *)filterParamItemView changedProgress:(CGFloat)progress;

@end


/**
 滤镜参数调节栏
 */
@interface FilterParamItemView : UIView

@property (nonatomic, assign) id<FilterParamItemViewDelegate> itemDelegate;
// 记录参数的 key
@property (nonatomic, strong) NSString *paramKey;
// 记录当前 progress
@property (nonatomic, assign) CGFloat progress;
// 控件主色调
@property (nonatomic, strong) UIColor *mainColor;


/**
 初始化调节栏视图的方法

 @param title 调节栏显示名称
 @param progress 初始显示progress
 */
- (void)initParamViewWith:(NSString *)title originProgress:(CGFloat)progress;

@end
