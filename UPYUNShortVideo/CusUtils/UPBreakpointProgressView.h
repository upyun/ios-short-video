//
//  UPBreakpointProgressView.h
//  UPYUNShortVideo
//
//  Created by lingang on 2018/3/28.
//  Copyright © 2018年 upyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPBreakpointProgressView : UIView


//-(instancetype)initWithFrame:(CGRect)frame MaxValue:(CGFloat)maxValue MinValue:(CGFloat)minValue;


@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;

@property (nonatomic, assign) CGFloat progress;

/// 更新进度条
- (void)updateProgress:(CGFloat)progress;
/// 更新进度条
- (void)updateProgressWithValue:(CGFloat)value;

- (void)addWithValue:(CGFloat)value;
- (void)addWithProgress:(CGFloat)progress;
- (void)removeLastPointView;



@end
