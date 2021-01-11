//
//  ParticleEffectListView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/11.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "ParticleEffectListView.h"
#import "HorizontalListItemView.h"

#import "Constants.h"

@interface ParticleEffectListView ()

/**
 魔法特效码
 */
@property (nonatomic, strong) NSArray *particleEffectCodes;

@end

@implementation ParticleEffectListView

+ (Class)listItemViewClass {
    return [HorizontalListItemView class];
}

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    NSArray *particleEffectCodes = kParticleEffectCodeArray;
    _particleEffectCodes = particleEffectCodes;
    NSArray *particleEffectColors = kParticleEffectColorArray;
    NSMutableDictionary *codeColorDic = [NSMutableDictionary dictionary];
    [particleEffectCodes enumerateObjectsUsingBlock:^(NSString *code, NSUInteger idx, BOOL * _Nonnull stop) {
        codeColorDic[code] = particleEffectColors[idx];
    }];
    _particleEffectCodeColors = codeColorDic.copy;
    
    // 配置 UI
    self.sideMargin = 0;
    [self addItemViewsWithCount:particleEffectCodes.count config:^(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *itemView) {
        // 标题
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", particleEffectCodes[index]];
        title = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
        itemView.titleLabel.text = title;
        // 缩略图
        NSString *imageName = [NSString stringWithFormat:@"lsq_effect_thumb_%@", particleEffectCodes[index]];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
        itemView.thumbnailView.image = [UIImage imageWithContentsOfFile:imagePath];
        // 选中颜色
        itemView.selectedImageView.backgroundColor = particleEffectColors[index];
        // 点击次数
        itemView.maxTapCount = -1;
    }];
}

#pragma mark - HorizontalListItemViewDelegate

/**
 列表项点击回调
 */
- (void)itemViewDidTap:(HorizontalListItemView *)itemView {
    [super itemViewDidTap:itemView];
    _selectedCode = _particleEffectCodes[self.selectedIndex];
    if ([self.delegate respondsToSelector:@selector(particleEffectList:didTapWithCode:color:tapCount:)]) {
        [self.delegate particleEffectList:self didTapWithCode:_selectedCode color:itemView.selectedImageView.backgroundColor tapCount:itemView.tapCount];
    }
}

@end
