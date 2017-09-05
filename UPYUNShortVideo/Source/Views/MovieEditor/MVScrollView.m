//
//  MVScrollView.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/26.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MVScrollView.h"
#import "TuSDKFramework.h"

@interface MVScrollView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    // 数据源
    // 贴纸组的数组
    NSMutableArray<TuSDKMVStickerAudioEffectData *> *_mvArr;
    // 记录上一次点击的时间
    CGFloat _lastTapTime;

}

@end

@implementation MVScrollView

#pragma mark - 视图布局方法
- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self createStickerCollection];
    }
    return self;
}

- (void)createStickerCollection
{
    // 创建FlowLayout方式
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    CGFloat itemHeight = self.lsqGetSizeHeight;
    layout.itemSize = CGSizeMake(itemHeight*13/18, itemHeight);
    layout.minimumLineSpacing = 11;
    layout.minimumInteritemSpacing = 11;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 创建collection
    _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = self.backgroundColor;
    _collectionView.showsVerticalScrollIndicator = false;
    _collectionView.showsHorizontalScrollIndicator = false;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    [self addSubview:_collectionView];
    
    // 获取贴纸组数据源
    NSArray<TuSDKPFStickerGroup *> *stickers = [[TuSDKPFStickerLocalPackage package] getSmartStickerGroupsWithFaceFeature:NO];
    
    _mvArr = [[NSMutableArray alloc]init];
    int i = 0;
    for (TuSDKPFStickerGroup *sticker in stickers) {
        NSURL *audioURL = [self getAudioURLWithStickerIdt:sticker.idt];
        TuSDKMVStickerAudioEffectData *mvData =  [[TuSDKMVStickerAudioEffectData alloc] initWithAudioURL:audioURL stickerGroup:sticker];
        [_mvArr addObject:mvData];
        i++;
    }
}

- (NSURL *)getAudioURLWithStickerIdt:(int64_t)stickerIdt;
{
    NSDictionary *fileNameDic = @{@(1420):@"sound_cat",
                                  @(1427):@"sound_crow",
                                  @(1469):@"sound_lively",
                                  @(1470):@"sound_oldmovie",
                                  @(1432):@"sound_tangyuan",
                                  @(1446):@"sound_children"};
    
    NSString *audioFileName = fileNameDic[@(stickerIdt)];
    NSURL *audioURL = !audioFileName ? nil : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:audioFileName ofType:@"mp3"]];
    return audioURL;
}

// 选中某一个cell
- (void)selectItemWithIndex:(NSIndexPath *)indexPath;
{
    if (_collectionView.indexPathsForSelectedItems && _collectionView.indexPathsForSelectedItems.count > 0) {
        NSIndexPath *currentIndexPath = _collectionView.indexPathsForSelectedItems[0];
        [_collectionView deselectItemAtIndexPath:currentIndexPath animated:YES];
        [self collectionView:_collectionView didDeselectItemAtIndexPath:currentIndexPath];
    }
    [_collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
    [self collectionView:_collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark -- collection代理方法 collectionDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat currentTime = [[NSDate date] timeIntervalSince1970];
    
    if ([_collectionView.indexPathsForSelectedItems isEqual:indexPath] || (currentTime - _lastTapTime) <= 0.5) {
        return NO;
    }
    
    _lastTapTime = currentTime;
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.mvDelegate respondsToSelector:@selector(clickMVListViewWith:)]) {
        if (indexPath.row == 0) {
            [self.mvDelegate clickMVListViewWith:nil];
        }else{
            [self.mvDelegate clickMVListViewWith:_mvArr[indexPath.row-1]];
        }
    }
    // 给cell添加选中边框
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 2;
    cell.layer.borderColor = HEXCOLOR(0x22bbf4).CGColor;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
        // 给上一个选中的cell取消选中边框
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 2;
    cell.layer.borderColor = [UIColor clearColor].CGColor;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _mvArr.count+1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 设置cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    
    CGRect rect;
    if (indexPath.row != 0) {
        rect = CGRectMake(0, 0, cell.lsqGetSizeWidth, cell.lsqGetSizeWidth);
    }else{
        rect = CGRectMake(0, 0, 30, 30);
    }
    
    UIImageView *iv = [[UIImageView alloc]initWithFrame:rect];
    iv.center = CGPointMake(cell.lsqGetSizeWidth/2, (cell.lsqGetSizeHeight - 20)/2);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.image = nil;
    // 注意：201为查找该cell上的iv时用的标志tag
    
    if (indexPath.row == 0) {
        // 第一张图固定
        iv.image = [UIImage imageNamed:@"video_style_default_btn_sticker_off"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, iv.lsqGetOriginY + iv.lsqGetSizeHeight + 3, cell.lsqGetSizeWidth, 20)];
        label.text = NSLocalizedString(@"lsq_deleteBtn_title", @"无效果");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = HEXCOLOR(0x22bbf4);
        label.font = [UIFont systemFontOfSize:12];
        label.adjustsFontSizeToFitWidth = YES;
        [cell addSubview:iv];
        [cell addSubview:label];
    }else{
        UIImageView *backIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, cell.lsqGetSizeWidth, cell.lsqGetSizeHeight)];
        backIV.image = [UIImage imageNamed:@"style_default_1.5.0_btn_mv_bg.jpg"];
        backIV.contentMode = UIViewContentModeScaleAspectFill;
        backIV.backgroundColor = [UIColor greenColor];
        [cell addSubview:backIV];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.lsqGetSizeWidth, 20)];
        label.text = _mvArr[indexPath.row-1].stickerGroup.name;
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        label.adjustsFontSizeToFitWidth = YES;
        // 获取对应贴纸的缩略图
        [[TuSDKPFStickerLocalPackage package] loadThumbWithStickerGroup:_mvArr[indexPath.row-1].stickerGroup imageView:iv];
        [cell addSubview:iv];
        label.center = CGPointMake(iv.lsqGetSizeWidth/2, cell.lsqGetSizeHeight-10);
        [cell addSubview:label];
    }
    cell.layer.cornerRadius = 3;
    cell.clipsToBounds = YES;
    return cell;
}

@end
