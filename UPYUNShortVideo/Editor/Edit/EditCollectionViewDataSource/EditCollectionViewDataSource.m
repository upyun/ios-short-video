//
//  EditCollectionViewDataSource.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditCollectionViewDataSource.h"
#import "EditCollectionViewCell.h"

// CollectionView 重用 ID
static NSString * const kEditItemCellId = @"EditItemCell";
// 功能项单元格标题键
static NSString * const kEffectItemTitleKey = @"title";
// 功能项单元格缩略图键
static NSString * const kEffectItemImageKey = @"image";

@interface EditCollectionViewDataSource ()

@property (nonatomic, strong) NSArray *effectItemTitles;

@end

@implementation EditCollectionViewDataSource

- (instancetype)init {
    if (self = [super init]) {
        _effectItemTitles =
        @[
          @{kEffectItemTitleKey: NSLocalizedStringFromTable(@"tu_滤镜", @"VideoDemo", @"滤镜"), kEffectItemImageKey: @"edit_tab_ic_filter"},
          @{kEffectItemTitleKey: @"MV", kEffectItemImageKey: @"edit_tab_ic_mv"},
          @{kEffectItemTitleKey: NSLocalizedStringFromTable(@"tu_配乐", @"VideoDemo", @"配乐"), kEffectItemImageKey: @"edit_tab_ic_music"},
          @{kEffectItemTitleKey: NSLocalizedStringFromTable(@"tu_文字", @"VideoDemo", @"文字"), kEffectItemImageKey: @"edit_tab_ic_text"},
          @{kEffectItemTitleKey: NSLocalizedStringFromTable(@"tu_特效", @"VideoDemo", @"特效"), kEffectItemImageKey: @"edit_tab_ic_special"},
          ];
    }
    return self;
}

#pragma mark - property

- (void)setCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    
    //[collectionView registerNib:[UINib nibWithNibName:@"EditItemCell" bundle:nil] forCellWithReuseIdentifier:kEditItemCellId];
    [collectionView registerClass:[EditCollectionViewCell class] forCellWithReuseIdentifier:kEditItemCellId];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator= NO;
    collectionView.allowsSelection = YES;
    collectionView.allowsMultipleSelection = NO;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat defaultItemWidth = 64;
    CGFloat itemWidth = CGRectGetWidth([UIScreen mainScreen].bounds) / _effectItemTitles.count;
    layout.itemSize = CGSizeMake(MAX(defaultItemWidth, itemWidth), 80);
}

#pragma mark - UICollectionViewDataSource

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EditCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kEditItemCellId forIndexPath:indexPath];
    NSDictionary *dic = _effectItemTitles[indexPath.item];
    cell.titleLabel.text = dic[kEffectItemTitleKey];
    cell.imageView.image = [UIImage imageNamed:dic[kEffectItemImageKey]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.effectItemTitles.count;
}

@end
