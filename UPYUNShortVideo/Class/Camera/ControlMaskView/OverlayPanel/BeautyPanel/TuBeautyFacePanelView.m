//
//  TuBeautyPanelView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/12/4.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuBeautyFacePanelView.h"
#import "TuBeautyFacePanelViewCell.h"
#import "Constants.h"

#define itemHeight 90
@interface TuBeautyFacePanelView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    //上一次选中的item
    NSInteger _lastSelectItem;
    
}
@property (nonatomic, strong) UICollectionView *collectionView;
//微整形数组
@property (nonatomic, strong) NSMutableArray *plasticDataSet;

@end

@implementation TuBeautyFacePanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initWithSubViews];
    }
    return self;
}

- (void)initWithSubViews
{
    //加载数据
    [self loadBeautyFaceData];
    
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
    [_collectionView registerClass:[TuBeautyFacePanelViewCell class] forCellWithReuseIdentifier:@"TuBeautyFacePanelViewCell"];
}

- (void)layoutSubviews
{
    self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.plasticDataSet.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 1)
    {
        return CGSizeMake(20, itemHeight);
    }
    else
    {
        return CGSizeMake(60, itemHeight);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuBeautyFacePanelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TuBeautyFacePanelViewCell" forIndexPath:indexPath];
    cell.beautyFaceData = self.plasticDataSet[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 1){}
    else
    {
        //上一次选中不为0，则需要将上一次点击事件重置
        if (indexPath.item != _lastSelectItem)
        {
            if (_lastSelectItem != 0)
            {
                TuBeautyFacePanelViewCell *lastCell = (TuBeautyFacePanelViewCell *)[self collectionView:_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_lastSelectItem inSection:0]];
                
                TuBeautyFaceData *lastData = self.plasticDataSet[_lastSelectItem];
                lastData.beautyFaceSelectType = TuBeautyFaceSelectTypeUnselected;
                lastCell.beautyFaceData = lastData;
            }
            else
            {
                for (int i = 0; i < self.plasticDataSet.count; i++)
                {
                    TuBeautyFaceData *data = self.plasticDataSet[i];
                    data.beautyFaceSelectType = TuBeautyFaceSelectTypeUnselected;
                    [self.plasticDataSet replaceObjectAtIndex:i withObject:data];
                }
            }
        }
        
        TuBeautyFacePanelViewCell *cell = [self collectionView:_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        TuBeautyFaceData *data = self.plasticDataSet[indexPath.item];
        data.beautyFaceSelectType = TuBeautyFaceSelectTypeSelected;
        cell.beautyFaceData = data;
        self.selectedFaceFeature = data.beautyFaceCode;
        //点击重置
        if (indexPath.item == 0)
        {
            //未选中时点击重置无效
            if (_lastSelectItem == 0)
            {
                return;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(tuBeautyFacePanelViewResetParamters)])
            {
                //重置所有微整形效果
                [self.delegate tuBeautyFacePanelViewResetParamters];
            }
        }
        else
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tuBeautyFacePanelView:didSelectFaceCode:)])
            {
                [self.delegate tuBeautyFacePanelView:self didSelectFaceCode:data.beautyFaceCode];
            }
        }
        
        [_collectionView reloadData];

        _lastSelectItem = indexPath.item;
    }
}

#pragma mark - method
- (void)loadBeautyFaceData
{
    self.plasticDataSet = [NSMutableArray array];
    
    TuBeautyFaceData *resetData = [[TuBeautyFaceData alloc] init];
    resetData.beautyFaceCode = @"reset";
    resetData.beautyFaceSelectType = TuBeautyFaceSelectTypeUnselected;
    [self.plasticDataSet addObject:resetData];
    
    TuBeautyFaceData *pointData = [[TuBeautyFaceData alloc] init];
    pointData.beautyFaceCode = @"point";
    pointData.beautyFaceSelectType = TuBeautyFaceSelectTypeUnselected;
    [self.plasticDataSet addObject:pointData];
    
    NSArray *faceFeatures = @[kBeautyFaceKeyCodes];
    
    for (int i = 0; i < faceFeatures.count; i++)
    {
        TuBeautyFaceData *faceData = [[TuBeautyFaceData alloc] init];
        faceData.beautyFaceCode = faceFeatures[i];
        faceData.beautyFaceSelectType = TuBeautyFaceSelectTypeUnselected;
        [self.plasticDataSet addObject:faceData];
    }
}
@end
