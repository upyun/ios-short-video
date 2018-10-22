//
//  TuPhotosViewController.m
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import "TuPhotosViewController.h"
#import "TuVideoModel.h"
#import "TuPhotosPreviewViewCell.h"
#import "TuPhotosFooterView.h"
#import "TuVideoContainerViewController.h"

@interface TuPhotosViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) UICollectionView *collectionView;

@end

static NSString *cellId = @"photoPreviewCell";
static NSString *cellFooterId = @"photoCellFooterId";

@implementation TuPhotosViewController

#pragma mark - init method

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"lsq_albumComponent_cancelButton", @"取消") style:UIBarButtonItemStylePlain target:self action:@selector(closeAlbum)];
    
    [self setup];
}

- (void)closeAlbum
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setup
{
    CGFloat width = self.view.frame.size.width;
    CGFloat heght = self.view.frame.size.height;
    
    CGFloat CVwidth = (width - 15 ) / 4;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(CVwidth, CVwidth);
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.footerReferenceSize = CGSizeMake(width, 40);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 5, width, heght) collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    [collectionView registerClass:[TuPhotosPreviewViewCell class] forCellWithReuseIdentifier:cellId];
    [collectionView registerClass:[TuPhotosFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:cellFooterId];
}

#pragma mark - collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allPhotosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuPhotosPreviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    cell.model = self.allPhotosArray[indexPath.item];
    
    __weak typeof(self) weakSelf = self;
    [cell setDidPHBlock:^(UICollectionViewCell *cell) {
        NSIndexPath *indexPt = [collectionView indexPathForCell:cell];
        TuVideoModel *model = weakSelf.allPhotosArray[indexPt.row];
        
//         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.isPreviewVideo) {
                
                TuVideoContainerViewController *vc = [[TuVideoContainerViewController alloc] init];
                vc.model = model;
                vc.didSelectedBlock = ^(TuVideoModel *selectedModel) {
                    if (selectedModel && [weakSelf.selectedDelegate respondsToSelector:@selector(selectedModel:)]) {
                        [weakSelf.selectedDelegate selectedModel:selectedModel];
                    }
                };
                [weakSelf.navigationController pushViewController:vc animated:YES];
                
            }else{
                if ([weakSelf.selectedDelegate respondsToSelector:@selector(selectedModel:)]) {
                    [weakSelf.selectedDelegate selectedModel:model];
                }
                [weakSelf closeAlbum];
            }
//        });
        
    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        TuPhotosFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellFooterId forIndexPath:indexPath];
        footerView.total = self.allPhotosArray.count;
        return footerView;
    }
    return nil;
}

#pragma mark - dealloc

- (void)dealloc
{
    
}

@end

