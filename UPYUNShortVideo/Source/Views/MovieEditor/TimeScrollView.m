//
//  TimeScrollView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/8/2.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TimeScrollView.h"
#import "ScrollListItemCell.h"
#import "TuSDKFramework.h"

// 列表数据字典 key
static NSString * const kTimeItemThumbnailKey = @"thumbnail";
static NSString * const kTimeItemTitleKey = @"title";
static NSString * const kTimeCellReuseId = @"timeCell";

@interface TimeScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>

/// 滚动列表
@property (nonatomic, strong) UICollectionView *collectionView;

/// 列表信息
@property (nonatomic, strong) NSArray<NSDictionary *> *timeItemDics;

@end

@implementation TimeScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

/**
 初始化列表
 */
- (void)commonInit
{
    // 列表数据
    _timeItemDics =
    @[
      @{kTimeItemTitleKey: NSLocalizedString(@"lsq_filter_repeat", @"反复"), kTimeItemThumbnailKey: @"lsq_filter_thumb_repeat"},
      @{kTimeItemTitleKey: NSLocalizedString(@"lsq_filter_slow", @"慢动作"), kTimeItemThumbnailKey: @"lsq_filter_thumb_slow"},
      @{kTimeItemTitleKey: NSLocalizedString(@"lsq_filter_reverse", @"逆转时光"), kTimeItemThumbnailKey: @"lsq_filter_thumb_reverse"},
      ];
    
    // 列表布局样式
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemHeight = self.lsqGetSizeHeight;
    layout.itemSize = CGSizeMake(itemHeight*13/18, itemHeight);
    layout.minimumLineSpacing = 12;
    layout.minimumInteritemSpacing = 12;
    layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 配置列表
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:_collectionView];
    _collectionView.backgroundColor = self.backgroundColor;
    _collectionView.showsVerticalScrollIndicator = false;
    _collectionView.showsHorizontalScrollIndicator = false;
    [_collectionView registerClass:[ScrollListItemCell class] forCellWithReuseIdentifier:kTimeCellReuseId];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

// 便捷获取 bundle 图片
- (UIImage *)imageWithName:(NSString *)imageName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    return [UIImage imageWithContentsOfFile:path];
}

#pragma mark - property

/**
 选中状态切换
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    if (selectedIndex < 0 || selectedIndex >= _timeItemDics.count) return;
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _timeItemDics.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 配置列表项
    ScrollListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTimeCellReuseId forIndexPath:indexPath];
    if (indexPath.item == 0) {
        [cell setupDisableStyle];
    } else {
        NSDictionary *timeItemDic = _timeItemDics[indexPath.item - 1];
        [cell setupWithThumbnail:[self imageWithName:timeItemDic[kTimeItemThumbnailKey]] title:timeItemDic[kTimeItemTitleKey]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 选中并回调
    _selectedIndex = indexPath.item;
    if ([self.delegate respondsToSelector:@selector(timeScrollView:didSelectedIndex:)]) {
        [self.delegate timeScrollView:self didSelectedIndex:_selectedIndex];
    }
}

@end
