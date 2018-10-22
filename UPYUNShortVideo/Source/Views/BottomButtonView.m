//
//  BottomButtonView.m
//  TuSDKVideoDemo
//
//  Created by wen on 21/08/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "BottomButtonView.h"
#import "TuSDKFramework.h"

@interface BottomButtonView (){
    // 按钮 背景scroll
    UIScrollView *_scrollBackView;

    // 非选中时 图片数组
    NSArray *_normalImageNames;
    // 选中时 图片数组
    NSArray *_selectImageNames;
    // 按钮显示 title 数组
    NSArray *_titles;
    // 按钮 tag 起始值
    NSInteger _basicTag;
    // 当前选中的按钮 tag
    NSInteger _currentSelectedIndex;
}

@end

@implementation BottomButtonView

#pragma mark - init method

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initDefaultData];
    }
    return self;
}

// 初始化默认设置
- (void)initDefaultData;
{
    _normalTitleColor = [UIColor whiteColor];
}

// 创建底部按钮视图
- (void)initButtonWith:(NSArray *)normalImageNames selectImageNames:(NSArray *)selectImageNames With:(NSArray *)titles;
{
    [self removeAllButtons];
    _basicTag = 200;
    _normalImageNames = normalImageNames;
    _selectImageNames = selectImageNames;
    _titles = titles;
    
    if (!_scrollBackView) {
        _scrollBackView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollBackView.bounces = NO;
        _scrollBackView.showsVerticalScrollIndicator = NO;
        _scrollBackView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollBackView];
    }

    NSInteger allCount = MAX(normalImageNames.count, titles.count);
    
    CGFloat btnHeight = 50;
    CGFloat btnWidth = 50;
    CGFloat centerX = 35;
    CGFloat btnFontSize = 12;
    CGFloat centerY = self.lsqGetSizeHeight/2;
    CGFloat interval = (_scrollBackView.lsqGetSizeWidth - centerX)/4;
    
    if (allCount <= 4 || _isEquallyDisplay) {
        interval = self.lsqGetSizeWidth/allCount;
        centerX = interval/2;
    }

    for (int i = 0; i < allCount; i++) {
        NSString *imageName = i >= normalImageNames.count ? @"" : normalImageNames[i];
        NSString *title = i >= titles.count ? @"" : titles[i];
        UIImage *btnImage = [UIImage imageNamed:imageName];
        CGSize imageSize = btnImage ? btnImage.size : CGSizeMake(0, 0);
        CGFloat titleWidth = [title lsqColculateTextSizeWithFont:[UIFont systemFontOfSize:btnFontSize] maxWidth:1000 maxHeihgt:btnHeight].width;
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
        btn.center = CGPointMake(centerX, centerY);
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn addTarget:self action:@selector(clickBottomButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:btnImage forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:_normalTitleColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:btnFontSize];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btnWidth/2-btnImage.size.width/2, 0, 0)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(btnHeight - 16, btnWidth/2 - titleWidth/2 - imageSize.width , 0, 0)];
        btn.tag = _basicTag + i;
        btn.adjustsImageWhenHighlighted = NO;
        [_scrollBackView addSubview:btn];
        
        if (i == 0)
            [self refreshSelectStateWith:btn];
        
        centerX += interval;
    }
    
//    _scrollBackView.contentSize = CGSizeMake(centerX - interval + btnWidth/2 + 10, _scrollBackView.lsqGetSizeHeight);
    
}

#pragma mark - help method

- (void)refreshSelectStateWith:(UIButton *)btn;
{
    // 取消上一个选中状态
    for (UIButton *btn in _scrollBackView.subviews) {
        if (btn.tag == _currentSelectedIndex) {
            NSInteger index = _currentSelectedIndex - _basicTag;
            NSString *normalImage = index >= _normalImageNames.count ? @"" : _normalImageNames[index];
            [btn setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
            [btn setTitleColor:_normalTitleColor forState:UIControlStateNormal];
        }
    }
    
    _currentSelectedIndex = btn.tag;
    NSInteger index = btn.tag - _basicTag;
    NSString *selectImage = index >= _selectImageNames.count ? nil : _selectImageNames[index];
    
    if (selectImage)
        [btn setImage:[UIImage imageNamed:selectImage] forState:UIControlStateNormal];
    if (_selectedTitleColor)
        [btn setTitleColor:_selectedTitleColor forState:UIControlStateNormal];
}

- (void)removeAllButtons;
{
    for (UIView *view in _scrollBackView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)clickBottomButtonEvent:(UIButton *)btn;
{
    // 针对文字选中做特殊处理
     NSInteger index = _currentSelectedIndex - _basicTag;
    if ([_titles[index] isEqualToString: NSLocalizedString(@"lsq_movieEditor_text",  "文字")]) {
        btn.selected = !btn.selected;
        [self refreshSelectStateWith:btn];
        if ([self.clickDelegate respondsToSelector:@selector(bottomButton:clickIndex:)]) {
            [self.clickDelegate bottomButton:self clickIndex:btn.tag - _basicTag];
        }
        return;
    }
    
    if (_currentSelectedIndex == btn.tag) return;
    btn.selected = !btn.selected;
    [self refreshSelectStateWith:btn];
    if ([self.clickDelegate respondsToSelector:@selector(bottomButton:clickIndex:)]) {
        [self.clickDelegate bottomButton:self clickIndex:btn.tag - _basicTag];
    }
}

@end
