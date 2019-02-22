//
//  TimeEffectListView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/11.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TimeEffectListView.h"
#import "Constants.h"


@interface TimeEffectListView ()

/**
 GIF 创建队列
 */
@property (nonatomic, strong) NSOperationQueue *gifQueue;

@end

@implementation TimeEffectListView

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    NSArray *timeEffectCodes = kTimeEffectCodeArray;
    _gifQueue = [[NSOperationQueue alloc] init];
    _gifQueue.maxConcurrentOperationCount = 1;
    
    // 配置 UI
    __weak typeof(self) weakSelf = self;
    [self addItemViewsWithCount:timeEffectCodes.count config:^(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *itemView) {
        // 标题
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", timeEffectCodes[index]];
        title = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
        itemView.titleLabel.text = title;
        // GIF 缩略图
        NSString *imageName = [NSString stringWithFormat:@"lsq_effect_thumb_%@", timeEffectCodes[index]];
        [weakSelf.gifQueue addOperationWithBlock:^{
            [TuSDKGIFImage requestGifImageWithName:imageName firstFrameImageCompletion:^(UIImage *firstFrameImage) {
                itemView.thumbnailView.image = firstFrameImage;
            } animatedImageCompletion:^(UIImage *animatedImage) {
                itemView.thumbnailView.image = animatedImage;
            }];
        }];

        // 选中颜色
        itemView.selectedImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        itemView.selectedImageView.image = nil;
    }];
    [self insertItemView:[HorizontalListItemView disableItemView] atIndex:0];
}

- (TimeEffectType)selectedType {
    return self.selectedIndex;
}
- (void)setSelectedType:(TimeEffectType)selectedType {
    self.selectedIndex = selectedType;
}

#pragma mark - HorizontalListItemViewDelegate

/**
 列表项点击回调
 */
- (void)itemViewDidTap:(HorizontalListItemView *)itemView {
    [super itemViewDidTap:itemView];
    if ([self.delegate respondsToSelector:@selector(timeEffectList:didSelectType:)]) {
        [self.delegate timeEffectList:self didSelectType:self.selectedIndex];
    }
}

@end
