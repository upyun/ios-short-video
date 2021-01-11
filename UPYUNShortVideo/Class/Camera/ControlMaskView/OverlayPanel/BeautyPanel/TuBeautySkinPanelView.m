//
//  TuBeautySkinPanelView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/12/9.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuBeautySkinPanelView.h"
#import "TuBeautySkinPanelViewCell.h"
#import "Constants.h"
#define itemHeight 90
@interface TuBeautySkinPanelView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    //上一次选中的item
    NSInteger _lastSelectItem;
    NSString *_selectCode;
}
@property (nonatomic, strong) UICollectionView *collectionView;
//美肤数组
@property (nonatomic, strong) NSMutableArray *skinDataSet;

@end

@implementation TuBeautySkinPanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _lastSelectItem = 999;
        [self initWithSubViews];
    }
    return self;
}

- (void)initWithSubViews
{
    //加载数据
    [self loadBeautySkinData];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_collectionView];
    [_collectionView registerClass:[TuBeautySkinPanelViewCell class] forCellWithReuseIdentifier:@"TuBeautySkinPanelViewCell"];
    
    //默认为自然
    _faceType = TuSkinFaceTypeBeauty;
}

- (void)layoutSubviews
{
    self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.skinDataSet.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 2)
    {
        return CGSizeMake(20, itemHeight);
    }
    else
    {
        return CGSizeMake((lsqScreenWidth - 40) / 5, itemHeight);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuBeautySkinPanelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TuBeautySkinPanelViewCell" forIndexPath:indexPath];
    cell.beautySkinData = self.skinDataSet[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 2) {}
    else
    {
        //上一次选中不为0，则需要将上一次点击事件重置
        if (indexPath.item != _lastSelectItem && _lastSelectItem != 999)
        {
            TuBeautySkinPanelViewCell *lastCell = (TuBeautySkinPanelViewCell *)[self collectionView:_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_lastSelectItem inSection:0]];
            TuBeautySkinData *lastData = self.skinDataSet[_lastSelectItem];
            lastData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
            lastCell.beautySkinData = lastData;
        }
        TuBeautySkinPanelViewCell *cell = [self collectionView:_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        TuBeautySkinData *data = self.skinDataSet[indexPath.item];
        data.beautySkinSelectType = TuBeautySkinSelectTypeSelected;
        cell.beautySkinData = data;
        [self.collectionView reloadData];
        
        _lastSelectItem = indexPath.item;
        
        if (indexPath.item == 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tuBeautySkinPanelViewResetParamters)])
            {
                _selectCode = nil;
                //重置美肤效果
                [self.delegate tuBeautySkinPanelViewResetParamters];
            }
            for (int i = 1; i < self.skinDataSet.count; i++)
            {
                TuBeautySkinData *data = self.skinDataSet[i];
                data.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
                [self.skinDataSet replaceObjectAtIndex:i withObject:data];
            }
            
        }
        else if (indexPath.item == 1)
        {
            if (_selectCode == nil)
            {
                [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
                return;
            }
            NSString *code = nil;
            NSString *ruddyCode = nil;
            
            if (_faceType == TuSkinFaceTypeBeauty)
            {
                _faceType = TuSkinFaceTypeMoist;
                
                code = @"skin_extreme";
                ruddyCode = @"ruddy";
            }
            else if (_faceType == TuSkinFaceTypeMoist)
            {
                _faceType = TuSkinFaceTypeNatural;
                
                //自然
                code = @"skin_precision";
                ruddyCode = @"ruddy";
            }
            else
            {
                _faceType = TuSkinFaceTypeBeauty;
                
                code = @"skin_beauty";
                ruddyCode = @"sharpen";
            }
            
            TuBeautySkinData *skinTypeData = self.skinDataSet[1];
            skinTypeData.beautySkinCode = code;
            [self.skinDataSet replaceObjectAtIndex:1 withObject:skinTypeData];
            
            TuBeautySkinData *data = self.skinDataSet[5];
            data.beautySkinCode = ruddyCode;
            [self.skinDataSet replaceObjectAtIndex:5 withObject:data];
            
            [self.collectionView reloadData];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(tuBeautySkinPanelView:didSelectSkinIndex:)])
            {
                [self.delegate tuBeautySkinPanelView:self didSelectSkinIndex:indexPath.item];
            }
            
            [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
        }
        else
        {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(tuBeautySkinPanelView:didSelectSkinIndex:)])
            {
                _selectCode = [self selectedSkinKey];
                [self.delegate tuBeautySkinPanelView:self didSelectSkinIndex:indexPath.item];
            }
        }
    }
}

#pragma mark - method
- (void)loadBeautySkinData
{
    self.skinDataSet = [NSMutableArray array];
    
    TuBeautySkinData *resetData = [[TuBeautySkinData alloc] init];
    resetData.beautySkinCode = @"reset";
    resetData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
    [self.skinDataSet addObject:resetData];

    NSArray *skinFeatures = @[TuBeautySkinKeys];
    
    TuBeautySkinData *faceData = [[TuBeautySkinData alloc] init];
    faceData.beautySkinCode = skinFeatures[0];
    faceData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
    [self.skinDataSet addObject:faceData];

    TuBeautySkinData *pointData = [[TuBeautySkinData alloc] init];
    pointData.beautySkinCode = @"point";
    pointData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
    [self.skinDataSet addObject:pointData];
    
    for (int i = 1; i < skinFeatures.count; i++)
    {
        TuBeautySkinData *faceData = [[TuBeautySkinData alloc] init];
        faceData.beautySkinCode = skinFeatures[i];
        faceData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
        [self.skinDataSet addObject:faceData];
    }
}

- (void)setFaceType:(TuSkinFaceType)faceType
{
    _faceType = faceType;
}

- (NSString *)selectedSkinKey;
{
    if (_faceType == TuSkinFaceTypeBeauty)
    {
        if (_lastSelectItem > 2 && _lastSelectItem - 2 < @[kBeautySkinKeys].count)
            return @[kBeautySkinKeys][_lastSelectItem - 2];
    }
    else
    {
        if (_lastSelectItem > 2 && _lastSelectItem - 2 < @[kNaturalBeautySkinKeys].count)
            return @[kNaturalBeautySkinKeys][_lastSelectItem - 2];
    }
    
    return nil;
}

@end
