//
//  FilterSwipeView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/10/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "FilterSwipeView.h"
#import "Constants.h"

static const NSTimeInterval kAnimationDuration = 0.25;

@interface FilterSwipeView ()

/**
 用于切换的滤镜数组
 */
@property (nonatomic, strong) NSArray *filterCodes;

@end


@implementation FilterSwipeView

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
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeAction:)];
    [self addGestureRecognizer:leftSwipe];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeAction:)];
    [self addGestureRecognizer:rightSwipe];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    _filterNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_filterNameLabel];
    _filterNameLabel.font = [UIFont systemFontOfSize:20];
    _filterNameLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    _filterNameLabel.alpha = 0.0;
    
    _filterCodes = @[@"", kVideoFilterCodes];
}

- (void)layoutSubviews {
    CGRect safeBounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
    }
    const CGSize filterTextSize = _filterNameLabel.intrinsicContentSize;
    _filterNameLabel.frame = CGRectMake(CGRectGetMidX(safeBounds) - filterTextSize.width / 2, 88, filterTextSize.width, filterTextSize.height);
}

#pragma mark - property

- (void)setCurrentFilterCode:(NSString *)currentFilterCode {
    _currentFilterCode = currentFilterCode;
    NSString *filterName = [NSString stringWithFormat:@"lsq_filter_%@", currentFilterCode];
    filterName = NSLocalizedStringFromTable(filterName, @"TuSDKConstants", @"无需国际化");
    if (!currentFilterCode.length) filterName = NSLocalizedStringFromTable(@"tu_无", @"VideoDemo", @"无");
    _filterNameLabel.text = filterName;
    [self setNeedsLayout];
    
    // 设置 currentFilterCode 属性时动画更新显示的滤镜名称
    if (_filterNameLabel.hidden || _filterNameLabel.alpha != 0.0) return;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.filterNameLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationDuration delay:1 options:0 animations:^{
            self.filterNameLabel.alpha = 0;
        } completion:^(BOOL finished) {}];
    }];
}

#pragma mark - action

/**
 左滑手势响应事件
 
 @param sender 滑动手势
 */
- (void)leftSwipeAction:(UISwipeGestureRecognizer *)sender {
    [self switchToNextFilter];
}

/**
 右滑手势响应事件
 
 @param sender 滑动手势
 */
- (void)rightSwipeAction:(UISwipeGestureRecognizer *)sender {
    [self switchToPreviousFilter];
}

/**
 切换至前一个滤镜
 */
- (void)switchToPreviousFilter {
    if (!_filterCodes.count) return;
    NSInteger currentFilterIndex = [_filterCodes containsObject:_currentFilterCode] ? [_filterCodes indexOfObject:_currentFilterCode] : 0;
    NSInteger previousFilterIndex = currentFilterIndex - 1;
    while (previousFilterIndex < 0) {
        previousFilterIndex += _filterCodes.count;
    }
    NSString *filterCode = _filterCodes[previousFilterIndex];
    
    if ([self.delegate respondsToSelector:@selector(filterSwipeView:shouldChangeFilterCode:)]) {
        if (![self.delegate filterSwipeView:self shouldChangeFilterCode:filterCode]) {
            _currentFilterCode = filterCode;
            return;
        }
    }
    self.currentFilterCode = filterCode;
}

/**
 切换至后一个滤镜
 */
- (void)switchToNextFilter {
    if (!_filterCodes.count) return;
    NSInteger currentFilterIndex = [_filterCodes containsObject:_currentFilterCode] ? [_filterCodes indexOfObject:_currentFilterCode] : 0;
    NSInteger nextFilterIndex = (currentFilterIndex + 1) % _filterCodes.count;
    NSString *filterCode = _filterCodes[nextFilterIndex];
    
    if ([self.delegate respondsToSelector:@selector(filterSwipeView:shouldChangeFilterCode:)]) {
        if (![self.delegate filterSwipeView:self shouldChangeFilterCode:filterCode]) {
            _currentFilterCode = filterCode;
            return;
        }
    }
    self.currentFilterCode = filterCode;
}

@end
