//
//  EditFilterViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditFilterViewController.h"
#import "FilterListView.h"
#import "ParametersAdjustView.h"
#import "FilterSwipeView.h"

@interface EditFilterViewController ()<FilterListViewDelegate, FilterSwipeViewDelegate>

/**
 滤镜展示列表视图
 */
@property (weak, nonatomic) IBOutlet FilterListView *filterListView;

/**
 滤镜参数视图
 */
@property (weak, nonatomic) IBOutlet ParametersAdjustView *paramtersView;

/**
 滤镜滑动切换视图
 */
@property (weak, nonatomic) IBOutlet FilterSwipeView *filterSwipeView;

@end

@implementation EditFilterViewController

+ (CGFloat)bottomPreviewOffset {
    return 132;
}

/**
 完成按钮事件

 @param sender 完成按钮
 */
- (void)doneButtonAction:(UIButton *)sender {
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
        // for (TuSDKFilterArg *arg in initialEffect.filterArgs) {
        // NSLog(@"%@: %f", arg.key, arg.precent);
        // }
        [self.movieEditor addMediaEffect:initialEffect];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.title = NSLocalizedStringFromTable(@"tu_滤镜", @"VideoDemo", @"滤镜");
    
    // 载入已设置的滤镜
    TuSDKMediaFilterEffect *filterEffect = (TuSDKMediaFilterEffect *)[self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].lastObject;
    
    if (filterEffect) {
        _filterSwipeView.currentFilterCode = filterEffect.effectCode;
        _filterListView.selectedFilterCode = filterEffect.effectCode;
        // 更新参数列表
        [self updateParamtersViewWithFilterEffect:filterEffect];
        self.initialEffects = @[filterEffect.copy];
    }
    _paramtersView.hidden = YES;
    _filterSwipeView.filterNameLabel.hidden = YES;
    
    // 开始播放
    [self.movieEditor startPreview];
}

/**
 更新参数列表视图中的效果

 @param filterEffect 滤镜效果
 */
- (void)updateParamtersViewWithFilterEffect:(TuSDKMediaFilterEffect *)filterEffect {
    // 配置参数列表
    NSArray<TuSDKFilterArg *> *args = filterEffect.filterArgs;
//    for (TuSDKFilterArg *arg in args) {
//        NSLog(@"%@: %f", arg.key, arg.precent);
//    }
    [self.paramtersView setupWithParameterCount:args.count config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent)) {
        NSString *parameterName = args[index].key;
        parameterName = [NSString stringWithFormat:@"lsq_filter_set_%@", parameterName];
        parameterItemConfig(NSLocalizedStringFromTable(parameterName, @"TuSDKConstants", @"无需国际化"), args[index].precent);
    } valueChange:^(NSUInteger index, double percent) {
        // 修改参数并提交参数
        args[index].precent = percent;
        [filterEffect.filterWrap submitParameter];
    }];
}

/**
 通过给定的滤镜码切换滤镜

 @param filterCode 滤镜码
 */
- (void)switchFilterWithCode:(NSString *)filterCode {
    TuSDKMediaFilterEffect *filterEffect = (TuSDKMediaFilterEffect *)[self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].lastObject;
    if (![filterEffect.effectCode isEqualToString:filterCode]) { // 仅当滤镜码不一致时才应用新滤镜
        // 选中滤镜列表第一项，code 为空时，移除滤镜
        if (!filterCode.length) {
            [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeFilter];
        } else {
            // 应用滤镜
            filterEffect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:filterCode];
            [self.movieEditor addMediaEffect:filterEffect];
        }
    }
    
    // 更新参数列表
    if (!_paramtersView.hidden)
        [self updateParamtersViewWithFilterEffect:filterEffect];
}

#pragma mark - property

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    if (!playing) {
        [self.movieEditor startPreview];
    }
}

#pragma mark - FilterListViewDelegate

/**
 滤镜码选中回调，在此提交效果或取消滤镜, 修改滤镜参数
 
 @param filterList 滤镜列表视图
 @param filterCode 选中滤镜的 filterCode
 @param tapCount 点击的次数
 */
- (void)filterList:(FilterListView *)filterList didSelectedCode:(NSString *)filterCode tapCount:(NSInteger)tapCount {
    _paramtersView.hidden = tapCount <= 1;
    [self switchFilterWithCode:filterCode];
    
    // 更新滤镜滑动切换视图
    _filterSwipeView.currentFilterCode = filterCode;
}

#pragma mark - FilterSwipeViewDelegate

/**
 响应手势滑动时回调
 
 @param filterSwipeView 滤镜滑动切换视图
 @param filterCode 即将切换到的滤镜码
 @return 是否更新显示的滤镜名称
 */
- (BOOL)filterSwipeView:(FilterSwipeView *)filterSwipeView shouldChangeFilterCode:(NSString *)filterCode {
    [self switchFilterWithCode:filterCode];
    
    // 更新滤镜列表
    _filterListView.selectedFilterCode = filterCode;
    
    // 不更新滤镜名称
    return NO;
}

@end
