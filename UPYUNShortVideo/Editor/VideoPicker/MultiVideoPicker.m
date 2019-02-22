//
//  MultiVideoPicker.m
//  MultiVideoPicker
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MultiVideoPicker.h"
#import "TuSDKFramework.h"

#import "MultiVideoPickerCell.h"
#import <Photos/Photos.h>

// CollectionView Cell 重用 ID
static NSString * const kCellReuseIdentifier = @"Cell";
// CollectionView Footer 重用 ID
static NSString * const kFooterReuseIdentifier = @"Footer";
// 单元格间距
static const CGFloat kCellMargin = 3;

@interface MultiVideoPicker ()

/**
 呈现的相册结果
 */
@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;

/**
 选中时加入 PHAsset，请求到 AVAsset 时再进行替换
 */
@property (nonatomic, strong) NSMutableArray *requestedAvAssets;

/**
 选中的 PHAsset
 */
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedPhAssets;

/**
 选中的索引
 */
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedIndexPaths;

/**
 请求中的视频 ID
 */
@property (nonatomic, strong) NSMutableDictionary<PHAsset *, NSNumber *> *requstingAssetIds;

@end

@implementation MultiVideoPicker

#pragma mark - property

- (NSMutableArray *)requestedAvAssets {
    if (!_requestedAvAssets) {
        _requestedAvAssets = [NSMutableArray array];
    }
    return _requestedAvAssets;
}

- (NSMutableArray *)selectedPhAssets {
    if (!_selectedPhAssets) {
        _selectedPhAssets = [NSMutableArray array];
    }
    return _selectedPhAssets;
}

- (NSMutableArray *)selectedIndexPaths {
    if (!_selectedIndexPaths) {
        _selectedIndexPaths = [NSMutableArray array];
    }
    return _selectedIndexPaths;
}

- (NSMutableDictionary *)requstingAssetIds {
    if (!_requstingAssetIds) {
        _requstingAssetIds = [NSMutableDictionary dictionary];
    }
    return _requstingAssetIds;
}

- (BOOL)requesting {
    return _requstingAssetIds.count > 0;
}

- (NSArray<AVURLAsset *> *)allSelectedAssets {
    return self.requesting ? nil : self.requestedAvAssets.copy;
}

- (NSTimeInterval)selectedVideosDutation {
    NSTimeInterval selectedVideosDutation = .0;
    for (PHAsset *phAsset in _selectedPhAssets) {
        selectedVideosDutation += phAsset.duration;
    }
    return selectedVideosDutation;
}

#pragma mark - view controller

+ (instancetype)picker {
    return [[self alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self.collectionView registerClass:[MultiVideoPickerCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    [self.collectionView registerClass:[MultiVideoPickerFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterReuseIdentifier];
    
    // 测试相册访问权限，并载入相册数据
    [TuSDKTSAssetsManager testLibraryAuthor:^(NSError *error) {
        if (error) {
            [TuSDKTSAssetsManager showAlertWithController:self loadFailure:error];
        } else {
            [self loadData];
        }
    }];
}

- (void)setupUI {
    CGFloat width = self.view.frame.size.width;
    CGFloat cellWidth = (width + kCellMargin) / 4 - kCellMargin;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.minimumInteritemSpacing = kCellMargin;
    flowLayout.minimumLineSpacing = kCellMargin;
    flowLayout.footerReferenceSize = CGSizeMake(width, 100);

    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    for (PHAsset *requestingPhAsset in _requstingAssetIds.allKeys) {
        [self cancelRequestWithVideo:requestingPhAsset];
    }
}

- (void)loadData {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    // PhotoKit 相册排序方式
    //options.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
    _fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
    [self.collectionView reloadData];
}

#pragma mark - public

- (PHAsset *)phAssetAtIndexPathItem:(NSInteger)indexPathItem {
    if (_fetchResult.count == 0) {
        return nil;
    }
    return _fetchResult[_fetchResult.count - 1 - indexPathItem];
}

- (NSInteger)selectedIndexForIndexPath:(NSIndexPath *)indexPath {
    NSInteger selectedIndex = -1;
    if ([_selectedIndexPaths containsObject:indexPath]) {
        selectedIndex = [_selectedIndexPaths indexOfObject:indexPath];
    }
    return selectedIndex;
}

- (void)setPhAsset:(PHAsset *)phAsset indexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    if (!phAsset && !indexPath) return;

    if (!indexPath) {
        indexPath = [self indexPathForPhAsset:phAsset];
    }
    
    if (!phAsset) {
        phAsset = [self phAssetAtIndexPathItem:indexPath.item];
    }
    
    if (_disableMultipleSelection) {
        // 处理单选
        [self singleSelectPhAsset:phAsset indexPath:indexPath];
    } else {
        // 处理多选
        [self multipleSelectPhAsset:phAsset indexPath:indexPath selected:selected];
    }
    
    // 更新单元格显示索引
    [self updateSelectedCellIndex];
}

#pragma mark - private

/**
 多选时，对单元格的勾选或取消勾选

 @param phAsset 选中的 PHAsset
 @param indexPath 选中的索引
 @param selected 是否选中
 */
- (void)multipleSelectPhAsset:(PHAsset *)phAsset indexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    __weak typeof(self) weakSelf = self;
    // 同步 UI
    MultiVideoPickerCell *cell = (MultiVideoPickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell.selectButton.selected != selected) cell.selectButton.selected = selected;
    
    // 处理选中、取消选中后的的数据
    if (selected) {
        // 确保唯一性
        if (![_selectedPhAssets containsObject:phAsset]) {
            [self.requestedAvAssets addObject:phAsset];
            [self.selectedPhAssets addObject:phAsset];
            [self.selectedIndexPaths addObject:indexPath];
            [self requestAVAssetForVideo:phAsset completion:^(PHAsset *inputPhAsset, AVAsset *avAsset) {
                if (![weakSelf.requestedAvAssets containsObject:inputPhAsset]) return;
                NSUInteger replaceIndex = [weakSelf.requestedAvAssets indexOfObject:inputPhAsset];
                [weakSelf.requestedAvAssets replaceObjectAtIndex:replaceIndex withObject:avAsset];
            }];
        }
    } else {
        NSUInteger assetIndex = [_selectedPhAssets indexOfObject:phAsset];
        if (assetIndex < _selectedPhAssets.count) {
            [_requestedAvAssets removeObjectAtIndex:assetIndex];
            [_selectedPhAssets removeObjectAtIndex:assetIndex];
            [_selectedIndexPaths removeObjectAtIndex:assetIndex];
            [self cancelRequestWithVideo:phAsset];
        }
    }
}

/**
 单选单元格

 @param phAsset 选中的 PHAsset
 @param indexPath 选中的索引
 */
- (void)singleSelectPhAsset:(PHAsset *)phAsset indexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    for (NSIndexPath *indexPathSelected in _selectedIndexPaths) {
        MultiVideoPickerCell *cell = (MultiVideoPickerCell *)[self.collectionView cellForItemAtIndexPath:indexPathSelected];
        cell.selectButton.selected = NO;
    }
    MultiVideoPickerCell *cellShouldBeSelected = (MultiVideoPickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cellShouldBeSelected.selectButton.selected = YES;
    
    for (PHAsset *requestingPhAsset in _requstingAssetIds.allKeys) {
        [self cancelRequestWithVideo:requestingPhAsset];
    }
    [_requestedAvAssets removeAllObjects];
    [_selectedPhAssets removeAllObjects];
    [_selectedIndexPaths removeAllObjects];
    if (_selectedPhAssets.count > 1 || ![_selectedPhAssets containsObject:phAsset]) {
        [self.selectedPhAssets addObject:phAsset];
        [self.selectedIndexPaths addObject:indexPath];
        [self requestAVAssetForVideo:phAsset completion:^(PHAsset *inputPhAsset, AVAsset *avAsset) {
            [weakSelf.requestedAvAssets addObject:avAsset];
        }];
    }
}

/**
 单元格被勾选

 @param cell 相册展示单元格
 @param selected 是否选择
 */
- (void)cell:(MultiVideoPickerCell *)cell didSelect:(BOOL)selected {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PHAsset *phAsset = [self phAssetAtIndexPathItem:indexPath.item];
    
    [self setPhAsset:phAsset indexPath:indexPath selected:selected];
}

/**
 更新所有选中索引的显示
 */
- (void)updateSelectedCellIndex {
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        MultiVideoPickerCell *cell = (MultiVideoPickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.selectedIndex = idx;
    }];
}

/**
 按 PHAsset 获取索引

 @param phAsset 视频文件对象
 @return 索引
 */
- (NSIndexPath *)indexPathForPhAsset:(PHAsset *)phAsset {
    NSInteger phAssetIndex = [_fetchResult indexOfObject:phAsset];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(_fetchResult.count - 1 - phAssetIndex) inSection:0];
    return indexPath;
}

/**
 请求 PHAsset 为 AVAsset，维护 _requstingAssetIds

 @param phAsset 视频文件对象
 @param completion 完成后的操作
 @return 视频对象的请求 ID
 */
- (PHImageRequestID)requestAVAssetForVideo:(PHAsset *)phAsset completion:(void (^)(PHAsset *inputPhAsset, AVAsset *avAsset))completion {
    // 若已经在请求，则直接返回 -1
    if ([_requstingAssetIds.allKeys containsObject:phAsset]) return -1;
    __weak typeof(self) weakSelf = self;
    
    // 配置请求
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        //NSLog(@"iCloud 下载 progress: %f", progress);
        // 若 phAsset 已移除请求，则直接返回
        if (![weakSelf.requstingAssetIds.allKeys containsObject:phAsset]) return;
        
        if (progress == 1.0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TuSDK shared].messageHub dismiss];
            });
        } else {
            [[TuSDK shared].messageHub showProgress:progress status:@"iCloud 同步中"];
        }
    };
    
    __block BOOL finish = NO;
    PHImageRequestID requestId = [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        //NSLog(@"请求结果：%@， info: %@", asset, info);
        finish = YES;
        if (!asset) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(phAsset, asset);
            [weakSelf.requstingAssetIds removeObjectForKey:phAsset];
        });
    }];
    if (!finish) self.requstingAssetIds[phAsset] = @(requestId);
    return requestId;
}

/**
 取消请求 PHAsset，维护 _requstingAssetIds

 @param phAsset 视频文件对象
 @return 是否取消请求
 */
- (BOOL)cancelRequestWithVideo:(PHAsset *)phAsset {
    NSNumber *requestIdNumber = _requstingAssetIds[phAsset];
    
    if (!requestIdNumber) return NO;
    PHImageRequestID requestId = (PHImageRequestID)requestIdNumber.integerValue;
    [[PHImageManager defaultManager] cancelImageRequest:requestId];
    [_requstingAssetIds removeObjectForKey:phAsset];
    
    [[TuSDK shared].messageHub dismiss];
    return YES;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self phAssetAtIndexPathItem:indexPath.item];
    MultiVideoPickerCell *cell = (MultiVideoPickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.selectButton.selected = [_selectedPhAssets containsObject:asset];
    cell.selectedIndex = [_selectedPhAssets indexOfObject:asset];
    
    __weak typeof(cell) weak_cell = cell;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(cell.contentView.bounds), CGRectGetHeight(cell.contentView.bounds));
    cell.duration = asset.duration;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weak_cell.imageView.image = result;
    }];
    __weak typeof(self) weakSelf = self;
    cell.selectButtonActionHandler = ^(MultiVideoPickerCell *cell, UIButton *sender) {
        BOOL selected = !sender.selected;
        // 若 iCloud 请求中则不让其选中
        if (selected && weakSelf.requesting) {
            return;
        }
        // 不允许选中则跳过
        if (selected && [weakSelf.delegate respondsToSelector:@selector(picker:shouldSelectItemAtIndexPath:)]) {
            if (![weakSelf.delegate picker:weakSelf shouldSelectItemAtIndexPath:indexPath]) {
                return;
            }
        }
        // 不允许取消选中则跳过
        if (!selected && [weakSelf.delegate respondsToSelector:@selector(picker:shouldDeselectItemAtIndexPath:)]) {
            if (![weakSelf.delegate picker:weakSelf shouldDeselectItemAtIndexPath:indexPath]) {
                return;
            }
        }
        // 应用选中
        sender.selected = selected;
        [weakSelf cell:cell didSelect:selected];
    };
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        MultiVideoPickerFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kFooterReuseIdentifier forIndexPath:indexPath];
        footerView.videoCount = self.fetchResult.count;
        return footerView;
    }
    return nil;
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return !self.requesting;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    PHAsset *phAsset = [self phAssetAtIndexPathItem:indexPath.item];
    if ([self.delegate respondsToSelector:@selector(picker:didTapItemWithIndexPath:phAsset:)]) {
        [self.delegate picker:self didTapItemWithIndexPath:indexPath phAsset:phAsset];
    }
}

@end
