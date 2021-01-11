//
//  TuCosmeticListView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/10/20.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuCosmeticPanelView.h"
#import "TuCosmeticCategoryCell.h"
#import "Constants.h"
#import "TuSDKFramework.h"
#import "TuCosmeticConfig.h"

#define itemHeight 90
@interface TuCosmeticPanelView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    //上一次选中的section
    NSInteger _lastSelectSection;
    //口红类型数据
    TuCosmeticLipStickData *_lipStickData;
    //眉毛类型数据
    TuCosmeticEyeBrowData *_eyeBrowData;
    //选中的眉毛code
    NSString *_eyebrowCode;
    //选中的唇彩类型
    NSString *_lipStickCode;
}
@property (nonatomic, strong) UICollectionView *collectionView;
//美妆数组
@property (nonatomic, strong) NSMutableArray *cosmeticDataSet;
//美妆贴纸数组
@property (nonatomic, strong) NSMutableArray *stickerDataSet;
//选中下标数组
@property (nonatomic, strong) NSMutableArray *selectDataSet;
@end

@implementation TuCosmeticPanelView

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
    self.cosmeticDataSet = [NSMutableArray array];
    self.stickerDataSet = [NSMutableArray array];
    NSArray *cosmeticArray = [TuCosmeticConfig cosmeticDataSet];
    
    for (NSString *cosmeticCode in cosmeticArray)
    {
        TuCosmeticHeaderData *data = [[TuCosmeticHeaderData alloc] init];
        data.cosmeticCode = cosmeticCode;
        data.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
        [self.cosmeticDataSet addObject:data];
        
        NSMutableArray *itemDataSet = [self comboDateSetWithCode:data.cosmeticCode];
        [self.stickerDataSet addObject:itemDataSet];
    }
    
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
    [_collectionView registerClass:[TuCosmeticCategoryCell class] forCellWithReuseIdentifier:@"TuCosmeticCell"];
}

- (void)layoutSubviews
{
    self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.cosmeticDataSet.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    TuCosmeticHeaderData *data = self.cosmeticDataSet[section];
    //从配置中获取元素数量
    NSArray *dataSource = [TuCosmeticConfig dataSetWithCosmeticCode:data.cosmeticCode];
    if ([data.cosmeticCode isEqualToString:@"point"])
    {
        return 1;
    }
    if (data.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
    {
        return 1;
    }
    else
    {
        return 1 + dataSource.count;
    }
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
    if (indexPath.item == 0)
    {
        NSArray *dataSet = [TuCosmeticConfig cosmeticDataSet];
        if (indexPath.section == 0 || indexPath.section == 1)
        {
            if ([data.cosmeticCode isEqualToString:@"point"])
            {
                return CGSizeMake(20, itemHeight);
            }
            if (self.lsqGetSizeWidth / dataSet.count < 60)
            {
                return CGSizeMake(60, itemHeight);
            }
            return CGSizeMake(self.lsqGetSizeWidth / dataSet.count, itemHeight);
        }
        else
        {
            if (data.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
            {
                if (self.lsqGetSizeWidth / dataSet.count < 60)
                {
                    return CGSizeMake(60, itemHeight);
                }
                return CGSizeMake(self.lsqGetSizeWidth / dataSet.count, itemHeight);
            }
            else
            {
                return CGSizeZero;
            }
        }
        
    }
    else
    {
        if (data.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
        {
            return CGSizeZero;
        }
        else
        {
            NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
            TuCosmeticItemData *stickerData = itemDataSet[indexPath.item - 1];
            
            if ([stickerData.stickerName isEqualToString:@"back"])
            {
                return CGSizeMake(60, itemHeight);
            }
            if ([stickerData.stickerName isEqualToString:@"point"])
            {
                return CGSizeMake(20, itemHeight);
            }
            return CGSizeMake(60, itemHeight);
        }
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuCosmeticCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TuCosmeticCell" forIndexPath:indexPath];
    
    if (indexPath.section == 2)
    {
        //口红
        if (indexPath.item == 0)
        {
            cell.data = self.cosmeticDataSet[indexPath.section];
        }
        else if (indexPath.item == 2)
        {
            //口红类型切换
            if (_lipStickData == nil)
            {
                TuCosmeticHeaderData *categoryData = self.cosmeticDataSet[indexPath.section];
                NSMutableArray *itemDataSet = [self comboDateSetWithCode:categoryData.cosmeticCode];
                //口红model
                TuCosmeticLipStickData *data = [[TuCosmeticLipStickData alloc] init];
                data.cosmeticCode = categoryData.cosmeticCode;
                data.itemCode = itemDataSet.firstObject;
                _lipStickData = data;
                cell.lipStickData = data;
            }
            else
            {
                cell.lipStickData = _lipStickData;
            }
        }
        else
        {
            NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
            TuCosmeticItemData *itemData = itemDataSet[indexPath.item - 1];
            cell.lipStickData = _lipStickData;
            cell.itemData = itemData;
        }
    }
    else if (indexPath.section == 4)
    {
        //眉毛
        if (indexPath.item == 0)
        {
            cell.data = self.cosmeticDataSet[indexPath.section];
        }
        else if (indexPath.item == 3)
        {
            if (_eyeBrowData == nil)
            {
                TuCosmeticHeaderData *categoryData = self.cosmeticDataSet[indexPath.section];
                NSMutableArray *itemDataSet = [self comboDateSetWithCode:categoryData.cosmeticCode];
                //眉毛类型model
                TuCosmeticEyeBrowData *data = [[TuCosmeticEyeBrowData alloc] init];
                data.cosmeticCode = categoryData.cosmeticCode;
                data.itemCode = itemDataSet.firstObject;
                _eyeBrowData = data;
                cell.eyeBrowData = data;
            }
            else
            {
                cell.eyeBrowData = _eyeBrowData;
            }
        }
        else
        {
            NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
            cell.eyeBrowData = _eyeBrowData;
            cell.itemData = itemDataSet[indexPath.item - 1];
        }
    }
    else
    {
        if (indexPath.item == 0)
        {
            cell.data = self.cosmeticDataSet[indexPath.section];
        }
        else
        {
            NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
            cell.itemData = itemDataSet[indexPath.item - 1];
        }
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuCosmeticCategoryCell *cell = (TuCosmeticCategoryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    
    if (indexPath.section == 0)
    {
        NSInteger count = 0;
        for (int i = 0; i < self.cosmeticDataSet.count; i++)
        {
            TuCosmeticHeaderData *data = self.cosmeticDataSet[i];
            
            if (data.cosmeticExistType == TuCosmeticTypeExist)
            {
                count++;
            }
        }
        //如果没有效果 则不提示
        if (count != 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:closeCosmetic:)])
            {
                [self.delegate tuCosmeticPanelView:self closeCosmetic:@"cosmeticReset"];
            }
        }
    }
    else if (indexPath.section == 1){}
    else if (indexPath.section == 2)
    {
        //口红
        if (indexPath.item == 0)
        {
            //判断是否点击同一个section，否则需要将上一个选中的section收起后再对当前选中的section进行操作
            if (indexPath.section != _lastSelectSection)
            {
                //上一次选中的cell
                [self packUpLastSection];
            }
            
            //对当前选中的section进行操作
            TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
            if (data.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
            {
                data.cosmeticSelectType = TuCosmeticSelectTypeSelected;
                
                [self judgeSliderBarIsHidden:NO section:indexPath.section];
            }

            cell.data = data;
            
            //刷新动画效果
            if (data.cosmeticSelectType == TuCosmeticSelectTypeSelected)
            {
                //目前点击选择第一个item后会隐藏，因此无需判断是否是选中状态
                [_collectionView reloadData];
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            }
        }
        else if (indexPath.item == 2)
        {
            //口红类型model
            _lipStickData = cell.lipStickData;
            //水润 -> 滋润 -> 雾面
            if (_lipStickData.lipStickType == TuCosmeticLipSticktWaterWet)
            {
                _lipStickData.lipStickType = TuCosmeticLipSticktMoist;
            }
            else if (_lipStickData.lipStickType == TuCosmeticLipSticktMoist)
            {
                _lipStickData.lipStickType = TuCosmeticLipSticktMatte;
            }
            else
            {
                _lipStickData.lipStickType = TuCosmeticLipSticktWaterWet;
            }
            cell.lipStickData = _lipStickData;
            [_collectionView reloadData];
            
            if (_lipStickCode.length != 0)
            {
                NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                NSInteger selectItem = [self.selectDataSet[indexPath.section] integerValue];
                TuCosmeticItemData *itemData = itemDataSet[selectItem - 1];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:didSelectedLipStickType:stickerName:)])
                {
                    [self.delegate tuCosmeticPanelView:self didSelectedLipStickType:_lipStickData.lipStickType stickerName:itemData.stickerName];
                }
            }
        }
        else
        {
            NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
            TuCosmeticItemData *stickerData = itemDataSet[indexPath.item - 1];
            TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
            
            if ([stickerData.stickerName isEqualToString:@"back"])
            {
                //收起操作
                if (data.cosmeticSelectType == TuCosmeticSelectTypeSelected)
                {
                    data.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                }

                cell.data = data;
                [_collectionView reloadData];
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                
                [self judgeSliderBarIsHidden:YES section:indexPath.section];
                
            }
            else if ([stickerData.stickerName isEqualToString:@"reset"])
            {
                //当前存在选中状态
                if ([self.selectDataSet[indexPath.section] integerValue] != 0)
                {
                    NSInteger selectItem = [self.selectDataSet[indexPath.section] integerValue];
                    
                    //上次选中和当前是同一个section，则需要将先前的选中状态取消
                    TuCosmeticCategoryCell *lastCell = (TuCosmeticCategoryCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectItem inSection:indexPath.section]];
                    
                    
                    NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                    TuCosmeticItemData *itemData = itemDataSet[selectItem - 1];
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                    lastCell.itemData = itemData;
                    [self.selectDataSet replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInteger:0]];
                    
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:closeCosmetic:)])
                    {
                        [self.delegate tuCosmeticPanelView:self closeCosmetic:data.cosmeticCode];
                        _lipStickCode = nil;
                    }
                    
                    //添加特效后显示已添加特效标识
                    data.cosmeticExistType = TuCosmeticTypeNone;
                    cell.data = data;
                    [_collectionView reloadData];
                }
            }
            else
            {
                //添加特效后显示已添加特效标识
                data.cosmeticExistType = TuCosmeticTypeExist;
                cell.data = data;
                
                //当前存在选中状态
                if ([self.selectDataSet[indexPath.section] integerValue] != 0)
                {
                    //上次选中和当前是同一个section，则需要将先前的选中状态取消
                    
                    NSInteger selectItem = [self.selectDataSet[indexPath.section] integerValue];
                    
                    TuCosmeticCategoryCell *lastCell = (TuCosmeticCategoryCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectItem inSection:indexPath.section]];
                    
                    NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                    TuCosmeticItemData *itemData = itemDataSet[selectItem - 1];
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                    lastCell.itemData = itemData;
                }
                
                NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                TuCosmeticItemData *itemData = itemDataSet[indexPath.item - 1];
                if (itemData.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
                {
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeSelected;
                    [self.selectDataSet replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInteger:indexPath.item]];
                }
                
                cell.itemData = itemData;
                [_collectionView reloadData];
                                
                if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:didSelectedLipStickType:stickerName:)])
                {
                    [self.delegate tuCosmeticPanelView:self didSelectedLipStickType:_lipStickData.lipStickType stickerName:itemData.stickerName];
                    _lipStickCode = itemData.stickerName;
                }
            }
        }
    }
    //眉毛
    else if (indexPath.section == 4)
    {
        if (indexPath.item == 0)
        {
            //判断是否点击同一个section，否则需要将上一个选中的section收起后再对当前选中的section进行操作
            if (indexPath.section != _lastSelectSection)
            {
                [self packUpLastSection];
            }
            //对当前选中的section进行操作
            TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
            if (data.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
            {
                data.cosmeticSelectType = TuCosmeticSelectTypeSelected;
                
                [self judgeSliderBarIsHidden:NO section:indexPath.section];
            }
            cell.data = data;
            
            if (data.cosmeticSelectType == TuCosmeticSelectTypeSelected)
            {
                [_collectionView reloadData];
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            }
        }
        else if (indexPath.item == 1){}
        else if (indexPath.item == 3)
        {
            //眉毛类型model
            _eyeBrowData = cell.eyeBrowData;
            //雾眉 -> 雾根眉
            if (_eyeBrowData.eyeBrowType == TuCosmeticEyeBrowFog)
            {
                _eyeBrowData.eyeBrowType = TuCosmeticEyeBrowFogen;
            }
            else
            {
                _eyeBrowData.eyeBrowType = TuCosmeticEyeBrowFog;
            }
            cell.eyeBrowData = _eyeBrowData;
            [_collectionView reloadData];
            
            if (_eyebrowCode.length != 0)
            {
                TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
                NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                NSInteger selectItem = [self.selectDataSet[indexPath.section] integerValue];
                TuCosmeticItemData *stickerData = itemDataSet[selectItem - 1];
                NSString *stickerCode = [TuCosmeticConfig eyeBrowCodeByBrowType:_eyeBrowData.eyeBrowType stickerName:stickerData.stickerName];
                if (stickerCode.length == 0)
                {
                    return;
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:didSelectedCosmeticCode:stickerCode:)])
                {
                    _eyebrowCode = stickerCode;
                    [self.delegate tuCosmeticPanelView:self didSelectedCosmeticCode:data.cosmeticCode stickerCode:stickerCode];
                }
            }
        }
        else
        {
            TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
            NSMutableArray *itemDataSet = [self comboDateSetWithCode:data.cosmeticCode];
            TuCosmeticItemData *stickerData = itemDataSet[indexPath.item - 1];
            
            if ([stickerData.stickerName isEqualToString:@"back"])
            {
                //收起操作
                TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
                if (data.cosmeticSelectType == TuCosmeticSelectTypeSelected)
                {
                    data.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                }
                cell.data = data;
                [_collectionView reloadData];
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                
                [self judgeSliderBarIsHidden:YES section:indexPath.section];
            }
            else if ([stickerData.stickerName isEqualToString:@"reset"])
            {
                //当前存在选中状态
                if ([self.selectDataSet[indexPath.section] integerValue] != 0)
                {
                    //上次选中和当前是同一个section，则需要将先前的选中状态取消
                    
                    NSInteger selectItem = [self.selectDataSet[indexPath.section] integerValue];
                    
                    TuCosmeticCategoryCell *lastCell = (TuCosmeticCategoryCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectItem inSection:indexPath.section]];
                    
                    NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                    TuCosmeticItemData *itemData = itemDataSet[selectItem - 1];
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                    lastCell.itemData = itemData;
                    [self.selectDataSet replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInteger:0]];
                    
                    TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:closeCosmetic:)])
                    {
                        _eyebrowCode = nil;
                        [self.delegate tuCosmeticPanelView:self closeCosmetic:data.cosmeticCode];
                    }
                    //添加特效后显示已添加特效标识
                    data.cosmeticExistType = TuCosmeticTypeNone;
                    cell.data = data;
                    [_collectionView reloadData];
                }
            }
            else
            {
                //添加特效后显示已添加特效标识
                data.cosmeticExistType = TuCosmeticTypeExist;
                cell.data = data;
                
                //当前存在选中状态
                if ([self.selectDataSet[indexPath.section] integerValue] != 0)
                {
                    //上次选中和当前是同一个section，则需要将先前的选中状态取消
                    
                    NSInteger selectItem = [self.selectDataSet[indexPath.section] integerValue];
                    
                    TuCosmeticCategoryCell *lastCell = (TuCosmeticCategoryCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectItem inSection:indexPath.section]];
                    
                    NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                    TuCosmeticItemData *itemData = itemDataSet[selectItem - 1];
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                    lastCell.itemData = itemData;
                }
                
                NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                TuCosmeticItemData *itemData = itemDataSet[indexPath.item - 1];
                if (itemData.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
                {
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeSelected;
                    [self.selectDataSet replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInteger:indexPath.item]];
                }
                
                cell.itemData = itemData;
                [_collectionView reloadData];
                                
                NSString *stickerCode = [TuCosmeticConfig eyeBrowCodeByBrowType:_eyeBrowData.eyeBrowType stickerName:stickerData.stickerName];
                if (stickerCode.length == 0)
                {
                    return;
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:didSelectedCosmeticCode:stickerCode:)])
                {
                    _eyebrowCode = stickerCode;
                    [self.delegate tuCosmeticPanelView:self didSelectedCosmeticCode:data.cosmeticCode stickerCode:stickerCode];
                }
            }
        }
    }
    else
    {
        if (indexPath.item == 0)
        {
            //判断是否点击同一个section，否则需要将上一个选中的section收起后再对当前选中的section进行操作
            if (indexPath.section != _lastSelectSection)
            {
                [self packUpLastSection];
            }
            //对当前选中的section进行操作
            TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
            if (data.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
            {
                data.cosmeticSelectType = TuCosmeticSelectTypeSelected;
                
                [self judgeSliderBarIsHidden:NO section:indexPath.section];
            }
            cell.data = data;
            
            if (data.cosmeticSelectType == TuCosmeticSelectTypeSelected)
            {
                [_collectionView reloadData];
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            }
        }
        else if (indexPath.item == 1){}
        else
        {
            TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
            NSMutableArray *itemDataSet = [self comboDateSetWithCode:data.cosmeticCode];
            TuCosmeticItemData *stickerData = itemDataSet[indexPath.item - 1];
            if ([stickerData.stickerName isEqualToString:@"back"])
            {
                //收起操作
                TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
                if (data.cosmeticSelectType == TuCosmeticSelectTypeSelected)
                {
                    data.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                }
                
                cell.data = data;
                [_collectionView reloadData];
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                
                [self judgeSliderBarIsHidden:YES section:indexPath.section];
            }
            else if ([stickerData.stickerName isEqualToString:@"reset"])
            {
                //当前存在选中状态
                if ([self.selectDataSet[indexPath.section] integerValue] != 0)
                {
                    //上次选中和当前是同一个section，则需要将先前的选中状态取消
                    
                    NSInteger selectItem = [self.selectDataSet[indexPath.section] integerValue];
                    
                    TuCosmeticCategoryCell *lastCell = (TuCosmeticCategoryCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectItem inSection:indexPath.section]];
                    
                    NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                    TuCosmeticItemData *itemData = itemDataSet[selectItem - 1];
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                    lastCell.itemData = itemData;
                    [self.selectDataSet replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInteger:0]];
                    
                    TuCosmeticHeaderData *data = self.cosmeticDataSet[indexPath.section];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:closeCosmetic:)])
                    {
                        [self.delegate tuCosmeticPanelView:self closeCosmetic:data.cosmeticCode];
                    }
                    
                    //添加特效后显示已添加特效标识
                    data.cosmeticExistType = TuCosmeticTypeNone;
                    cell.data = data;
                    [_collectionView reloadData];
                }
            }
            else if ([stickerData.stickerName isEqualToString:@"point"]) {}
            else
            {
                //添加特效后显示已添加特效标识
                data.cosmeticExistType = TuCosmeticTypeExist;
                cell.data = data;
                
                //当前存在选中状态
                if ([self.selectDataSet[indexPath.section] integerValue] != 0)
                {
                    //上次选中和当前是同一个section，则需要将先前的选中状态取消
                    
                    NSInteger selectItem = [self.selectDataSet[indexPath.section] integerValue];
                    
                    TuCosmeticCategoryCell *lastCell = (TuCosmeticCategoryCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectItem inSection:indexPath.section]];
                    
                    NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                    TuCosmeticItemData *itemData = itemDataSet[selectItem - 1];
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
                    lastCell.itemData = itemData;
                }
                
                NSMutableArray *itemDataSet = self.stickerDataSet[indexPath.section];
                TuCosmeticItemData *itemData = itemDataSet[indexPath.item - 1];
                if (itemData.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
                {
                    itemData.cosmeticSelectType = TuCosmeticSelectTypeSelected;
                    [self.selectDataSet replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInteger:indexPath.item]];
                }
                
                cell.itemData = itemData;
                [_collectionView reloadData];
                                
                NSString *stickerCode = [TuCosmeticConfig effectCodeByCosmeticCode:data.cosmeticCode stickerName:stickerData.stickerName];
                if (stickerCode.length == 0)
                {
                    return;
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:didSelectedCosmeticCode:stickerCode:)])
                {
                    [self.delegate tuCosmeticPanelView:self didSelectedCosmeticCode:data.cosmeticCode stickerCode:stickerCode];
                }
            }
        }
    }
    _lastSelectSection = indexPath.section;
}

//是否收起调节栏
- (void)judgeSliderBarIsHidden:(BOOL)hidden section:(NSInteger)section
{
    if (hidden == NO)
    {
        if ([self.selectDataSet[section] integerValue] != 0)
        {
            hidden = NO;
        }
        else
        {
            hidden = YES;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tuCosmeticPanelView:closeSliderBar:)])
    {
        [self.delegate tuCosmeticPanelView:self closeSliderBar:hidden];
    }
}

//收起上一个section
- (void)packUpLastSection
{
    TuCosmeticCategoryCell *lastCell = (TuCosmeticCategoryCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:_lastSelectSection]];
    //将上一次选中的section收起
    TuCosmeticHeaderData *lastData = self.cosmeticDataSet[_lastSelectSection];
    lastData.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
    lastCell.data = lastData;
}

//组合item data数据
- (NSMutableArray *)comboDateSetWithCode:(NSString *)cosmeticCode
{
    NSArray *dataSource = [TuCosmeticConfig dataSetWithCosmeticCode:cosmeticCode];
    NSMutableArray *itemDataSet = [NSMutableArray array];
    for (NSString *code in dataSource) {
        TuCosmeticItemData *data = [[TuCosmeticItemData alloc] init];
        data.stickerName = code;
        data.cosmeticCode = cosmeticCode;
        data.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
        [itemDataSet addObject:data];
    }
    return itemDataSet;
}


#pragma mark - property
- (void)setResetCosmetic:(BOOL)resetCosmetic
{
    _resetCosmetic = resetCosmetic;
    if (resetCosmetic)
    {
        [self.stickerDataSet removeAllObjects];

        for (int i = 0; i < self.cosmeticDataSet.count; i++)
        {
            TuCosmeticHeaderData *data = self.cosmeticDataSet[i];
            data.cosmeticExistType = TuCosmeticTypeNone;
            data.cosmeticSelectType = TuCosmeticSelectTypeUnselected;
            [self.cosmeticDataSet replaceObjectAtIndex:i withObject:data];
            
            NSMutableArray *itemDataSet = [self comboDateSetWithCode:data.cosmeticCode];
            [self.stickerDataSet addObject:itemDataSet];
        }
        [self.selectDataSet removeAllObjects];
        for (int i = 0; i < [TuCosmeticConfig cosmeticDataSet].count; i++)
        {
            [self.selectDataSet addObject:[NSNumber numberWithInt:0]];
        }

        [_collectionView reloadData];
    }
}

#pragma mark - lazyload
- (NSMutableArray *)selectDataSet
{
    if (!_selectDataSet)
    {
        _selectDataSet = [NSMutableArray array];
        for (int i = 0; i < [TuCosmeticConfig cosmeticDataSet].count; i++)
        {
            [_selectDataSet addObject:[NSNumber numberWithInt:0]];
        }
    }
    return _selectDataSet;
}

@end
