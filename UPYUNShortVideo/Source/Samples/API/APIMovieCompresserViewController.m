//
//  APIMovieCompresserViewController.m
//  TuSDKVideoDemo
//
//  Created by WYW on 2018/3/21.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "APIMovieCompresserViewController.h"
#import "TopNavBar.h"
#import "TuSDKFramework.h"

@interface APIMovieCompresserViewController ()<TopNavBarDelegate, TuSDKAssetVideoComposerDelegate, TuSDKICSeekBarDelegate>{
    // 编辑页面顶部控制栏视图
    TopNavBar *_topBar;
    // 视频图像提取器
    TuSDKAssetVideoComposer *_movieCompresser;
    // 距离定点距离
    CGFloat topYDistance;
    
    // 原始视频label
    UILabel *_originLabel;
    // 结果视频label
    UILabel *_resultLabel;
}

// 系统播放器
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, weak) UIView *playerView;

@end

@implementation APIMovieCompresserViewController
#pragma mark - 基础配置方法

// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        return NO;
    }
    
    return YES;
}

// 是否允许旋转 IOS5
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

// 是否允许旋转 IOS6
-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 视图布局方法

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    // 销毁播放器
    [self destroyPlayer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarHidden:YES animated:NO];
    if (![UIDevice lsqIsDeviceiPhoneX]) {
        [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = lsqRGB(217, 217, 217);
    
    topYDistance = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topYDistance += 44;
    }
    
    // 顶部栏初始化
    [self initWithTopBar];
    // 视频播放器初始化
    [self initWithVideoPlayer];
    // 界面布局
    [self layoutView];
}


// 界面布局
- (void)layoutView;
{
    CGFloat sideGapDistance = 50;
    [[[ALAssetsLibrary alloc] init] assetForURL:_inputURL resultBlock:^(ALAsset *asset) {
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            NSInteger fileSize = [[asset defaultRepresentation] size];
            CGFloat newFileSize = fileSize/1024.0/1024.0;
            _originLabel.text = [NSString stringWithFormat:@"原视频：%.2f M", newFileSize];
        }
    } failureBlock:^(NSError *error) {
    }];
   
    _originLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    _originLabel.center = CGPointMake(90,  self.view.lsqGetSizeWidth*9/16 + sideGapDistance *2.5 + topYDistance*2);
    _originLabel.textAlignment = NSTextAlignmentLeft;
    _originLabel.text = [NSString stringWithFormat:@"原视频： "];
    [self.view addSubview:_originLabel];
    
    _resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    _resultLabel.center = CGPointMake(self.view.lsqGetSizeWidth - 90,  _originLabel.center.y);
    _resultLabel.textAlignment = NSTextAlignmentRight;
    _resultLabel.text = @"压缩后： ";
    [self.view addSubview:_resultLabel];
    
     [self initWithSeekBarAndLabels:@"压缩比" originY:_resultLabel.lsqGetOriginY + 40 tag:11];
    
    UIButton *compressButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    compressButton.center = CGPointMake(self.view.lsqGetSizeWidth/2, _originLabel.center.y + 100);
    compressButton.backgroundColor =  lsqRGB(252, 143, 96);
    compressButton.layer.cornerRadius = 3;
    [compressButton setTitle:NSLocalizedString(@"lsq_api_usage_video_start_compress",@"压缩视频") forState:UIControlStateNormal];
    [compressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [compressButton addTarget:self action:@selector(startCompress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:compressButton];
}

/**
 创建拖动条
 
 @param titleLabelText 左侧 Label 的 title
 @param originY 组件显示的纵坐标
 @param seekBarTag 组件的 tag
 */
- (void)initWithSeekBarAndLabels:(NSString *)titleLabelText originY:(CGFloat)originY tag:(NSInteger)seekBarTag;
{
    CGFloat sideGapDistance = 50;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, originY, sideGapDistance, sideGapDistance)];
    titleLabel.text = titleLabelText;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    UILabel * argValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.lsqGetSizeWidth - sideGapDistance, originY, sideGapDistance, sideGapDistance)];
    argValueLabel.text = @"0%";
    argValueLabel.textColor = lsqRGB(252, 143, 96);
    argValueLabel.font = [UIFont systemFontOfSize:15];
    argValueLabel.textAlignment = NSTextAlignmentCenter;
    argValueLabel.tag = seekBarTag;
    [self.view addSubview:argValueLabel];
    
    TuSDKICSeekBar *originalAudioVolumeBar = [TuSDKICSeekBar initWithFrame:CGRectMake(sideGapDistance, originY, self.view.lsqGetSizeWidth - sideGapDistance *2 , 50)];
    originalAudioVolumeBar.delegate = self;
    originalAudioVolumeBar.progress = 0;
    originalAudioVolumeBar.aboveView.backgroundColor = lsqRGB(252, 143, 96);
    originalAudioVolumeBar.belowView.backgroundColor = lsqRGB(213, 213, 213);
    originalAudioVolumeBar.dragView.backgroundColor = lsqRGB(252, 143, 96);
    originalAudioVolumeBar.tag = seekBarTag;
    [self.view addSubview: originalAudioVolumeBar];
}

/**
 开始压缩视频
 */
- (void)startCompress;
{
    [self destroyPlayer];
    
    if (!_movieCompresser) {
        _movieCompresser = [[TuSDKAssetVideoComposer alloc] initWithAsset:nil];
        _movieCompresser.delegate = self;
        // 指定输出文件格式
        _movieCompresser.outputFileType = lsqFileTypeMPEG4;
        NSURL *sampleOneURL = _inputURL;
        
        // 添加待压缩的视频源
        [_movieCompresser addInputAsset:[AVAsset assetWithURL:sampleOneURL]];
    }
    
    // 指定输出文件的码率
//     _movieCompresser.outputVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_High2];
    
    // 指定压缩比 outputVideoQuality 和 outputCompressionScale 可二选一。
    // 同时设置时优先使用 outputVideoQuality。
    
    // 压缩比为0和1时,输出原视频码率AVVideoProfileLevelH264Main41级别的视频,建议压缩比范围1%-99%。
    _movieCompresser.outputCompressionScale = self.progress;

    [_movieCompresser startComposing];
}

// 重新获取
- (void)resetGain
{
    for (UIView*view in self.view.subviews) {
        if (view.tag > 0) {
            if ([view isMemberOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView*)view;
                [imageView setImage:[UIImage imageNamed:@""]];
            }
        }
    }
}
// 顶部栏初始化
- (void)initWithTopBar;
{
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topYDistance, self.view.bounds.size.width, 44)];
    [_topBar setBackgroundColor:[UIColor whiteColor]];
    _topBar.topBarDelegate = self;
    [_topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_api_video_compress", @"视频压缩")
                     leftButtonInfo:@[@"video_style_default_btn_back.png"]
                    rightButtonInfo:nil];
    [_topBar.centerTitleLabel lsqSetSizeWidth:_topBar.lsqGetSizeWidth/2];
    _topBar.centerTitleLabel.center = CGPointMake(self.view.lsqGetSizeWidth/2, _topBar.lsqGetSizeHeight/2);
    [self.view addSubview:_topBar];
}

// 播放器初始化
- (void)initWithVideoPlayer;
{
    UIView *playerView = [[UIView alloc]initWithFrame:CGRectMake(0, topYDistance/2 + _topBar.lsqGetSizeHeight, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth*9/16)];
    [playerView setBackgroundColor:[UIColor clearColor]];
    playerView.multipleTouchEnabled = NO;
    _playerView = playerView;
    [self.view addSubview:playerView];
    
    // 添加视频资源
    _playerItem = [[AVPlayerItem alloc]initWithURL:_inputURL];
    // 播放
    _player = [[AVPlayer alloc]initWithPlayerItem:_playerItem];
    _player.volume = 0.5;
    // 播放视频需要在AVPlayerLayer上进行显示
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = playerView.frame;
    [playerView.layer addSublayer:playerLayer];
    // 循环播放的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playVideoCycling) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_player play];
}

#pragma mark - TopNavBarDelegate

/**
 左侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onLeftButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
    // 返回按钮
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TuSDKICSeekBarDelegate

/**
 压缩比拖动事件
 
 @param seekbar 拖动条
 @param progress 压缩比
 */
- (void)onTuSDKICSeekBar:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress{
    for (UIView*view in self.view.subviews ) {
        if (view.tag == seekbar.tag) {
            if ([view isMemberOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel*)view;
                label.text =  [NSString stringWithFormat:@"%d%%",(int)(seekbar.progress*100)];
            }
        }
    }
    
    if (seekbar.tag == 11)
    {
        self.progress = progress;
    }
}



#pragma mark - TuSDKAssetVideoComposerDelegate

/**
 压缩状态改变事件
 
 @param composer TuSDKAssetVideoComposer
 @param status lsqAssetVideoComposerStatus 当前状态
 */
-(void)assetVideoComposer:(TuSDKAssetVideoComposer *)composer statusChanged:(TuSDKAssetVideoComposerStatus)status
{
    switch (status)
    {
        case TuSDKAssetVideoComposerStatusStarted:
             [[TuSDK shared].messageHub showToast:NSLocalizedString(@"lsq_api_compress_movie_compressing", @"正在压缩...")];
            break;
        case TuSDKAssetVideoComposerStatusCompleted:
        {
            [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_api_splice_movie_success", @"操作完成，请去相册查看视频")];
            [self initWithVideoPlayer];
            break;
        }
        case TuSDKAssetVideoComposerStatusFailed:
            [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_failed", @"操作失败，无法生成视频文件")];
            [self initWithVideoPlayer];
            break;
        case TuSDKAssetVideoComposerStatusCancelled:
            [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_cancelled", @"出现问题，操作被取消")];
            [self initWithVideoPlayer];
            break;
        default:
            break;
    }
}

/**
 压缩进度事件
 
 @param composer TuSDKAssetVideoComposer
 @param progress 处理进度
 @param index 当前正在处理的视频索引
 */
-(void)assetVideoComposer:(TuSDKAssetVideoComposer *)composer processChanged:(float)progress assetIndex:(NSUInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _resultLabel.text = [NSString stringWithFormat:@"压缩进度 %.0f%%", progress * 100];
    });
}

/**
 视频压缩完毕
 
 @param composer TuSDKAssetVideoComposer
 @param result TuSDKVideoResult
 */
-(void)assetVideoComposer:(TuSDKAssetVideoComposer *)composer saveResult:(TuSDKVideoResult *)result
{
    // 视频处理结果
    NSLog(@"result path : %@",result.videoPath);
    NSInteger fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:result.videoPath error:nil].fileSize;
    CGFloat newFileSize = fileSize/1000.0/1000.0;
    dispatch_async(dispatch_get_main_queue(), ^{
        _resultLabel.text = [NSString stringWithFormat:@"压缩后：%.2f M", newFileSize];
    });
    NSLog(@"result path: %@ ",result.videoAsset);
}

- (void)playVideoCycling;
{
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}


- (void)dealloc
{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    // 销毁播放器
    [self destroyPlayer];
}

- (void)destroyPlayer
{
    if (!_player) {
        return;
    }
    [_player cancelPendingPrerolls];
    [_playerItem cancelPendingSeeks];
    [_playerItem.asset cancelLoading];
    [_player pause];
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    _playerItem = nil;
    [_playerView removeFromSuperview];
    _playerView = nil;
}

@end
