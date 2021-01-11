//
//  MusicListView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/2.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MusicListView.h"
#import "HorizontalListItemView.h"

#import "Constants.h"

@interface MusicListView ()

/**
 配乐 URL 数组
 */
@property (nonatomic, strong) NSArray *musicURLs;

@end


@implementation MusicListView

+ (Class)listItemViewClass {
    return [HorizontalListItemView class];
}

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    // 配乐 URL
    NSMutableArray *musicURLs = [NSMutableArray array];
    for (NSString *musicFileName in kMusicFileNameArray) {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:musicFileName withExtension:@"mp3"];
        [musicURLs addObject:URL];
    }
    self.musicURLs = musicURLs;
    
    NSArray *musicTitles = kMusicTitleArray;
    NSArray *musicThubnails = kMusicThumbnailArray;
    
    // 配置 UI
    [self addItemViewsWithCount:3 config:^(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *itemView) {
        // 标题
        NSString *musicTitle = musicTitles[index];
        itemView.titleLabel.text = musicTitle;
        // 缩略图
        UIImage *image = [UIImage imageNamed:musicThubnails[index]];
        itemView.thumbnailView.image = image;
    }];
    HorizontalListItemView *recordItemView = [HorizontalListItemView itemViewWithImage:[UIImage imageNamed:@"edit_ic_transcription"] title:NSLocalizedStringFromTable(@"tu_录音", @"VideoDemo", @"录音")];
    [self insertItemView:recordItemView atIndex:0];
    [self insertItemView:[HorizontalListItemView disableItemView] atIndex:0];
}

/**
 获取选中音乐的 URL 地址

 @param musicURL 音乐文件的 URL 地址
 */
- (void)selectMusicURL:(NSURL *)musicURL {
    if (!musicURL) {
        self.selectedIndex = 0;
        return;
    }
    NSInteger selectedIndex = [_musicURLs indexOfObject:musicURL];
    if (selectedIndex >= _musicURLs.count) {
        self.selectedIndex = 1;
        return;
    }
    selectedIndex += 2;
    self.selectedIndex = selectedIndex;
}

#pragma mark - HorizontalListItemViewDelegate

/**
 列表项点击回调
 */
- (void)itemViewDidTap:(HorizontalListItemView *)itemView {
    [super itemViewDidTap:itemView];
    if (self.selectedIndex == 1) {
        self.selectedIndex = 0;
        if ([self.delegate respondsToSelector:@selector(musicListDidNeedRecord:)]) {
            [self.delegate musicListDidNeedRecord:self];
        }
        return;
    }
    NSURL *musicURL = nil;
    if (self.selectedIndex > 1) {
        musicURL = _musicURLs[self.selectedIndex - 2];
    }
    if ([self.delegate respondsToSelector:@selector(musicList:didSelectMusic:tapCount:)]) {
        [self.delegate musicList:self didSelectMusic:musicURL tapCount:itemView.tapCount];
    }
}

@end
