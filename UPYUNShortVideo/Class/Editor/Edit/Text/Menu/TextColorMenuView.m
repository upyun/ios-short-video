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
#import "AttributedLabel.h"


@interface TextColorMenuView ()
{
    __weak AttributedLabel *_label;
}
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

// 各控件间的间隔
static const CGFloat kItemSpacing = 8;
// 控件高度
static const CGFloat kItemHeight = 16;
// 右侧距离
static const CGFloat kRightSpacing = 14;

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
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
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

- (void)setColorProgress:(CGFloat)colorProgress;{
    _colorSliders.firstObject.progress = colorProgress;
    [_colorSliders.firstObject layoutSubviews];
}

/**
 颜色 slider 值变更回调
 */
- (void)sliderValueChangeAction:(ColorSlider *)slider {
    _colorProgress = slider.progress;
    _label.textColorProgress = _colorProgress;
    if ([self.delegate respondsToSelector:@selector(menu:didChangeTextColor:)]) {
        [self.delegate menu:self didChangeTextColor:slider.color];
    }
}

/**
 设置
 @param label 设置属性
 */
- (void)updateByAttributeLabel:(AttributedLabel *)label;{
    _label = label;
    [self setColorProgress:_label.textColorProgress];
}


@end
