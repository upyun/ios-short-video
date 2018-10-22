//
//  TuSDKPFEditTextStyleAdjustView.m
//  TuSDKGeeV1
//
//  Created by wen on 28/07/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import "TuSDKPFEditTextStyleAdjustView.h"

@interface TuSDKPFEditTextStyleAdjustView (){
    UIScrollView *_backScroll;
}

@end

@implementation TuSDKPFEditTextStyleAdjustView

#pragma mark - setter getter

- (void)setStyleImageNames:(NSArray<NSNumber *> *)styleImageNames;
{
    _styleImageNames = styleImageNames;
    [self resetStyleView];
}

#pragma mark - init method

- (instancetype)init;
{
    if (self = [super init]) {
        [self initDefaultData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initDefaultData];
    }
    return self;
}

- (void)initDefaultData;
{
    _edgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
}

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
                                            color:[UIColor whiteColor]];
        [btn setStateNormalLSQBundleImageName:defaultIcon];
        [btn setImage:[UIImage imageLSQBundleNamed:selectedIcon] forState:UIControlStateHighlighted];
        [btn setTitleColor:lsqRGB(252, 103, 61) forState:UIControlStateHighlighted];
        [btn centerImageAndTitle: 2];
        btn.center = CGPointMake(btnCenterX, btnCenterY);
        btn.tag = styleNum.integerValue;
        
        [btn addTarget:self action:@selector(clickStyleBtnWith:) forControlEvents:UIControlEventTouchUpInside];
        [_backScroll addSubview:btn];
        
        btnCenterX = btnCenterX + btnWidth ;
    }
    _backScroll.contentSize = CGSizeMake(btnCenterX - btnWidth/2 , _backScroll.lsqGetSizeHeight);
}

#pragma mark - custom method

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

- (void)clickStyleBtnWith:(UIButton *)btn;
{
    if ([self.styleDelegate respondsToSelector:@selector(onSelectStyle:)]) {
        [self.styleDelegate onSelectStyle:(TuSDKPFEditTextStyleType)btn.tag];
    }
}


@end
