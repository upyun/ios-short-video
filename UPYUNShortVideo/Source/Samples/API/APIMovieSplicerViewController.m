//
//  APIMovieSplicerViewController.m
//  TuSDKVideoDemo
//
//  Created by wen on 27/06/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "TuSDKFramework.h"

#import "APIMovieSplicerViewController.h"
#import "TopNavBar.h"

@interface APIMovieSplicerViewController ()<TopNavBarDelegate, TuSDKMovieSplicerDelegate>{
    // 编辑页面顶部控制栏视图
    TopNavBar *_topBar;
    // 拼接对象
    TuSDKTSMovieSplicer *_movieSplicer;
    // 底部说明 label
    UILabel * explainationLabel;
}

// 系统播放器
@property (strong, nonatomic) AVPlayer *firstPlayer;
@property (nonatomic, strong) AVPlayerItem *firstPlayerItem;
@property (strong, nonatomic) AVPlayer *secondPlayer;
@property (nonatomic, strong) AVPlayerItem *secondPlayerItem;
@end

@implementation APIMovieSplicerViewController

#pragma mark - 基础配置方法

// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面设置
    self.wantsFullScreenLayout = YES;
    [self setNavigationBarHidden:YES animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lsqClorWithHex:@"#F3F3F3"];

    // 顶部栏初始化
    [self initWithTopBar];
    // 视频播放器初始化
    [self initWithVideoPlayer];
    // 视频拼接
    [self initWithSplicerButton];
    // 底部说明 label
    [self initWithExplainationLabel];
}

// 底部说明 label
- (void)initWithExplainationLabel;
{
    CGFloat sideGapDistance = 50;
    explainationLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - 10, _topBar.lsqGetSizeHeight)];
    explainationLabel.backgroundColor = lsqRGB(236, 236, 236);
    explainationLabel.center = CGPointMake(self.view.lsqGetSizeWidth/2, self.view.lsqGetSizeHeight - sideGapDistance*0.5);
    explainationLabel.textColor = [UIColor blackColor];
    explainationLabel.text = NSLocalizedString(@"lsq_api_splice_movie_explaination" , @"点击「视频拼接」按钮，将两段视频合为一段视频，保存成功后请去相册查看视频");    
    explainationLabel.numberOfLines = 0;
    explainationLabel.textAlignment = NSTextAlignmentCenter;
    explainationLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:explainationLabel];
}

// 视频拼接按钮
- (void)initWithSplicerButton;
{
    CGFloat sideGapDistance = 50;
    CGFloat buttonWidth = self.view.lsqGetSizeWidth - sideGapDistance*2;
    
    // 开始页面 合成视频btn
    UIButton *mixButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, sideGapDistance)];
    mixButton.center = CGPointMake(self.view.lsqGetSizeWidth/2, self.view.lsqGetSizeHeight - sideGapDistance*2);
    mixButton.backgroundColor =  lsqRGB(252, 143, 96);
    [mixButton setTitle:NSLocalizedString(@"lsq_api_Splice_movie" , @"视频拼接") forState:UIControlStateNormal];
    [mixButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mixButton lsqSetCornerRadius:10];
    mixButton.adjustsImageWhenHighlighted = NO;
    [mixButton addTouchUpInsideTarget: self action:@selector(movieSplicer)];
    [self.view addSubview:mixButton];
}

// 播放器初始化
- (void)initWithVideoPlayer;
{
    // 视频素材一播放器
    UIView *firstPlayerView = [[UIView alloc]initWithFrame:CGRectMake(0, _topBar.lsqGetSizeHeight - 20, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth*9/16)];
    [firstPlayerView setBackgroundColor:[UIColor clearColor]];
    firstPlayerView.multipleTouchEnabled = NO;
    [self.view addSubview:firstPlayerView];
    // 添加视频资源
    _firstPlayerItem = [[AVPlayerItem alloc]initWithURL:[self filePathName:@"tusdk_sample_video.mov"]];
    // 播放
    _firstPlayer = [[AVPlayer alloc]initWithPlayerItem:_firstPlayerItem];
    _firstPlayer.volume = 0.5;
    // 播放视频需要在AVPlayerLayer上进行显示
    AVPlayerLayer *firstPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_firstPlayer];
    firstPlayerLayer.frame = firstPlayerView.frame;
    [firstPlayerView.layer addSublayer:firstPlayerLayer];
    // 循环播放的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playSampleOneVideoCycling) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_firstPlayer play];
    
    // 视频素材二播放器
    UIView *secondPlayerView = [[UIView alloc]initWithFrame:CGRectMake(0, _topBar.lsqGetSizeHeight + 80, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth*9/16)];
    [secondPlayerView setBackgroundColor:[UIColor clearColor]];
    secondPlayerView.multipleTouchEnabled = NO;
    [self.view addSubview:secondPlayerView];
    // 添加视频资源
    _secondPlayerItem = [[AVPlayerItem alloc]initWithURL:[self filePathName:@"tusdk_sample_splice_video.mov"]];
    // 播放
    _secondPlayer = [[AVPlayer alloc]initWithPlayerItem:_secondPlayerItem];
    _secondPlayer.volume = 0.5;
    // 播放视频需要在AVPlayerLayer上进行显示
    AVPlayerLayer *secondPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_secondPlayer];
    secondPlayerLayer.frame = secondPlayerView.frame;
    [secondPlayerView.layer addSublayer:secondPlayerLayer];
    // 循环播放的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playSampleTwoVideoCycling) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_secondPlayer play];
}


// 顶部栏初始化
- (void)initWithTopBar;
{
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [_topBar setBackgroundColor:[UIColor whiteColor]];
    _topBar.topBarDelegate = self;
    [_topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_video_mixed", @"多视频拼接")
                     leftButtonInfo:@[[NSString stringWithFormat:@"video_style_default_btn_back.png+%@",NSLocalizedString(@"lsq_go_back", @"返回")]]
                    rightButtonInfo:nil];
    [_topBar.centerTitleLabel lsqSetSizeWidth:_topBar.lsqGetSizeWidth/2];
    _topBar.centerTitleLabel.center = CGPointMake(self.view.lsqGetSizeWidth/2, _topBar.lsqGetSizeHeight/2);
    [self.view addSubview:_topBar];
}

- (void)movieSplicer;
{
    if (!_movieSplicer) {
        _movieSplicer = [TuSDKTSMovieSplicer createSplicer];
        _movieSplicer.splicerDelegate = self;
    }

    NSURL *sampleOneURL = [self filePathName:@"tusdk_sample_splice_video.mov"];
    NSURL *sampleTwoURL = [self filePathName:@"tusdk_sample_video.mov"];
    
    NSString *moviePath1 = sampleOneURL.path;
    TuSDKTimeRange *timeRange1 = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:8];
    TuSDKMoiveFragment *fragment1 = [[TuSDKMoiveFragment alloc]initWithMoviePath:moviePath1 atTimeRange:timeRange1];
    
    NSString *moviePath2 = sampleTwoURL.path;
    TuSDKTimeRange *timeRange2 = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:15];
    TuSDKMoiveFragment *fragment2 = [[TuSDKMoiveFragment alloc]initWithMoviePath:moviePath2 atTimeRange:timeRange2];

    [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"正在合并...", @"正在合并...")];
    
    _movieSplicer.movies = [NSArray arrayWithObjects:fragment1, fragment2, nil];
    [_movieSplicer startSplicingWithCompletionHandler:^(NSString *filePath, lsqMovieSplicerSessionStatus status) {
        if (status == lsqMovieSplicerSessionStatusCompleted){
            // 操作成功 保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
        }else if(status == lsqMovieSplicerSessionStatusFailed || status == lsqMovieSplicerSessionStatusCancelled || status == lsqMovieSplicerSessionStatusUnknown){
            // 其他操作
        }
    }];

}

#pragma mark - TuSDKMovieSplicerDelegate

/**
 状态通知代理

 @param editor editor TuSDKTSMovieSplicer
 @param status status lsqMovieSplicerSessionStatus
 */
- (void)onMovieSplicer:(TuSDKTSMovieSplicer *)editor statusChanged:(lsqMovieSplicerSessionStatus)status;
{
    if (status == lsqMovieSplicerSessionStatusCompleted) {
        // 操作完成
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_api_splice_movie_success", @"操作完成，请去相册查看视频")];
    }else if (status == lsqMovieSplicerSessionStatusFailed) {
        // 操作失败
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_failed", @"操作失败，无法生成视频文件")];
    }else if (status == lsqMovieSplicerSessionStatusCancelled) {
        // 操作取消
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_cancelled", @"出现问题，操作被取消")];
    }
}

/**
 结果通知代理

 @param editor editor TuSDKTSMovieSplicer
 @param result result TuSDKVideoResult
 */
- (void)onMovieSplicer:(TuSDKTSMovieSplicer *)editor result:(TuSDKVideoResult *)result;
{
    NSLog(@"result   path: %@   duration : %f",result.videoPath,result.duration);
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

- (NSURL *)filePathName:(NSString *)fileName
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:fileName ofType:nil]];
}

- (void)playSampleOneVideoCycling;
{
    [_firstPlayer seekToTime:CMTimeMake(0, 1)];
    [_firstPlayer play];
}

- (void)playSampleTwoVideoCycling;
{
    [_secondPlayer seekToTime:CMTimeMake(0, 1)];
    [_secondPlayer play];
}

- (void)dealloc;
{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    // 销毁播放器
    [self destroyPlayer];
}

- (void)destroyPlayer
{
    if (!_firstPlayer) {
        return;
    }
    [_firstPlayer cancelPendingPrerolls];
    [_firstPlayerItem cancelPendingSeeks];
    [_firstPlayerItem.asset cancelLoading];
    [_firstPlayer pause];
    _firstPlayerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:@""]];
    // 初始化player对象
    self.firstPlayer = [[AVPlayer alloc]initWithPlayerItem:_firstPlayerItem];
    
    _firstPlayer = nil;
    _firstPlayerItem = nil;
    
    if (!_secondPlayer) {
        return;
    }
    [_secondPlayer cancelPendingPrerolls];
    [_secondPlayerItem cancelPendingSeeks];
    [_firstPlayerItem.asset cancelLoading];
    [_secondPlayer pause];
    _secondPlayerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:@""]];
    // 初始化player对象
    self.secondPlayer = [[AVPlayer alloc]initWithPlayerItem:_secondPlayerItem];
    
    _secondPlayer = nil;
    _secondPlayerItem = nil;
}

@end
