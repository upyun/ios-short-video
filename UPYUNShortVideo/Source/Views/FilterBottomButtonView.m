//
//  FilterBottomButtonView.m
//  TuSDKVideoDemo
//
//  Created by wen on 22/08/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "FilterBottomButtonView.h"

@interface FilterBottomButtonView ()<BottomButtonViewDelegate>

@end

@implementation FilterBottomButtonView

#pragma mark - init method

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initBottomView];
    }
    return self;
}

- (void)initBottomView;
{
    _filterView = [[FilterView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, self.lsqGetSizeHeight - 60)];
    [self addSubview:_filterView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _filterView.lsqGetSizeHeight, self.lsqGetSizeWidth, 1)];
    line.backgroundColor = lsqRGB(230, 230, 230);
    [self addSubview:line];

    NSArray *normalImageNames = @[@"style_default_1.7.1_btn_beauty_default", @"style_default_1.11_btn_filter_unselected"];
    NSArray *selectImageNames = @[@"style_default_1.7.1_btn_beauty_selected",@"style_default_1.11_btn_filter"];
    NSArray *titles = @[NSLocalizedString(@"lsq_filter_beautyArg", @"美颜"),NSLocalizedString(@"lsq_movieEditor_filterBtn", @"滤镜")];
    
    _bottomButton = [[BottomButtonView alloc]initWithFrame:CGRectMake(0, self.lsqGetSizeHeight - 55, self.lsqGetSizeWidth, 50)];
    _bottomButton.clickDelegate = self;
    _bottomButton.isEquallyDisplay = YES;
    _bottomButton.selectedTitleColor = [UIColor lsqClorWithHex:@"#f4a11a"];
    _bottomButton.normalTitleColor = [UIColor lsqClorWithHex:@"#9fa0a0"];

    [_bottomButton initButtonWith:normalImageNames selectImageNames:selectImageNames With:titles];
    [self addSubview:_bottomButton];
    
}

#pragma mark - BottomButtonViewDelegate

- (void)bottomButton:(BottomButtonView *)bottomButtonView clickIndex:(NSInteger)index;
{
    if (index == 0) {
        _filterView.beautyParamView.hidden = NO;
        _filterView.filterChooseView.hidden = YES;
    }else{
        _filterView.beautyParamView.hidden = YES;
        _filterView.filterChooseView.hidden = NO;
    }
}
@end
