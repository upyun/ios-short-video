//
//  BottomNavigationBar.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BottomNavigationBar.h"

@interface BottomNavigationBar ()

/**
 标题容器视图
 */
@property (nonatomic, strong) UIView *titleContainerView;

/**
 水平分割线
 */
@property (nonatomic, strong) CALayer *horizontalSeparatorLayer;

@end

@implementation BottomNavigationBar

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
    _horizontalSeparatorLayer = [CALayer layer];
    [self.layer addSublayer:_horizontalSeparatorLayer];
    _horizontalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1].CGColor;
    
    _leftButton = [self.class commonButton];
    [self addSubview:_leftButton];
    _rightButton = [self.class commonButton];
    [self addSubview:_rightButton];
    _titleContainerView = [[UIView alloc] init];
    [self addSubview:_titleContainerView];
}

#pragma mark - property

- (void)setTitle:(NSString *)title {
    _title = title;
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    self.titleView = label;
}

- (void)setTitleView:(UIView *)titleView {
    _titleView = titleView;
    if (!titleView) return;
    [self.titleContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleContainerView addSubview:titleView];
}

#pragma mark - UIView

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    CGRect safeBounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
    }
    
    _horizontalSeparatorLayer.frame = CGRectMake(0, 0, size.width, 1);
    
    const CGFloat buttonHeight = CGRectGetHeight(safeBounds);
    _leftButton.frame =
    CGRectMake(CGRectGetMinX(safeBounds), CGRectGetMinY(safeBounds),
               buttonHeight, buttonHeight);
    _rightButton.frame =
    CGRectMake(CGRectGetMaxX(safeBounds) - buttonHeight, CGRectGetMinY(safeBounds),
               buttonHeight, buttonHeight);
    _titleContainerView.frame =
    CGRectMake(CGRectGetMaxX(_leftButton.frame), CGRectGetMinY(safeBounds),
               CGRectGetMinX(_rightButton.frame) - CGRectGetWidth(_leftButton.frame), buttonHeight);
    _titleView.frame = _titleContainerView.bounds;
}

#pragma mark - private

/**
 生成统一的按钮
 */
+ (UIButton *)commonButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tintColor = [UIColor whiteColor];
    return button;
}

@end
