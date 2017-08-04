//
//  FilterView.m
//  ImageArrTest
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 wen. All rights reserved.
//

#import "FilterView.h"
#import "FilterItemView.h"
#import "TuSDKFramework.h"
#import "VideoClipView.h"

@interface FilterView ()<FilterItemViewClickDelegate,TuSDKICSeekBarDelegate>
{
    // 数据源
    // 滤镜code数组
    NSArray *_filters;

    // 视图布局
    // 滤镜滑动scroll
    UIScrollView *_filterScroll;
    // 参数栏背景view
    UIView *_paramBackView;
    // 美颜按钮
    UIButton *_beautyBtn;
    // 美颜的边框view
    UIView *_beautyBorderView;
    // 记录参数调节数值的label
    UILabel *_argValueLabel;
    
    // 记录参数栏数据源信息
    NSString *_filterDescription;
    NSArray *_args;
    CGFloat _beautyLevel;
    
}

@end



@implementation FilterView

#pragma mark - 视图布局方法；
- (void)createFilterWith:(NSArray *)filterArr
{
    _filters = filterArr;
    
    if (self.canAdjustParameter) {
        // 参数可调节
        // 垂直布局方式： paramBackView + basicViewScroll ，当调节参数增多时，修改自动调整在paramBackVidw中的中心位置
        CGFloat offsetX = (self.lsqGetSizeHeight*0.48) * 13/18 + 10 + 7;
        [self createFilterChooseViewWith:CGRectMake(offsetX, 0.374*self.lsqGetSizeHeight , self.bounds.size.width - offsetX, 0.48*self.lsqGetSizeHeight)];
    }
}

- (void)createFilterChooseViewWith:(CGRect)theFrame
{
    CGFloat basicHeight = theFrame.size.height;
    CGFloat basicWidth = basicHeight*13/18;

    // 创建参数栏背景view
    _paramBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth - 50, theFrame.origin.y)];
    [self addSubview:_paramBackView];

    // 数值label
    _argValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(_paramBackView.lsqGetOriginX + _paramBackView.lsqGetSizeWidth, _paramBackView.lsqGetOriginY, 50, _paramBackView.lsqGetSizeHeight)];
    _argValueLabel.text = @"0%";
    _argValueLabel.textColor = HEXCOLOR(0x22bbf4);
    _argValueLabel.font = [UIFont systemFontOfSize:13];
    _argValueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_argValueLabel];

    // 美颜按钮
    _beautyBorderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, basicWidth, basicHeight)];
    _beautyBorderView.center = CGPointMake(10 + basicWidth/2, theFrame.origin.y + theFrame.size.height/2);
    _beautyBorderView.layer.cornerRadius = 3;
    [self addSubview:_beautyBorderView];
    
    UIImage *beautyImage = [UIImage imageNamed:@"style_default_1.5.0_btn_beauty"];
    _beautyBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _beautyBorderView.lsqGetSizeWidth, _beautyBorderView.lsqGetSizeHeight)];
    _beautyBtn.center = CGPointMake(_beautyBorderView.lsqGetSizeWidth/2, _beautyBorderView.lsqGetSizeHeight/2);
    [_beautyBtn addTarget:self action:@selector(beautyButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_beautyBtn setImage:beautyImage forState:UIControlStateNormal];
    NSString *beautyBtnTitle = NSLocalizedString(@"lsq_filter_beautyArg", @"美颜");
    [_beautyBtn setTitle:beautyBtnTitle forState:UIControlStateNormal];
    [_beautyBtn setTitleColor:HEXCOLOR(0x22bbf4) forState:UIControlStateNormal];
    _beautyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _beautyBtn.adjustsImageWhenHighlighted = NO;
    _beautyBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _beautyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_beautyBtn setImageEdgeInsets:UIEdgeInsetsMake(_beautyBtn.lsqGetSizeHeight/2 - beautyImage.size.height, (_beautyBtn.lsqGetSizeWidth - beautyImage.size.width)/2, 0, 0)];
    CGFloat titleOffset = [beautyBtnTitle lsqColculateTextSizeWithFont:_beautyBtn.titleLabel.font maxWidth:100 maxHeihgt:50].width/2;
    [_beautyBtn setTitleEdgeInsets:UIEdgeInsetsMake(_beautyBtn.lsqGetSizeHeight/2 + 5, _beautyBtn.lsqGetSizeWidth/2 - beautyImage.size.width - titleOffset  , 0, 0)];
    _beautyBtn.selected = YES;
    // 该数值用于设置磨皮的滑动条的初始值，因为SDK中默认值为0.75，此处应保持一致，该数值更改时，请注意要更改 movieEditer中的响应初始值
    _beautyLevel = 0.75;
    [_beautyBorderView addSubview:_beautyBtn];

    // 创建滤镜scroll
    _filterScroll = [[UIScrollView alloc]initWithFrame:theFrame];
    _filterScroll.showsHorizontalScrollIndicator = false;
    _filterScroll.bounces = false;
    [self addSubview:_filterScroll];

    // 滤镜view配置参数
    CGFloat centerX = basicWidth/2;
    CGFloat centerY = _filterScroll.lsqGetSizeHeight/2;
    
    // 创建滤镜view
    NSInteger i = 200;
    CGFloat itemInterval = 7;
    for (NSString *name in _filters) {
        FilterItemView *basicView = [FilterItemView new];
        basicView.frame = CGRectMake(0, 0, basicWidth, basicHeight);
        basicView.center = CGPointMake(centerX, centerY);
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@",name];
        NSString *imageName = [NSString stringWithFormat:@"lsq_filter_thumb_%@",name];
        [basicView setViewInfoWith:imageName title:NSLocalizedString(title, @"滤镜") titleFontSize:12];
        basicView.clickDelegate = self;
        basicView.viewDescription = name;
        basicView.tag = i;
        [_filterScroll addSubview:basicView];
        if (i == _currentFilterTag) {
            [basicView refreshClickColor:HEXCOLOR(0x22bbf4)];
        }
        centerX += basicWidth + itemInterval;
        i++;
    }
    _filterScroll.contentSize = CGSizeMake(centerX - basicWidth/2, _filterScroll.bounds.size.height);
}

// 选择某个路径后创建上面的参数调节view
- (void)refreshAdjustParameterViewWith:(NSString *)filterDescription filterArgs:(NSArray *)args
{
    _filterDescription = filterDescription;
    _args = args;
    
    if (_paramBackView) {
        [_paramBackView removeAllSubviews];
        _argValueLabel.text = @"";
    }
    
    if ([filterDescription isEqualToString:@"Original"]) {
        return;
    }
    // 布局方式：allHeight初始化边距 + 参数栏整体居中
    CGFloat allHeight = 0;
    CGFloat centerHeightInterval = (_paramBackView.lsqGetSizeHeight - allHeight)/(args.count);
    CGFloat parameterHeight = 30;
    // 创建参数栏,目前Demo中使用的滤镜，只有一个参数，若添加多参数滤镜，需要调整此处布局
    for (int i = 0; i<args.count; i++) {
        TuSDKFilterArg *arg = args[i];
        
        // Demo 中美颜(即润滑) 效果通过 beautyLevel 调节，故此处忽略 美颜参数
        if ([arg.key isEqualToString:@"smoothing"]) {
            continue;
        }
        allHeight += centerHeightInterval;
        
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _paramBackView.lsqGetSizeWidth, parameterHeight)];
        backView.center = CGPointMake(_paramBackView.lsqGetSizeWidth/2, allHeight);
        [_paramBackView addSubview:backView];
        
        // 参数名
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, 40, parameterHeight)];
        nameLabel.textColor = HEXCOLOR(0x22bbf4);
        nameLabel.font = [UIFont systemFontOfSize:12];
        NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", arg.key];
        nameLabel.text = NSLocalizedString(title, @"");
        nameLabel.textAlignment = NSTextAlignmentRight;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [backView addSubview:nameLabel];
        
        // 滑动条
        CGFloat seekBarX = nameLabel.lsqGetOriginX + nameLabel.lsqGetSizeWidth + 15;
        TuSDKICSeekBar *seekBar = [TuSDKICSeekBar initWithFrame:CGRectMake(seekBarX, 0, _paramBackView.lsqGetSizeWidth - seekBarX - 10 , parameterHeight)];
        seekBar.delegate = self;
        seekBar.progress = ((TuSDKFilterArg *)args[i]).precent;
        seekBar.aboveView.backgroundColor = HEXCOLOR(0x22bbf4);
        seekBar.belowView.backgroundColor = lsqRGB(217, 217, 217);
        seekBar.dragView.backgroundColor = HEXCOLOR(0x22bbf4);
        seekBar.tag = i;
        [backView addSubview: seekBar];
        _argValueLabel.text = [NSString stringWithFormat:@"%d%%",(int)(seekBar.progress*100)];
    }
}

#pragma mark - 事件响应方法

// 美颜按钮点击响应事件
- (void)beautyButtonClickEvent:(UIButton *)btn
{
    _beautyBorderView.layer.borderWidth = 2;
    _beautyBorderView.layer.borderColor = HEXCOLOR(0x22bbf4).CGColor;
    [self changeBeautyParameter];
    
    // 取消美颜设置的边框
    [self refreshSelectedBounds:_currentFilterTag selectedColor:nil];
}

- (void)changeBeautyParameter
{
    if (_paramBackView) {
        [_paramBackView removeAllSubviews];
    }
    
    // 布局方式：参数栏整体居中
    CGFloat allHeight = 0;
    CGFloat centerHeightInterval = (_paramBackView.lsqGetSizeHeight - allHeight)/2;
    CGFloat parameterHeight = 30;
    // 创建参数栏
    allHeight += centerHeightInterval;
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _paramBackView.lsqGetSizeWidth, parameterHeight)];
    backView.center = CGPointMake(_paramBackView.lsqGetSizeWidth/2, allHeight);
    [_paramBackView addSubview:backView];
    
    // 参数名
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, 40, parameterHeight)];
    nameLabel.textColor = HEXCOLOR(0x22bbf4);
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.text = NSLocalizedString(@"lsq_filter_beautyArg", @"磨皮");
    nameLabel.textAlignment = NSTextAlignmentRight;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    [backView addSubview:nameLabel];
    
    // 滑动条
    CGFloat seekBarX = nameLabel.lsqGetOriginX + nameLabel.lsqGetSizeWidth + 15;
    TuSDKICSeekBar *seekBar = [TuSDKICSeekBar initWithFrame:CGRectMake(seekBarX, 0, _paramBackView.lsqGetSizeWidth - seekBarX - 10 , parameterHeight)];
    seekBar.delegate = self;
    seekBar.progress = _beautyLevel;
    seekBar.aboveView.backgroundColor = HEXCOLOR(0x22bbf4);
    seekBar.belowView.backgroundColor = lsqRGB(217, 217, 217);
    seekBar.dragView.backgroundColor = HEXCOLOR(0x22bbf4);
    seekBar.progress = _beautyLevel;
    _argValueLabel.text = [NSString stringWithFormat:@"%d%%",(int)(_beautyLevel*100)];
    seekBar.tag = 201;
    [backView addSubview: seekBar];
}

- (void)refreshSelectedBounds:(CGFloat)index selectedColor:(UIColor *)color
{
    for (UIView *view in _filterScroll.subviews) {
        if ([view isMemberOfClass:[FilterItemView class]]) {
            if (view.tag == index) {
                // 修改上一个点击效果
                FilterItemView * theView = (FilterItemView *)view;
                [theView refreshSelectedBoundsColor:color];
            }
        }
    }

}

#pragma mark -- 滤镜view点击的代理方法 BasicDisplayViewClickDelegate

// 滤镜view点击的响应代理方法
- (void)clickBasicViewWith:(NSString *)viewDescription withBasicTag:(NSInteger)tag
{
    _beautyBorderView.layer.borderWidth = 0;
    _beautyBorderView.layer.borderColor = [UIColor clearColor].CGColor;

    if (tag == _currentFilterTag) {
        [self refreshAdjustParameterViewWith:_filterDescription filterArgs:_args];
        // 取消美颜设置的边框
        [self refreshSelectedBounds:_currentFilterTag selectedColor:HEXCOLOR(0x22bbf4)];
        return;
    }
    for (UIView *view in _filterScroll.subviews) {
        if ([view isMemberOfClass:[FilterItemView class]]) {
            if (view.tag == _currentFilterTag) {
                // 修改上一个点击效果
                FilterItemView * theView = (FilterItemView *)view;
                [theView refreshClickColor:nil];
            }else if (view.tag == tag){
                // 更显当前点击控件效果
                FilterItemView * theView = (FilterItemView *)view;
                [theView refreshClickColor:HEXCOLOR(0x22bbf4)];
            }
        }
    }
    // 记录新值
    _currentFilterTag = tag;

    // 目前选择了某个滤镜
    if ([self.filterEventDelegate respondsToSelector:@selector(filterViewSwitchFilterWithCode:)]) {
        [self.filterEventDelegate filterViewSwitchFilterWithCode:viewDescription];
    }
}


#pragma mark -- 滑动条调整代理方法 TuSDKICSeekBarDelegate
// 滑动条调整的响应方法
- (void)onTuSDKICSeekBar:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress
{
    _argValueLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];

    if (seekbar.tag == 201) {
        // 美颜磨皮参数调整
        if (progress == 0) {
            if (_beautyBtn.selected) {
                [_beautyBtn setImage:[UIImage imageNamed:@"style_default_1.5.0_btn_beauty_unselected"] forState:UIControlStateNormal];
                [_beautyBtn setTitleColor:[UIColor lsqClorWithHex:@"#9fa0a0"] forState:UIControlStateNormal];
                _beautyBtn.selected = NO;
                _beautyBorderView.layer.borderWidth = 0;
                _beautyBorderView.layer.borderColor = [UIColor clearColor].CGColor;
            }
        }else{
            // 用selected 做显示状态改变的判断，防止无用的重复设置
            if (!_beautyBtn.selected) {
                [_beautyBtn setImage:[UIImage imageNamed:@"style_default_1.5.0_btn_beauty"] forState:UIControlStateNormal];
                [_beautyBtn setTitleColor:HEXCOLOR(0x22bbf4) forState:UIControlStateNormal];
                _beautyBtn.selected = YES;
                _beautyBorderView.layer.borderWidth = 2;
                _beautyBorderView.layer.borderColor = HEXCOLOR(0x22bbf4).CGColor;
            }
        }
        if ([self.filterEventDelegate respondsToSelector:@selector(filterViewChangeBeautyLevel:)]) {
            [self.filterEventDelegate filterViewChangeBeautyLevel:progress];
            _beautyLevel = progress;
        }
        return;
    }
    
    if ([self.filterEventDelegate respondsToSelector:@selector(filterViewParamChangedWith:changedProgress:)]) {
        [self.filterEventDelegate filterViewParamChangedWith:seekbar changedProgress:progress];
    }
}

- (void)dealloc
{
    for (UIView *view in _filterScroll.subviews) {
        [view removeAllSubviews];
    }
    _filterScroll = nil;
}


@end
