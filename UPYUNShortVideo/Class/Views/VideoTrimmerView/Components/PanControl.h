//
//  PanControl.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/13.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PanControl;

@protocol PanConrolDelegate <NSObject>

@optional

/**
 开始滑动回调
 */
- (void)controlDidBeginPan:(PanControl *)control;

/**
 滑动中回调
 */
- (void)controlPaning:(PanControl *)control;

/**
 滑动结束回调
 */
- (void)controlDidEndPan:(PanControl *)control;

@end


/**
 拖动控件
 */
@interface PanControl : UIView

@property (nonatomic, weak) id<PanConrolDelegate> delegate;

/**
 位移
 */
@property (nonatomic, readonly) CGPoint translation;

/**
 滑动手势
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;

@end
