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

// 美颜列表高度
static const CGFloat kBeautyListHeight = 120;
// 美颜 tabbar 高度
static const CGFloat kBeautyTabbarHeight = 30;
// 美颜列表与参数视图间隔
static const CGFloat kBeautyListParamtersViewSpacing = 24;

@interface CameraBeautyPanelView () <PageTabbarDelegate, ViewSliderDataSource, ViewSliderDelegate>
/**
 微整形列表
 */
@property (nonatomic, strong) CameraBeautyFaceListView *beautyFaceListView;

/**
 美颜列表
 */
@property (nonatomic, strong) CameraBeautySkinListView *beautySkinListView;


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
            [weakSelf.delegate filterPanel:weakSelf didSelectedFilterCode:@[kBeautySkinKeys][index]];
    
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
    
  [self addSubview:_beautyFaceListView];

    PageTabbar *tabbar = [[PageTabbar alloc] initWithFrame:CGRectZero];
    [self addSubview:tabbar];
    _tabbar = tabbar;
    //tabbar.itemWidth = CGRectGetWidth([UIScreen mainScreen].bounds) / 2.0;
    tabbar.trackerSize = CGSizeMake(20, 2);
    tabbar.itemSelectedColor = [UIColor whiteColor];
    tabbar.itemNormalColor = [UIColor colorWithWhite:1 alpha:.25];
    tabbar.delegate = self;
    tabbar.itemTitles = @[NSLocalizedStringFromTable(@"tu_美肤", @"VideoDemo", @"美肤"), NSLocalizedStringFromTable(@"tu_微整形", @"VideoDemo", @"微整形")];
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
    
    _tabbar.itemWidth = CGRectGetWidth(safeBounds) / 2;
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

-(BOOL)useSkinNatural;
{
    return _beautySkinListView.useSkinNatural;
}

-(NSString *)selectedSkinKey;
{
    return _beautySkinListView.selectedSkinKey;
}

- (NSInteger)selectedTabIndex;
{
    return _pageSlider.selectedIndex;
}


/**
 清除选择的微整形特效
 */
- (void)resetPlasticFaceEffect {
    _beautyFaceListView.selectedIndex = 0;
    [self reloadBeautyFaceParamters];
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
    [_paramtersView setupWithParameterCount:[self.dataSource numberOfParamter:self] config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent)) {
    
        // 参数名称
        NSString *parameterName = [self.dataSource filterPanel:weakSelf paramterNameAtIndex:index];

        // 是否进行配置，只更新选中项参数
        BOOL shouldConfig =  self.selectedTabIndex == 1 && ![self.beautyFaceListView.selectedFaceFeature isEqualToString:parameterName];
        if (shouldConfig) return;
        
        // 参数值为从数据源获取的值
        double percentValue = [self.dataSource filterPanel:weakSelf percentValueAtIndex:index];
        
        // 显示偏移取值范围
        if ([parameterName isEqualToString:@"mouthWidth"] ||
            [parameterName isEqualToString:@"archEyebrow"] ||
            [parameterName isEqualToString:@"jawSize"] ||
            [parameterName isEqualToString:@"eyeAngle"] ||
            [parameterName isEqualToString:@"eyeDis"]) {
            itemView.displayValueOffset = -.5;
        }
        
        // 更新显示参数名称和参数值
        parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
        parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), percentValue);
    } valueChange:^(NSUInteger index, double percent) {
        if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didChangeValue:paramterIndex:)]) {
            [weakSelf.delegate filterPanel:weakSelf didChangeValue:percent paramterIndex:index];
        }
    }];
}


/**
 更新显示美颜参数
 */
- (void)reloadSkinFaceParamters {
    __weak typeof(self) weakSelf = self;
    [_paramtersView setupWithParameterCount:[self.dataSource numberOfParamter:self] config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent)) {
        
        // 参数名称
        NSString *parameterName = [self.dataSource filterPanel:weakSelf paramterNameAtIndex:index];    
        // 参数值为从数据源获取的值
        double percentValue = [self.dataSource filterPanel:weakSelf percentValueAtIndex:index];

        // 更新显示参数名称和参数值
        parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
        parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), percentValue);
    } valueChange:^(NSUInteger index, double percent) {
        if ([weakSelf.delegate respondsToSelector:@selector(filterPanel:didChangeValue:paramterIndex:)]) {
            [weakSelf.delegate filterPanel:weakSelf didChangeValue:percent paramterIndex:index];
        }
    }];
}


/**
 重载滤镜参数值
 */
- (void)reloadFilterParamters {
    if (!self.display && self.paramtersView.hidden) return;
    
    switch (self.selectedTabIndex) {
        case 0:
            [self reloadSkinFaceParamters];
            break;
        default:
            [self reloadBeautyFaceParamters];
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
    return 2;
}

/**
  各分页显示的视图
   */
- (UIView *)viewSlider:(ViewSlider *)slider viewAtIndex:(NSInteger)index {
    switch (index) {
           case 0:{
               return _beautySkinListView;
          } break;
             case 1:{
                return _beautyFaceListView;
            } break;
            default:{
                  return nil;

                
            } break;
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
       [self reloadBeautyFaceParamters];
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

@end
