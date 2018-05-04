//
//  TuAlbumViewController.m
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import "TuAlbumViewController.h"
#import "TuAssetManager.h"
#import "TuAlbumModel.h"
#import "TuPhotosViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface TuAlbumViewController ()<UITableViewDataSource, UITableViewDelegate, TuVideoSelectedDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *allAlbumArray;
@property (strong, nonatomic) NSMutableArray *allImagesAy;

@end

@implementation TuAlbumViewController

#pragma mark - setter getter

- (NSMutableArray *)allAlbumArray
{
    if (!_allAlbumArray) {
        _allAlbumArray = [NSMutableArray array];
    }
    return _allAlbumArray;
}

#pragma mark - init method

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self loadPhotos];
}

- (void)loadPhotos
{
    
    TuAssetManager *assetManger = [TuAssetManager sharedManager];
    __weak typeof(self) weakSelf = self;
    
    [assetManger getAllAlbumWithStart:^{
        
    } WithEnd:^(NSArray *allAlbum,NSArray *images) {
        
        weakSelf.allAlbumArray = [NSMutableArray arrayWithArray:allAlbum];
        weakSelf.allImagesAy = [NSMutableArray arrayWithArray:images];
        [weakSelf.tableView reloadData];
        
        if (weakSelf.allImagesAy.count != 0) {
            TuAlbumModel *model = [weakSelf.allAlbumArray lastObject];
            TuPhotosViewController *vc = [[TuPhotosViewController alloc] init];
            
            vc.title = model.albumName;
            vc.allPhotosArray = [weakSelf.allImagesAy lastObject];
            vc.selectedDelegate = self;
            vc.isPreviewVideo = self.isPreviewVideo;
            [weakSelf.navigationController pushViewController:vc animated:NO];
        }
    } WithFailure:^(NSError *error) {
        
    }];
}

- (void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setup
{
    self.title = NSLocalizedString(@"lsq_albumComponent_albumTitle", @"相册");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"lsq_albumComponent_closeButton", @"关闭") style:UIBarButtonItemStylePlain target:self action:@selector(closeVC)];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.95 green:0.59 blue:0.10 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    _tableView = tableView;
    [tableView registerClass:[TuTableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allAlbumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    TuAlbumModel *model = self.allAlbumArray[indexPath.row];
    
    cell.model = model;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TuAlbumModel *model = self.allAlbumArray[indexPath.row];
    TuPhotosViewController *vc = [[TuPhotosViewController alloc] init];
    vc.title = model.albumName;
    vc.allPhotosArray = self.allImagesAy[indexPath.row];
    vc.selectedDelegate = self;
    vc.isPreviewVideo = self.isPreviewVideo;
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)selectedModel:(TuVideoModel *)model;
{
    if ([self.selectedDelegate respondsToSelector:@selector(selectedModel:)]) {
        [self.selectedDelegate selectedModel:model];
    }
}

#pragma mark - dealloc

- (void)dealloc
{
    
}

@end



@interface TuTableViewCell ()

@property (weak, nonatomic) UIImageView *photoView;
@property (weak, nonatomic) UILabel *photoNameLb;
@property (weak, nonatomic) UILabel *photoNumLb;
@property (weak, nonatomic) UIButton *selectIcon;

@end


@implementation TuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat height = 62;
    CGFloat width = self.frame.size.width;
    
    UIImageView *photoView = [[UIImageView alloc] init];
    photoView.frame = CGRectMake(15, 1.5, 60, 60);
    photoView.contentMode = UIViewContentModeScaleAspectFill;
    photoView.clipsToBounds = YES;
    [self.contentView addSubview:photoView];
    _photoView = photoView;
    
    UILabel *photoNameLb = [[UILabel alloc] init];
    photoNameLb.textColor = [UIColor blackColor];
    photoNameLb.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:photoNameLb];
    _photoNameLb = photoNameLb;
    
    UILabel *photoNumLb = [[UILabel alloc] init];
    photoNumLb.textColor = [UIColor lightGrayColor];
    photoNumLb.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:photoNumLb];
    _photoNumLb = photoNumLb;
    
    UIButton *selectIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    selectIcon.titleLabel.font = [UIFont systemFontOfSize:14];
    selectIcon.frame = CGRectMake(width, 0, selectIcon.currentBackgroundImage.size.width, selectIcon.currentBackgroundImage.size.height);
    selectIcon.center = CGPointMake(selectIcon.center.x, 31);
    [self.contentView addSubview:selectIcon];
    _selectIcon = selectIcon;
    
    UILabel *line = [[UILabel alloc] init];
    line.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    [self.contentView addSubview:line];
    line.frame = CGRectMake(85, height - 0.5, width, 0.5);
}

- (void)setModel:(TuAlbumModel *)model
{
    _model = model;
    
    CGFloat height = 62;
    
    NSString *photoName = model.albumName;
    
    CGFloat width = [photoName boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : _photoNameLb.font} context:nil].size.width;
    
    _photoNameLb.text = photoName;
    
    _photoNameLb.frame = CGRectMake(85, 0, width, 20);
    
    _photoNameLb.center = CGPointMake(_photoNameLb.center.x, height / 2);
    
    CGFloat photoNameMaxX = CGRectGetMaxX(_photoNameLb.frame);
    
    _photoNumLb.text = [NSString stringWithFormat:@"(%ld)",model.photosNum];
    _photoNumLb.frame = CGRectMake(photoNameMaxX + 10, 0, 100, 20);
    _photoNumLb.center = CGPointMake(_photoNumLb.center.x, height / 2);
    
    _photoView.image = model.coverImage;
}

- (void)setCount:(NSInteger)count
{
    _count = count;
    
    if (count == 0) {
        _selectIcon.hidden = YES;
    }else {
        _selectIcon.hidden = NO;
        [_selectIcon setTitle:[NSString stringWithFormat:@"%ld",count] forState:UIControlStateNormal];
    }
}

@end


