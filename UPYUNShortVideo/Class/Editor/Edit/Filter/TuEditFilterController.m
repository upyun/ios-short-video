//
//  TuEditFilterController.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/7/23.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuEditFilterController.h"
#import "CameraNormalFilterListView.h"
#import "ParametersAdjustView.h"
#import "PageTabbar.h"
#import "ViewSlider.h"

// 滤镜列表高度
static const CGFloat kFilterListHeight = 120;
// 滤镜列表与参数面板的间隔
static const CGFloat kFilterListParamtersViewSpacing = 24;
// tabbar 高度
static const CGFloat kFilterTabbarHeight = 36;
//预览区域底部缩进
static const CGFloat kFilterBottomOffset = 172;

@interface TuEditFilterController ()<PageTabbarDelegate, ViewSliderDataSource, ViewSliderDelegate>

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
 标题数组
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *filterTitles;
/**
 滤镜组-滤镜数量
 */
@property (nonatomic, strong) NSMutableArray *filtersGroups;
@property (nonatomic, strong) NSMutableArray *filtersOptions;

/**
 参数面板
 */
@property (nonatomic, strong, readonly) ParametersAdjustView *paramtersView;
/**
 选中的下标
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 选中的页面
 */
@property (nonatomic, strong) CameraNormalFilterListView *selectFilterView;

/**
 垂直分割线
 */
@property (nonatomic, strong) CALayer *verticalSeparatorLayer;

/**
 水平分割线
 */
@property (nonatomic, strong) CALayer *horizontalSeparatorLayer;

@end

@implementation TuEditFilterController


+ (CGFloat)bottomPreviewOffset
{
    return kFilterBottomOffset;
}

/**
 完成按钮事件

 @param sender 完成按钮
 */
- (void)doneButtonAction:(UIButton *)sender
{
    [super doneButtonAction:sender];
}

/**
 取消按钮事件

 @param sender 取消按钮
 */
- (void)cancelButtonAction:(UIButton *)sender {
    [super cancelButtonAction:sender];
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeFilter];
    for (TuSDKMediaFilterEffect *initialEffect in self.initialEffects) {

        [self.movieEditor addMediaEffect:initialEffect];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithSubViews];
    
    // Do any additional setup after loading the view.
}



- (void)initWithSubViews
{
    self.title = NSLocalizedStringFromTable(@"tu_滤镜", @"VideoDemo", @"滤镜");
    
    // 开始播放
    [self.movieEditor startPreview];
    
    
    self.filterTitles = [NSMutableArray array];
    self.filtersGroups = [NSMutableArray array];
    self.filtersOptions = [NSMutableArray array];
    
    NSString *configPath = [TuSDKTSBundle sdkBundleOther:lsqSdkConfigs];
    NSString *sJson = [NSString stringWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:nil];
    TuSDKConfig *lsqSDKConfig = [TuSDKConfig initWithString:sJson];
    
    
    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *options = [NSMutableArray array];
    NSMutableArray *groups = [NSMutableArray array];
    
    for (TuSDKFilterGroup *filterGroup in lsqSDKConfig.filterGroups)
    {
        if (filterGroup.groupFilterType == lsqGroupFilterTypeGeneral)
        {
            
            [titles addObject: NSLocalizedStringFromTable(filterGroup.name, @"TuSDKConstants", @"无需国际化")];
            
            [options addObject:filterGroup.filters];
            
            NSMutableArray *filters = [NSMutableArray arrayWithCapacity:filterGroup.filters.count];
            
            for (TuSDKFilterOption *option in filterGroup.filters) {
                [filters addObject:[option.name componentsSeparatedByString:@"lsq_filter_"].lastObject];
            }
            
            [groups addObject:filters];
        }
    }
    
    [self.filterTitles addObjectsFromArray:[[titles reverseObjectEnumerator] allObjects]];
    
    [self.filtersGroups addObjectsFromArray:[[groups reverseObjectEnumerator] allObjects]];
    [self.filtersOptions addObjectsFromArray:options];
    
    //重置按钮
    self.unsetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.unsetButton setImage:[UIImage imageNamed:@"video_ic_nix"] forState:0];
    [self.unsetButton addTarget:self action:@selector(unsetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.unsetButton];
    
    // 分页标签栏
    PageTabbar *tabbar = [[PageTabbar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tabbar];
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
    [self.view addSubview:pageSlider];
    _pageSlider = pageSlider;
    pageSlider.dataSource = self;
    pageSlider.delegate = self;
    pageSlider.selectedIndex = 0;
    pageSlider.disableSlide = YES;
    
    // 参数面板
    _paramtersView = [[ParametersAdjustView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_paramtersView];
    _paramtersView.hidden = YES;
    
    _verticalSeparatorLayer = [CALayer layer];
    [self.view.layer addSublayer:_verticalSeparatorLayer];
    _verticalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    _horizontalSeparatorLayer = [CALayer layer];
    [self.view.layer addSublayer:_horizontalSeparatorLayer];
    _horizontalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect safeBounds = self.view.frame;
    const CGFloat pageSliderHeight = kFilterListHeight - kFilterTabbarHeight;
    //间隔高度
    CGFloat marginHeight = 0;
    CGFloat spaceHeight = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        marginHeight = lsq_TAB_BAR_HEIGHT;
        spaceHeight = kFilterListParamtersViewSpacing;
    }
    
    self.unsetButton.frame = CGRectMake(0, CGRectGetMaxY(self.movieEditor.holderView.frame) + marginHeight, 52, kFilterTabbarHeight);
    self.tabbar.frame = CGRectMake(CGRectGetMaxX(_unsetButton.frame) + 10, CGRectGetMinY(_unsetButton.frame), CGRectGetWidth(safeBounds) - CGRectGetMaxX(_unsetButton.frame), kFilterTabbarHeight);
    
    _pageSlider.frame = CGRectMake(CGRectGetMinX(safeBounds), CGRectGetMaxY(_tabbar.frame), CGRectGetWidth(safeBounds), pageSliderHeight);
    
    const CGFloat paramtersViewAvailableHeight = CGRectGetMaxY(safeBounds) - CGRectGetHeight(self.unsetButton.frame) - spaceHeight - kFilterBottomOffset;
    const CGFloat paramtersViewLeftMargin = 16;
    const CGFloat paramtersViewRightMargin = 9;
    const CGFloat paramtersViewHeight = _paramtersView.contentHeight;
    
    _paramtersView.frame =
    CGRectMake(CGRectGetMinX(safeBounds) + paramtersViewLeftMargin,
               paramtersViewAvailableHeight - paramtersViewHeight,
               CGRectGetWidth(safeBounds) - paramtersViewLeftMargin - paramtersViewRightMargin,
               paramtersViewHeight);
    
    _verticalSeparatorLayer.frame = CGRectMake(CGRectGetMaxX(_unsetButton.frame), CGRectGetMinY(_unsetButton.frame), 1, kFilterTabbarHeight);
    _horizontalSeparatorLayer.frame = CGRectMake(0, CGRectGetMaxY(_unsetButton.frame), CGRectGetWidth(safeBounds), 1);
    
    if (self.filtersGroups.count < 6) {
        
        CGFloat tabBarWidth = (CGRectGetWidth(safeBounds) - CGRectGetMinX(_tabbar.frame)) / self.filtersGroups.count;
        _tabbar.itemWidth = tabBarWidth;
        
    } else {
        _tabbar.itemsSpacing = 32;
    }
}

/**
 移除所有特效
 */
- (void)unsetButtonAction:(UIButton *)sender
{
    self.paramtersView.hidden = YES;
    
    _selectFilterView.selectedIndex = -1;
    
    //移除所有的滤镜特效
    [self switchFilterWithCode:nil];
}

#pragma mark - ViewSliderDataSource
- (NSInteger)numberOfViewsInSlider:(ViewSlider *)slider
{
    return self.filterTitles.count;
}

/**
 各分页显示的视图
*/
- (UIView *)viewSlider:(ViewSlider *)slider viewAtIndex:(NSInteger)index
{
    __weak typeof(self) weakSelf = self;
    //普通滤镜列表
    CameraNormalFilterListView *filterListView = [[CameraNormalFilterListView alloc] initWithFrame:CGRectZero];

    filterListView.tag = _tabbar.selectedIndex;
    filterListView.filterCodes = self.filtersGroups[index];
    filterListView.itemViewTapActionHandler = ^(HorizontalListItemView *filterListView, HorizontalListItemView *selectedItemView, NSString *filterCode) {
        weakSelf.paramtersView.hidden = selectedItemView.tapCount < selectedItemView.maxTapCount;

        [weakSelf switchFilterWithCode:filterCode];
    };
    if (index == 0) {
        filterListView.selectedIndex = 0;
        [self switchFilterWithCode:self.filtersGroups[0][0]];
    }
    return filterListView;
}

- (void)viewSlider:(ViewSlider *)slider didSwitchToIndex:(NSInteger)index
{
    _selectedIndex = index;
    _selectFilterView = (CameraNormalFilterListView *)slider.currentView;
}

/**
 通过给定的滤镜码切换滤镜
 @param filterCode 滤镜码
 
*/
- (void)switchFilterWithCode:(NSString *)filterCode
{
    TuSDKMediaFilterEffect *filterEffect = (TuSDKMediaFilterEffect *)[self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].lastObject;
    // 仅当滤镜码不一致时才应用新滤镜
    if (![filterEffect.effectCode isEqualToString:filterCode])
    {
        // 选中滤镜列表的code 为空时，移除滤镜
        if (!filterCode.length)
        {
            [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeFilter];
        }
        else
        {
            filterEffect = [[TuSDKMediaFilterEffect alloc]initWithEffectCode:filterCode];
            [self.movieEditor addMediaEffect:filterEffect];
        }
    }
    // 更新参数列表
    if (!_paramtersView.hidden)
    {
        [self updateParamtersViewWithFilterEffect:filterEffect];
    }
}

#pragma mark - PageTabbarDelegate
- (void)tabbar:(PageTabbar *)tabbar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    _pageSlider.selectedIndex = toIndex;
    [self reloadFilterParamters];
}

#pragma mark - method
/**
 更新参数列表视图中的效果

 @param filterEffect 滤镜效果
*/
- (void)updateParamtersViewWithFilterEffect:(TuSDKMediaFilterEffect *)filterEffect
{
    NSArray<TuSDKFilterArg *> *args = filterEffect.filterArgs;
    
    [self.paramtersView setupWithParameterCount:args.count config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent, double defaultValue)) {
        NSString *parameterName = args[index].key;
        parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
        parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), args[index].precent, args[index].precent);
    } valueChange:^(NSUInteger index, double percent) {
        // 修改参数并提交参数
        args[index].precent = percent;
        [filterEffect.filterWrap submitParameter];
    }];
}

/**
 重载滤镜参数数据
 */
- (void)reloadFilterParamters
{
    
    _paramtersView.hidden = YES;

    [_paramtersView setupWithParameterCount:1 config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent, double defaultValue)) {


        NSString *parameterName = self.filtersGroups[self.selectedIndex][index];

        TuSDKFilterOption *option = self.filtersOptions[self.selectedIndex][index];
        
        double percentVale = [[option.args allValues].lastObject doubleValue];
        parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
        parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), percentVale, percentVale);

    } valueChange:^(NSUInteger index, double percent) {

        
    }];
}

#pragma mark - property

- (void)setPlaying:(BOOL)playing
{
    [super setPlaying:playing];
    if (!playing) {
        [self.movieEditor startPreview];
    }
}

- (NSInteger)selectedIndex
{
    return _tabbar.selectedIndex;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
