//
//  ComponentListViewController.m
//  TuSDKVideoDemo
//
//  Created by TuSDK on 22/06/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "ComponentListViewController.h"
#import "MultipleCameraViewController.h"
#import "MoviePreviewAndCutViewController.h"
#import "MovieEditorViewController.h"
#import "MovieRecordViewController.h"
#import "RecordCameraViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MovieRecordFullScreenController.h"
#import "MoviePreviewAndCutFullScreenController.h"
#import "MoviePreviewAndCutRatioAdaptedController.h"
#import "MovieEditorRatioAdaptedController.h"
#import "RecordCameraViewController.h"
#import "APIAudioMixViewController.h"
#import "APIMovieMixViewController.h"
#import "APIMovieSplicerViewController.h"
#import "APIMovieClipperViewController.h"
#import "APIVideoThumbnailsViewController.h"
#import "APIAudioRecorderViewController.h"
#import "APIMovieCompresserViewController.h"
#import "TuAssetManager.h"
#import "TuAlbumViewController.h"

#pragma mark - ComponentListView
/**
 *  演示选择
 */
@protocol DemoChooseDelegate <NSObject>
/**
 *  选中一个演示
 *
 *  @param index 演示索引
 */
- (void)onDemoChoosedWithIndex:(NSIndexPath*)indexPath;
@end

@interface ComponentListView : UIView<UITableViewDelegate,UITableViewDataSource>
{
    // 表格视图
//    TuSDKICTableView *_tableView;
    UITableView *_tableView;
    // 缓存标记
    NSString *_cellIdentifier;
    // 演示列表
    NSArray *_sectionTitle;
    
    NSArray<NSArray*> *_cellTitles;
}

/**
 * 演示选择
 */
@property (nonatomic, assign) id<DemoChooseDelegate> delegate;

@end

@implementation ComponentListView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

- (void)lsqInitView;
{
    // 缓存标记
    _cellIdentifier = @"MainViewCellIdentify";
    // 演示列表
    _sectionTitle = @[NSLocalizedString(@"lsq_composite_components", @"功能组合展示"),NSLocalizedString(@"lsq_common_components", @"功能单个展示"),NSLocalizedString(@"lsq_custom_components", @"自定义组件示例"),NSLocalizedString(@"lsq_api_usage_example", @"功能 API 展示")];
    
    _cellTitles = @[
                   @[NSLocalizedString(@"lsq_video_mainVC_record" , @"录制视频"),NSLocalizedString(@"lsq_video_preview_editor", @"给定视频 + 视频编辑")],
                   @[NSLocalizedString(@"lsq_normal_record_camera", @"正常录制相机"),NSLocalizedString(@"lsq_record_camera", @"断点续拍相机"),NSLocalizedString(@"lsq_capture_record_camera", @"拍照录制相机"),NSLocalizedString(@"lsq_album_video_editor", @"选择视频+添加滤镜保存")],
                   @[NSLocalizedString(@"lsq_full_screen_record_preview_editor", @"全屏展示：断点续拍"),NSLocalizedString(@"lsq_full_screen_album_video_timecut_editor", @"全屏展示：相册导入 + 时间裁剪 + 视频编辑"),NSLocalizedString(@"lsq_full_screen_record_preview_ratio_editor", @"全屏展示：拍照录制+视频编辑（视频自适应比例）")],
                   @[NSLocalizedString(@"lsq_audio_mixed", @"音频混合"),NSLocalizedString(@"lsq_video_bgm", @"视频 + 背景音乐"),NSLocalizedString(@"lsq_gain_thumbnail", @"获取缩略图"),NSLocalizedString(@"lsq_video_mixed", @"视频拼接"),NSLocalizedString(@"lsq_video_timecut_save", @"时间裁剪保存"),NSLocalizedString(@"lsq_record_audio_save", @"录制音频"),NSLocalizedString(@"lsq_api_video_compress", @"视频压缩")],
                   ];
    
    // 表格视图
    CGFloat height = lsqScreenHeight;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        height -= 34;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, lsqScreenWidth, height) style:UITableViewStylePlain];
    _tableView.tableHeaderView.backgroundColor = [UIColor lightGrayColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.allowsMultipleSelection = NO;
    [self addSubview:_tableView];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (self.delegate) {
        [self.delegate onDemoChoosedWithIndex:indexPath];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return _sectionTitle.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 280, 30)];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 240, 30)];
    [titleLabel setText: _sectionTitle[section]];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [titleView addSubview:titleLabel];
    titleView.backgroundColor = [UIColor lsqClorWithHex:@"#F3F3F3"];
    
    return titleView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 30;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _cellTitles[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    TuSDKICTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (!cell) {
        cell = [TuSDKICTableViewCell initWithReuseIdentifier:_cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = lsqFontSize(15);
    cell.textLabel.text = [NSString stringWithFormat:@"    %@", [_cellTitles[indexPath.section]objectAtIndex:indexPath.row]];
    return cell;
}

@end

#pragma mark - ComponentListViewController

@interface ComponentListViewController()<DemoChooseDelegate, UINavigationControllerDelegate, TuVideoSelectedDelegate>

/**
 *  覆盖控制器视图
 */
@property (nonatomic, retain) ComponentListView *view;

/**
 *  直接进入视频编辑
 */
@property (nonatomic,assign) int enableOpenVCType;


@end

@implementation ComponentListViewController
@dynamic view;

// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:NO animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)loadView;
{
    [super loadView];
    
    [self setNavigationBarHidden:NO animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    self.view = [ComponentListView initWithFrame:CGRectMake(0, 0, lsqScreenWidth, lsqScreenHeight)];
    self.view.backgroundColor = lsqRGB(255, 255, 255);
    self.view.delegate = self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"app_name", @"TuSDK 涂图"), lsqVideoVersion ];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:NSLocalizedString(@"back", @"返回")
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(backActionHadAnimated)];
    
}

#pragma mark - DemoChooseDelegate
/**
 *  选中一个演示
 *
 *  @param index 演示索引
 */
- (void)onDemoChoosedWithIndex:(NSIndexPath*)indexPath;
{
    if (indexPath.section == 0) {
        // 功能套件展示
        switch (indexPath.row)
        {
            case 0:
                // 首页录制视频
                [self openVideoEditor];
                break;
            case 1:
                // 相册导入 + 视频编辑
                _enableOpenVCType = 0;
                [self openImportVideo];
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1)
    {
        // 功能组件展示
        switch (indexPath.row)
        {
            case 0:
                // 正常录制相机
                [self openNormalRecordVideo];
                break;
            case 1:
                // 断点续拍相机
                [self openRecordVideo];
                break;
            case 2:
                // 拍照录制相机
                [self openClickPressCamera];
                break;
            case 3:
                // 选择视频 + 添加滤镜保存视频
                _enableOpenVCType = 1;
                [self openImportVideo];
                break;
            default:
                break;
        }
    }else if (indexPath.section == 2)
    {
        // 自定义组件修改
        switch (indexPath.row)
        {
            case 0:
                // 全屏展示：断点续拍 + 视频编辑
                [self openFullScreenRecordCamera];
                break;
            case 1:
                // 全屏展示：相册导入 + 时间裁剪 + 视频编辑
                _enableOpenVCType = 2;
                [self openImportVideo];
                break;
            case 2:
                // 比例自适应：相册导入 + 时间裁剪 + 视频编辑（视频比例自适应）
                _enableOpenVCType = 3;
                [self openImportVideo];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 3)
    {
        switch (indexPath.row)
        {
            // API 使用示例
            case 0:
                // 音频混合
                [self openAudioMixer];
                break;
            case 1:
                // 视频 + 背景音乐
                [self openMovieMixer];
                break;
            case 2:
                // 获取缩略图
                [self openGetThumbnail];
                break;
            case 3:
                // 视频合成
                [self openMovieSplicer];
                break;
            case 4:
                // 相册选择 + 时间裁剪保存视频
                [self openMovieClipper];
                break;
            case 5:
                // 录制音频
                [self openAudioRecorder];
                break;
            case 6:
                // 压缩视频
                [self openMovieCompresser];
                break;
            default:
                break;
        }
    }
}

#pragma mark - 自定义事件方法


// 功能组合展示：断点续拍 + 裁剪 + 视频编辑
- (void)openVideoEditor;
{
    RecordCameraViewController *vc = [RecordCameraViewController new];
    vc.inputRecordMode = lsqRecordModeKeep;
    [self.navigationController pushViewController:vc animated:YES];
}

// 全屏展示： 断点续拍 + 视频编辑
- (void)openFullScreenRecordCamera;
{
    MovieRecordFullScreenController *vc = [MovieRecordFullScreenController new];
    vc.inputRecordMode = lsqRecordModeKeep;
    [self.navigationController pushViewController:vc animated:YES];
}
// 开启视频录制
- (void)openRecordVideoEditor;
{
    RecordCameraViewController *vc = [RecordCameraViewController new];
    vc.inputRecordMode = lsqRecordModeKeep;
    [self.navigationController pushViewController:vc animated:YES];
}

// 开启断点续拍相机
- (void)openRecordVideo;
{
    MovieRecordViewController *vc = [MovieRecordViewController new];
    vc.inputRecordMode = lsqRecordModeKeep;
    [self.navigationController pushViewController:vc animated:YES];
}

// 开启正常模式录制相机
- (void)openNormalRecordVideo;
{
    MovieRecordViewController *vc = [MovieRecordViewController new];
    vc.inputRecordMode = lsqRecordModeNormal;
    [self.navigationController pushViewController:vc animated:YES];
}

// 点按拍摄
- (void)openClickPressCamera;
{
    MultipleCameraViewController *vc = [MultipleCameraViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

// 相册选择 + preview
- (void)openImportVideo;
{
    [TuAssetManager sharedManager].ifRefresh = YES;
    TuAlbumViewController *videoSelector = [[TuAlbumViewController alloc] init];
    videoSelector.selectedDelegate = self;
    // 若需要选择视频后进行预览 设置为YES，默认为NO
    videoSelector.isPreviewVideo = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:videoSelector];
    [self presentViewController:nav animated:YES completion:nil];
}

// 音频录制
- (void)openAudioRecorder;
{
    APIAudioRecorderViewController *vc = [APIAudioRecorderViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

// 音频混合
- (void)openAudioMixer;
{
    APIAudioMixViewController *vc = [APIAudioMixViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

// 视频 + 背景音乐
- (void)openMovieMixer;
{
    APIMovieMixViewController *vc = [APIMovieMixViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

// 获取缩略图
- (void)openGetThumbnail;
{
    APIVideoThumbnailsViewController *vc = [APIVideoThumbnailsViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

// 压缩视频
- (void)openMovieCompresser;
{
    APIMovieCompresserViewController *vc = [APIMovieCompresserViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

// 视频合成
- (void)openMovieSplicer;
{
    APIMovieSplicerViewController *vc = [APIMovieSplicerViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

// 相册选择 + 时间裁剪保存视频
- (void)openMovieClipper;
{
    APIMovieClipperViewController *vc = [APIMovieClipperViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TuVideoSelectedDelegate

- (void)selectedModel:(TuVideoModel *)model;
{
    ComponentListViewController *wSelf = self;
    NSURL *url = model.url;
    
    if (_enableOpenVCType == 0) {
        // 相册导入 + 裁剪 + 视频编辑
        MoviePreviewAndCutViewController *vc = [MoviePreviewAndCutViewController new];
        vc.inputURL = url;
        [wSelf.navigationController pushViewController:vc animated:YES];
    }else if (_enableOpenVCType == 1)
    {
        // 相册导入 + 视频编辑
        AVAsset *avasset = [AVAsset assetWithURL:url];
        MovieEditorRatioAdaptedController *vc = [MovieEditorRatioAdaptedController new];
        vc.inputURL = url;
        vc.startTime = 0;
        vc.endTime = CMTimeGetSeconds(avasset.duration);
        [wSelf.navigationController pushViewController:vc animated:YES];
    } else if (_enableOpenVCType == 2) {
        // 全屏显示，相册导入 + 时间裁剪 + 视频编辑
        MoviePreviewAndCutFullScreenController *vc = [MoviePreviewAndCutFullScreenController new];
        vc.inputURL = url;
        [wSelf.navigationController pushViewController:vc animated:YES];
    }else if (_enableOpenVCType == 3){
        MoviePreviewAndCutRatioAdaptedController *vc = [MoviePreviewAndCutRatioAdaptedController new];
        vc.inputURL = url;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
