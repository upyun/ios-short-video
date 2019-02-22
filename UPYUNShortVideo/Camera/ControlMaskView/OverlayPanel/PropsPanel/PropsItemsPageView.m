//
//  StickerCategoryPageView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "PropsItemsPageView.h"

// CollectionView Cell 重用 ID
static NSString * const kPropsItemCellReuseID = @"PropsItemCellReuseID";

/**
 道具单元格
 */
@interface PropsItemCollectionCell()

/**
 选中状态视图
 */
@property (nonatomic, strong) UIView *selectedView;

/**
 删除按钮事件回调
 */
@property (nonatomic, copy) void (^deleteButtonActionHandler)(PropsItemCollectionCell *cell);

@end

@implementation PropsItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIColor *borderColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    
    _thumbnailView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_thumbnailView];
    _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_loadingView];
    _loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _loadingView.hidesWhenStopped = YES;
    
    CGSize size = self.bounds.size;
    _downloadIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_ic_download"]];
    [self.contentView addSubview:_downloadIconView];
    CGSize downloadIconSize = _downloadIconView.intrinsicContentSize;
    _downloadIconView.frame = CGRectMake(size.width - downloadIconSize.width, size.height - downloadIconSize.height, downloadIconSize.width, downloadIconSize.height);
    _downloadIconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_deleteButton];
    [_deleteButton setImage:[UIImage imageNamed:@"video_ic_delete"] forState:UIControlStateNormal];
    _deleteButton.imageView.contentMode = UIViewContentModeCenter;
    _deleteButton.hidden = YES;
    _deleteButton.layer.borderColor = borderColor.CGColor;
    _deleteButton.layer.borderWidth = 2;
    _deleteButton.layer.cornerRadius = 4;
    _deleteButton.layer.masksToBounds = YES;
    _deleteButton.backgroundColor = [UIColor colorWithWhite:0 alpha:.65];
    _deleteButton.frame = self.contentView.bounds;
    _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *selectedView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:selectedView];
    _selectedView = selectedView;
    selectedView.layer.borderColor = borderColor.CGColor;
    selectedView.layer.borderWidth = 2;
    selectedView.layer.cornerRadius = 4;
    selectedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    selectedView.userInteractionEnabled = NO;
    selectedView.hidden = YES;
}

#pragma mark - property

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _selectedView.hidden = !selected;
}

- (void)setOnline:(BOOL)online {
    _online = online;
    _downloadIconView.hidden = !online;
    [_loadingView stopAnimating];
}

#pragma mark - action

- (void)deleteButtonAction:(UIButton *)sender {
    if (self.deleteButtonActionHandler) self.deleteButtonActionHandler(self);
}

#pragma mark - public

- (void)startLoading {
    [self.loadingView startAnimating];
    self.downloadIconView.hidden = YES;
}
- (void)finishLoading {
    [self.loadingView stopAnimating];
}

/**
 隐藏/显示删除按钮

 @param hidden 是否隐藏
 @param animated 是否动画更新
 */
- (void)setDeleteButtonHidden:(BOOL)hidden animated:(BOOL)animated {
    if (!animated) {
        _deleteButton.hidden = hidden;
        return;
    }
    double startAlpha = hidden;
    double endAlpha = !hidden;
    _deleteButton.alpha = startAlpha;
    _deleteButton.hidden = NO;
    [UIView animateWithDuration:.25 animations:^{
        self.deleteButton.alpha = endAlpha;
    } completion:^(BOOL finished) {
        self.deleteButton.hidden = hidden;
        self.deleteButton.alpha = 1;
    }];
}

@end


/**
 道具每个分类的页面视图
 */
@interface PropsItemsPageView() <UIGestureRecognizerDelegate>

/**
 显示删除按钮的索引对象
 */
@property (nonatomic, strong) NSIndexPath *shouldShowDeleteButtonIndexPath;

/**
 选中项索引对象
 */
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation PropsItemsPageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    const int countPerRow = 5;
    const CGFloat itemHorizontalSpacing = 21;
    const CGFloat itemVerticalSpacing = 15;
    CGFloat itemWidth = (screenWidth - itemHorizontalSpacing) / countPerRow - itemHorizontalSpacing;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.sectionInset = UIEdgeInsetsMake(itemVerticalSpacing, itemHorizontalSpacing, itemVerticalSpacing, itemHorizontalSpacing);
    flowLayout.minimumLineSpacing = itemVerticalSpacing;
    
    _itemCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    [self addSubview:_itemCollectionView];
    _itemCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _itemCollectionView.backgroundColor = [UIColor clearColor];
    _itemCollectionView.dataSource = self;
    _itemCollectionView.allowsSelection = NO;
    
    [_itemCollectionView registerClass:[PropsItemCollectionCell class] forCellWithReuseIdentifier:kPropsItemCellReuseID];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;
}

#pragma mark - property

- (void)setShouldShowDeleteButtonIndexPath:(NSIndexPath *)shouldShowDeleteButtonIndexPath {
    if ([shouldShowDeleteButtonIndexPath isEqual:_shouldShowDeleteButtonIndexPath]) {
        return;
    }
    
    PropsItemCollectionCell *cellShouldHideButton = (PropsItemCollectionCell *)[_itemCollectionView cellForItemAtIndexPath:_shouldShowDeleteButtonIndexPath];
    [cellShouldHideButton setDeleteButtonHidden:YES animated:YES];
    PropsItemCollectionCell *cellShouldShowButton = (PropsItemCollectionCell *)[_itemCollectionView cellForItemAtIndexPath:shouldShowDeleteButtonIndexPath];
    [cellShouldShowButton setDeleteButtonHidden:NO animated:YES];
    
    _shouldShowDeleteButtonIndexPath = shouldShowDeleteButtonIndexPath;
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    if ([selectedIndexPath isEqual:_selectedIndexPath]) {
        return;
    }
    for (UICollectionViewCell *cellShouldDeselect in _itemCollectionView.visibleCells) {
        if (cellShouldDeselect.selected) cellShouldDeselect.selected = NO;
    }
    UICollectionViewCell *cellShouldSelect = [_itemCollectionView cellForItemAtIndexPath:selectedIndexPath];
    cellShouldSelect.selected = YES;
    
    _selectedIndexPath = selectedIndexPath;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex < 0 || selectedIndex >= [self.dataSource numberOfItemsInCategoryPageView:self]) {
        return;
    }
    
    self.selectedIndexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
}
- (NSInteger)selectedIndex {
    return _selectedIndexPath.item;
}

#pragma mark - public

- (void)dismissDeleteButtons {
    if ([_shouldShowDeleteButtonIndexPath isEqual:_selectedIndexPath]) {
        [self deselect];
        if ([self.delegate respondsToSelector:@selector(propsItemsPageView:didSelectCell:atIndex:)]) {
            [self.delegate propsItemsPageView:self didSelectCell:nil atIndex:-1];
        }
    }
    self.shouldShowDeleteButtonIndexPath = nil;
}

- (void)deselect {
    self.selectedIndexPath = nil;
}

#pragma mark - action

/**
 点击手势事件

 @param sender 点击手势
 */
- (void)tapAction:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:_itemCollectionView];
    if (!CGRectContainsPoint(_itemCollectionView.bounds, touchPoint)) return;
    NSIndexPath *touchIndexPath = [_itemCollectionView indexPathForItemAtPoint:touchPoint];
    if (!touchIndexPath) return;
    
    [self dismissDeleteButtons];
    self.selectedIndexPath = touchIndexPath;
    PropsItemCollectionCell *cell = (PropsItemCollectionCell *)[_itemCollectionView cellForItemAtIndexPath:touchIndexPath];
    if ([self.delegate respondsToSelector:@selector(propsItemsPageView:didSelectCell:atIndex:)]) {
        [self.delegate propsItemsPageView:self didSelectCell:cell atIndex:touchIndexPath.item];
    }
}

/**
 长按手势事件

 @param sender 长按手势
 */
- (void)longPressAction:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state != UIGestureRecognizerStateBegan) return;

    CGPoint touchPoint = [sender locationInView:_itemCollectionView];
    if (!CGRectContainsPoint(_itemCollectionView.bounds, touchPoint)) return;
    
    NSIndexPath *touchIndexPath = [_itemCollectionView indexPathForItemAtPoint:touchPoint];
    if (!touchIndexPath) return;
    
    if ([self.delegate respondsToSelector:@selector(propsItemsPageView:canDeleteButtonAtIndex:)]) {
        if (![self.delegate propsItemsPageView:self canDeleteButtonAtIndex:touchIndexPath]) {
            NSLog(@"canDeleteButtonAtIndex return false.");
            return;
        }
    }
    
    self.shouldShowDeleteButtonIndexPath = touchIndexPath;
}

/**
 单元格点击删除按钮

 @param cell 单元格
 @param indexPath 单元格索引对象
 */
- (void)cell:(PropsItemCollectionCell *)cell didTapDeleteButtonWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(propsItemsPageView:didTapDeleteButtonAtIndex:)]) {
        [self.delegate propsItemsPageView:self didTapDeleteButtonAtIndex:indexPath.item];
    }
}

#pragma mark - UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PropsItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPropsItemCellReuseID forIndexPath:indexPath];
    
    //cell.thumbnailView.image = [UIImage imageNamed:@"default"];
    [self.dataSource propsItemsPageView:self setupStickerCollectionCell:cell atIndex:indexPath.item];

    // 选中当前项
    cell.selected = [_selectedIndexPath isEqual:indexPath];
    
    cell.deleteButton.hidden = cell.selected || ![indexPath isEqual:_shouldShowDeleteButtonIndexPath] || cell.online;
    __weak typeof(self) weakSelf = self;
    cell.deleteButtonActionHandler = ^(PropsItemCollectionCell *cell) {
        [weakSelf cell:cell didTapDeleteButtonWithIndexPath:indexPath];
    };
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInCategoryPageView:self];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    for (UIView *view in _itemCollectionView.visibleCells) {
        if ([touch.view isDescendantOfView:view]) {
            return YES;
        }
    }
    return NO;
}

@end
