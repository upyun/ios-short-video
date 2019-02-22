//
//  ThumbView.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "ThumbView.h"

@implementation ThumbView

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
    _themeColor = [UIColor whiteColor];
    _cornerRadii = CGSizeMake(6, 6);
    self.backgroundColor = [UIColor clearColor];
}

- (void)setDecoratingImageView:(UIImageView *)decoratingImageView {
    if (!decoratingImageView) return;
    if (_decoratingImageView) {
        [_decoratingImageView removeFromSuperview];
    }
    _decoratingImageView = decoratingImageView;
    [self addSubview:decoratingImageView];
    [decoratingImageView sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _decoratingImageView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    const CGFloat expandToWidth = 44;
    CGRect expandBounds = CGRectInset(self.bounds, -0.5 * (expandToWidth - CGRectGetWidth(self.bounds)), -10);

    return CGRectContainsPoint(expandBounds, point);
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:_cornerRadii];
    if (_left) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:_cornerRadii];
    }
    
    [path closePath];
    [self.themeColor setFill];
    [path fill];
}

@end
