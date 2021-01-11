//
//  TransitionEffectListView.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/6/4.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "TransitionEffectListView.h"
#import "HorizontalListItemView.h"
#import "Constants.h"
#import "TransitionHorizontalListItemView.h"


@interface TransitionEffectListView()

/**
 场景特效码
 */
@property (nonatomic, strong) NSArray<NSNumber *> *transitionEffectTypes;

/**
 GIF 创建队列
 */
@property (nonatomic, strong) NSOperationQueue *gifQueue;


@end

@implementation TransitionEffectListView

+ (Class)listItemViewClass {
    return [TransitionHorizontalListItemView class];
}

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    NSArray *transitionEffectTypes = kTransitionTypesArray;
    _transitionEffectTypes = transitionEffectTypes;
    NSArray *transitionEffectColors = kTransitionEffectColorArray;
//    /** 转场 - 淡入  @since v3.4.1 */
//    TuSDKTransitionTypeFadeIn = 0,
//    /** 转场 - 飞入  @since v3.4.1 */
//    TuSDKTransitionTypeFlyIn,
//    /** 转场 - 拉入--右侧进入  @since v3.4.1 */
//    TuSDKTransitionTypePullInRight,
//    /** 转场 - 拉入--左侧进入  @since v3.4.1 */
//    TuSDKTransitionTypePullInLeft,
//    /** 转场 - 拉入--顶部进入  @since v3.4.1 */
//    TuSDKTransitionTypePullInTop,
//    /** 转场 - 拉入--底部进入  @since v3.4.1 */
//    TuSDKTransitionTypePullInBottom,
//    /** 转场 - 散步进入  @since v3.4.1 */
//    TuSDKTransitionTypeSpreadIn,
//    /** 转场 - 闪光灯  @since v3.4.1 */
//    TuSDKTransitionTypeFlashLight,
//    /** 转场 - 翻页  @since v3.4.1 */
//    TuSDKTransitionTypeFlip,
//    /** 转场 - 聚焦-小到大  @since v3.4.1 */
//    TuSDKTransitionTypeFocusOut,
//    /** 转场 - 聚焦-大到小 @since v3.4.1 */
//    TuSDKTransitionTypeFocusIn,
//    /** 转场 - 叠起 @since v3.4.1 */
//    TuSDKTransitionTypeStackUp,
//    /** 转场 - 缩放 @since v3.4.1 */
//    TuSDKTransitionTypeZoom
    NSArray *titles = @[@"FadeIn", @"FlyIn", @"PullInRight", @"PullInLeft", @"PullInTop", @"PullInBottom", @"SpreadIn", @"FlashLight", @"Flip", @"FocusOut", @"FocusIn", @"StackUp" , @"Zoom"];
    
    NSArray *imageNames = @[@"z_ic_fadein",@"z_ic_flyin", @"z_ic_pullright",@"z_ic_pullnleft", @"z_ic_pullnbottom", @"z_ic_pullntop", @"z_ic_spreadin",@"z_ic_flashlight", @"z_ic_flip",@"z_ic_focusout", @"z_ic_focusin",@"z_ic_stackup", @"z_ic_zoom"];
    NSMutableDictionary *codeColorDic = [NSMutableDictionary dictionary];
    [transitionEffectTypes enumerateObjectsUsingBlock:^(NSNumber *type, NSUInteger idx, BOOL * _Nonnull stop) {
        codeColorDic[type] = transitionEffectColors[idx];
    }];
    _transitionEffectCodeColors = codeColorDic.copy;
    _gifQueue = [[NSOperationQueue alloc] init];
    _gifQueue.maxConcurrentOperationCount = 1;
    
    // 配置 UI
    self.sideMargin = 0;
//    __weak typeof(self) weakSelf = self;
    [self addItemViewsWithCount:transitionEffectTypes.count config:^(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *itemView) {
        // 标题
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", titles[index]];
        itemView.titleLabel.text = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
        // 缩略图
        itemView.thumbnailView.image = [UIImage imageNamed:imageNames[index]];
        // 选中颜色
        itemView.selectedImageView.backgroundColor = transitionEffectColors[index];
        itemView.selectedImageView.image = nil;
    }];
    self.disableAutoSelect = YES;
}




#pragma mark - HorizontalListItemViewDelegate

/**
 列表项点击回调
 */
- (void)itemViewDidTap:(HorizontalListItemView *)itemView {
    [super itemViewDidTap:itemView];
    NSInteger index = [self indexOfItemView:itemView];
    if ([self.delegate respondsToSelector:@selector(transitionEffectList:didTapWithType:color:)]) {
        [self.delegate transitionEffectList:self didTapWithType:index color:_transitionEffectCodeColors[@(index)]];
    }
}



@end
