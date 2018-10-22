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
#import "FilterParamItemView.h"

@interface FilterView ()<FilterItemViewClickDelegate, FilterParamItemViewDelegate>
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
    UIButton *_clearFilterBtn;
    // 美颜的边框view
    UIView *_clearFilterBorderView;
    // 记录参数栏数据源信息
    NSString *_filterDescription;
    NSArray *_args;
    CGFloat _smoothingLevel;
    CGFloat _eyeSizeLevel;
    CGFloat _chinSizeLevel;
    
}

@end



@implementation FilterView


- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initDefaultData];
    }
    return self;
}

- (void)initDefaultData;
{
    _smoothingLevel = -1;
    _eyeSizeLevel = -1;
    _chinSizeLevel = -1;
}

#pragma mark - view method

- (void)createFilterWith:(NSArray *)filterArr
{
    _filters = filterArr;
    [self createFilterChooseView];
}

- (void)createFilterChooseView;
{
    _filterChooseView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:_filterChooseView];
    
    CGFloat filterItemHeight = 0.44*self.lsqGetSizeHeight;
    CGFloat filterItemWidth = filterItemHeight * 13/18;
    CGFloat offsetX = filterItemWidth + 10 + 7;
    CGFloat bottom = self.lsqGetSizeHeight/15;

    CGRect filterScrollFrame = CGRectMake(offsetX, self.lsqGetSizeHeight - filterItemHeight - bottom, self.bounds.size.width - offsetX, filterItemHeight);
    

    // 创建参数栏背景view
    _paramBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, self.lsqGetSizeWidth, filterScrollFrame.origin.y - 10)];
    [_filterChooseView addSubview:_paramBackView];


    // 清除滤镜按钮
    _clearFilterBorderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, filterItemWidth, filterItemHeight)];
    _clearFilterBorderView.center = CGPointMake(10 + filterItemWidth/2, filterScrollFrame.origin.y + filterScrollFrame.size.height/2);
    _clearFilterBorderView.layer.cornerRadius = 3;
    [_filterChooseView addSubview:_clearFilterBorderView];
    
    _clearFilterBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _clearFilterBorderView.lsqGetSizeWidth, _clearFilterBorderView.lsqGetSizeHeight)];
    _clearFilterBtn.center = CGPointMake(_clearFilterBorderView.lsqGetSizeWidth/2, _clearFilterBorderView.lsqGetSizeHeight/2);
    [_clearFilterBtn addTarget:self action:@selector(clickClearFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_clearFilterBtn setImage:[UIImage imageNamed:@"style_default_1.11_btn_effect_unselect"] forState:UIControlStateNormal];
    [_clearFilterBtn setImage:[UIImage imageNamed:@"style_default_1.11_btn_effect_select"] forState:UIControlStateSelected];
    [_clearFilterBorderView addSubview:_clearFilterBtn];
    
    // 创建滤镜scroll
    _filterScroll = [[UIScrollView alloc]initWithFrame:filterScrollFrame];
    _filterScroll.showsHorizontalScrollIndicator = false;
    _filterScroll.bounces = false;
    [_filterChooseView addSubview:_filterScroll];

    // 滤镜view配置参数
    CGFloat centerX = filterItemWidth/2;
    CGFloat centerY = _filterScroll.lsqGetSizeHeight/2;
    
    // 创建滤镜view
    NSInteger i = 200;
    CGFloat itemInterval = 12;
    for (NSString *name in _filters) {
        FilterItemView *basicView = [FilterItemView new];
        basicView.frame = CGRectMake(0, 0, filterItemWidth, filterItemHeight);
        basicView.center = CGPointMake(centerX, centerY);
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@",name];
        NSString *imageName = [NSString stringWithFormat:@"lsq_filter_thumb_%@",name];
        [basicView setViewInfoWith:imageName title:NSLocalizedString(title, @"滤镜") titleFontSize:12];
        basicView.clickDelegate = self;
        basicView.viewDescription = name;
        basicView.tag = i;
        [_filterScroll addSubview:basicView];
        if (i == _currentFilterTag) {
            [basicView refreshClickColor:lsqRGB(244, 161, 24)];
        }
        centerX += filterItemWidth + itemInterval;
        i++;
    }
    _filterScroll.contentSize = CGSizeMake(centerX - filterItemWidth/2, _filterScroll.bounds.size.height);
    [self clickClearFilterBtn:nil];
}

// 选择某个滤镜后创建上面的参数调节view
- (void)refreshAdjustParameterViewWith:(NSString *)filterDescription filterArgs:(NSArray *)args
{
    _filterDescription = filterDescription;
    _args = args;
    
    if (!args ) {
        // 空滤镜
        return;
    }

    if (_paramBackView) {
        [_paramBackView removeAllSubviews];
    }
    
    NSMutableArray *beautyKeys = [[NSMutableArray alloc]init];
    NSMutableArray<NSNumber *> *originProgressArr = [[NSMutableArray alloc]init];
    
    NSInteger allCount = args.count;
    
//    参数   smoothing: 润滑
//          eyeSize: 大眼
//          chinSize: 瘦脸
//          noseSize: 瘦鼻
//          mouthWidth: 嘴型
//          eyeAngle: 眼角
//          archEyebrow: 细眉
//          jawSize: 下巴
//          whitening: 白皙
//          mixied: 效果
    // demo创建smoothing，eyeSize，chinSize，whitening，mixied参数调节栏，用户可自定义其他参数调节栏的创建
    for (TuSDKFilterArg *arg in args) {
        if ([arg.key isEqualToString:@"smoothing"] && !_isHiddenSmoothingParamSingleAdjust) {
            [beautyKeys addObject:arg.key];
            [originProgressArr addObject:@(arg.precent)];
            allCount --;
        }else if([arg.key isEqualToString:@"eyeSize"]){
            if (!_isHiddenEyeChinParam) {
                [beautyKeys addObject:arg.key];
                [originProgressArr addObject:@(arg.precent)];
            }
            allCount --;
        }else if([arg.key isEqualToString:@"chinSize"]){
            if (!_isHiddenEyeChinParam) {
                [beautyKeys addObject:arg.key];
                [originProgressArr addObject:@(arg.precent)];
            }
            allCount --;
        }else if([arg.key isEqualToString:@"noseSize"]){
            allCount --;
        }else if([arg.key isEqualToString:@"mouthWidth"]){
            allCount --;
        }else if([arg.key isEqualToString:@"eyeDis"]){
            allCount --;
        }else if([arg.key isEqualToString:@"eyeAngle"]){
            allCount --;
        }else if([arg.key isEqualToString:@"archEyebrow"]){
            allCount --;
        }else if([arg.key isEqualToString:@"jawSize"]){
            allCount --;
        }
    }
    
    // 布局方式：参数栏整体居中
    CGFloat parameterHeight = (_paramBackView.lsqGetSizeHeight/(allCount > 0 ? allCount : 1));
    CGFloat itemHeight = parameterHeight > 40 ? 40 : parameterHeight;
    CGFloat centerY = -parameterHeight/2;
    CGFloat centerX = _paramBackView.lsqGetSizeWidth/2;
    // 创建参数栏,目前Demo中使用的滤镜，只有一个参数，若添加多参数滤镜，需要调整此处布局
    for (int i = 0; i<args.count; i++) {
        TuSDKFilterArg *arg = args[i];

        if ([filterDescription isEqualToString:@"Original"]) {
            break;
        }
        
        // 抽离每个滤镜中的 润滑、大眼、瘦脸，通过beautyView中的参数调节逻辑 进行统一调节设置； 若有其他需求，可自行更改
        if (([arg.key isEqualToString:@"smoothing"] && !_isHiddenSmoothingParamSingleAdjust)|| [arg.key isEqualToString:@"eyeSize"] || [arg.key isEqualToString:@"chinSize"]) {
            continue;
        }
        
        // demo中只创建白皙和效果参数调节栏，更多参数调节栏可自定义创建
        if ([arg.key isEqualToString:@"mixied"] || [arg.key isEqualToString:@"whitening"]) {
            
            centerY += parameterHeight;
            
            FilterParamItemView *paramItem = [[FilterParamItemView alloc]initWithFrame:CGRectMake(0, 0, _paramBackView.lsqGetSizeWidth, itemHeight)];
            paramItem.center = CGPointMake(centerX, centerY);
            NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", arg.key];
            [paramItem initParamViewWith:NSLocalizedString(title,@"效果") originProgress:((TuSDKFilterArg *)args[i]).precent];
            paramItem.paramKey = arg.key;
            paramItem.itemDelegate = self;
            [_paramBackView addSubview:paramItem];
        }
    }
    
    if (_isHiddenSmoothingParamSingleAdjust && _isHiddenEyeChinParam) return;
    
    [self createBeautyParameterWith:beautyKeys originProgressArr:originProgressArr];
}

// 创建美颜参数调节栏，包含 磨皮(润滑)、大眼、瘦脸
- (void)createBeautyParameterWith:(NSArray *)beautyKeys originProgressArr:(NSArray<NSNumber *> *)originProgressArr;
{
    if (_beautyParamView) {
        [_beautyParamView removeAllSubviews];
    }else{
        _beautyParamView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, self.lsqGetSizeWidth, self.lsqGetSizeHeight - 20)];
        [self addSubview:_beautyParamView];
    }
    
    if (!beautyKeys || beautyKeys.count < 1) return;
    
    // 布局方式：参数栏整体居中
    CGFloat parameterHeight = _beautyParamView.lsqGetSizeHeight/beautyKeys.count;
    CGFloat itemHeight = parameterHeight > 40 ? 40 : parameterHeight;
    CGFloat centerY = -parameterHeight/2;
    CGFloat centerX = _paramBackView.lsqGetSizeWidth/2;
    
    // 创建参数栏,目前Demo中使用的滤镜，参数统一，若添加更多参数的滤镜，需要调整此处布局
    for (int i = 0; i<beautyKeys.count; i++) {
        NSString *key = beautyKeys[i];
        CGFloat progress = (i >= originProgressArr.count ? 80 : originProgressArr[i].floatValue);

        if ([key isEqualToString:@"smoothing"]) {
            if (_smoothingLevel != -1) progress = _smoothingLevel;
        }else if ([key isEqualToString:@"eyeSize"]){
            if (_eyeSizeLevel != -1) progress = _eyeSizeLevel;
        }else if ([key isEqualToString:@"chinSize"]){
            if (_chinSizeLevel != -1) progress = _chinSizeLevel;
        }

        centerY += parameterHeight;
        
        FilterParamItemView *paramItem = [[FilterParamItemView alloc]initWithFrame:CGRectMake(0, 0, _paramBackView.lsqGetSizeWidth, itemHeight)];
        paramItem.center = CGPointMake(centerX, centerY);
        NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", beautyKeys[i]];
        [paramItem initParamViewWith:NSLocalizedString(title,@"美颜") originProgress: progress];
        paramItem.paramKey = beautyKeys[i];
        paramItem.itemDelegate = self;
        [_beautyParamView addSubview:paramItem];
    }
    
    [self resetBeautyParamWith:beautyKeys];
}


#pragma mark - event method

// 美颜按钮点击响应事件
- (void)clickClearFilterBtn:(UIButton *)btn
{
    [self enableBeautyParam:NO];
    [_paramBackView removeAllSubviews];
    [self selectClearBtn:YES];
    // 取消选中滤镜的边框设置
    [self refreshSelectedFilter:-1 lastFilterIndex:_currentFilterTag selectedColor:nil];
    _currentFilterTag = -1;
    
    // 清除滤镜
    if ([self.filterEventDelegate respondsToSelector:@selector(filterViewSwitchFilterWithCode:)]) {
        [self.filterEventDelegate filterViewSwitchFilterWithCode:nil];
    }
}

- (void)selectClearBtn:(BOOL)selected;
{
    if (selected) {
        _clearFilterBtn.selected = YES;
        _clearFilterBorderView.layer.borderWidth = 2;
        _clearFilterBorderView.layer.borderColor = lsqRGB(244, 161, 24).CGColor;
    }else{
        _clearFilterBtn.selected = NO;
        _clearFilterBorderView.layer.borderWidth = 0;
        _clearFilterBorderView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

/**
 刷新某个滤镜的选中状态

 @param newIndex 当前选中滤镜
 @param lastIndex 上一个选中的滤镜
 @param color 选中颜色
 */
- (void)refreshSelectedFilter:(NSInteger)newIndex lastFilterIndex:(NSInteger)lastIndex selectedColor:(UIColor *)color
{
    for (UIView *view in _filterScroll.subviews) {
        if ([view isMemberOfClass:[FilterItemView class]]) {
            if (view.tag == lastIndex) {
                // 修改上一个点击效果
                FilterItemView * theView = (FilterItemView *)view;
                [theView refreshClickColor:nil];
            }else if (view.tag == newIndex){
                // 更改当前点击控件效果
                FilterItemView * theView = (FilterItemView *)view;
                [theView refreshClickColor:color];
            }
        }
    }
}

#pragma mark - help method

// 美颜相关参数栏是否可调节
- (void)enableBeautyParam:(BOOL)enabled;
{
    if (enabled) {
        for (FilterParamItemView *paramItem in _beautyParamView.subviews) {
            if ([paramItem isMemberOfClass:[FilterParamItemView class]]) {
                
                if ([paramItem.paramKey isEqualToString:@"smoothing"]) {
                    if(_smoothingLevel != -1) paramItem.progress = _smoothingLevel;
                }else if ([paramItem.paramKey isEqualToString:@"eyeSize"]){
                    if(_eyeSizeLevel != -1) paramItem.progress = _eyeSizeLevel;
                }else if ([paramItem.paramKey isEqualToString:@"chinSize"]){
                    if(_chinSizeLevel != -1) paramItem.progress = _chinSizeLevel;
                }
                
                paramItem.mainColor = [UIColor lsqClorWithHex:@"#f4a11a"];
            }
        }
    }else{
        for (FilterParamItemView *paramItem in _beautyParamView.subviews) {
            if ([paramItem isMemberOfClass:[FilterParamItemView class]]) {
                paramItem.progress = 0;
                paramItem.mainColor = [UIColor grayColor];
                paramItem.userInteractionEnabled = NO;
            }
        }
    }
}

// 重置美颜相关效果
- (void)resetBeautyParamWith:(NSArray *)beautyKeys;
{
    BOOL needChangeSmoothing = NO;
    BOOL needChangeEyeSize = NO;
    BOOL needChangeChinSize = NO;
    
    for (NSString *key in beautyKeys) {
        if ([key isEqualToString:@"smoothing"]) {
            needChangeSmoothing = YES;
        }else if ([key isEqualToString:@"eyeSize"]){
            needChangeEyeSize = YES;
        }else if ([key isEqualToString:@"chinSize"]){
            needChangeChinSize = YES;
        }
    }
    
    for (TuSDKFilterArg *arg in _args) {
        if ([arg.key isEqualToString:@"smoothing"]) {
            if (needChangeSmoothing && _smoothingLevel != -1) arg.precent = _smoothingLevel;
        }else if ([arg.key isEqualToString:@"eyeSize"]){
            if (needChangeEyeSize && _eyeSizeLevel != -1) arg.precent = _eyeSizeLevel;
        }else if ([arg.key isEqualToString:@"chinSize"]){
            if (needChangeChinSize && _chinSizeLevel != -1) arg.precent = _chinSizeLevel;
        }
    }

    BOOL beautyChange = needChangeSmoothing || needChangeEyeSize || needChangeChinSize;
    if (beautyChange && [self.filterEventDelegate respondsToSelector:@selector(filterViewParamChanged)]) {
        [self.filterEventDelegate filterViewParamChanged];
    }
}

#pragma mark - BasicDisplayViewClickDelegate

// 滤镜view点击的响应代理方法
- (void)clickBasicViewWith:(NSString *)viewDescription withBasicTag:(NSInteger)tag
{
    if (_currentFilterTag == tag) return;
    [self selectClearBtn:NO];
    [self enableBeautyParam:YES];
    [self refreshSelectedFilter:tag lastFilterIndex:_currentFilterTag selectedColor:lsqRGB(244, 161, 24)];
    // 记录新值
    _currentFilterTag = tag;

    // 目前选择了某个滤镜
    if ([self.filterEventDelegate respondsToSelector:@selector(filterViewSwitchFilterWithCode:)]) {
        [self.filterEventDelegate filterViewSwitchFilterWithCode:viewDescription];
    }
}

#pragma mark - FilterParamItemViewDelegate

// 滑动条调整的响应方法
- (void)filterParamItemView:(FilterParamItemView *)filterParamItemView changedProgress:(CGFloat)progress;
{
    // 调节参数限制，参数值越大，效果不一定越好，可根据场景选择最适合参数值
    if ([filterParamItemView.paramKey isEqualToString:@"smoothing"] && !_isHiddenSmoothingParamSingleAdjust) {
        _smoothingLevel = progress * 0.7;
    }else if ([filterParamItemView.paramKey isEqualToString:@"eyeSize"]){
        _eyeSizeLevel = progress * 0.7;
    }else if ([filterParamItemView.paramKey isEqualToString:@"chinSize"]){
        _chinSizeLevel = progress * 0.4;
    }
    
    for (TuSDKFilterArg *arg in _args) {
        if ([arg.key isEqualToString:filterParamItemView.paramKey]) {
            
            if([arg.key isEqualToString:@"mixied"]){
                arg.precent = progress * 0.7;
            }else if([arg.key isEqualToString:@"whitening"]){
                arg.precent = progress * 0.6;
            }else if([arg.key isEqualToString:@"smoothing"]){
                arg.precent = progress * 0.7;
            }else if([arg.key isEqualToString:@"eyeSize"]){
                arg.precent = progress * 0.7;
            }else if([arg.key isEqualToString:@"chinSize"]){
                arg.precent = progress * 0.4;
            }
        }
    }
    
    if ([self.filterEventDelegate respondsToSelector:@selector(filterViewParamChanged)]) {
        [self.filterEventDelegate filterViewParamChanged];
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
