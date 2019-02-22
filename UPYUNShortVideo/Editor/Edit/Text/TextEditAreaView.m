//
//  TextEditAreaView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/6.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextEditAreaView.h"
#import "TextItemTransformControl.h"

// 动画时长
static const NSTimeInterval kAnimationDuration = 0.25;

@interface TextEditAreaView ()

/**
 文字项
 */
@property (nonatomic, strong) NSMutableArray<TextItemTransformControl *> *textItemControls;

/**
 下一个文字项中点坐标
 */
@property (nonatomic, assign) CGPoint nextTextEditItemCenter;

/**
 下一个文字项位移
 */
@property (nonatomic, assign) CGPoint ascPoint;

/**
 上一次 bounds 值
 */
@property (nonatomic, assign) CGRect previousBounds;

@end

@implementation TextEditAreaView

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
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    _textItemControls = [NSMutableArray array];
    
    _ascPoint = CGPointMake(7, 7);
    _selectedIndex = -1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(self.bounds, self.previousBounds)) {
        _previousBounds = self.bounds;
        CGSize size = self.bounds.size;
        
        for (TextItemTransformControl *textItemControl in _textItemControls) {
            if (!CGPointEqualToPoint(CGPointZero, textItemControl.textLabel.initialPercentCenter)) {
                CGPoint initialCenter = textItemControl.textLabel.initialPercentCenter;
                initialCenter.x *= size.width;
                initialCenter.y *= size.height;
                textItemControl.center = initialCenter;
            }
        }
    }
}

#pragma mark - property

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.nextTextEditItemCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex callback:NO];
}

- (NSInteger)textEditItemCount {
    return self.textItemControls.count;
}

#pragma mark - public

- (void)addTextEditItem:(AttributedLabel *)textLabel {
    TextItemTransformControl *control = [[TextItemTransformControl alloc] initWithFrame:CGRectZero];
    control.center = _nextTextEditItemCenter;
    control.textLabel = textLabel;
    [self addSubview:control];
    [_textItemControls addObject:control];
    __weak typeof(self) weakSelf = self;
    control.closeButtonActionHandler = ^(TextItemTransformControl *control, UIButton *sender) {
        [weakSelf controlCloseButtonAction:control];
    };
    __weak typeof(control) weak_control = control;
    textLabel.labelUpdateHandler = ^(AttributedLabel *label) {
        [weak_control updateLayoutWithContentSize:label.intrinsicContentSize];
    };
    
    [control addTarget:self action:@selector(controlTapAction:) forControlEvents:UIControlEventTouchUpInside];
    self.selectedIndex = _textItemControls.count - 1;
    
    if ([self.delegate respondsToSelector:@selector(textEditAreaView:didUpdateItem:itemIndex:added:removed:)]) {
        [self.delegate textEditAreaView:self didUpdateItem:textLabel itemIndex:self.selectedIndex added:YES removed:NO];
    }
}

- (void)addDefaultTextEditItem {
    self.nextTextEditItemCenter = CGPointMake(_nextTextEditItemCenter.x + _ascPoint.x, _nextTextEditItemCenter.y + _ascPoint.y);
    AttributedLabel *textLabel = [AttributedLabel defaultLabel];
    
    [self addTextEditItem:textLabel];
}

- (void)setTextItemAtIndex:(NSInteger)index hidden:(BOOL)hidden animated:(BOOL)animated {
    TextItemTransformControl *textItemControl = [self textItemControlAtIndex:index];
    [self setTextItemControl:textItemControl hidden:hidden animated:animated];
}

- (void)showTextItemAtTime:(CMTime)time index:(NSInteger)index animated:(BOOL)animated {
    TextItemTransformControl *textItemControl = [self textItemControlAtIndex:index];
    // CMTimeRangeContainsTime 不包含末尾
    BOOL hidden = !CMTimeRangeContainsTime(textItemControl.textLabel.timeRange, time) &&  !CMTIME_COMPARE_INLINE(time, ==, CMTimeRangeGetEnd(textItemControl.textLabel.timeRange));
    [self setTextItemControl:textItemControl hidden:hidden animated:animated];
}

- (void)hideAllTextItems {
    for (TextItemTransformControl *textItemControl in _textItemControls) {
        textItemControl.alpha = 0;
    }
}

- (AttributedLabel *)itemLabelAtIndex:(NSInteger)index {
    return [self textItemControlAtIndex:index].textLabel;
}

#pragma mark - private

/**
 设置下一个文字项位置

 @param nextTextEditItemCenter 下一个文字项中点
 */
- (void)setNextTextEditItemCenter:(CGPoint)nextTextEditItemCenter {
    _nextTextEditItemCenter = nextTextEditItemCenter;
    // 防超出屏幕与防重叠处理
    if (nextTextEditItemCenter.x > CGRectGetMaxX(self.bounds)) {
        _ascPoint.x *= -1;
        _nextTextEditItemCenter.x = CGRectGetMaxX(self.bounds);
    } else if (nextTextEditItemCenter.x < 0) {
        _ascPoint.x *= -1;
        _nextTextEditItemCenter.x = 0;
    }
    if (nextTextEditItemCenter.y > CGRectGetMaxY(self.bounds)) {
        _ascPoint.y *= -1;
        _nextTextEditItemCenter.y = CGRectGetMaxY(self.bounds);
    } else if (nextTextEditItemCenter.y < 0) {
        _ascPoint.y *= -1;
        _nextTextEditItemCenter.y = 0;
    }
}

/**
 设置文字项隐藏/显示

 @param textItemControl 文字项
 @param hidden 是否隐藏
 @param animated 是否动画更新
 */
- (void)setTextItemControl:(TextItemTransformControl *)textItemControl hidden:(BOOL)hidden animated:(BOOL)animated {
    CGFloat alpha = hidden ? .0 : 1.0;
    if (textItemControl.alpha == alpha) return;
    void (^animationsHandler)(void) = ^{
        textItemControl.alpha = alpha;
    };
    if (animated) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:kAnimationDuration animations:animationsHandler completion:NULL];
    } else {
        animationsHandler();
    }
}

/**
 设置选中索引

 @param selectedIndex 选中索引
 @param callback 是否进行回调
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex callback:(BOOL)callback {
    BOOL valueChanged = _selectedIndex != selectedIndex;
    
    // 清理前一个状态
    TextItemTransformControl *textItemContolShouldDeselect = [self textItemControlAtIndex:_selectedIndex];
    textItemContolShouldDeselect.selected = NO;
    
    // 应用选中状态
    TextItemTransformControl *textItemControlShouldSelect = [self textItemControlAtIndex:selectedIndex];
    textItemControlShouldSelect.selected = YES;
    
     _selectedIndex = selectedIndex;
    if (!callback) return;
    
    if (!valueChanged) {
        if (textItemControlShouldSelect && [self.delegate respondsToSelector:@selector(textEditAreaView:shouldEditItem:)]) {
            [self.delegate textEditAreaView:self shouldEditItem:textItemControlShouldSelect.textLabel];
        }
        return;
    }
   
    if ([self.delegate respondsToSelector:@selector(textEditAreaView:didSelectIndex:itemLabel:)]) {
        [self.delegate textEditAreaView:self didSelectIndex:_selectedIndex itemLabel:textItemControlShouldSelect.textLabel];
    }
}

/**
 从给定索引获取文字项
 
 @param index 文字项索引
 @return 文字项
 */
- (TextItemTransformControl *)textItemControlAtIndex:(NSInteger)index {
    if (index < 0 || index >= _textItemControls.count) return nil;
    return _textItemControls[index];
}

#pragma mark - action

/**
 关闭按钮事件

 @param sender 点击的文字项
 */
- (void)controlCloseButtonAction:(TextItemTransformControl *)sender {
    NSInteger itemIndex = [_textItemControls indexOfObject:sender];
    [_textItemControls removeObject:sender];
    [sender removeFromSuperview];
    self.selectedIndex = -1;
    
    if ([self.delegate respondsToSelector:@selector(textEditAreaView:didUpdateItem:itemIndex:added:removed:)]) {
        [self.delegate textEditAreaView:self didUpdateItem:sender.textLabel itemIndex:itemIndex added:NO removed:YES];
    }
}

/**
 文字项点击事件

 @param sender 点击的文字项
 */
- (void)controlTapAction:(TextItemTransformControl *)sender {
    [self setSelectedIndex:[_textItemControls indexOfObject:sender] callback:YES];
}

@end
