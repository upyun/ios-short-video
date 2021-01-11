//
//  TopNavigationBar.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TopNavigationBar.h"

@interface TopNavigationBar ()

@end

@implementation TopNavigationBar

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
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_backButton];
    _backButton.tintColor = [UIColor whiteColor];
    [_backButton setImage:[UIImage imageNamed:@"edit_nav_ic_back"] forState:UIControlStateNormal];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_rightButton];
    _rightButton.tintColor = [UIColor whiteColor];
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    CALayer *rightButtonLayer = _rightButton.layer;
    rightButtonLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    rightButtonLayer.cornerRadius = 2;
    rightButtonLayer.masksToBounds = YES;
}

- (void)layoutSubviews {
    CGRect safeBounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
    }
    
    CGFloat backButtonWidth = 42;
    _backButton.frame =
    CGRectMake(CGRectGetMinX(safeBounds), (CGRectGetHeight(safeBounds) - backButtonWidth) / 2 + CGRectGetMinY(safeBounds),
               backButtonWidth, backButtonWidth);
    
    [self.rightButton sizeToFit];
    CGSize rightButtonCompactSize = self.rightButton.bounds.size;
    CGFloat rightButtonWidth = rightButtonCompactSize.width + 20;
    CGFloat rightButtonHeight = 30;
    _rightButton.frame =
    CGRectMake(CGRectGetMaxX(safeBounds) - rightButtonWidth - 10,
               (CGRectGetHeight(safeBounds) - rightButtonHeight) / 2 + CGRectGetMinY(safeBounds),
               rightButtonWidth, rightButtonHeight);
}

@end
