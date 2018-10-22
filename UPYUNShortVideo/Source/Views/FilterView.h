//
//  FilterView.h
//  ImageArrTest
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

//滤镜栏事件代理
@protocol FilterViewEventDelegate <NSObject>
/**
 滤镜栏当前滤镜的参数栏改变时进行通知 执行 submit 方法
 */
- (void)filterViewParamChanged;

/**
 点击选择新滤镜

 @param filterCode 选中滤镜的code
 */
- (void)filterViewSwitchFilterWithCode:(NSString *)filterCode;

@end



/**
 滤镜栏
 */
@interface FilterView : UIView

// 滤镜事件的代理
@property (nonatomic, assign) id<FilterViewEventDelegate> filterEventDelegate;
// 当前选中的滤镜的tag值 基于200
@property (nonatomic, assign) NSInteger currentFilterTag;
// 是否隐藏大眼、瘦脸参数调节UI   YES：若存在该参数，则不显示
@property (nonatomic, assign) BOOL isHiddenEyeChinParam;
// 是否屏蔽磨皮参数的单独调节UI  YES：磨皮参数不单独显示，归类为滤镜参数中    默认：NO
@property (nonatomic, assign) BOOL isHiddenSmoothingParamSingleAdjust;
// 美颜参数调节 view 包含 磨皮、大眼、瘦脸
@property (nonatomic, strong) UIView *beautyParamView;
// 滤镜选择 View
@property (nonatomic, strong) UIView *filterChooseView;

//根据滤镜数组创建滤镜view
- (void)createFilterWith:(NSArray *)filterArr;

/**
 改变滤镜后，需重新设置滤镜参数栏view

 @param filterDescription 当前滤镜的code
 @param args 当前滤镜的参数数组
 */
- (void)refreshAdjustParameterViewWith:(NSString *)filterDescription filterArgs:(NSArray<TuSDKFilterArg *> *)args;

@end

