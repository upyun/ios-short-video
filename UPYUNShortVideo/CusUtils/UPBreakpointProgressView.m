//
//  UPBreakpointProgressView.m
//  UPYUNShortVideo
//
//  Created by lingang on 2018/3/28.
//  Copyright © 2018年 upyun. All rights reserved.
//

#import "UPBreakpointProgressView.h"


@interface UPBreakpointProgressView()

@property (nonatomic, strong) UIView *progressColorView;

@property (nonatomic, strong) UIView *minPointView;

@property (nonatomic, strong) NSMutableArray *pointViewList;

@end

@implementation UPBreakpointProgressView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _progressColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(frame))];
        
        _minPointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, CGRectGetHeight(frame))];
        _pointViewList = [NSMutableArray array];
        
        
        _progressColorView.backgroundColor = [UIColor blueColor];
        
        _minPointView.backgroundColor = [UIColor whiteColor];
        _minPointView.hidden = YES;
        
        [self addSubview:_progressColorView];
        [self addSubview:_minPointView];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame MaxValue:(CGFloat)maxValue MinValue:(CGFloat)minValue {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        
    }
    return self;
    
}


- (void)removeLastPointView {
    UIView *view = _pointViewList.lastObject;
    if (!view) {
        self.progress = 0;
        return;
    }
    [view removeFromSuperview];
    
    [_pointViewList removeLastObject];
    UIView *nowLastView = _pointViewList.lastObject;
    
    
    CGRect frame = CGRectMake(0, 0, 0, CGRectGetHeight(self.frame));
    if (nowLastView) {
        frame = CGRectMake(0, 0, nowLastView.frame.origin.x, CGRectGetHeight(self.frame));
    }
    
    self.progress = nowLastView.frame.origin.x/CGRectGetHeight(self.frame);
    _progressColorView.frame = frame;
}


/// 更新进度条
- (void)updateProgress:(CGFloat)progress {
    if (progress < 0 || progress > 1) {
        return;
    }
    self.progress = progress;
    
    _progressColorView.frame = CGRectMake(0, 0, progress * CGRectGetWidth(self.frame) - 1, CGRectGetHeight(self.frame));
    
}
/// 更新进度条
- (void)updateProgressWithValue:(CGFloat)value {
    CGFloat progress = value/_maxValue;
    [self updateProgress:progress];
}

- (void)addWithValue:(CGFloat)value {
    CGFloat progress = value/_maxValue;
    [self addWithProgress:progress];
}

- (void)addWithProgress:(CGFloat)progress {
    UIView *view = [self pointViewWith:progress];
    [_pointViewList addObject:view];
    
    [self addSubview:view];
    self.progress = progress;
    _progressColorView.frame = CGRectMake(0, 0, progress * CGRectGetWidth(self.frame) - 1, CGRectGetHeight(self.frame));
}

- (UIView *)pointViewWith:(CGFloat)progress {
    
    CGFloat pointProgress  = progress >= 1 ? 1:progress;
    
    
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(pointProgress * CGRectGetWidth(self.frame), 0, 1, CGRectGetHeight(self.frame))];
    pointView.backgroundColor = [UIColor whiteColor];
    return pointView;
}


- (void)setMinValue:(CGFloat)minValue {
    
    if (minValue <= 0) {
        _minPointView.hidden = YES;
        return;
    }
    _minPointView.hidden = NO;
    CGFloat progress = minValue/_maxValue;
    
    _minPointView.frame = CGRectMake(progress * CGRectGetWidth(self.frame) - 1, 0,  2, CGRectGetHeight(self.frame));
    
}




@end
