//
//  TextColorMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextColorMenuView.h"
#import "ColorSlider.h"
#import "UIImage+Demo.h"

// 各控件间的间隔
static const CGFloat kItemSpacing = 8;
// 控件高度
static const CGFloat kItemHeight = 16;
// 右侧距离
static const CGFloat kRightSpacing = 14;

@interface TextColorMenuView ()

/**
 颜色 slider
 */
@property (nonatomic, strong) NSArray<ColorSlider *> *colorSliders;

/**
 颜色标签
 */
@property (nonatomic, strong) NSArray<UILabel *> *colorLabels;

/**
 返回按钮
 */
@property (nonatomic, strong) UIButton *backButton;

@end


@implementation TextColorMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor blackColor];
    NSMutableArray *colorSliders = [NSMutableArray array];
    NSMutableArray *colorLabels = [NSMutableArray array];
    // 字体
    {
        UILabel *label = [self.class colorLabel];
        [self addSubview:label];
        label.text = NSLocalizedStringFromTable(@"tu_字体", @"VideoDemo", @"字体");
        [colorLabels addObject:label];
        
        ColorSlider *slider = [self colorSlider];
        [self addSubview:slider];
        [colorSliders addObject:slider];
    }
    // 背景
    {
        UILabel *label = [self.class colorLabel];
        [self addSubview:label];
        label.text = NSLocalizedStringFromTable(@"tu_背景", @"VideoDemo", @"背景");
        [colorLabels addObject:label];
        
        ColorSlider *slider = [self colorSlider];
        [self addSubview:slider];
        [colorSliders addObject:slider];
        slider.progress = 0;
    }
    // 描边
    {
        UILabel *label = [self.class colorLabel];
        [self addSubview:label];
        label.text = NSLocalizedStringFromTable(@"tu_描边", @"VideoDemo", @"描边");
        [colorLabels addObject:label];
        
        ColorSlider *slider = [self colorSlider];
        [self addSubview:slider];
        [colorSliders addObject:slider];
    }
    _colorSliders = colorSliders.copy;
    _colorLabels = colorLabels.copy;
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_backButton];
    [_backButton setImage:[UIImage imageNamed:@"edit_ic_return"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    const CGFloat backWidth = 76;
    const NSInteger count = _colorLabels.count;
    _backButton.frame = CGRectMake(0, 0, backWidth, size.height);
    const CGFloat baseY = (size.height - ((kItemHeight + kItemSpacing) * count - kItemSpacing)) / 2;
    CGFloat maxLabelWidth = _colorLabels.firstObject.intrinsicContentSize.width;
    for (UILabel *label in _colorLabels) {
        if (label.intrinsicContentSize.width > maxLabelWidth) {
            maxLabelWidth = label.intrinsicContentSize.width;
        }
    }
    for (int i = 0; i < count; i++) {
        UILabel *label = _colorLabels[i];
        CGSize labelContentSize = label.intrinsicContentSize;
        CGFloat y = baseY + i * (kItemHeight + kItemSpacing);
        label.frame = CGRectMake(backWidth, y, labelContentSize.width, kItemHeight);
        
        UIView *slider = _colorSliders[i];
        CGFloat sliderWidth = size.width - maxLabelWidth - kItemSpacing - backWidth - kRightSpacing;
        slider.frame = CGRectMake(size.width - sliderWidth - kRightSpacing, y, sliderWidth, kItemHeight);
    }
}

/**
 创建统一的标签
 */
+ (UILabel *)colorLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    label.font = [UIFont systemFontOfSize:10];
    return label;
}

/**
 创建统一的颜色 slider
 */
- (ColorSlider *)colorSlider {
    ColorSlider *slider = [[ColorSlider alloc] initWithFrame:CGRectZero];
    [slider addTarget:self action:@selector(sliderValueChangeAction:) forControlEvents:UIControlEventValueChanged];
    return slider;
}

/**
 返回按钮事件
 */
- (void)backButtonAction:(UIButton *)sender {
    [self removeFromSuperview];
}

/**
 颜色 slider 值变更回调
 */
- (void)sliderValueChangeAction:(ColorSlider *)slider {
    TextColorType type = [_colorSliders indexOfObject:slider];
    if ([self.delegate respondsToSelector:@selector(menu:didChangeColor:forType:)]) {
        [self.delegate menu:self didChangeColor:slider.color forType:type];
    }
}

@end
