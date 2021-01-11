//
//  PanControl.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/13.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "PanControl.h"

@interface PanControl ()

/**
 位移
 */
@property (nonatomic, assign) CGPoint translation;

/**
 开始滑动点
 */
@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation PanControl

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self panControl_commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self panControl_commonInit];
    }
    return self;
}

- (void)panControl_commonInit {
    self.backgroundColor = [UIColor clearColor];
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:gestureRecognizer];
    _pan = gestureRecognizer;
}

/**
 滑动手势事件

 @param sender 滑动手势
 */
- (void)panAction:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint translationInView = [sender translationInView:self.superview];
        self.startPoint = CGPointMake(roundf(translationInView.x), translationInView.y);
        
        if ([self.delegate respondsToSelector:@selector(controlDidBeginPan:)]) {
            [self.delegate controlDidBeginPan:self];
        }
    } else if (sender.state == UIGestureRecognizerStateChanged) {

        CGPoint translation = [sender translationInView:self.superview];

        if (self.frame.origin.x <=0 && translation.x <0) return;        
        self.translation = CGPointMake(roundf(self.startPoint.x + translation.x),
                                       roundf(self.startPoint.y + translation.y));
        
        if ([self.delegate respondsToSelector:@selector(controlPaning:)]) {
            [self.delegate controlPaning:self];
        }
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        if ([self.delegate respondsToSelector:@selector(controlDidEndPan:)]) {
            [self.delegate controlDidEndPan:self];
        }
    }
}

@end
