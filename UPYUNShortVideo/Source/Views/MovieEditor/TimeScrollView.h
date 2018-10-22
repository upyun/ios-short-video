//
//  TimeScrollView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/8/2.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeScrollView;

/**
 时间特效列表回调接口
 */
@protocol TimeScrollViewDelegate <NSObject>

@optional
/**
 选中回调
 */
- (void)timeScrollView:(TimeScrollView *)timeScrollView didSelectedIndex:(NSInteger)index;

@end

/**
 时间特效列表
 */
@interface TimeScrollView : UIView

/// 时间特效回调代理
@property (nonatomic, weak) id<TimeScrollViewDelegate> delegate;

/// 时间特效选中索引
@property (nonatomic, assign) NSInteger selectedIndex;

@end
