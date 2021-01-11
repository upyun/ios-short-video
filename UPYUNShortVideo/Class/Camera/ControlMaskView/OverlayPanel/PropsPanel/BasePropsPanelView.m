//
//  BaseStickerPanelView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BasePropsPanelView.h"

@interface BasePropsPanelView ()

/**
 背景视图
 */
@property (nonatomic, strong) UIView *backgroundView;

/**
 重置按钮
 */
@property (nonatomic, strong) UIButton *unsetButton;

/**
 分类名称标签栏
 */
@property (nonatomic, strong) PageTabbar *categoryTabbar;

/**
 分页管理控件
 */
@property (nonatomic, strong) ViewSlider *categoryPageSlider;

/**
 垂直分割线
 */
@property (nonatomic, strong) CALayer *verticalSeparatorLayer;

/**
 水平分割线
 */
@property (nonatomic, strong) CALayer *horizontalSeparatorLayer;

@end

@implementation BasePropsPanelView

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
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    
    _verticalSeparatorLayer = [CALayer layer];
    [self.layer addSublayer:_verticalSeparatorLayer];
    _verticalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    _horizontalSeparatorLayer = [CALayer layer];
    [self.layer addSublayer:_horizontalSeparatorLayer];
    _horizontalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_backgroundView];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    UIButton *unsetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:unsetButton];
    _unsetButton = unsetButton;
    [unsetButton setImage:[UIImage imageNamed:@"video_ic_nix"] forState:UIControlStateNormal];
    
    PageTabbar *tabbar = [[PageTabbar alloc] initWithFrame:CGRectZero];
    [self addSubview:tabbar];
    _categoryTabbar = tabbar;
    tabbar.itemsSpacing = 24;
    tabbar.trackerSize = CGSizeMake(32, 2);
    tabbar.itemSelectedColor = [UIColor whiteColor];
    tabbar.itemNormalColor = [UIColor whiteColor];
    tabbar.delegate = self;
    tabbar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    ViewSlider *pageSlider = [[ViewSlider alloc] initWithFrame:CGRectZero];
    [self addSubview:pageSlider];
    _categoryPageSlider = pageSlider;
    pageSlider.dataSource = self;
    pageSlider.delegate = self;
    pageSlider.selectedIndex = 0;
}

- (void)layoutSubviews {
    _backgroundView.frame = self.bounds;
    const CGSize size = self.bounds.size;
    CGRect safeBounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
    }
    const CGFloat tabbarHeight = 32;
    _unsetButton.frame = CGRectMake(CGRectGetMinX(safeBounds), CGRectGetMinY(safeBounds), 52, tabbarHeight);
    _categoryTabbar.frame = CGRectMake(CGRectGetMaxX(_unsetButton.frame), CGRectGetMinY(safeBounds), CGRectGetWidth(safeBounds) - CGRectGetMaxX(_unsetButton.frame), tabbarHeight);
    _categoryPageSlider.frame = CGRectMake(CGRectGetMinX(safeBounds), tabbarHeight, CGRectGetWidth(safeBounds), size.height - tabbarHeight);
    _verticalSeparatorLayer.frame = CGRectMake(CGRectGetMaxX(_unsetButton.frame), 0, 1, tabbarHeight);
    _horizontalSeparatorLayer.frame = CGRectMake(0, tabbarHeight, size.width, 1);
}

#pragma mark - PageTabbarDelegate

/**
 标签项选中回调
 
 @param tabbar 标签栏对象
 @param fromIndex 起始索引
 @param toIndex 目标索引
 */
- (void)tabbar:(PageTabbar *)tabbar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    _categoryPageSlider.selectedIndex = toIndex;
}

#pragma mark - ViewSliderDataSource

- (NSInteger)numberOfViewsInSlider:(ViewSlider *)slider {
    // 子类重写
    return 0;
}

- (UIView *)viewSlider:(ViewSlider *)slider viewAtIndex:(NSInteger)index {
    // 子类重写
    return nil;
}

#pragma mark - ViewSliderDelegate

- (void)viewSlider:(ViewSlider *)slider didSwitchBackIndex:(NSInteger)index {
    // 子类重写
}

- (void)viewSlider:(ViewSlider *)slider didSwitchToIndex:(NSInteger)index {
    _categoryTabbar.selectedIndex = index;
}

- (void)viewSlider:(ViewSlider *)slider switchingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    // 子类重写
}

@end
