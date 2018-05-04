//
//  DubScrollView.m
//  TuSDKVideoDemo
//
//  Created by wen on 04/07/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "DubScrollView.h"
#import "TuSDKFramework.h"

@interface DubScrollView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    
    // 视图布局
    // collection 对象
    UICollectionView *_collectionView;
    // 无效果图片展示IV
    UIImageView *_noEffectIV;
    // 无效果title
    UILabel *_noEffectLabel;
    // 录音图片展示IV
    UIImageView *_recordIV;
    // 录音title
    UILabel *_recordLabel;

    // 数据源
    // 音乐图片数组
    NSArray *_audioImageArr;
    // 音乐名称数组
    NSArray *_audioNameArr;
    // 音乐URL数组
    NSArray *_audioURLArr;
    
    // 记录上一次点击的时间
    CGFloat _lastTapTime;
    // 记录当前选中音乐的index
    NSIndexPath *_currentSelectIndexPath;

}

@end

@implementation DubScrollView

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
    layout.minimumLineSpacing = 12;
    layout.minimumInteritemSpacing = 12;
    layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 创建collection
    _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = self.backgroundColor;
    _collectionView.showsVerticalScrollIndicator = false;
    _collectionView.showsHorizontalScrollIndicator = false;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    
    // 设置音乐数据源
    _audioImageArr = @[@"lsq_audio_thumb_lively.jpg", @"lsq_audio_thumb_oldmovie.jpg", @"lsq_audio_thumb_relieve.jpg"];
    _audioNameArr = @[NSLocalizedString(@"lsq_audio_lively", @"欢快"), NSLocalizedString(@"lsq_audio_oldmovie", @"老电影"), NSLocalizedString(@"lsq_audio_relieve", @"舒缓")];
    
    NSURL *url1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_lively" ofType:@"mp3"] ];
    NSURL *url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_oldmovie" ofType:@"mp3"] ];
    NSURL *url3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_relieve" ofType:@"mp3"] ];

    _audioURLArr = @[url1,url2,url3];
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
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat currentTime = [[NSDate date] timeIntervalSince1970];

    if (_lastTapTime == 0 || (currentTime - _lastTapTime) > 0.5) {
        _lastTapTime = currentTime;
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dubDelegate respondsToSelector:@selector(clickDubListViewWith:)]) {
        if (indexPath.row == 0) {
            [self.dubDelegate clickDubListViewWith:nil];
        }else if (indexPath.row == 1){
            [self.dubDelegate clickDubListViewWith:nil];
            if ([self.dubDelegate respondsToSelector:@selector(displayRecorderView)]) {
                [self.dubDelegate displayRecorderView];
            }
        }else{
            [self.dubDelegate clickDubListViewWith:_audioURLArr[indexPath.row - 2]];
        }
    }
    
    // 给cell添加选中边框
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 2;
    cell.layer.borderColor = lsqRGB(244, 161, 24).CGColor;
    _currentSelectIndexPath = indexPath;
    
    if (indexPath.row == 0) {
        _noEffectIV.image = [UIImage imageNamed:@"style_default_1.11_btn_effect_select"];
        _noEffectLabel.textColor = lsqRGB(244, 161, 24);
    }else{
        _noEffectIV.image = [UIImage imageNamed:@"style_default_1.11_btn_effect_unselect"];
        _noEffectLabel.textColor = [UIColor lsqClorWithHex:@"#CCCCCC"];
    }

    if (indexPath.row == 1) {
        _recordIV.image = [UIImage imageNamed:@"style_default_1.11_btn_edit_recordSound_select"];
        _recordLabel.textColor = lsqRGB(244, 161, 24);
    }else{
        _recordIV.image = [UIImage imageNamed:@"style_default_1.11_btn_edit_recordSound_unselect"];
        _recordLabel.textColor = [UIColor lsqClorWithHex:@"#CCCCCC"];
    }
    
    for (UIView *view in cell.subviews) {
        if (view.tag == 103) {
            view.backgroundColor = lsqRGB(244, 161, 24);
        }
    }

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 给上一个选中的cell取消选中边框
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        cell.layer.borderWidth = 2;
        cell.layer.borderColor = [UIColor clearColor].CGColor;
        for (UIView *view in cell.subviews) {
            if (view.tag == 103) {
                view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            }
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _audioURLArr.count+2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
{
    if (![indexPath isEqual:_currentSelectIndexPath]) {
        cell.layer.borderWidth = 2;
        cell.layer.borderColor = [UIColor clearColor].CGColor;
        for (UIView *view in cell.subviews) {
            if (view.tag == 103) {
                view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            }
        }
    }else{
        cell.layer.borderWidth = 2;
        cell.layer.borderColor = lsqRGB(244, 161, 24).CGColor;
        for (UIView *view in cell.subviews) {
            if (view.tag == 103) {
                view.backgroundColor = lsqRGB(244, 161, 24);
            }
        }

    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 设置cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    
    CGRect rect;
    CGPoint center;
    if (indexPath.row > 1) {
        rect = CGRectMake(0, 0, cell.lsqGetSizeWidth, cell.lsqGetSizeHeight);
        center = CGPointMake(cell.lsqGetSizeWidth/2, (cell.lsqGetSizeHeight)/2);
    }else{
        rect = CGRectMake(0, 0, 30, 30);
        center = CGPointMake(cell.lsqGetSizeWidth/2, (cell.lsqGetSizeHeight - 20)/2);
    }
    
    UIImageView *iv = [[UIImageView alloc]initWithFrame:rect];
    iv.center = center;
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.image = nil;
    
    if (indexPath.row == 0) {
        // 无效果
        iv.image = [UIImage imageNamed:@"style_default_1.11_btn_effect_unselect"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, iv.lsqGetOriginY + iv.lsqGetSizeHeight + 3, cell.lsqGetSizeWidth, 30)];
        label.text = NSLocalizedString(@"lsq_deleteBtn_title", @"无效果");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lsqClorWithHex:@"#CCCCCC"];
        label.font = [UIFont systemFontOfSize:11];
        label.adjustsFontSizeToFitWidth = YES;
        _noEffectIV = iv;
        _noEffectLabel = label;
        [cell addSubview:iv];
        [cell addSubview:label];
        cell.backgroundColor = [UIColor lsqClorWithHex:@"#EFEFEF"];
        
    }else if (indexPath.row == 1){
        // 录音
        iv.image = [UIImage imageNamed:@"style_default_1.11_btn_edit_recordSound_unselect"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, iv.lsqGetOriginY + iv.lsqGetSizeHeight + 3, cell.lsqGetSizeWidth, 30)];
        label.text = NSLocalizedString(@"lsq_record_title", @"自己录音");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lsqClorWithHex:@"#CCCCCC"];
        label.font = [UIFont systemFontOfSize:11];
        label.adjustsFontSizeToFitWidth = YES;
        _recordIV = iv;
        _recordLabel = label;
        [cell addSubview:iv];
        [cell addSubview:label];
        cell.backgroundColor = [UIColor lsqClorWithHex:@"#EFEFEF"];
        
    }else{
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.lsqGetSizeWidth, 20)];
        label.text = _audioNameArr[indexPath.row - 2];
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.adjustsFontSizeToFitWidth = YES;
        label.tag = 103;
        // 获取对应贴纸的缩略图
        iv.image = [UIImage imageNamed:_audioImageArr[indexPath.row - 2]];
        [cell addSubview:iv];
        label.center = CGPointMake(iv.lsqGetSizeWidth/2, cell.lsqGetSizeHeight-10);
        [cell addSubview:label];
    }
    cell.layer.cornerRadius = 3;
    cell.clipsToBounds = YES;
    return cell;
}

@end
