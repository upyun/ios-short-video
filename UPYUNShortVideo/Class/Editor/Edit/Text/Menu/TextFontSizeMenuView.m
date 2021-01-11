//
//  TextFontSizeMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextFontSizeMenuView.h"
#import "ColorSlider.h"
#import "CustomSlider.h"
#import "UIImage+Demo.h"
#import "TuSDKFramework.h"
#import "AttributedLabel.h"


@interface TextFontSizeMenuView ()

/**
 颜色 slider
 */
@property (nonatomic, strong) UISlider*slider;

/**
 返回按钮
 */
@property (nonatomic, strong) UIButton *backButton;

@end


@implementation TextFontSizeMenuView

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
    _defaultFontSize = 24;
    _maxFontSize = _defaultFontSize * 4;
    
    // 字号
    {
        _slider = [self borderSlider];
        _slider.value = _defaultFontSize;
        [self setDefaultFontSize:24];
        
        [self addSubview:_slider];
    
    }
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_backButton];
    [_backButton setImage:[UIImage imageNamed:@"edit_ic_return"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    const CGFloat backWidth = 76;
    _backButton.frame = CGRectMake(0, 0, backWidth, size.height);
  
     _slider.frame = CGRectMake(_backButton.lsqGetRightX , _backButton.center.y - kItemHeight/2 , self.lsqGetSizeWidth - (_backButton.lsqGetRightX + kRightSpacing *2) , kItemHeight);
}

-(void)setDefaultFontSize:(CGFloat)defaultFontSize;{
    _defaultFontSize = defaultFontSize;
    _slider.minimumValue = defaultFontSize - (defaultFontSize/2.0f);
    _slider.maximumValue = self.maxFontSize;
}

- (void)setFontSize:(CGFloat)fontSize;{
    _fontSize = fontSize;
    _slider.value = fontSize;
}

/**
 设置
 @param label 设置属性
 */
- (void)updateByAttributeLabel:(AttributedLabel *)label;{
    [self setFontSize:label.font.pointSize];
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
- (UISlider *)borderSlider {
    CustomSlider *slider = [[CustomSlider alloc] initWithFrame:CGRectZero];
    slider.minimumTrackTintColor =[UIColor whiteColor];
    
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
- (void)sliderValueChangeAction:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(menu:didChangeFontSize:)])
        [self.delegate menu:self didChangeFontSize:slider.value];
}

@end
