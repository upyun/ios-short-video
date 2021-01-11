//
//  FilterListView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/28.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "FilterListView.h"
#import "HorizontalListItemView.h"

#import "Constants.h"

@interface FilterListView ()

@end

@implementation FilterListView

+ (Class)listItemViewClass {
    return [HorizontalListItemView class];
}

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    NSArray *filterCodes = @[kVideoFilterCodes];
    _filterCodes = filterCodes;
    
    // 配置 UI
    [self addItemViewsWithCount:filterCodes.count config:^(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *itemView) {
        NSString *filterCode = filterCodes[index];
        // 标题
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", filterCode];
        itemView.titleLabel.text = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
        // 缩略图
        NSString *imageName = [NSString stringWithFormat:@"lsq_filter_thumb_%@", filterCode];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
        itemView.thumbnailView.image = [UIImage imageWithContentsOfFile:imagePath];
        // 点击次数
        itemView.maxTapCount = 2;
    }];
    [self insertItemView:[HorizontalListItemView disableItemView] atIndex:0];
}

- (void)setSelectedFilterCode:(NSString *)selectedFilterCode {
    _selectedFilterCode = selectedFilterCode;
    if (!selectedFilterCode.length) {
        self.selectedIndex = 0;
    }
    NSInteger index = [_filterCodes indexOfObject:selectedFilterCode];
    if (index >= _filterCodes.count) return;
    self.selectedIndex = index + 1;
}

#pragma mark - HorizontalListItemViewDelegate

/**
 列表项点击回调
 */
- (void)itemViewDidTap:(HorizontalListItemView *)itemView {
    [super itemViewDidTap:itemView];
    NSString *code = nil;
    if (self.selectedIndex > 0) {
        code = _filterCodes[self.selectedIndex - 1];
    }
    _selectedFilterCode = code;
    if ([self.delegate respondsToSelector:@selector(filterList:didSelectedCode:tapCount:)]) {
        [self.delegate filterList:self didSelectedCode:code tapCount:itemView.tapCount];
    }
}

@end
