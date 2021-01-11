//
//  SceneEffectListView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/11.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "SceneEffectListView.h"
#import "HorizontalListItemView.h"

#import "Constants.h"

@interface SceneEffectListView ()

/**
 场景特效码
 */
@property (nonatomic, strong) NSArray<NSString *> *sceneEffectCodes;

/**
 GIF 创建队列
 */
@property (nonatomic, strong) NSOperationQueue *gifQueue;

@end

@implementation SceneEffectListView

+ (Class)listItemViewClass {
    return [HorizontalListItemView class];
}

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    NSArray *sceneEffectCodes = kSceneEffectCodeArray;
    _sceneEffectCodes = sceneEffectCodes;
    NSArray *sceneEffectColors = kSceneEffectColorArray;
    NSMutableDictionary *codeColorDic = [NSMutableDictionary dictionary];
    [sceneEffectCodes enumerateObjectsUsingBlock:^(NSString *code, NSUInteger idx, BOOL * _Nonnull stop) {
        codeColorDic[code] = sceneEffectColors[idx];
    }];
    _sceneEffectCodeColors = codeColorDic.copy;
    _gifQueue = [[NSOperationQueue alloc] init];
    _gifQueue.maxConcurrentOperationCount = 1;
    
    // 配置 UI
    self.sideMargin = 0;
    __weak typeof(self) weakSelf = self;
    [self addItemViewsWithCount:sceneEffectCodes.count config:^(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *itemView) {
        // 标题
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", sceneEffectCodes[index]];
        title = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
        itemView.titleLabel.text = title;
        // 配置 GIF 动图
        NSString *imageName = [NSString stringWithFormat:@"lsq_effect_thumb_%@", sceneEffectCodes[index]];
        [weakSelf.gifQueue addOperationWithBlock:^{
            [TuSDKGIFImage requestGifImageWithName:imageName firstFrameImageCompletion:^(UIImage *firstFrameImage) {
                itemView.thumbnailView.image = firstFrameImage;
            } animatedImageCompletion:^(UIImage *animatedImage) {
                itemView.thumbnailView.image = animatedImage;
            }];
        }];
        // 选中颜色
        itemView.selectedImageView.backgroundColor = sceneEffectColors[index];
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
    if ([self.delegate respondsToSelector:@selector(sceneEffectList:didTapWithCode:color:)]) {
        [self.delegate sceneEffectList:self didTapWithCode:_sceneEffectCodes[index] color:itemView.selectedImageView.backgroundColor];
    }
}

/**
 列表项按下回调
 */
- (void)itemViewDidTouchDown:(HorizontalListItemView *)itemView {
    // 此处做延时处理，以消除与列表滚动事件的交互冲突
    [self performSelector:@selector(_itemViewDidTouchDown:) withObject:itemView afterDelay:0.2];
}

- (void)_itemViewDidTouchDown:(HorizontalListItemView *)itemView {
    [super itemViewDidTouchDown:itemView];
    // 按下响应时禁止滚动
    self.scrollEnabled = NO;
    NSInteger index = [self indexOfItemView:itemView];
    self.selectedIndex = index;
    if ([self.delegate respondsToSelector:@selector(sceneEffectList:didTouchDownWithCode:color:)]) {
        [self.delegate sceneEffectList:self didTouchDownWithCode:_sceneEffectCodes[index] color:itemView.selectedImageView.backgroundColor];
    }
}

/**
 列表项抬起回调
 */
- (void)itemViewDidTouchUp:(HorizontalListItemView *)itemView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.scrollEnabled) return;
    // 抬起恢复滚动
    self.scrollEnabled = YES;
    
    [super itemViewDidTouchUp:itemView];
    NSInteger index = [self indexOfItemView:itemView];
    self.selectedIndex  = -1;
    if ([self.delegate respondsToSelector:@selector(sceneEffectList:didTouchUpWithCode:color:)]) {
        [self.delegate sceneEffectList:self didTouchUpWithCode:_sceneEffectCodes[index] color:itemView.selectedImageView.backgroundColor];
    }
}

@end
