//
//  CameraBeautyPanelView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "CameraBeautyPanelView.h"
#import "ParametersAdjustView.h"
#import "HorizontalListView.h"
#import "PageTabbar.h"
#import "ViewSlider.h"
#import "Constants.h"
#import "CameraBeautyFaceListView.h"
#import "TuCosmeticPanelView.h"
#import "TuBeautyFacePanelView.h"
#import "TuBeautySkinPanelView.h"

#import "TuCosmeticConfig.h"
#import "TuCameraEffectConfig.h"
// 美颜列表高度
static const CGFloat kBeautyListHeight = 120;
// 美颜 tabbar 高度
static const CGFloat kBeautyTabbarHeight = 30;
// 美颜列表与参数视图间隔
static const CGFloat kBeautyListParamtersViewSpacing = 24;

@interface CameraBeautyPanelView () <PageTabbarDelegate,
                                    ViewSliderDataSource,
                                    ViewSliderDelegate,
                                    TuCosmeticPanelViewDelegate,
                                    TuBeautyFacePanelViewDelegate,
                                    TuBeautySkinPanelViewDelegate>
/**
 微整形列表
 */
@property (nonatomic, strong) CameraBeautyFaceListView *beautyFaceListView;

/**
 美颜列表
 */
@property (nonatomic, strong) CameraBeautySkinListView *beautySkinListView;

/**
 美妆列表
 */
@property (nonatomic, strong) TuCosmeticPanelView *cosmeticListView;
/**微整形*/
@property (nonatomic, strong) TuBeautyFacePanelView *beautyFacePanelView;
/**美肤列表*/
@property (nonatomic, strong) TuBeautySkinPanelView *beautySkinPanelView;

/**
 参数调节视图
 */
@property (nonatomic, strong, readonly) ParametersAdjustView *paramtersView;

/**
 模糊背景
 */
@property (nonatomic, strong) UIVisualEffectView *effectBackgroundView;

/**
 面板切换标签栏
 */
@property (nonatomic, strong) PageTabbar *tabbar;

/**
 页面切换控件
 */
@property (nonatomic, strong) ViewSlider *pageSlider;

@property (nonatomic, assign) NSInteger cosmeticIndex;

@end

@implementation CameraBeautyPanelView

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
    __weak typeof(self) weakSelf = self;
    
    self.cosmeticIndex = -1;
    
    _paramtersView = [[ParametersAdjustView alloc] initWithFrame:CGRectZero];
    [self addSubview:_paramtersView];
    _paramtersView.hidden = YES;
    
    _beautySkinListView = [[CameraBeautySkinListView alloc] initWithFrame:CGRectZero];
    _beautySkinListView.itemViewTapActionHandler = ^(CameraBeautySkinListView *listView, HorizontalListItemView *selectedItemView) {
      
        // 重置参数
        if (listView.selectedIndex == 0)
        {
            [weakSelf resetParamters];
            
        }else if([weakSelf.delegate respondsToSelector:@selector(filterPanel:didSelectedFilterCode:)])
        {
             // 切换美颜模式
            NSUInteger index = MAX(listView.selectedIndex - 2, 0);
            if (weakSelf.beautySkinListView.faceType == TuSkinFaceTypeNatural)
            {
                [weakSelf.delegate filterPanel:weakSelf didSelectedFilterCode:@[kNaturalBeautySkinKeys][index]];
            }
            else
            {
                [weakSelf.delegate filterPanel:weakSelf didSelectedFilterCode:@[kBeautySkinKeys][index]];
            }
            
    
            // 切换新的美颜时，默认切换到第一个滤镜参数
            if (listView.selectedIndex < 3)
                [listView setSelectedIndex:3];
        }
        
        weakSelf.paramtersView.hidden = listView.selectedIndex == 0;
        [weakSelf reloadFilterParamters];
        
    };

    
    _effectBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self addSubview:_effectBackgroundView];
    
    _beautyFaceListView = [[CameraBeautyFaceListView alloc] initWithFrame:CGRectZero];
    _beautyFaceListView.itemViewTapActionHandler = ^(CameraBeautyFaceListView *listView, HorizontalListItemView *selectedItemView, NSString *faceFeature) {
        weakSelf.paramtersView.hidden = faceFeature == nil;
        
        // 重置参数
        if (listView.selectedIndex == 0) {
            [weakSelf resetParamters];
        } else {
          
            if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didSelectedFilterCode:)]) {
                [weakSelf.delegate filterPanel:weakSelf didSelectedFilterCode:@[kBeautyFaceKeys][listView.selectedIndex - 1]];
            }
            [weakSelf reloadBeautyFaceParamters];
        }
    };
    
    _beautyFacePanelView = [[TuBeautyFacePanelView alloc] initWithFrame:CGRectZero];
    _beautyFacePanelView.delegate = self;
    [self addSubview:_beautyFacePanelView];
    
    _beautySkinPanelView = [[TuBeautySkinPanelView alloc] initWithFrame:CGRectZero];
    _beautySkinPanelView.delegate = self;
    [self addSubview:_beautySkinPanelView];
    
    _cosmeticListView = [[TuCosmeticPanelView alloc] initWithFrame:CGRectZero];
    _cosmeticListView.delegate = weakSelf;
    
    [self addSubview:_beautyFaceListView];

    PageTabbar *tabbar = [[PageTabbar alloc] initWithFrame:CGRectZero];
    [self addSubview:tabbar];
    _tabbar = tabbar;
    tabbar.trackerSize = CGSizeMake(20, 2);
    tabbar.itemSelectedColor = [UIColor whiteColor];
    tabbar.itemNormalColor = [UIColor colorWithWhite:1 alpha:.25];
    tabbar.delegate = self;
    tabbar.itemTitles = @[NSLocalizedStringFromTable(@"tu_美肤", @"VideoDemo", @"美肤"), NSLocalizedStringFromTable(@"tu_微整形", @"VideoDemo", @"微整形"), NSLocalizedStringFromTable(@"tu_美妆", @"VideoDemo", @"美妆")];
    tabbar.disableAnimation = YES;
    tabbar.itemTitleFont = [UIFont systemFontOfSize:13];
    
    ViewSlider *pageSlider = [[ViewSlider alloc] initWithFrame:CGRectZero];
    [self addSubview:pageSlider];
    _pageSlider = pageSlider;
    pageSlider.dataSource = self;
    pageSlider.delegate = self;
    pageSlider.selectedIndex = 0;
    pageSlider.disableSlide = YES;

}

- (void)layoutSubviews {
    const CGSize size = self.bounds.size;
    CGRect safeBounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
    }
    
    _tabbar.itemWidth = CGRectGetWidth(safeBounds) / 3;
    const CGFloat tabbarY = CGRectGetMaxY(safeBounds) - kBeautyListHeight;
    _tabbar.frame = CGRectMake(CGRectGetMinX(safeBounds), tabbarY, CGRectGetWidth(safeBounds), kBeautyTabbarHeight);
    const CGFloat pageSliderHeight = kBeautyListHeight - kBeautyTabbarHeight;
    _pageSlider.frame = CGRectMake(CGRectGetMinX(safeBounds), CGRectGetMaxY(_tabbar.frame), CGRectGetWidth(safeBounds), pageSliderHeight);

    const CGFloat paramtersViewAvailableHeight = CGRectGetMaxY(safeBounds) - kBeautyListHeight - kBeautyListParamtersViewSpacing;
    const CGFloat paramtersViewSideMargin = 15;
    const CGFloat paramtersViewHeight = _paramtersView.contentHeight;
    _paramtersView.frame =
    CGRectMake(CGRectGetMinX(safeBounds) + paramtersViewSideMargin,
               paramtersViewAvailableHeight - paramtersViewHeight,
               CGRectGetWidth(_tabbar.frame) - paramtersViewSideMargin * 2,
               paramtersViewHeight);
    _effectBackgroundView.frame = CGRectMake(0, tabbarY, size.width, size.height - tabbarY);
}

#pragma mark - property

- (BOOL)display {
    return self.alpha > 0.0;
}


-(NSString *)selectedSkinKey;
{
//    return _beautySkinListView.selectedSkinKey;
    return _beautySkinPanelView.selectedSkinKey;
}

- (NSInteger)selectedTabIndex;
{
    return _pageSlider.selectedIndex;
}

- (TuSkinFaceType)faceType
{
//    return _beautySkinListView.faceType;
    return _beautySkinPanelView.faceType;
}


/**
 清除选择的微整形特效
 */
- (void)resetPlasticFaceEffect {
    _beautyFaceListView.selectedIndex = 0;
    [self reloadBeautyFaceParamters];
}

/**
 清除选择的美妆特效
 */
- (void)setResetCosmetic:(BOOL)resetCosmetic
{
    _resetCosmetic = resetCosmetic;
    if (resetCosmetic)
    {
        _cosmeticListView.resetCosmetic = resetCosmetic;
    }
}

#pragma mark - private

- (void)resetParamters {
    NSArray *beautyFaceKeys = @[kBeautyFaceKeys];
    if ([self.delegate respondsToSelector:@selector(filterPanel:resetParamterKeys:)]) {
        [self.delegate filterPanel:self resetParamterKeys:beautyFaceKeys];
    }
}

#pragma mark - public

/**
 更新显示微整形参数
 */
- (void)reloadBeautyFaceParamters {
    __weak typeof(self) weakSelf = self;
    [_paramtersView setupWithParameterCount:[self.dataSource numberOfParamter:self] config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent, double defaultValue)) {
    
        weakSelf.paramtersView.hidden = NO;
        // 参数名称
        NSString *parameterName = [self.dataSource filterPanel:weakSelf paramterNameAtIndex:index];
        if (parameterName == nil)
        {
            weakSelf.paramtersView.hidden = YES;
        }

        // 是否进行配置，只更新选中项参数
        BOOL shouldConfig =  self.selectedTabIndex == 1 && ![self.beautyFacePanelView.selectedFaceFeature isEqualToString:parameterName];
        if (shouldConfig) return;
        
        // 参数值为从数据源获取的值
        double percentValue = [self.dataSource filterPanel:weakSelf percentValueAtIndex:index];
        
        // 显示偏移取值范围
        if ([parameterName isEqualToString:@"mouthWidth"]
            || [parameterName isEqualToString:@"archEyebrow"]
            || [parameterName isEqualToString:@"jawSize"]
            || [parameterName isEqualToString:@"eyeAngle"]
            || [parameterName isEqualToString:@"eyeDis"]
            || [parameterName isEqualToString:@"forehead"]
            || [parameterName isEqualToString:@"browPosition"]
            || [parameterName isEqualToString:@"lips"]
            || [parameterName isEqualToString:@"philterum"]) {
            itemView.displayValueOffset = -.5;
        }
        
        NSDictionary *effectConfig = [[TuCameraEffectConfig sharePackage] defaultPlasticValue];
        CGFloat defaultValue = 0;
        if ([effectConfig objectForKey:parameterName])
        {
            defaultValue = [[effectConfig objectForKey:parameterName] floatValue];
        }
        
        // 更新显示参数名称和参数值
        parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
        parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), percentValue, defaultValue);
    } valueChange:^(NSUInteger index, double percent) {
        if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didChangeValue:paramterIndex:)]) {
            [weakSelf.delegate filterPanel:weakSelf didChangeValue:percent paramterIndex:index];
        }
    }];
}


/**
 更新显示美肤参数
 */
- (void)reloadSkinFaceParamters {
    __weak typeof(self) weakSelf = self;
    [_paramtersView setupWithParameterCount:[self.dataSource numberOfParamter:self] config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent, double defaultValue)) {
        
        weakSelf.paramtersView.hidden = NO;
        // 参数名称
        NSString *parameterName = [self.dataSource filterPanel:weakSelf paramterNameAtIndex:index];
        if (parameterName == nil || parameterName == NULL)
        {
            weakSelf.paramtersView.hidden = YES;
            return;
        }
        // 参数值为从数据源获取的值
        double percentValue = [self.dataSource filterPanel:weakSelf percentValueAtIndex:index];
        double defaultValue = [self.dataSource filterPanel:weakSelf defaultPercentValueAtIndex:index];
        if ([parameterName isEqualToString:@"ruddy"])
        {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:parameterName])
            {
                percentValue = [[[NSUserDefaults standardUserDefaults] objectForKey:parameterName] doubleValue];
            }
            else
            {
                percentValue = 0.2;
            }
            
            defaultValue = 0.2;
        }
        if ([parameterName isEqualToString:@"whitening"])
        {
            defaultValue = 0.3;
        }
        if ([parameterName isEqualToString:@"smoothing"])
        {
            defaultValue = 0.8;
        }
        if ([parameterName isEqualToString:@"sharpen"])
        {
            defaultValue = 0.6;
        }

        // 更新显示参数名称和参数值
        parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
        parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), percentValue, defaultValue);
    } valueChange:^(NSUInteger index, double percent) {
        if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didChangeValue:paramterIndex:)]) {
            
            // 参数名称
            NSString *parameterName = [self.dataSource filterPanel:weakSelf paramterNameAtIndex:index];
            if ([parameterName isEqualToString:@"ruddy"])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:percent] forKey:parameterName];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            [weakSelf.delegate filterPanel:weakSelf didChangeValue:percent paramterIndex:index];
        }
    }];
}

/**
 更新显示美妆参数
 */
- (void)reloadCosmeticParamters:(NSInteger)cosmeticIndex
{
    __weak typeof(self) weakSelf = self;
    
    if (cosmeticIndex == -1) {
        weakSelf.paramtersView.hidden = YES;
        return;
    }
    [_paramtersView setupWithParameterCount:1 config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent, double defaultValue)) {
        
        weakSelf.paramtersView.hidden = NO;
        // 参数名称
        NSString *parameterName = @"alpha";
        // 参数值为从数据源获取的值
        
        double percentValue = [self.dataSource filterPanel:weakSelf cosmeticPercentValueAtIndex:index cosmeticIndex:cosmeticIndex];
        double defaultValue = [self.dataSource filterPanel:weakSelf cosmeticDefaultValueAtIndex:index cosmeticIndex:cosmeticIndex];
        // 更新显示参数名称和参数值
        parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
        parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), percentValue, defaultValue);
    } valueChange:^(NSUInteger index, double percent) {
        
        switch (cosmeticIndex) {
            case 0:
            case 1:
            case 2:
            {
                if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didChangeValue:paramterIndex:)])
                {
                    [weakSelf.delegate filterPanel:weakSelf didChangeValue:percent paramterIndex:cosmeticIndex];
                }
            }
                break;
            case 3:
            case 4:
            case 5:
            {
                if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didChangeValue:cosmeticIndex:)])
                {
                    [weakSelf.delegate filterPanel:weakSelf didChangeValue:percent cosmeticIndex:cosmeticIndex];
                }
            }
                break;
            default:
            {
                
            }
                break;
        }
    }];
}

/**
 重载滤镜参数值
 */
- (void)reloadFilterParamters {
    if (!self.display && self.paramtersView.hidden) return;
    
    switch (self.selectedTabIndex)
    {
        case 0:
            [self reloadSkinFaceParamters];
            break;
        case 1:
            [self reloadBeautyFaceParamters];
            break;
        case 2:
            [self reloadCosmeticParamters:0];
            break;
        default:

            break;
    }
}

/**
  - 标签项选中回调
  -
  - @param tabbar 标签栏对象
  - @param fromIndex 起始索引
  - @param toIndex 目标索引
  - */
- (void)tabbar:(PageTabbar *)tabbar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    _pageSlider.selectedIndex = toIndex;
     [self reloadFilterParamters];
}

#pragma mark - ViewSliderDataSource

/**
 分页数量
 */
- (NSInteger)numberOfViewsInSlider:(ViewSlider *)slider {
    return 3;
}

/**
  各分页显示的视图
   */
- (UIView *)viewSlider:(ViewSlider *)slider viewAtIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
        {
//            return _beautySkinListView;
            return _beautySkinPanelView;
        }
            break;
        case 1:
        {
//            return _beautyFaceListView;
            return _beautyFacePanelView;
            
        }
            break;
        default:
        {
            return _cosmeticListView;
        }
            break;
    }
}

#pragma mark - ViewSliderDelegate

/**
   切换分页回调
 
  @param slider 分页控件
  @param index 目标页面索引
  */
-(void)viewSlider:(ViewSlider *)slider didSwitchToIndex:(NSInteger)index {
    _tabbar.selectedIndex = index;
    
    switch (index)
    {
        case 0:
            [self reloadSkinFaceParamters];
            break;
        case 1:
            [self reloadBeautyFaceParamters];
            break;
        case 2:
            [self reloadCosmeticParamters:self.cosmeticIndex];
            break;
        default:

            break;
    }
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

#pragma mark - TuCosmeticPanelViewDelegate
/**
 美妆点击回调
 @param view 美妆视图
 @param code 美妆code
 @param stickerCode 美妆贴纸code
 */
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view didSelectedCosmeticCode:(NSString *)code stickerCode:(nonnull NSString *)stickerCode
{
    self.paramtersView.hidden = NO;
    
    NSArray *codeArray = [TuCosmeticConfig cosmeticDataSet];
    if ([codeArray containsObject:code])
    {
        [self reloadCosmeticParamters:[codeArray indexOfObject:code] - 2];
    }
    
    self.cosmeticIndex = [codeArray indexOfObject:code] - 2;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanel:didSelectedFilterCode:)])
    {
        [self.delegate filterPanel:self didSelectedCosmeticCode:code stickerCode:stickerCode];
    }
}

/**
 美妆-口红 点击回调
 @param view 美妆视图
 @param lipStickType 口红类型
 @param stickerName 美妆贴纸名称
 */
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view didSelectedLipStickType:(NSInteger)lipStickType stickerName:(NSString *)stickerName
{
    self.paramtersView.hidden = NO;
    self.cosmeticIndex = 0;
    [self reloadCosmeticParamters:self.cosmeticIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanel:didSelectedLipStickType:stickerName:)])
    {
        [self.delegate filterPanel:self didSelectedLipStickType:lipStickType stickerName:stickerName];
    }
}

/**
 美妆重置
 @param view 美妆视图
 @param code 美妆code
 */
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view closeCosmetic:(NSString *)code
{
    self.paramtersView.hidden = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanel:closeCosmetic:)])
    {
        [self.delegate filterPanel:self closeCosmetic:code];
    }
    
    NSArray *codeArray = [TuCosmeticConfig cosmeticDataSet];
    if ([codeArray containsObject:code])
    {
        [self reloadCosmeticParamters:-1];
    }
    self.cosmeticIndex = -1;
    
}

/**
 美妆调节栏
 */
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view closeSliderBar:(BOOL)close
{
    self.paramtersView.hidden = close;
    self.cosmeticIndex = -1;
}

#pragma mark - TuBeautyFacePanelViewDelegate
- (void)tuBeautyFacePanelViewResetParamters
{
    [self resetParamters];
    self.paramtersView.hidden = YES;
    [self reloadFilterParamters];
}
/**
 点击微整形
 @param view 微整形视图
 @param faceCode 微整形code
 */
- (void)tuBeautyFacePanelView:(TuBeautyFacePanelView *)view didSelectFaceCode:(NSString *)faceCode;
{
    self.paramtersView.hidden = faceCode == nil;
    if ([self.delegate respondsToSelector:@selector(filterPanel:didSelectedFilterCode:)])
    {
        [self.delegate filterPanel:self didSelectedFilterCode:faceCode];
    }
    [self reloadBeautyFaceParamters];
}

#pragma mark - TuBeautySkinPanelViewDelegate
- (void)tuBeautySkinPanelViewResetParamters
{
    [self resetParamters];
    
    self.paramtersView.hidden = YES;
    [self reloadFilterParamters];
}

/**
 点击美肤
 @param view 美肤视图
 @param skinIndex 美肤index
 */
- (void)tuBeautySkinPanelView:(TuBeautySkinPanelView *)view didSelectSkinIndex:(NSInteger)skinIndex
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanel:didSelectedFilterCode:)])
    {
        // 切换美肤模式
        NSUInteger index = MAX(skinIndex - 2, 0);
        if (index == 0)
        {
            [self.delegate filterPanel:self didSelectedFilterCode:@"skin_default"];
        }
        else
        {
            if (self.beautySkinPanelView.faceType == TuSkinFaceTypeNatural)
            {
                
                [self.delegate filterPanel:self didSelectedFilterCode:@[kNaturalBeautySkinKeys][index]];
            }
            else
            {
                [self.delegate filterPanel:self didSelectedFilterCode:@[kBeautySkinKeys][index]];
            }
        }
        
    }
    self.paramtersView.hidden = NO;
    [self reloadFilterParamters];
}


@end
