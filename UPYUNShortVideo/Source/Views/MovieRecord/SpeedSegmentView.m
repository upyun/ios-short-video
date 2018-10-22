//
//  SpeedSegmentView.m
//  TuSDKVideoDemo
//
//  Created by wen on 2018/1/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "SpeedSegmentView.h"

@interface SpeedSegmentView(){
    
    // 内容View
    UIView *_contentView;
    // 展示当前选择的View
    UIView *_selectView;
    // tag的设置基础值
    NSInteger _basicTag;
    // 上一次选择的按钮对象
    UIButton *_lastSelectBtn;
}
@end


@implementation SpeedSegmentView

#pragma mark - setter getter


/**
 设置title数组
 */
- (void)setTitleArr:(NSArray<NSString *> *)titleArr;
{
    _titleArr = titleArr;
    [self addTitles];
}

#pragma mark - 视图布局

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initContentView];
        return self;
    }
    return nil;
}

- (void)initContentView;
{
    self.layer.cornerRadius = 2;
    _basicTag = 200;
    
    _selectView = [[UIView alloc]init];
    _selectView.backgroundColor = lsqRGBA(244, 161, 26, 0.7);
    _selectView.layer.cornerRadius = 2;
    [self addSubview:_selectView];

    _contentView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:_contentView];
    
}

/**
 添加title显示按钮
 */
- (void)addTitles;
{
    // 移除子视图
    _lastSelectBtn = nil;
    [_contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    CGFloat btnWidth = _contentView.lsqGetSizeWidth/_titleArr.count;
    CGFloat btnHeight = _contentView.lsqGetSizeHeight;
    CGFloat centerX = btnWidth/2;
    CGFloat centerY = _contentView.lsqGetSizeHeight/2;
    
    for (int i = 0; i < _titleArr.count; i++) {
        UIButton *titleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
        titleBtn.center = CGPointMake(centerX, centerY);
        titleBtn.tag = _basicTag + i;
        [titleBtn addTarget:self action:@selector(clickTitle:) forControlEvents:UIControlEventTouchUpInside];
        [titleBtn setTitle:_titleArr[i] forState:UIControlStateNormal];
        [titleBtn setTitleColor:[UIColor lsqClorWithHex:@"#F4A11A"] forState:UIControlStateNormal];
        [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_contentView addSubview:titleBtn];
        
        if (i == _titleArr.count/2) {
            _lastSelectBtn = titleBtn;
            titleBtn.selected = YES;
        }
        centerX += btnWidth;
    }
    
    _selectView.frame = _lastSelectBtn.frame;
}

#pragma mark - 事件处理

/**
 按钮点击事件
 */
- (void)clickTitle:(UIButton *)sender;
{
    _lastSelectBtn.selected = NO;
    sender.selected = YES;
    _lastSelectBtn = sender;
    
    [UIView animateWithDuration:0.2 animations:^{
        _selectView.frame = sender.frame;
    }];
    
    if ([self.eventDelegate respondsToSelector:@selector(speedSegmentView:withIndex:)]) {
        [self.eventDelegate speedSegmentView:self withIndex:sender.tag - _basicTag];
    }
}
@end
