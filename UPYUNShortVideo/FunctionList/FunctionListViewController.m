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
#import "APIVideoThumbnailsViewController.h"
#import "APIMovieSpliceViewController.h"
#import "APIMovieClipViewController.h"

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
    // 视频拼接
    APIRowIndexMovieSplice,
    // 视频裁剪
    APIRowIndexMovieClip,
    // 音频录制
    APIRowIndexAudioRecord,
    // 音频变调
    APIRowIndexAudioPitchEngine
};

@interface FunctionListViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) MultiVideoPickerViewController *picker;
@property (nonatomic, strong) NSArray *apiRowIndexKeys;

@end

@implementation FunctionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _apiRowIndexKeys =
    @[
      @"APIAudioMixViewController",
      @"APIMovieMixViewController",
      @"APIVideoThumbnailsViewController",
      @"APIMovieSpliceViewController",
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
            // 视频拼接
            case APIRowIndexMovieSplice:{
                [self selectVideoWithCount:2 completion:^{
                    [self performSegueWithIdentifier:self.apiRowIndexKeys[rowIndex] sender:self];
                }];
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
    } else if ([self segue:segue matchRowIndex:APIRowIndexMovieSplice]) {
        // 多视频拼接
        APIMovieSpliceViewController *spliceViewController = (APIMovieSpliceViewController *)segue.destinationViewController;
        AVURLAsset *firstAsset = _picker.allSelectedAssets.firstObject;
        AVURLAsset *secondAsset = _picker.allSelectedAssets.lastObject;
        spliceViewController.firstInputURL = firstAsset.URL;
        spliceViewController.secondInputURL = secondAsset.URL;
    } else if ([self segue:segue matchRowIndex:APIRowIndexMovieClip]) {
        // 视频时间裁剪
        APIMovieClipViewController *clipViewController = (APIMovieClipViewController *)segue.destinationViewController;
        AVURLAsset *asset = _picker.allSelectedAssets.lastObject;
        clipViewController.inputURL = asset.URL;
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
    MultiVideoPickerViewController *picker = [[MultiVideoPickerViewController alloc] initWithNibName:nil bundle:nil];
    self.picker = picker;
    picker.maxSelectedCount = picker.minSelectedCount = videoCount;
    picker.rightButtonActionHandler = ^(MultiVideoPickerViewController *picker, UIButton *sender) {
        if (completion) completion();
    };
    [self.navigationController pushViewController:picker animated:YES];
}

@end
