//
//  TuCameraFilterCell.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/9/9.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuCameraFilterCell.h"

@interface TuCameraFilterCell()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *filterCollectionView;

@end

@implementation TuCameraFilterCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
//        [self initWithSubViews];
    }
    return self;
}

- (void)initWithSubViews
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(60, 60);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.filterCollectionView.dataSource = self;
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.showsHorizontalScrollIndicator = NO;
    self.filterCollectionView.bounces = NO;
    [self addSubview:self.filterCollectionView];
    [self.filterCollectionView registerClass:[CameraFilterCell class] forCellWithReuseIdentifier:@"CameraFilterCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.codeArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CameraFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CameraFilterCell" forIndexPath:indexPath];
    cell.backgroundColor = UIColor.yellowColor;
    cell.codeName = self.codeArray[indexPath.item];
    return cell;
}

- (void)layoutSubviews
{
    self.filterCollectionView.frame = self.bounds;
}

#pragma mark - setter
- (void)setCodeArray:(NSArray *)codeArray
{
    _codeArray = codeArray;
}

@end



@implementation CameraFilterCell

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
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
    
    _thumbnailView = [[UIImageView alloc] init];
    [self addSubview:_thumbnailView];
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    _thumbnailView.userInteractionEnabled = NO;
    
    _titleLabel = [[UILabel alloc] init];
    [self addSubview:_titleLabel];
    _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _titleLabel.font = [UIFont systemFontOfSize:10];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.userInteractionEnabled = NO;
    
//    _selectedImageView = [[UIImageView alloc] init];
//    [self addSubview:_selectedImageView];
//    _selectedImageView.contentMode = UIViewContentModeCenter;
//    _selectedImageView.image = [UIImage imageNamed:@"ic_parameter"];
//    _selectedImageView.hidden = YES;
//    _selectedImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
//    _selectedImageView.userInteractionEnabled = NO;
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    _thumbnailView.frame = self.bounds;
    const CGFloat labelHeight = 16;
    _titleLabel.frame = CGRectMake(0, size.height - labelHeight, size.width, labelHeight);
}

#pragma mark - setter
- (void)setCodeName:(NSString *)codeName
{
    _codeName = codeName;
    
    // 标题
    NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", _codeName];
    self.titleLabel.text = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
    // 缩略图
    NSString *imageName = [NSString stringWithFormat:@"lsq_filter_thumb_%@", _codeName];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    self.thumbnailView.image = [UIImage imageWithContentsOfFile:imagePath];
}

@end
