//
//  MaskLayer.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "MaskLayer.h"

@implementation MaskLayer

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentsScale = [UIScreen mainScreen].scale;
    self.fillRule = kCAFillRuleEvenOdd;
    self.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
}

- (void)setMaskRect:(CGRect)maskRect {
    _maskRect = maskRect;
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathAddRect(mPath, NULL, self.bounds);
    CGPathAddRect(mPath, NULL, maskRect);
    self.path = mPath;
}

@end

@implementation BorderLayer

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentsScale = [UIScreen mainScreen].scale;
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = [UIColor whiteColor].CGColor;
}

- (void)setBorderRect:(CGRect)borderRect {
    if (CGRectEqualToRect(_borderRect, borderRect)) return;
    _borderRect = borderRect;
    borderRect = CGRectInset(borderRect, -self.lineWidth / 2.0, -self.lineWidth / 2.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:borderRect];
    self.path = path.CGPath;
}

@end
