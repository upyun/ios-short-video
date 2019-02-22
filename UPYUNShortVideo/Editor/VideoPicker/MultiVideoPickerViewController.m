//
//  MultiVideoPickerViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MultiVideoPickerViewController.h"
#import "TuSDKFramework.h"

#import "MultiVideoPicker.h"
#import "MoviePreviewViewController.h"

// 最小视频时长
static const NSTimeInterval kMinDuration = 3.0;

@interface MultiVideoPickerViewController ()<MultiVideoPickerDelegate>

/**
 多视频选择器
 */
@property (nonatomic, strong) MultiVideoPicker *picker;

@end

@implementation MultiVideoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    // 最多可选
    if (!_maxSelectedCount) _maxSelectedCount = 9;
    // 最少需选
    if (!_minSelectedCount) _minSelectedCount = 1;
    
    // 配置多视频选择器
    MultiVideoPicker *picker = [MultiVideoPicker picker];
    _picker = picker;
    
    [self.view insertSubview:picker.view atIndex:0];
    [self addChildViewController:picker];
    picker.view.frame = self.view.bounds;
    picker.collectionView.contentInset = UIEdgeInsetsMake(self.topContentOffset, 0, 0, 0);
    picker.delegate = self;
    picker.disableMultipleSelection = _maxSelectedCount == 1;
    
    // 配置其他 UI
    self.topNavigationBar.backgroundColor = [UIColor blackColor];
    [self.topNavigationBar.rightButton setTitle:NSLocalizedStringFromTable(@"tu_下一步", @"VideoDemo", @"下一步") forState:UIControlStateNormal];
}

- (void)base_rightButtonAction:(UIButton *)sender {
    if (_picker.requesting) return;
    
    if (self.allSelectedAssets.count < _minSelectedCount) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_请选择%zu个视频", @"VideoDemo", @"请选择%zu个视频"), _minSelectedCount];
        [[TuSDK shared].messageHub showError:message];
        return;
    }
    
    if (_picker.selectedVideosDutation < kMinDuration) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_视频时长不得小于%@秒，请重新选择", @"VideoDemo", @"视频时长不得小于%@秒，请重新选择"), @(kMinDuration)];
        [[TuSDK shared].messageHub showToast:message];
        return;
    }
    
    [super base_rightButtonAction:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - property

- (void)setMaxSelectedCount:(NSUInteger)maxSelectedCount {
    _picker.disableMultipleSelection = maxSelectedCount == 1;
    _maxSelectedCount = maxSelectedCount;
}

#pragma mark - public

- (NSArray<AVURLAsset *> *)allSelectedAssets {
    return _picker.allSelectedAssets;
}

#pragma mark - MultiVideoPickerDelegate

/**
 点击单元格事件回调
 
 @param picker 多视频选择器
 @param indexPath 点击的 NSIndexPath 对象
 @param phAsset 对应的 PHAsset 对象
 */
- (void)picker:(MultiVideoPicker *)picker didTapItemWithIndexPath:(NSIndexPath *)indexPath phAsset:(PHAsset *)phAsset {
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
        [weakSelf.picker setPhAsset:phAsset indexPath:indexPath selected:sender.selected];
        previewer.selectedIndex = [picker selectedIndexForIndexPath:indexPath];
    };
    
    previewer.rightButtonActionHandler = ^(__kindof BaseNavigationViewController *controller, UIButton *sender) {
        [weakSelf base_rightButtonAction:sender];
    };
    [self.navigationController pushViewController:previewer animated:YES];
}

/**
 目标项是否可选中
 
 @param picker 多视频选择器
 @param indexPath 目标 indexPath
 @return 目标项是否可选中
 */
- (BOOL)picker:(MultiVideoPicker *)picker shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
    if (picker.allSelectedAssets.count >= _maxSelectedCount) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_最多只能选择%zu个视频", @"VideoDemo", @"最多只能选择%zu个视频"), _maxSelectedCount];
        [[TuSDK shared].messageHub showToast:message];
        return NO;
    }
    return YES;
}

@end
