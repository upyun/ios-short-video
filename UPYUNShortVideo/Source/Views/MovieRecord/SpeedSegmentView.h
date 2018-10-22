//
//  SpeedSegmentView.h
//  TuSDKVideoDemo
//
//  Created by wen on 2018/1/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

@class SpeedSegmentView;
#pragma mark - SpeedSegmentViewDelegate

/**
 SpeedSegmentView 点击事件代理
 */
@protocol SpeedSegmentViewDelegate <NSObject>

/**
 选择某个title的回调

 @param segmentView SpeedSegmentView对象
 @param index 当前选择的title对应的index
 */
- (void)speedSegmentView:(SpeedSegmentView *)segmentView  withIndex:(NSInteger)index;

@end

#pragma mark - SpeedSegmentView

/**
 速率选择View
 */
@interface SpeedSegmentView : UIView

/**
 title 显示数组
 */
@property (nonatomic, assign) NSArray<NSString *> *titleArr;

/**
 事件代理对象
 */
@property (nonatomic, assign) id<SpeedSegmentViewDelegate> eventDelegate;

@end
