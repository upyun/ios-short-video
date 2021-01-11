//
//  APIImageVideoPickerViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/5/29.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "APIImageVideoPickerViewController.h"
#import "MoviePreviewViewController.h"
#import "ImagePreviewViewController.h"

#import "PageTabbar.h"
#import "TuSDKFramework.h"
#import "MultiAssetPicker.h"

// 最小视频时长
static const NSTimeInterval kMinDuration = 3.0;

@interface APIImageVideoPickerViewController ()<PageTabbarDelegate, MultiPickerDelegate>

@property (weak, nonatomic) IBOutlet PageTabbar *pageBar;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) MultiAssetPicker *imagePicker;
@property (nonatomic, strong) MultiAssetPicker *videoPicker;

@end

@implementation APIImageVideoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - setupUI
- (void)setupUI {
    [self setupPageBar];
    [self setupContentView];
    [self tabbar:_pageBar didSwitchFromIndex:0 toIndex:0];
}

- (void)setupPageBar {
    _pageBar.trackerSize = CGSizeMake(48, 2);
    _pageBar.itemSelectedColor = lsqRGB(255.0, 204.0, 0.0);
    _pageBar.itemNormalColor = [UIColor whiteColor];
    _pageBar.itemWidth = lsqScreenWidth * 0.5;
    _pageBar.delegate = self;
    _pageBar.itemTitles = @[NSLocalizedStringFromTable(@"tu_视频", @"VideoDemo", @"视频"), NSLocalizedStringFromTable(@"tu_照片", @"VideoDemo", @"照片")];
    _pageBar.disableAnimation = YES;
    _pageBar.itemTitleFont = [UIFont systemFontOfSize:14];
}


- (void)setupContentView {
    
    // 最多可选
    if (!_maxSelectedCount) _maxSelectedCount = 9;
    // 最少需选
    if (!_minSelectedCount) _minSelectedCount = 1;
    
    // 最多可选图片
    if (!_maxSelectedImageCount) _maxSelectedImageCount = _maxSelectedCount;
    // 最少需选
    if (!_minSelectedImageCount) _minSelectedImageCount = _minSelectedCount;
    
    // 最多可选视频
    if (!_maxSelectedVideoCount) _maxSelectedVideoCount = _maxSelectedCount;
    // 最少需选
    if (!_minSelectedVideoCount) _minSelectedVideoCount = _minSelectedCount;
    
    // 配置其他 UI
    self.topNavigationBar.backgroundColor = [UIColor blackColor];
    [self.topNavigationBar.rightButton setTitle:NSLocalizedStringFromTable(@"tu_下一步", @"VideoDemo", @"下一步") forState:UIControlStateNormal];
}


- (void)base_rightButtonAction:(UIButton *)sender {
    
    if (APIImageVideoPickerSelectedAssetTypeVideo == self.selectedAssetType && self.allSelectedPhAssets.count < self.minSelectedVideoCount) {
        [[TuSDK shared].messageHub showToast:[NSString stringWithFormat:@"视频选择的个数最少为：%lu", (unsigned long)self.minSelectedVideoCount]];
        return;
    }
    
    if (APIImageVideoPickerSelectedAssetTypeImage == self.selectedAssetType && self.allSelectedPhAssets.count < self.minSelectedImageCount) {
        [[TuSDK shared].messageHub showToast:[NSString stringWithFormat:@"图片选择的个数最少为：%lu", (unsigned long)self.minSelectedImageCount]];
        return;
    }
    
    if (self.rightButtonActionHandler) {
        self.rightButtonActionHandler(self, sender);
    }
}

#pragma mark - public

- (NSArray<AVURLAsset *> *)allSelectedAssets {
    if (_pageBar.selectedIndex == 0) {
        return _videoPicker.allSelectedAssets;
    }
    return _imagePicker.allSelectedAssets;
}

-(NSArray<PHAsset *> *)allSelectedPhAssets;{
    if (_pageBar.selectedIndex == 0) {
        return _videoPicker.allSelectedPhAssets;
    }
    return _imagePicker.allSelectedPhAssets;
}

#pragma mark - MultiVideoPickerDelegate

/**
 点击单元格事件回调
 
 @param picker 多视频选择器
 @param indexPath 点击的 NSIndexPath 对象
 @param phAsset 对应的 PHAsset 对象
 */
- (void)picker:(MultiAssetPicker *)picker didTapItemWithIndexPath:(NSIndexPath *)indexPath phAsset:(PHAsset *)phAsset {
    
    if (phAsset.mediaType == PHAssetMediaTypeImage) {
        ImagePreviewViewController *previewer = [[ImagePreviewViewController alloc] init];
        previewer.selectedIndex = [picker selectedIndexForIndexPath:indexPath];
        previewer.disableSelect = previewer.selectedIndex < 0 && picker.allSelectedAssets.count >= _maxSelectedCount;
        if (picker.disableMultipleSelection) {
            PHAsset *phAsset = [picker phAssetAtIndexPathItem:indexPath.item];
            previewer.disableSelect = phAsset.duration < kMinDuration;
        }
        previewer.phAsset = phAsset;
        __weak typeof(self) weakSelf = self;
        
        previewer.addButtonActionHandler = ^(ImagePreviewViewController * _Nonnull previewer, UIButton * _Nonnull sender) {
            [weakSelf.imagePicker setPhAsset:phAsset indexPath:indexPath selected:sender.selected];
            previewer.selectedIndex = [picker selectedIndexForIndexPath:indexPath];
        };
        
        previewer.rightButtonActionHandler = ^(__kindof BaseNavigationViewController *controller, UIButton *sender) {
            [weakSelf base_rightButtonAction:sender];
        };
        [self.navigationController pushViewController:previewer animated:YES];
        return;
    }
    
    
    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
        MoviePreviewViewController *previewer = [[MoviePreviewViewController alloc] initWithNibName:nil bundle:nil];
        
        previewer.selectedIndex = [picker selectedIndexForIndexPath:indexPath];
        previewer.disableSelect = previewer.selectedIndex < 0 && picker.allSelectedAssets.count >= _maxSelectedCount;
        if (picker.disableMultipleSelection) {
            PHAsset *phAsset = [picker phAssetAtIndexPathItem:indexPath.item];
            previewer.disableSelect = phAsset.duration < kMinDuration;
        }
        previewer.phAsset = phAsset;
        __weak typeof(self) weakSelf = self;
        
        previewer.addButtonActionHandler = ^(MoviePreviewViewController * _Nonnull previewer, UIButton * _Nonnull sender) {
            [weakSelf.videoPicker setPhAsset:phAsset indexPath:indexPath selected:sender.selected];
            previewer.selectedIndex = [picker selectedIndexForIndexPath:indexPath];
        };
        
        previewer.rightButtonActionHandler = ^(__kindof BaseNavigationViewController *controller, UIButton *sender) {
            [weakSelf base_rightButtonAction:sender];
        };
        [self.navigationController pushViewController:previewer animated:YES];
    }
    
}


/**
 目标项是否可选中
 
 @param picker 多视频选择器
 @param indexPath 目标 indexPath
 @return 目标项是否可选中
 */
- (BOOL)picker:(MultiAssetPicker *)picker shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 图像选择过滤
    if (picker == _imagePicker) {
        
        if (picker.allSelectedAssets.count >= _maxSelectedImageCount) {
            NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_最多只能选择%zu个照片", @"VideoDemo", @"最多只能选择%zu个照片"), _maxSelectedImageCount];
            [[TuSDK shared].messageHub showToast:message];
            return NO;
        }
        return YES;
    }
    
    if (picker.disableMultipleSelection) {
        PHAsset *phAsset = [picker phAssetAtIndexPathItem:indexPath.item];
        NSTimeInterval duration = phAsset.duration;
        if (duration < kMinDuration) {
            NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_视频时长不得小于%@秒，请重新选择", @"VideoDemo", @"视频时长不得小于%@秒，请重新选择"), @(kMinDuration)];
            [[TuSDK shared].messageHub showToast:message];
            return NO;
        }
        return YES;
    }
    
    if (picker.allSelectedAssets.count >= _maxSelectedVideoCount) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_最多只能选择%zu个视频", @"VideoDemo", @"最多只能选择%zu个视频"), _maxSelectedVideoCount];
        [[TuSDK shared].messageHub showToast:message];
        return NO;
    }
    return YES;
}

#pragma mark - PageBarDelegate

- (void)tabbar:(PageTabbar *)tabbar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (toIndex == 0) {
        self.videoPicker.view.hidden = NO;
        self.imagePicker.view.hidden = YES;
        self.selectedAssetType = APIImageVideoPickerSelectedAssetTypeVideo;
    } else {
        self.videoPicker.view.hidden = YES;
        self.imagePicker.view.hidden = NO;
        self.selectedAssetType = APIImageVideoPickerSelectedAssetTypeImage;
    }
}


#pragma mark - setter getter
- (MultiAssetPicker *)imagePicker {
    if (!_imagePicker) {
        // 配置多图片选择器
        _imagePicker = [MultiAssetPicker picker];
        _imagePicker.fetchMediaTypes = @[@(PHAssetMediaTypeImage)];
        
        [self.contentView insertSubview:_imagePicker.view atIndex:1];
        [self addChildViewController:_imagePicker];
        _imagePicker.view.frame = self.contentView.bounds;
        _imagePicker.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _imagePicker.delegate = self;
        _imagePicker.disableMultipleSelection = _maxSelectedImageCount == 1;
    }
    return _imagePicker;
}


- (MultiAssetPicker *)videoPicker {
    if (!_videoPicker) {
        // 配置多视频选择器
        _videoPicker = [MultiAssetPicker picker];
        _videoPicker.fetchMediaTypes = @[@(PHAssetMediaTypeVideo)];
        [self.contentView insertSubview:_videoPicker.view atIndex:0];
        [self addChildViewController:_videoPicker];
        _videoPicker.view.frame = self.contentView.bounds;
        _videoPicker.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _videoPicker.delegate = self;
        _videoPicker.disableMultipleSelection = _maxSelectedVideoCount == 1;
    }
    return _videoPicker;
}

@end
