//
//  MultiVideoPicker.m
//  MultiVideoPicker
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MultiVideoPicker.h"
#import "TuAssetManager.h"
#import "MultiVideoPickerCell.h"
#import "TopNavBar.h"
#import "TuSDKFramework.h"
#import "APIMovieSplicerViewController.h"

static NSString * const reuseIdentifier = @"Cell";
static const CGFloat kCellMargin = 3;

@interface MultiVideoPicker ()<TopNavBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>{
    // 编辑页面顶部控制栏视图
    TopNavBar *_topBar;
    
    // 距离定点距离
    CGFloat topYDistance;
}

@property (nonatomic, strong) NSMutableArray *fetchResult;

@property (nonatomic, strong) NSMutableArray *selectedAssets;

@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedIndexPaths;

@property (nonatomic, weak) UICollectionView  *collentionView;

@end

@implementation MultiVideoPicker

#pragma mark - property

- (NSMutableArray *)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

- (NSMutableArray *)selectedIndexPaths {
    if (!_selectedIndexPaths) {
        _selectedIndexPaths = [NSMutableArray array];
    }
    return _selectedIndexPaths;
}

#pragma mark - view controller

+ (instancetype)picker {
    return [[self alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 顶部栏初始化
    [self initWithTopBar];
    
    [self setupUI];
    
    // Register cell classes
    [self.collentionView registerClass:[MultiVideoPickerCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self loadData];
}

// 顶部栏初始化
- (void)initWithTopBar;
{
    self.title = NSLocalizedString(@"lsq_albumComponent_albumTitle", @"相册");
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.95 green:0.59 blue:0.10 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButtonClicked)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButtonClicked)];
}

- (void)setupUI {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat cellWidth = (width + kCellMargin) / 4 - kCellMargin;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.minimumInteritemSpacing = kCellMargin;
    flowLayout.minimumLineSpacing = kCellMargin;
    flowLayout.footerReferenceSize = CGSizeMake(width, 42);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 5, width, height) collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.allowsMultipleSelection = YES;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    _collentionView = collectionView;
}

- (void)loadData {
    
    _fetchResult = [NSMutableArray arrayWithCapacity:3];
    
    TuAssetManager *assetManger = [TuAssetManager sharedManager];
    __weak typeof(self) weakSelf = self;
    
    [assetManger getAllAlbumWithStart:^{
        
    } WithEnd:^(NSArray *allAlbum,NSArray *images) {
        if (images.count != 0) {
            [images enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [weakSelf.fetchResult addObjectsFromArray:obj];
            }];
            [weakSelf.collentionView reloadData];
        }
        
    } WithFailure:^(NSError *error) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (NSMutableArray<NSURL *> *)allSelectedAssets {
    
//    NSLog(@"%@", self.selectedAssets);
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:3];
    
    [self.selectedAssets enumerateObjectsUsingBlock:^(TuVideoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = obj.url;
        [assets addObject:url];
    }];
    return assets;
}

#pragma mark - tool

- (void)updateSelectedIndex {
    [self.selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        TuVideoModel *model = self.fetchResult[indexPath.item];
        NSInteger index = [self.selectedAssets indexOfObject:model];
        MultiVideoPickerCell *cell = (MultiVideoPickerCell *)[self.collentionView cellForItemAtIndexPath:indexPath];
        cell.selectedIndex = index;
    }];
}

- (void)onRightButtonClicked{
    APIMovieSplicerViewController *vc = [APIMovieSplicerViewController new];
    vc.urlArray = [self allSelectedAssets];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onLeftButtonClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TuVideoModel *model = self.fetchResult[indexPath.item];
    MultiVideoPickerCell *cell = (MultiVideoPickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor redColor];
    cell.model = model;
    
    __weak typeof(self) weakSelf = self;
    cell.selectButtonActionHandler = ^(MultiVideoPickerCell *cell, BOOL selected) {
        if (selected) {
            [weakSelf.selectedAssets addObject:model];
            [weakSelf.selectedIndexPaths addObject:indexPath];
        } else {
            [weakSelf.selectedAssets removeObject:model];
            [weakSelf.selectedIndexPaths removeObject:indexPath];
        }
        [weakSelf updateSelectedIndex];
    };
    cell.selectButton.selected = [self.selectedIndexPaths containsObject:indexPath];
    cell.selectedIndex = [self.selectedIndexPaths indexOfObject:indexPath];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MultiVideoPickerCell *cell = (MultiVideoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected = YES;
    cell.selectButtonActionHandler(cell, YES);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    MultiVideoPickerCell *cell = (MultiVideoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected = NO;
    cell.selectButtonActionHandler(cell, NO);
}

@end
