//
//  TextBgColorMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextBgColorMenuView.h"
#import "ColorSlider.h"
#import "CustomSlider.h"
#import "TuSDKFramework.h"
#import "UIImage+Demo.h"
#import "AttributedLabel.h"

@interface TextBgColorMenuView ()
{
    AttributedLabel *_label;
}
/**
 颜色 slider
 */
@property (nonatomic, strong) NSArray<UIView *> *colorSliders;

/**
 颜色标签
 */
@property (nonatomic, strong) NSArray<UILabel *> *colorLabels;

/**
 返回按钮
 */
@property (nonatomic, strong) UIButton *backButton;

@end


@implementation TextBgColorMenuView

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
    
    // 不透明度
    {
        UILabel *label = [self.class colorLabel];
        [self addSubview:label];
        label.text = NSLocalizedStringFromTable(@"tu_不透明度", @"VideoDemo", @"不透明度");
        [colorLabels addObject:label];
        
        UISlider *slider = [self slider];
        slider.tag = 1;
        slider.minimumValue = 0;
        slider.maximumValue = 1;
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
 设置
 @param label 设置属性
 */
- (void)updateByAttributeLabel:(AttributedLabel *)label;{
    if (_colorSliders.count < 2) return;
    _label = label;
    UIColor *color = label.backgroundColor;
    ((ColorSlider *)_colorSliders[0]).progress = label.bgColorProgress;
    [((ColorSlider *)_colorSliders[0]) layoutSubviews];
    ((UISlider *)_colorSliders[1]).value = CGColorGetAlpha(color.CGColor);
}

/**
 颜色 slider 值变更回调
 */
- (void)sliderValueChangeAction:(UISlider *)slider {
    
    switch (slider.tag) {
        case 0:{
            
            ColorSlider *colorSlider = (ColorSlider *)slider;
            _label.bgColorProgress = colorSlider.progress;
            if ([self.delegate respondsToSelector:@selector(menu:didChangeBgColor:)])
                [self.delegate menu:self didChangeBgColor:colorSlider.color];
            break;
        }
        case 1:{
        
            if ([self.delegate respondsToSelector:@selector(menu:didChangeBgAlpha:)])
                [self.delegate menu:self didChangeBgAlpha:slider.value];
            break;
        }
            
        default:
            break;
    }
   
    
    
}

@end
