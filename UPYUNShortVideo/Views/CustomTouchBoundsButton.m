//
//  CustomTouchBoundsButton.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/9/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "CustomTouchBoundsButton.h"

@implementation CustomTouchBoundsButton

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    _targetTouchSize = CGSizeMake(44, 44);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGSize size = self.bounds.size;
    CGRect expandBounds = self.bounds;
    if (MIN(_targetTouchSize.width, _targetTouchSize.height) > MAX(size.width, size.height)) {
        expandBounds = CGRectInset(self.bounds, -0.5 * (_targetTouchSize.width - size.width), -0.5 * (_targetTouchSize.height - size.height));
    }
    return CGRectContainsPoint(expandBounds, point);
}

@end
