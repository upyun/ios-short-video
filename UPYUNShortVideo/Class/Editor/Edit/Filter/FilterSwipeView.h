//
//  FilterSwipeView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/10/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterSwipeView;

@protocol FilterSwipeViewDelegate <NSObject>
@optional

/**
 响应手势滑动时回调

 @param filterSwipeView 滤镜滑动切换视图
 @param filterCode 即将切换到的滤镜码
 @return 是否更新显示的滤镜名称
 */
- (BOOL)filterSwipeView:(FilterSwipeView *)filterSwipeView shouldChangeFilterCode:(NSString *)filterCode;

@end

/**
 滤镜滑动切换视图
 */
@interface FilterSwipeView : UIView

/**
 滤镜名称标签
 */
@property (nonatomic, strong, readonly) UILabel *filterNameLabel;

/**
 当前显示的滤镜 code
 */
@property (nonatomic, copy) NSString *currentFilterCode;

@property (nonatomic, weak) IBOutlet id<FilterSwipeViewDelegate> delegate;

@end
