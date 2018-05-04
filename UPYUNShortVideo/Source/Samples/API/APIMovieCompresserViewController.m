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

@interface APIMovieCompresserViewController ()<TopNavBarDelegate, TuSDKMovieCompresserDelegate>{
    // 编辑页面顶部控制栏视图
    TopNavBar *_topBar;
    // 视频图像提取器
    TuSDKTSMovieCompresser *_movieCompresser;
    // 距离定点距离
    CGFloat topYDistance;
    // 原视频路径
    NSString *_filePath;
    
    // 原始视频label
    UILabel *_originLabel;
    // 结果视频label
    UILabel *_resultLabel;
}

// 系统播放器
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

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
    NSInteger fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil].fileSize;
    CGFloat newFileSize = fileSize/1024.0/1024.0;
    _originLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    _originLabel.center = CGPointMake(120,  self.view.lsqGetSizeWidth*9/16 + sideGapDistance *2.5 + topYDistance*2);
    _originLabel.text = [NSString stringWithFormat:@"原视频：%.2f M", newFileSize];
    [self.view addSubview:_originLabel];
    
    _resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    _resultLabel.center = CGPointMake(self.view.lsqGetSizeWidth - 80,  _originLabel.center.y);
    _resultLabel.text = @"压缩后： ";
    [self.view addSubview:_resultLabel];
    // 获取缩略图
    UIButton *compressButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    compressButton.center = CGPointMake(self.view.lsqGetSizeWidth/2, _originLabel.center.y + 100);
    compressButton.backgroundColor =  lsqRGB(252, 143, 96);
    compressButton.layer.cornerRadius = 3;
    [compressButton setTitle:NSLocalizedString(@"lsq_api_usage_video_start_compress",@"压缩视频") forState:UIControlStateNormal];
    [compressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [compressButton addTarget:self action:@selector(startCompress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:compressButton];
}

- (void)startCompress;
{
    if (!_movieCompresser) {
        _movieCompresser = [[TuSDKTSMovieCompresser alloc]initWithMoviePath:_filePath];
        _movieCompresser.compressDelegate = self;
        _movieCompresser.outputFileType = lsqFileTypeMPEG4;
    }
    
    // 压缩比，范围 0-1
    // _movieCompresser.videoBitRateScale = 0.5;
    // 设置码率，设置后「压缩比」参数不再生效
    _movieCompresser.videoBitRate = 3000 * 1000;
    [_movieCompresser startCompressing];
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
    [self.view addSubview:playerView];
    
    _filePath = [[NSBundle mainBundle]pathForResource:@"tusdk_compression_video" ofType:@"mp4"];
    
    // 添加视频资源
    _playerItem = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:_filePath]];
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

// 状态通知代理
- (void)onMovieCompresser:(TuSDKTSMovieCompresser *)compresser statusChanged:(lsqMovieCompresserSessionStatus)status;
{
    NSLog(@"TuSDKTSMovieCompresser 的目前的状态是 ： %ld",(long)status);
    
    if (status == lsqMovieCompresserSessionStatusCompleted)
    {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_api_splice_movie_success", @"操作完成，请去相册查看视频")];
    }else if (status == lsqMovieCompresserSessionStatusFailed)
    {
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_failed", @"操作失败，无法生成视频文件")];
    }else if(status == lsqMovieCompresserSessionStatusCancelled)
    {
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_cancelled", @"出现问题，操作被取消")];
    }else if (status == lsqMovieCompresserSessionStatusCompressing)
    {
        [[TuSDK shared].messageHub showToast:NSLocalizedString(@"lsq_api_compress_movie_compressing", @"正在压缩...")];
    }
}

// 结果通知代理
- (void)onMovieCompresser:(TuSDKTSMovieCompresser *)compresser result:(TuSDKVideoResult *)result;
{
    if (result.videoPath) {
        NSLog(@"result path : %@",result.videoPath);
        // 操作成功 保存到相册
        NSInteger fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:result.videoPath error:nil].fileSize;
        CGFloat newFileSize = fileSize/1000.0/1000.0;
        _resultLabel.text = [NSString stringWithFormat:@"压缩后：%.2f M", newFileSize];
        // gain bits sample code
        // NSURL *videoURL = [NSURL fileURLWithPath:result.videoPath];
        // AVAsset *videoAsset =[AVAsset assetWithURL:videoURL];
        // AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        // CGFloat videoDataBits = [videoTrack estimatedDataRate];
        // NSLog(@"生成视频的码率： %lf",videoDataBits);    
        UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
    }
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
    _playerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:@""]];
    // 初始化player对象
    self.player = [[AVPlayer alloc]initWithPlayerItem:_playerItem];
    
    _player = nil;
    _playerItem = nil;
}

@end
