//
//  StickerTextStyleAdjustView.m
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright © 2018 tusdk.com. All rights reserved.
//

#import "StickerTextStyleAdjustView.h"

/**
 样式选择视图类
 @since     v2.2.0
 */
@interface StickerTextStyleAdjustView (){
    // 滚动视图
    UIScrollView *_backScroll;
    // 按钮数组
    NSMutableArray *_btnArray;
}

@end

@implementation StickerTextStyleAdjustView

#pragma mark - setter getter

/**
 设置图片数组
 @param styleImageNames NSArray
 @since     v2.2.0
 */
- (void)setStyleImageNames:(NSArray<NSNumber *> *)styleImageNames;
{
    _styleImageNames = styleImageNames;
    [self resetStyleView];
}

#pragma mark - init method

/**
 初始化
 @return UIView
 @since   v2.2.0
 */
- (instancetype)init;
{
    if (self = [super init]) {
        [self initDefaultData];
    }
    return self;
}

/**
 初始化
 @param frame 外部设定的frame
 @return UIView
 @since   v2.2.0
 */
- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initDefaultData];
    }
    return self;
}

/**
 设置边距
 @since   v2.2.0
 */
- (void)initDefaultData;
{
    _edgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
}

/**
 重新创建文字样式视图
 @since   v2.2.0
 */
- (void)resetStyleView;
{
    if (_backScroll) {
        for (UIView *view in _backScroll.subviews) {
            if (view.tag >= 200)
                [view removeFromSuperview];
        }
    }else{
        _backScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(_edgeInsets.left, _edgeInsets.top, self.lsqGetSizeWidth - _edgeInsets.left - _edgeInsets.right, self.lsqGetSizeHeight - _edgeInsets.top - _edgeInsets.bottom)];
        _backScroll.bounces = NO;
        _backScroll.showsVerticalScrollIndicator = NO;
        _backScroll.showsHorizontalScrollIndicator = NO;
        [self addSubview:_backScroll];
    }
    [_btnArray removeAllObjects];
    _btnArray = [NSMutableArray arrayWithCapacity:6];
    
    CGFloat btnWidth = _backScroll.lsqGetSizeWidth / 4.5;
    if (_styleImageNames.count <= 4)
        btnWidth = _backScroll.lsqGetSizeWidth / _styleImageNames.count;
    
    CGFloat btnHeight = _backScroll.lsqGetSizeHeight;
    CGFloat btnCenterX = btnWidth / 2;
    CGFloat btnCenterY = _backScroll.lsqGetSizeHeight / 2;
    
    for (NSNumber *styleNum in _styleImageNames) {
        NSString *name = [self getStyleNameWith:(TuSDKPFEditTextStyleType)styleNum.integerValue];

        NSString *title = [NSString stringWithFormat:@"lsq_edit_text_style_%@", name];
        NSString *defaultIcon = [NSString stringWithFormat:@"lsq_edit_text_style_icon_%@_default", name];
        NSString *selectedIcon = [NSString stringWithFormat:@"lsq_edit_text_style_icon_%@_selected", name];

        UIButton *btn = [UIButton buttonWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)
                                            title:LSQString(title, @"参数名")
                                             font:lsqFontSize(10)
                                            color:lsqRGB(153,153,153)];
        [btn setStateNormalImage:[UIImage imageNamed:defaultIcon]];
        [btn setImage:[UIImage imageNamed:selectedIcon] forState:UIControlStateHighlighted];
        [btn setTitleColor:lsqRGB(244,161,24) forState:UIControlStateHighlighted];
        [btn centerImageAndTitle: 2];
        btn.center = CGPointMake(btnCenterX, btnCenterY);
        btn.tag = styleNum.integerValue;
        
        [btn addTarget:self action:@selector(clickStyleBtnWith:) forControlEvents:UIControlEventTouchUpInside];
        [_backScroll addSubview:btn];
        
        btnCenterX = btnCenterX + btnWidth ;
        [_btnArray addObject:btn];
    }
    _backScroll.contentSize = CGSizeMake(btnCenterX - btnWidth/2 , _backScroll.lsqGetSizeHeight);
}

#pragma mark - custom method

/**
 选择文字样式
 @param styleType 样式
 @return NSString
 @since     v2.2.0
 */
- (NSString *)getStyleNameWith:(TuSDKPFEditTextStyleType)styleType;
{
    NSString *name = @"style";
    switch (styleType) {
        case TuSDKPFEditTextStyleType_LeftToRight:
            name = @"leftToRight";
            break;
        case TuSDKPFEditTextStyleType_RightToLeft:
            name = @"rightToLeft";
            break;
        case TuSDKPFEditTextStyleType_Underline:
            name = @"underline";
            break;
        case TuSDKPFEditTextStyleType_AlignmentLeft:
            name = @"alignmentLeft";
            break;
        case TuSDKPFEditTextStyleType_AlignmentRight:
            name = @"alignmentRight";
            break;
        case TuSDKPFEditTextStyleType_AlignmentCenter:
            name = @"alignmentCenter";
            break;
            
        default:
            break;
    }
    return name;
}

/**
 样式事件
 @param btn 对应的样式
 @since    v2.2.0
 */
- (void)clickStyleBtnWith:(UIButton *)btn;
{
    for (UIButton *normalBtn in _btnArray) {
        
        NSString *name = [self getStyleNameWith:(TuSDKPFEditTextStyleType)normalBtn.tag];
        NSString *defaultIcon = [NSString stringWithFormat:@"lsq_edit_text_style_icon_%@_default", name];
        NSString *selectedIcon = [NSString stringWithFormat:@"lsq_edit_text_style_icon_%@_selected", name];
        
        if (btn == normalBtn) {
            [btn setImage:[UIImage imageNamed:selectedIcon] forState:UIControlStateNormal];
            [btn setTitleColor:lsqRGB(244,161,24) forState:UIControlStateNormal];
        } else {
            [normalBtn setImage:[UIImage imageNamed:defaultIcon] forState:UIControlStateNormal];
            [normalBtn setTitleColor:lsqRGB(153,153,153) forState:UIControlStateNormal];
        }
    }
    if ([self.styleDelegate respondsToSelector:@selector(onSelectStyle:)]) {
        [self.styleDelegate onSelectStyle:(TuSDKPFEditTextStyleType)btn.tag];
    }
}

@end
