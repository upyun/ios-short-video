//
//  TextMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextMenuView.h"

@interface MenuItemControl()

/**
 文本标签
 */
@property (nonatomic, strong) UILabel *textLabel;

/**
 事件接收按钮
 */
@property (nonatomic, strong) UIButton *eventButton;

@end

@implementation MenuItemControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:10];
        _textLabel.textColor = [UIColor whiteColor];
        [self addSubview:_textLabel];
        _eventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_eventButton];
        [_eventButton addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    CGSize textSize = [_textLabel intrinsicContentSize];
    _iconView.frame = CGRectMake(0, 0, size.width, size.height - textSize.height - _spacing);
    _textLabel.frame = CGRectMake((size.width - textSize.width) / 2, size.height - textSize.height, textSize.width, textSize.height);
    _eventButton.frame = self.bounds;
}

- (void)setIconView:(UIView *)iconView {
    _iconView = iconView;
    [self addSubview:iconView];
    iconView.contentMode = UIViewContentModeCenter;
}

- (void)tapAction:(UIButton *)sender {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end


@interface TextMenuView ()

/**
 返回按钮
 */
@property (nonatomic, strong) UIButton *backButton;

/**
 滚动视图
 */
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TextMenuView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor blackColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_scrollView];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_backButton];
    [_backButton setImage:[UIImage imageNamed:@"edit_ic_return"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    _backButton.frame = CGRectMake(0, 0, 76, size.height);
    const CGFloat scrollViewWidth = size.width - CGRectGetMaxX(_backButton.frame);
    _scrollView.frame = CGRectMake(size.width - scrollViewWidth, 0, scrollViewWidth, size.height);
    _scrollView.contentSize = CGSizeMake((_itemSpacing + _itemSize.width) * _menuItemViews.count - _itemSpacing, size.height);
    
    [_menuItemViews enumerateObjectsUsingBlock:^(UIView *menuItemView, NSUInteger idx, BOOL * _Nonnull stop) {
        menuItemView.frame = CGRectMake((self.itemSize.width + self.itemSpacing) * idx, (size.height - self.itemSize.height) / 2, self.itemSize.width, self.itemSize.height);
    }];
}

/**
 返回按钮事件

 @param sender 返回按钮
 */
- (void)backButtonAction:(UIButton *)sender {
    [self removeFromSuperview];
}

@end
