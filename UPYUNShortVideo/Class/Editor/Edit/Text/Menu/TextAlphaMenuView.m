//
//  TextAlphaMenuView.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/6.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "TextAlphaMenuView.h"
#import "CustomSlider.h"
#import "TuSDKFramework.h"
#import "AttributedLabel.h"


@interface TextAlphaMenuView()

/**
 颜色 slider
 */
@property (nonatomic, strong) NSArray<UISlider *> *sliders;

/**
 颜色标签
 */
@property (nonatomic, strong) NSArray<UILabel *> *labels;

/**
 返回按钮
 */
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation TextAlphaMenuView

// 各控件间的间隔
static const CGFloat kItemSpacing = 15;
// 控件高度
static const CGFloat kItemHeight = 14;
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
    
    // 字间距
    {
        UILabel *label = [self.class lable];
        [self addSubview:label];
        label.text = NSLocalizedStringFromTable(@"tu_不透明度", @"VideoDemo", @"不透明度");
        [colorLabels addObject:label];
        
        UISlider *slider = [self slider];
        slider.minimumValue = 0;
        slider.maximumValue = 1;
        [self addSubview:slider];
        [colorSliders addObject:slider];
    }
  
   
    _sliders = colorSliders.copy;
    _labels = colorLabels.copy;
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_backButton];
    [_backButton setImage:[UIImage imageNamed:@"edit_ic_return"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    const CGFloat backWidth = 76;
    const NSInteger count = _labels.count;
    _backButton.frame = CGRectMake(0, 0, backWidth, size.height);
    const CGFloat baseY = (size.height - ((kItemHeight + kItemSpacing) * count - kItemSpacing)) / 2;
    CGFloat maxLabelWidth = _labels.firstObject.intrinsicContentSize.width;
    for (UILabel *label in _labels) {
        if (label.intrinsicContentSize.width > maxLabelWidth) {
            maxLabelWidth = label.intrinsicContentSize.width;
        }
    }
    for (int i = 0; i < count; i++) {
        UILabel *label = _labels[i];
        CGSize labelContentSize = label.intrinsicContentSize;
        CGFloat y = baseY + i * (kItemHeight + kItemSpacing);
        label.frame = CGRectMake(backWidth, y, labelContentSize.width, kItemHeight);
        
        UIView *slider = _sliders[i];
        CGFloat sliderWidth = size.width - maxLabelWidth - kItemSpacing - backWidth - kRightSpacing;
        slider.frame = CGRectMake(size.width - sliderWidth - kRightSpacing, y, sliderWidth, kItemHeight);
    }
}

/**
 创建统一的标签
 */
+ (UILabel *)lable {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    return label;
}

/**
 创建统一的颜色 slider
 */
- (UISlider *)slider {
    CustomSlider *slider = [[CustomSlider alloc] initWithFrame:CGRectZero];
    slider.minimumTrackTintColor =[UIColor whiteColor];
    slider.maximumTrackTintColor = [UIColor lsqClorWithHex:@"#2f2f2f"];

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
  slider 值变更回调
 */
- (void)sliderValueChangeAction:(UISlider *)slider {
    _alphaValue = slider.value;
    if ([self.delegate respondsToSelector:@selector(menu:didChangeAlphavalue:)]) {
        [self.delegate menu:self didChangeAlphavalue:slider.value];
    }
}

/**
 设置值
 
 @param alphaValue 当前值
 */
- (void)setAlphaValue:(CGFloat)alphaValue;{
    _alphaValue = alphaValue;
    self.sliders.firstObject.value = alphaValue;
}

/**
 设置
 @param label 设置属性
 */
- (void)updateByAttributeLabel:(AttributedLabel *)label;{
    CGFloat alpha = CGColorGetAlpha(label.textColor.CGColor);
    [self setAlphaValue:alpha];
}

@end
