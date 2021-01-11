//
//  CameraFilterPanelView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "CameraFilterPanelView.h"
#import "CameraNormalFilterListView.h"
#import "CameraComicsFilterListView.h"
#import "TuCameraFilterPackage.h"
#import "PageTabbar.h"
#import "ViewSlider.h"
#import "Constants.h"
#import "TuCameraFilterCell.h"
// 滤镜列表高度
static const CGFloat kFilterListHeight = 120;
// 滤镜列表与参数面板的间隔
static const CGFloat kFilterListParamtersViewSpacing = 24;
// tabbar 高度
static const CGFloat kFilterTabbarHeight = 36;

@interface CameraFilterPanelView () <PageTabbarDelegate,
                                    ViewSliderDataSource,
                                    ViewSliderDelegate,
                                    CameraNormalFilterListViewDelegate,
                                    CameraComicsFilterListViewDelegate
                                    >

/**
 普通滤镜列表
 */
@property (nonatomic, strong, readonly) CameraNormalFilterListView *normalFilterListView;

/**
 漫画滤镜列表
 */
@property (nonatomic, strong, readonly) CameraComicsFilterListView *comicsFilterListView;

/**
 参数面板
 */
@property (nonatomic, strong, readonly) ParametersAdjustView *paramtersView;

/**
 模糊背景
 */
@property (nonatomic, strong) UIVisualEffectView *effectBackgroundView;

/**
 重置按钮
 */
@property (nonatomic, strong) UIButton *unsetButton;

/**
 面板切换标签栏
 */
@property (nonatomic, strong) PageTabbar *tabbar;

/**
 页面切换控件
 */
@property (nonatomic, strong) ViewSlider *pageSlider;

/**
 需要过滤的滤镜参数
 */
@property (nonatomic, strong) NSArray *skippedFilterKeys;

@property (nonatomic, strong) NSMutableArray *filterViews;

/**
 垂直分割线
 */
@property (nonatomic, strong) CALayer *verticalSeparatorLayer;

/**
 水平分割线
 */
@property (nonatomic, strong) CALayer *horizontalSeparatorLayer;


@end

@implementation CameraFilterPanelView

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
    _skippedFilterKeys = @[kBeautySkinKeys, kBeautyFaceKeys];
    __weak typeof(self) weakSelf = self;
    
    self.filterTitles = [NSMutableArray array];
    self.filtersGroups = [NSMutableArray array];
    self.filtersOptions = [NSMutableArray array];
    
    //获取滤镜标题数组
    NSArray *titleDataSet = [[TuCameraFilterPackage sharePackage] titleGroupsWithComics:YES];
    //获取滤镜列表
    NSArray *filtersDataSet = [[TuCameraFilterPackage sharePackage] filterOptionsGroups];
    //获取滤镜codes列表
    NSArray *codesDataSet = [[TuCameraFilterPackage sharePackage] filterCodesGroups];

    [self.filterTitles addObjectsFromArray:titleDataSet];
    [self.filtersGroups addObjectsFromArray:codesDataSet];
    [self.filtersOptions addObjectsFromArray:filtersDataSet];

    // 模糊背景
    _effectBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self addSubview:_effectBackgroundView];
    
    
    for (int viewIndex = 0; viewIndex < self.filtersOptions.count; viewIndex++) {
        __weak typeof(self) weakSelf = self;
        // 普通滤镜列表
        CameraNormalFilterListView *filterListView = [[CameraNormalFilterListView alloc] initWithFrame:CGRectZero];
        filterListView.tag = viewIndex;
        filterListView.delegate = self;
        
        filterListView.filterCodes = self.filtersGroups[viewIndex];
        filterListView.itemViewTapActionHandler = ^(HorizontalListItemView *filterListView, HorizontalListItemView *selectedItemView, NSString *filterCode) {
            
            weakSelf.paramtersView.hidden = selectedItemView.tapCount < selectedItemView.maxTapCount;

            if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didSelectedFilterCode:)]) {
                [weakSelf.delegate filterPanel:weakSelf didSelectedFilterCode:filterCode];
            }
            // 不能在此处调用 reloadData，应在外部滤镜应用后才调用
        };
        [self.filterViews addObject:filterListView];
    }
    
    // 漫画滤镜列表
    _comicsFilterListView = [[CameraComicsFilterListView alloc] initWithFrame:CGRectZero];
    _comicsFilterListView.tag = self.filterTitles.count - 1;
    _comicsFilterListView.delegate = self;
    _comicsFilterListView.itemViewTapActionHandler = ^(HorizontalListItemView *filterListView, HorizontalListItemView *selectedItemView, NSString *filterCode) {
        weakSelf.paramtersView.hidden = YES;
        if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didSelectedFilterCode:)]) {
            [weakSelf.delegate filterPanel:weakSelf didSelectedFilterCode:filterCode];
        }
        // 不能在此处调用 reloadData，应在外部滤镜应用后才调用
    };
    
    // 参数面板
    _paramtersView = [[ParametersAdjustView alloc] initWithFrame:CGRectZero];
    [self addSubview:_paramtersView];
    _paramtersView.hidden = YES;
    
    _verticalSeparatorLayer = [CALayer layer];
    [self.layer addSublayer:_verticalSeparatorLayer];
    _verticalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    _horizontalSeparatorLayer = [CALayer layer];
    [self.layer addSublayer:_horizontalSeparatorLayer];
    _horizontalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    
    //重置按钮
    self.unsetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.unsetButton setImage:[UIImage imageNamed:@"video_ic_nix"] forState:0];
    [self.unsetButton addTarget:self action:@selector(unsetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.unsetButton];
    
    // 分页标签栏
    PageTabbar *tabbar = [[PageTabbar alloc] initWithFrame:CGRectZero];
    [self addSubview:tabbar];
    _tabbar = tabbar;
    tabbar.trackerSize = CGSizeMake(48, 2);
    tabbar.itemSelectedColor = [UIColor whiteColor];
    tabbar.itemNormalColor = [UIColor colorWithWhite:1 alpha:.25];
    tabbar.delegate = self;
    tabbar.itemTitles = self.filterTitles;
    tabbar.disableAnimation = YES;
    tabbar.itemTitleFont = [UIFont systemFontOfSize:13];
    tabbar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    // 分页控件
    ViewSlider *pageSlider = [[ViewSlider alloc] initWithFrame:CGRectZero];
    [self addSubview:pageSlider];
    _pageSlider = pageSlider;
    pageSlider.dataSource = self;
    pageSlider.delegate = self;
    pageSlider.selectedIndex = 0;
    pageSlider.disableSlide = YES;

    [tabbar setSelectedIndex:0];
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    CGRect safeBounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
    }
    
    const CGFloat tabbarY = CGRectGetMaxY(safeBounds) - kFilterListHeight;
    _unsetButton.frame = CGRectMake(CGRectGetMinX(safeBounds), tabbarY, 52, kFilterTabbarHeight);
    
    _tabbar.frame = CGRectMake(CGRectGetMaxX(_unsetButton.frame) + 10, tabbarY, CGRectGetWidth(safeBounds) - CGRectGetMaxX(_unsetButton.frame), kFilterTabbarHeight);
    const CGFloat pageSliderHeight = kFilterListHeight - kFilterTabbarHeight;
    _pageSlider.frame = CGRectMake(CGRectGetMinX(safeBounds), CGRectGetMaxY(_tabbar.frame), CGRectGetWidth(safeBounds), pageSliderHeight);
        
    _verticalSeparatorLayer.frame = CGRectMake(CGRectGetMaxX(_unsetButton.frame), CGRectGetMinY(_unsetButton.frame), 1, kFilterTabbarHeight);
    _horizontalSeparatorLayer.frame = CGRectMake(0, CGRectGetMaxY(_unsetButton.frame), CGRectGetWidth(safeBounds), 1);
    
    const CGFloat paramtersViewAvailableHeight = CGRectGetMaxY(safeBounds) - kFilterListHeight - kFilterListParamtersViewSpacing;
    const CGFloat paramtersViewLeftMargin = 16;
    const CGFloat paramtersViewRightMargin = 9;
    const CGFloat paramtersViewHeight = _paramtersView.contentHeight;
    _paramtersView.frame =
    CGRectMake(CGRectGetMinX(safeBounds) + paramtersViewLeftMargin,
               paramtersViewAvailableHeight - paramtersViewHeight,
               CGRectGetWidth(safeBounds) - paramtersViewLeftMargin - paramtersViewRightMargin,
               paramtersViewHeight);
    _effectBackgroundView.frame = CGRectMake(0, tabbarY, size.width, size.height - tabbarY);
    
    if (self.filterTitles.count < 6) {
        
        CGFloat tabBarWidth = (CGRectGetWidth(safeBounds) - CGRectGetMinX(_tabbar.frame)) / self.filterTitles.count;
        _tabbar.itemWidth = tabBarWidth;
        
    } else {
        _tabbar.itemsSpacing = 32;
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(-1, kFilterListParamtersViewSpacing + kFilterListHeight + _paramtersView.intrinsicContentSize.height);
}

/**
 判断滤镜参数是否过滤

 @param key 滤镜参数
 @return 是否过滤
 */
- (BOOL)shouldSkipFilterKey:(NSString *)key {
    BOOL isBeautyFilterKey = NO;
    if (!key.length) return isBeautyFilterKey;
    for (NSString *beautyFilterKey in _skippedFilterKeys) {
        if ([beautyFilterKey isEqualToString:key]) {
            isBeautyFilterKey = YES;
            break;
        }
    }
    return isBeautyFilterKey;
}

#pragma mark - property

/**
 重置滤镜
 */
- (void)unsetButtonAction:(UIButton *)sender
{
    self.paramtersView.hidden = YES;

    for (NSInteger viewIndex = 0; viewIndex < self.filterTitles.count; viewIndex++)
    {
        if (viewIndex == self.filterTitles.count - 1)
        {
            _comicsFilterListView.selectedIndex = -1;
        }
        
        else
        {
            CameraNormalFilterListView *filterView = self.filterViews[viewIndex];
            filterView.selectedIndex = -1;
        }
    }

    if ([self.delegate respondsToSelector:@selector(filterPanel:didSelectedFilterCode:)])
    {
        [self.delegate filterPanel:self didSelectedFilterCode:nil];
    }
}

- (void)setSelectedFilterCode:(NSString *)selectedFilterCode {
    _selectedFilterCode = selectedFilterCode;

    for (NSInteger viewIndex = 0; viewIndex < self.filterTitles.count; viewIndex++)
    {
        if (viewIndex == self.filterTitles.count - 1)
        {
            NSArray *filterCodes = @[kCameraComicsFilterCodes];
            
            if ([filterCodes containsObject:selectedFilterCode])
            {
                _comicsFilterListView.selectedFilterCode = selectedFilterCode;
            }
            else
            {
                _comicsFilterListView.selectedIndex = -1;
            }
        }
        else
        {
            CameraNormalFilterListView *filterView = self.filterViews[viewIndex];
            NSArray *filterGroup = self.filtersGroups[viewIndex];
            if ([filterGroup containsObject:selectedFilterCode])
            {
                filterView.selectedFilterCode = selectedFilterCode;
            }
            else
            {
                filterView.selectedIndex = -1;
            }
        }
    }
}

- (BOOL)display {
    return self.alpha > 0.0;
}

- (NSInteger)selectedTabIndex {
    return _tabbar.selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    _tabbar.selectedIndex = selectedIndex;
}


#pragma mark - public

/**
 重载滤镜参数数据
 */
- (void)reloadFilterParamters {
    if (!self.display) return;
    if (_tabbar.selectedIndex == _filterTitles.count - 1) {
        _paramtersView.hidden = YES;
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    
    [_paramtersView setupWithParameterCount:1 config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent, double defaultValue)) {
        NSString *parameterName = [self.dataSource filterPanel:weakSelf  paramterNameAtIndex:index];
        // 跳过美颜、美型滤镜参数
        BOOL shouldSkip = [self shouldSkipFilterKey:parameterName];
        if (!shouldSkip) {
            double percentVale = [self.dataSource filterPanel:weakSelf percentValueAtIndex:index];
            parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
            
            parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), percentVale, percentVale);
        }
    } valueChange:^(NSUInteger index, double percent) {
            
        if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didChangeValue:paramterIndex:)]) {
            [weakSelf.delegate filterPanel:weakSelf didChangeValue:percent paramterIndex:index];
        }
    }];
}

- (NSInteger)numberOfParamters
{
    return [self.filtersGroups[self.selectedTabIndex] count];;
}

#pragma mark - PageTabbarDelegate


/**
 标签项选中回调
 
 @param tabbar 标签栏对象
 @param fromIndex 起始索引
 @param toIndex 目标索引
 */
- (void)tabbar:(PageTabbar *)tabbar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    _pageSlider.selectedIndex = toIndex;

    [self reloadFilterParamters];
    if ([self.delegate respondsToSelector:@selector(filterPanel:didSwitchTabIndex:)]) {
        [self.delegate filterPanel:self didSwitchTabIndex:toIndex];
    }
}

#pragma mark - ViewSliderDataSource

/**
 分页数量
 */
- (NSInteger)numberOfViewsInSlider:(ViewSlider *)slider {
    return self.filterTitles.count;
}

/**
 各分页显示的视图
 */
- (UIView *)viewSlider:(ViewSlider *)slider viewAtIndex:(NSInteger)index {

    if (index == self.filterTitles.count - 1)
    {
        return _comicsFilterListView;
    }
    else
    {
        // 普通滤镜列表
        CameraNormalFilterListView *filterListView = self.filterViews[index];
        return filterListView;
    }
}

#pragma mark - CameraNormalFilterListViewDelegate
- (void)tuCameraNormalViewScrollToViewLeft
{
//    NSLog(@"普通滤镜滑动到左侧");
//    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanel:toIndex:direction:)])
//    {
//        if (self.tabbar.selectedIndex == 0)
//        {
//            self.tabbar.selectedIndex = self.filterTitles.count - 1;
//        }
//        else
//        {
//            self.tabbar.selectedIndex--;
//        }
//        [self.delegate filterPanel:self toIndex:self.tabbar.selectedIndex direction:TuFilterViewScrollDirectionLeft];
//    }
}

- (void)tuCameraNormalViewScrollToViewRight
{
//    NSLog(@"普通滤镜滑动到右侧");
//    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanel:toIndex:direction:)])
//    {
//        self.tabbar.selectedIndex++;
//        [self.delegate filterPanel:self toIndex:self.tabbar.selectedIndex direction:TuFilterViewScrollDirectionRight];
//    }
}

#pragma mark - CameraComicsFilterListViewDelegate
- (void)tuCameraComicsViewScrollToViewLeft
{
//    NSLog(@"漫画滤镜滑动到左侧");
//    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanel:toIndex:direction:)])
//    {
//        self.tabbar.selectedIndex--;
//        [self.delegate filterPanel:self toIndex:self.tabbar.selectedIndex direction:TuFilterViewScrollDirectionLeft];
//    }
}

- (void)tuCameraComicsViewScrollToViewRight
{
//    NSLog(@"漫画滤镜滑动到右侧");
//    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanel:toIndex:direction:)])
//    {
//        self.tabbar.selectedIndex = 0;
//        [self.delegate filterPanel:self toIndex:self.tabbar.selectedIndex direction:TuFilterViewScrollDirectionRight];
//    }
}

#pragma mark - touch

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01 || ![self pointInside:point withEvent:event]) return nil;
    UIView *hitView = [super hitTest:point withEvent:event];
    // 响应子视图
    if (hitView != self && !hitView.hidden) {
        return hitView;
    }
    return nil;
}

#pragma mark - private
- (NSMutableArray *)filterViews
{
    if (!_filterViews) {
        _filterViews = [NSMutableArray array];
    }
    return _filterViews;
}

@end
