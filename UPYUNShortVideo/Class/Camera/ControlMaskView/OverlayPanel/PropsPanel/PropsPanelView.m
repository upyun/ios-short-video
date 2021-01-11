//
//  StickerPanelView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "PropsPanelView.h"
#import "TuSDKFramework.h"
#import "PropsItemStickerCategory.h"
#import "PropsItemMonsterCategory.h"
#import "PropsItemsPageView.h"
#import "StickerDownloader.h"

@interface PropsPanelView () <PropsItemsPageViewDataSource, PropsItemsPageViewDelegate,TuSDKOnlineStickerDownloaderDelegate>

/** 最后一次选中的道具 */
@property (nonatomic) PropsItem* lastSelectedPropsItem;
@property (nonatomic, strong) NSArray *categoryNames;
@property (nonatomic, weak) PropsItemsPageView *currentCategoryPageView;


@end

@implementation PropsPanelView

- (void)commonInit {
    [self loadData];
    [super commonInit];
    [self setupUI];
}

/**
 加载所有道具数据
 */
- (void)loadData {
    
    NSMutableArray<PropsItemCategory *> *allCategories = [NSMutableArray array];
    if ([PropsItemStickerCategory allCategories])
        [allCategories addObjectsFromArray:[PropsItemStickerCategory allCategories]];
    
    if ([PropsItemMonsterCategory allCategories])
        [allCategories addObjectsFromArray:[PropsItemMonsterCategory allCategories]];

    _categorys = allCategories;
    
    NSMutableArray *categoryNames = [NSMutableArray array];
    for (PropsItemCategory *stickerCategory in _categorys) {
        [categoryNames addObject:stickerCategory.name];
    }
    _categoryNames = categoryNames.copy;
}

- (void)setupUI {
    self.categoryTabbar.itemTitles = _categoryNames;
    [self.unsetButton addTarget:self action:@selector(unsetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    [[StickerDownloader shared] addDelegate:self];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [_currentCategoryPageView dismissDeleteButtons];
}

/**
 重新加载视图
 */
- (void)reloadPanelView:(TuSDKMediaEffectDataType)effectType {
    if (_categorys[_currentCategoryPageView.pageIndex].categoryType != effectType) return;
    [_currentCategoryPageView.itemCollectionView reloadData];
}

#pragma mark - action

/**
 重置按钮事件

 @param sender 点击的按钮
 */
- (void)unsetButtonAction:(UIButton *)sender {
    [self unsetPropsItemCategory];
}

/**
 点击手势事件

 @param sender 点击手势
 */
- (void)tapAction:(UITapGestureRecognizer *)sender {
    [_currentCategoryPageView dismissDeleteButtons];
}

#pragma mark - data source

#pragma mark ViewSliderDataSource

/**
 分页数量
 */
- (NSInteger)numberOfViewsInSlider:(ViewSlider *)slider {
    return _categorys.count;
}

/**
 各分页显示的视图
 */
- (UIView *)viewSlider:(ViewSlider *)slider viewAtIndex:(NSInteger)index {
    // 每个贴纸分类下的列表是一个 StickerCategoryPageView 独立页面，显示时创建，完全离开屏幕时销毁。
    PropsItemsPageView *categoryView = [[PropsItemsPageView alloc] initWithFrame:CGRectZero];
    categoryView.pageIndex = index;
    categoryView.dataSource = self;
    categoryView.delegate = self;
    return categoryView;
}

#pragma mark StickerCategoryPageViewDataSource

/**
 当前分类页面的贴纸个数
 
 @param pageView 贴纸分类展示视图
 @return 当前分类页面贴纸个数
 */
- (NSInteger)numberOfItemsInCategoryPageView:(PropsItemsPageView *)pageView {
    return _categorys[pageView.pageIndex].propsItems.count;
}

/**
 配置当前分类下每个贴纸单元格
 
 @param pageView 贴纸分类展示视图
 @param cell 贴纸按钮
 @param index 按钮索引
 */
- (void)propsItemsPageView:(PropsItemsPageView *)pageView setupStickerCollectionCell:(PropsItemCollectionCell *)cell atIndex:(NSInteger)index {
    
    PropsItem *propsItem = _categorys[pageView.pageIndex].propsItems[index];
    cell.online = propsItem.online;
    
    if (propsItem.isDownLoading) {
        [cell startLoading];
    }
    else {
        [cell finishLoading];
    }
    [propsItem loadThumb:cell.thumbnailView completed:^(BOOL result) {
        if (!propsItem.isDownLoading)
            [cell finishLoading];
    }];
}

#pragma mark - delegate

#pragma mark PropsItemPageViewDelegate

/**
 准备删除道具时回调

 @param pageView 道具视图
 @param indexPath 道具物品索引
 @return 是否可以被删除 true ： 是否可以被删除
 */
- (BOOL)propsItemsPageView:(PropsItemsPageView *)pageView canDeleteButtonAtIndex:(NSIndexPath *)indexPath;
{
    return [_categorys[pageView.pageIndex] canRemovePropsItem:_categorys[pageView.pageIndex].propsItems[indexPath.row]];
}

/**
 删除按钮点击回调

 @param pageView 贴纸分类展示视图
 @param index 按钮索引
 */
- (void)propsItemsPageView:(PropsItemsPageView *)pageView didTapDeleteButtonAtIndex:(NSInteger)index {
    NSString *title = NSLocalizedStringFromTable(@"tu_确认删除本地文件？", @"VideoDemo", @"确认删除本地文件？");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_取消", @"VideoDemo", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.currentCategoryPageView dismissDeleteButtons];
    }]];
    
    typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_删除", @"VideoDemo", @"删除") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.currentCategoryPageView dismissDeleteButtons];
        
        PropsItem *propsItem = weakSelf.categorys[pageView.pageIndex].propsItems[index];
        if ([weakSelf.categorys[pageView.pageIndex] removePropsItem:propsItem]) {
            [weakSelf.currentCategoryPageView.itemCollectionView reloadData];
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(propsPanel:didRemovePropsItem:)]) {
            [weakSelf.delegate propsPanel:weakSelf didRemovePropsItem:propsItem];
        }

        
    }]];
    [[self viewController] presentViewController:alertController animated:YES completion:nil];
}

/**
 贴纸项选中回调

 @param pageView 贴纸分类展示视图
 @param cell 贴纸按钮
 @param index 按钮索引
 */
- (void)propsItemsPageView:(PropsItemsPageView *)pageView didSelectCell:(PropsItemCollectionCell *)cell atIndex:(NSInteger)index {
    if (!cell) {
        [self unsetPropsItemCategory];
        return;
    }
    typeof(self) weakSelf = self;
    PropsItem *propsItem = _categorys[_currentCategoryPageView.pageIndex].propsItems[index];
    _lastSelectedPropsItem = propsItem;
    
    [cell startLoading];

    [propsItem loadEffect:^(id<TuSDKMediaEffect> effect) {
        
        [cell finishLoading];
        
        if (propsItem == weakSelf.lastSelectedPropsItem)
            [weakSelf applyPropsItem:propsItem];
    }];

}

#pragma mark ViewSliderDelegate

/**
 切换分页回调
 
 @param slider 分页控件
 @param index 目标页面索引
 */
- (void)viewSlider:(ViewSlider *)slider didSwitchToIndex:(NSInteger)index {
    [super viewSlider:slider didSwitchToIndex:index];
    _currentCategoryPageView = (PropsItemsPageView *)slider.currentView;
}



#pragma mark - private

/**
 取消应用贴纸并更新 UI
 */
- (void)unsetPropsItemCategory {
    
    if (_currentCategoryPageView.pageIndex >= 0 && _currentCategoryPageView.pageIndex < _categorys.count)
    {
       PropsItemCategory *categroy = _categorys[_currentCategoryPageView.pageIndex];
        if ([self.delegate respondsToSelector:@selector(propsPanel:unSelectPropsItemCategory:)]) {
            [self.delegate propsPanel:self unSelectPropsItemCategory:categroy];
        }
    }
    [_currentCategoryPageView deselect];
}

/**
 应用道具

 @param propsItem 道具
 */
- (void)applyPropsItem:(PropsItem *)propsItem {
    if ([self.delegate respondsToSelector:@selector(propsPanel:didSelectPropsItem:)]) {
        [self.delegate propsPanel:self didSelectPropsItem:propsItem];
    }
}

/**
 获取当前视图的控制器

 @return 视图控制器
 */
- (UIViewController *)viewController {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    
    return nil;
}


#pragma mark TuSDKOnlineStickerDownloaderDelegate

/**
 贴纸下载结束回调
 
 @param stickerGroupId 贴纸分组 ID
 @param progress 下载进度
 @param status 下载状态
 */
- (void)onDownloadProgressChanged:(uint64_t)stickerGroupId progress:(CGFloat)progress changedStatus:(lsqDownloadTaskStatus)status {
    if (status == lsqDownloadTaskStatusDowned || status == lsqDownloadTaskStatusDownFailed) {
        [self reloadPanelView:TuSDKMediaEffectDataTypeSticker];
    }
}
@end


