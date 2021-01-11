//
//  FunctionListViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/15.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "FunctionListViewController.h"
#import "TuSDKFramework.h"
#import <Photos/Photos.h>
#import "MultiVideoPickerViewController.h"
#import "APIImageVideoPickerViewController.h"
#import "APIVideoThumbnailsViewController.h"
#import "APIMovieSpliceViewController.h"
#import "APIMovieClipViewController.h"
#import "MovieCutViewController.h"
#import "MovieEditViewController.h"
#import "APIImageVideoComposer.h"


static NSString * const kCellReuseIdentifierKey = @"cell";

/**
 API 示例页面索引
 */
typedef NS_ENUM(NSInteger, APIRowIndex) {
    // 音频混合
    APIRowIndexAudioMix = 0,
    // 音视频混合
    APIRowIndexMovieMix,
    // 获取视频缩略图
    APIRowIndexVideoThumbnails,
    // 图片与视频合成
    APIRowIndexImageVideoComposer,
    // 视频裁剪
    APIRowIndexMovieClip,
    // 音频录制
    APIRowIndexAudioRecord,
    // 音频变调
    APIRowIndexAudioPitchEngine,
};

@interface FunctionListViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) MultiVideoPickerViewController *picker;
@property (nonatomic, weak) APIImageVideoPickerViewController *imageVideoPiker;
@property (nonatomic, strong) NSArray *apiRowIndexKeys;

/** 当前选中的功能下标 */
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation FunctionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _apiRowIndexKeys =
    @[
      @"APIAudioMixViewController",
      @"APIMovieMixViewController",
      @"APIVideoThumbnailsViewController",
      @"APIImageVideoPickerViewController",
      @"APIMovieClipViewController",
      @"APIAudioRecordViewController",
      @"APIAudioPitchEngineViewController",
      ];
    
    // 国际化
    _titleLabel.text = NSLocalizedStringFromTable(@"tu_功能列表", @"VideoDemo", @"功能列表");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - table view dataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:{
            return NSLocalizedStringFromTable(@"tu_API示例", @"VideoDemo", @"API示例");
        } break;
        default:{} break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _apiRowIndexKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifierKey];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseIdentifierKey];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = NSLocalizedStringFromTable(_apiRowIndexKeys[indexPath.row], @"VideoDemo", @"API示例列表");
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        APIRowIndex rowIndex = indexPath.row;
        _currentIndex = rowIndex;
        switch (rowIndex) {
            // 音频混合
            case APIRowIndexAudioMix:{
                [self performSegueWithIdentifier:self.apiRowIndexKeys[rowIndex] sender:self];
            } break;
            // 音视频混合
            case APIRowIndexMovieMix:{
                [self performSegueWithIdentifier:self.apiRowIndexKeys[rowIndex] sender:self];
            } break;
            // 获取视频缩略图
            case APIRowIndexVideoThumbnails:{
                [self selectVideoWithCount:1 completion:^{
                    [self performSegueWithIdentifier:self.apiRowIndexKeys[rowIndex] sender:self];
                }];
            } break;
            // 图片与视频合成
            case APIRowIndexImageVideoComposer:{
                [self mutilSelectAssetsMediaTypes:@[@(PHAssetMediaTypeVideo),@(PHAssetMediaTypeImage)] maxSelectedCount:9 minSelectedCount:3];
            } break;
            // 视频裁剪
            case APIRowIndexMovieClip:{
                [self selectVideoWithCount:1 completion:^{
                    [self performSegueWithIdentifier:self.apiRowIndexKeys[rowIndex] sender:self];
                }];
            } break;
            // 音频录制
            case APIRowIndexAudioRecord:{
                [self performSegueWithIdentifier:self.apiRowIndexKeys[rowIndex] sender:self];
            } break;
            // 音频录制
            case APIRowIndexAudioPitchEngine:{
                [self performSegueWithIdentifier:self.apiRowIndexKeys[rowIndex] sender:self];
            } break;
        }
    }
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    segue.destinationViewController.title = NSLocalizedStringFromTable(NSStringFromClass(segue.destinationViewController.class), @"VideoDemo", @"API示例列表");
    if ([self segue:segue matchRowIndex:APIRowIndexVideoThumbnails]) {
        // 获取缩略图
        APIVideoThumbnailsViewController *thumbnailsViewController = (APIVideoThumbnailsViewController *)segue.destinationViewController;
        AVURLAsset *asset = _picker.allSelectedAssets.lastObject;
        thumbnailsViewController.inputURL = asset.URL;
    } else if ([self segue:segue matchRowIndex:APIRowIndexMovieClip]) {
        // 视频时间裁剪
        APIMovieClipViewController *clipViewController = (APIMovieClipViewController *)segue.destinationViewController;
        AVURLAsset *asset = _picker.allSelectedAssets.lastObject;
        clipViewController.inputURL = asset.URL;
        
    } else if ([self segue:segue matchRowIndex:APIRowIndexImageVideoComposer]) {
        // 图片视频拼接
    }
}

- (BOOL)segue:(UIStoryboardSegue *)segue matchRowIndex:(APIRowIndex)rowIndex {
    NSString *rowIndexKey = _apiRowIndexKeys[rowIndex];
    return [segue.identifier isEqualToString:rowIndexKey] && [segue.destinationViewController isKindOfClass:NSClassFromString(rowIndexKey)];
}

#pragma mark - tool


/**
 调整到多视频选择器选择指定数量的视频
 
 @param videoCount 指定的视图数量
 @param completion 完成回调
 */
- (void)selectVideoWithCount:(NSUInteger)videoCount completion:(void (^)(void))completion {
    [self selectAssetsMediaTypes:@[@(PHAssetMediaTypeVideo)] maxSelectedCount:videoCount minSelectedCount:videoCount completion:completion];
}

/**
 打开相册页面，选择指定的多媒体文件

 @param mediaTypes 选择的媒体文件类型
 @param maxSelectedCount 最大选择数量
 @param minSelectedCount 最小选择数量
 @param completion 完成回调
 */
- (void)selectAssetsMediaTypes:(NSArray<NSNumber *> *)mediaTypes maxSelectedCount:(NSUInteger)maxSelectedCount minSelectedCount:(NSUInteger)minSelectedCount completion:(void (^)(void))completion {
    MultiVideoPickerViewController *picker = [[MultiVideoPickerViewController alloc] initWithNibName:nil bundle:nil];
    picker.fetchMediaTypes = mediaTypes;
    self.picker = picker;
    picker.maxSelectedCount = maxSelectedCount;
    picker.minSelectedCount = minSelectedCount;

    picker.rightButtonActionHandler = ^(MultiVideoPickerViewController *picker, UIButton *sender) {
        if (completion) completion();
    };
    [self.navigationController pushViewController:picker animated:YES];
}


/**
 打开相册页面，分开选择图片或视频资源
 
 @param mediaTypes 选择的媒体文件类型
 @param maxSelectedCount 最大选择数量
 @param minSelectedCount 最小选择数量
 */
- (void)mutilSelectAssetsMediaTypes:(NSArray<NSNumber *> *)mediaTypes maxSelectedCount:(NSUInteger)maxSelectedCount minSelectedCount:(NSUInteger)minSelectedCount {
    
    APIImageVideoPickerViewController *picker = [[UIStoryboard storyboardWithName:@"APIImageVideoPickerViewController" bundle:nil] instantiateInitialViewController];
    self.imageVideoPiker = picker;
    self.picker = nil;
    picker.maxSelectedCount = maxSelectedCount;
    picker.minSelectedCount = minSelectedCount;
    picker.maxSelectedVideoCount = 9;
    picker.minSelectedVideoCount = 1;
    
    __weak typeof(self)weakSelf = self;
    picker.rightButtonActionHandler = ^(APIImageVideoPickerViewController *picker, UIButton *sender) {
   
        [weakSelf imageAndVideoCompose:picker];
    };
    [self.navigationController pushViewController:picker animated:YES];
}

/**
 图像合成视频
 @since v3.4.1
 */
- (void)imageAndVideoCompose:(APIImageVideoPickerViewController *)imageVideoPicker {
    
    // 选择视频的情况下
    if (imageVideoPicker.selectedAssetType == APIImageVideoPickerSelectedAssetTypeVideo) {
        // 视频合成的 --- 去剪切页面
        MovieCutViewController *cutter = [[MovieCutViewController alloc] initWithNibName:nil bundle:nil];
        cutter.inputAssets = imageVideoPicker.allSelectedAssets;
        cutter.rightButtonActionHandler = ^(MovieCutViewController *cutter, UIButton *sender) {
            MovieEditViewController *edit = [[MovieEditViewController alloc] initWithNibName:nil bundle:nil];
            edit.inputURL = cutter.outputURL;
            [self.navigationController pushViewController:edit animated:YES];
        };
        [self.navigationController pushViewController:cutter animated:YES];
        return;
    }
    
    APIImageVideoComposer *compose = [[APIImageVideoComposer alloc] init];
    compose.inputPHAssets = imageVideoPicker.allSelectedPhAssets;
    compose.singleImageDuration = 2.0;
    [compose setComposerCompleted:^(__kindof AVURLAsset * _Nonnull asset) {
        if (imageVideoPicker.selectedAssetType == APIImageVideoPickerSelectedAssetTypeImage) {
            // 图像合成的 --- 去编辑页面
            MovieEditViewController *edit = [[MovieEditViewController alloc] initWithNibName:nil bundle:nil];
            edit.inputURL = asset.URL;
            [self.navigationController pushViewController:edit animated:YES];
        } else if (imageVideoPicker.selectedAssetType == APIImageVideoPickerSelectedAssetTypeVideo) {
            
            // 视频合成的 --- 去剪切页面
            MovieCutViewController *cutter = [[MovieCutViewController alloc] initWithNibName:nil bundle:nil];
            cutter.inputAssets = @[asset];
            cutter.rightButtonActionHandler = ^(MovieCutViewController *cutter, UIButton *sender) {
                MovieEditViewController *edit = [[MovieEditViewController alloc] initWithNibName:nil bundle:nil];
                edit.inputURL = cutter.outputURL;
                [self.navigationController pushViewController:edit animated:YES];
            };
            [self.navigationController pushViewController:cutter animated:YES];
        }
    }];
    
    [compose startCompose];
    return;
    
    // 之前的视频处理
    /*
    if (imageVideoPicker.selectedAssetType == APIImageVideoPickerSelectedAssetTypeVideo) {
        // 视频拼接 --- 视频剪切器可以直接处理
        MovieCutViewController *cutter = [[MovieCutViewController alloc] initWithNibName:nil bundle:nil];
        cutter.inputAssets = imageVideoPicker.allSelectedAssets;
        cutter.rightButtonActionHandler = ^(MovieCutViewController *cutter, UIButton *sender) {
            MovieEditViewController *edit = [[MovieEditViewController alloc] initWithNibName:nil bundle:nil];
            edit.inputURL = cutter.outputURL;
            [weakSelf.navigationController pushViewController:edit animated:YES];
        };
        [weakSelf.navigationController pushViewController:cutter animated:YES];
    }
    */
}

@end
