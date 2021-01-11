//
//  SegmentButton.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "SegmentButton.h"

@interface SegmentButton ()

/**
 按钮组
 */
@property (nonatomic, strong) NSArray<UIButton *> *buttons;

/**
 遮罩
 */
@property (nonatomic, strong) CALayer *mask;

@end

@implementation SegmentButton

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
    _font = [UIFont systemFontOfSize:13];
    _mask = [CALayer layer];
    [self.layer addSublayer:_mask];
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat buttonWidth = width / _buttons.count;
    [_buttons enumerateObjectsUsingBlock:^(UIButton * button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.frame = CGRectMake(idx * buttonWidth, 0, buttonWidth, height);
    }];
    _mask.frame = _buttons[_selectedIndex].frame;
    _mask.hidden = _style == SegmentButtonStylePlain;
}

#pragma mark - property

- (void)setButtonTitles:(NSArray<NSString *> *)buttonTitles {
    _buttonTitles = buttonTitles;
    // 创建按钮
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSString *title in _buttonTitles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = _font;
        [self addSubview:button];
        [buttons addObject:button];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(subButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    _buttons = buttons.copy;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    for (UIButton *button in _buttons) {
        button.titleLabel.font = font;
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    _selectedBackgroundColor = selectedBackgroundColor;
    _mask.backgroundColor = selectedBackgroundColor.CGColor;
    if (_style == SegmentButtonStyleSlideMask) return;
    for (UIButton *button in _buttons) {
        [button setBackgroundImage:[self.class imageWithColor:selectedBackgroundColor] forState:UIControlStateSelected];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    _selectedIndex = selectedIndex;
    for (UIButton *button in _buttons) {
        button.selected = NO;
    }
    UIButton *selectedButton = _buttons[_selectedIndex];
    selectedButton.selected = YES;
    if (_style == SegmentButtonStylePlain) return;
    [UIView animateWithDuration:0.25 animations:^{
        self.mask.frame = selectedButton.frame;
    }];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    
    self.mask.cornerRadius = cornerRadius;
    self.mask.masksToBounds = YES;
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    for (UIButton *button in _buttons) {
        [button setTitleColor:color forState:state];
    }
}

- (float)getSpeed {
    switch (_selectedIndex) {
        case 0:
            return 0.5;
        case 1:
            return 0.7;
        case 3:
            return 1.5;
        case 4:
            return 2.0;
        default:
            return 1.0;
    }
}

/**
 创建纯色图片

 @param color 颜色
 @return UIImage 对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color {
    if (!color) return nil;
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - action

/**
 子按钮点击事件

 @param sender 点击的按钮
 */
- (void)subButtonAction:(UIButton *)sender {
    NSInteger index = [_buttons indexOfObject:sender];
    if (index == self.selectedIndex) {
        return;
    }
    sender.selected = !sender.selected;
    self.selectedIndex = index;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
