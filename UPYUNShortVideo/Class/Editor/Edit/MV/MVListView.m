//
//  MVListView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MVListView.h"
#import "HorizontalListItemView.h"

#import "Constants.h"
#import "TuSDKMediaStickerAudioEffect+Equal.h"

@interface MVListView ()

/**
 MV 特效数组
 */
@property (nonatomic, strong) NSArray<TuSDKMediaStickerAudioEffect *> *mvEffectDatas;

@end


@implementation MVListView

+ (Class)listItemViewClass {
    return [HorizontalListItemView class];
}

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    // 获取贴纸组数据源
    NSMutableArray *mvEffectDatas = [NSMutableArray array];
    NSArray<TuSDKPFStickerGroup *> *stickers = [[TuSDKPFStickerLocalPackage package] getSmartStickerGroupsWithFaceFeature:NO];
    for (TuSDKPFStickerGroup *sticker in stickers) {
        NSURL *audioURL = [self audioURLWithStickerIdt:sticker.idt];
        //过滤录制相机中的动态贴纸，与音乐文件不匹配的动态贴纸都不是MV
        if(!audioURL) continue;
        TuSDKMediaStickerAudioEffect *mvData = [[TuSDKMediaStickerAudioEffect alloc] initWithAudioURL:audioURL stickerGroup:sticker];
        [mvEffectDatas addObject:mvData];
    }
    self.mvEffectDatas = mvEffectDatas.copy;
    
    // 配置 UI
    [self addItemViewsWithCount:mvEffectDatas.count config:^(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *itemView) {
        TuSDKMediaStickerAudioEffect *mvEffectData = mvEffectDatas[index];
        // MV 名称
        NSString *mvName = mvEffectData.stickerEffect.stickerGroup.name;
        mvName = NSLocalizedStringFromTable(mvName, @"VideoDemo", @"无需国际化");
        itemView.titleLabel.text = mvName;
        // MV 缩略图
        [[TuSDKPFStickerLocalPackage package] loadThumbWithStickerGroup:mvEffectData.stickerEffect.stickerGroup imageView:itemView.thumbnailView];
        // 点击次数
        itemView.maxTapCount = 2;
    }];
    [self insertItemView:[HorizontalListItemView disableItemView] atIndex:0];
}

- (NSURL *)audioURLWithStickerIdt:(int64_t)stickerIdt {
    NSString *audioName = kMVEffectAudioDictionary[@(stickerIdt)];
    if (!audioName) return nil;
    
    return [[NSBundle mainBundle] URLForResource:audioName withExtension:@"mp3"];
}

/**
 选中 MV 效果

 @param mvEffect MV 效果
 */
- (void)selectMVWithEffect:(TuSDKMediaStickerAudioEffect *)mvEffect {
    NSInteger selectedIndex = -1;
    for (int i = 0; i < _mvEffectDatas.count; i++) {
        TuSDKMediaStickerAudioEffect *mvEffectData = _mvEffectDatas[i];
        if ([mvEffectData isEqualToMvEffect:mvEffect]) {
            selectedIndex = i;
            break;
        }
    }
    if (selectedIndex < 0) return;
    selectedIndex += 1;
    self.selectedIndex = selectedIndex;
}

#pragma mark - HorizontalListItemViewDelegate

/**
 列表项点击回调
 */
- (void)itemViewDidTap:(HorizontalListItemView *)itemView {
    [super itemViewDidTap:itemView];
    TuSDKMediaStickerAudioEffect *mvEffectData = nil;
    if (self.selectedIndex > 0) {
        mvEffectData = _mvEffectDatas[self.selectedIndex - 1];
    }
    if ([self.delegate respondsToSelector:@selector(mvlist:didSelectEffect:tapCount:)]) {
        [self.delegate mvlist:self didSelectEffect:mvEffectData tapCount:itemView.tapCount];
    }
}

@end
