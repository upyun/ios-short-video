//
//  APIMovieMixViewController.m
//  TuSDKVideoDemo
//
//  Created by wen on 27/06/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "TuSDKFramework.h"

#import "APIMovieMixViewController.h"
#import "TopNavBar.h"

@interface APIMovieMixViewController ()<TopNavBarDelegate, TuSDKTSMovieMixerDelegate,TuSDKICSeekBarDelegate>{
    // 编辑页面顶部控制栏视图
    TopNavBar *_topBar;
    // 音乐播放器
    AVAudioPlayer *firstBGMPlayer;
    AVAudioPlayer *secondBGMPlayer;
    TuSDKTSAudio *firstMixAudio;
    TuSDKTSAudio *secondMixAudio;
    TuSDKTSMovieMixer *movieMixer;
}

// 系统播放器
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation APIMovieMixViewController

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

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    // 销毁播放器
    [self destroyPlayer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面设置
    self.wantsFullScreenLayout = YES;
    [self setNavigationBarHidden:YES animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lsqClorWithHex:@"#F3F3F3"];

    // 顶部栏初始化
    [self initWithTopBar];
    // 视频播放器初始化
    [self initWithVideoPlayer];
    // 音频播放器初始化
    [self initWithAudioPlayer];
    // 初始化音视频混合对象
    [self initWithMovieMixer];
    // 合成 button
    [self initWithMixButton];
}

- (void)initWithMovieMixer;
{
    NSURL *firstAudioURL = [self filePathName:@"sound_cat.mp3"];
    AVURLAsset *firstMixAudioAsset = [AVURLAsset URLAssetWithURL:firstAudioURL options:nil];
    firstMixAudio = [[TuSDKTSAudio alloc]initWithAsset:firstMixAudioAsset];
    firstMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:1 endSeconds:6];

    NSURL *secondAudioURL = [self filePathName:@"sound_children.mp3"];
    secondMixAudio = [[TuSDKTSAudio alloc]initWithAudioURL:secondAudioURL];
    secondMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:1 endSeconds:6];
    
    // 初始化音视频混合器对象
    NSURL *videoURL = [self filePathName:@"tusdk_sample_video.mov"];
    movieMixer = [[TuSDKTSMovieMixer alloc]initWithMoviePath:videoURL.path];
    movieMixer.mixDelegate = self;
    // 是否允许音频循环 默认 NO
    movieMixer.enableCycleAdd = YES;
    // 混合时视频的选中时间
    movieMixer.videoTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:1 endSeconds:20];
    // 是否保留视频原音
    movieMixer.enableVideoSound = NO;
}

- (NSURL *)filePathName:(NSString *)fileName
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:fileName ofType:nil]];
}

- (void)initWithMixButton;
{
    CGFloat sideGapDistance = 50;
    
    // 开始页面 合成视频btn
    UIButton *mixButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    mixButton.center = CGPointMake(self.view.lsqGetSizeWidth/2, self.view.lsqGetSizeWidth + sideGapDistance*4);
    mixButton.backgroundColor = lsqRGB(252, 143, 96);
    [mixButton setTitle:NSLocalizedString(@"lsq_api_mix_movie_audio" , @"合成视频") forState:UIControlStateNormal];
    [mixButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mixButton lsqSetCornerRadius:10];
    mixButton.adjustsImageWhenHighlighted = NO;
    [mixButton addTouchUpInsideTarget: self action:@selector(mixVideoAndAudio)];
    [self.view addSubview:mixButton];
}

// 合唱 button 的点击事件
- (void)mixVideoAndAudio;
{
    [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"lsq_api_start_mix_movie_audio", @"开始合成...")];
    // 混合的音频
    movieMixer.mixAudios = [NSArray arrayWithObjects:firstMixAudio, secondMixAudio, nil];
    // 开始混合
    [movieMixer startMovieMixWithCompletionHandler:^(NSString *filePath, lsqMovieMixStatus status) {
        if (status == lsqMovieMixStatusCompleted) {
            // 操作成功 保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
        }else{
            // 提示失败
            NSLog(@"保存失败");
        }
    }];
}

// movieMixer cancel 操作
- (void)cancelMovieMixer
{
    if (movieMixer) {
        [movieMixer cancelMixing];
    }
}

- (void)initWithAudioPlayer;
{
    // 创建seekBar
     CGFloat sideGapDistance = 50;
    [self initWithSeekBarAndLabels:NSLocalizedString(@"lsq_api_origin_audio", @"原音") originY:self.view.lsqGetSizeWidth tag:11];
    [self initWithSeekBarAndLabels:NSLocalizedString(@"lsq_api_first_mix_audio", @"混音一") originY:self.view.lsqGetSizeWidth + sideGapDistance tag:12];
    [self initWithSeekBarAndLabels:NSLocalizedString(@"lsq_api_second_mix_audio", @"混音二") originY:self.view.lsqGetSizeWidth + sideGapDistance*2 tag:13];
    
    firstBGMPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[self filePathName:@"sound_cat.mp3"] error:nil];
    firstBGMPlayer.numberOfLoops = -1;//循环播放
    firstBGMPlayer.volume = 0.5;
    [firstBGMPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [firstBGMPlayer play];
    
    secondBGMPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[self filePathName:@"sound_children.mp3"] error:nil];
    secondBGMPlayer.numberOfLoops = -1;//循环播放
    secondBGMPlayer.volume = 0.5;
    [secondBGMPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [secondBGMPlayer play];
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
    argValueLabel.text = @"50%";
    argValueLabel.textColor = lsqRGB(252, 143, 96);
    argValueLabel.font = [UIFont systemFontOfSize:15];
    argValueLabel.textAlignment = NSTextAlignmentCenter;
    argValueLabel.tag = seekBarTag;
    [self.view addSubview:argValueLabel];
    
    TuSDKICSeekBar *originalAudioVolumeBar = [TuSDKICSeekBar initWithFrame:CGRectMake(sideGapDistance, originY, self.view.lsqGetSizeWidth - sideGapDistance *2 , 50)];
    originalAudioVolumeBar.delegate = self;
    originalAudioVolumeBar.progress = 0.5;
    originalAudioVolumeBar.aboveView.backgroundColor = lsqRGB(252, 143, 96);
    originalAudioVolumeBar.belowView.backgroundColor = lsqRGB(213, 213, 213);
    originalAudioVolumeBar.dragView.backgroundColor = lsqRGB(252, 143, 96);
    originalAudioVolumeBar.tag = seekBarTag;
    [self.view addSubview: originalAudioVolumeBar];
}

// 播放器初始化
- (void)initWithVideoPlayer;
{
    UIView *playerView = [[UIView alloc]initWithFrame:CGRectMake(0, _topBar.lsqGetSizeHeight, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth*9/16)];
    [playerView setBackgroundColor:[UIColor clearColor]];
    playerView.multipleTouchEnabled = NO;
    [self.view addSubview:playerView];
    // 添加视频资源
    _playerItem = [[AVPlayerItem alloc]initWithURL:[self filePathName:@"tusdk_sample_video.mov"]];
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

// 顶部栏初始化
- (void)initWithTopBar;
{
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [_topBar setBackgroundColor:[UIColor whiteColor]];
    _topBar.topBarDelegate = self;
    [_topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_video_bgm", @"视频 + 背景音乐")
                     leftButtonInfo:@[[NSString stringWithFormat:@"video_style_default_btn_back.png+%@",NSLocalizedString(@"lsq_go_back", @"返回")]]
                    rightButtonInfo:nil];
    [_topBar.centerTitleLabel lsqSetSizeWidth:_topBar.lsqGetSizeWidth/2];
    _topBar.centerTitleLabel.center = CGPointMake(self.view.lsqGetSizeWidth/2, _topBar.lsqGetSizeHeight/2);
    [self.view addSubview:_topBar];
}


#pragma mark - TuSDKTSMovieMixerDelegate
/**
 状态通知代理

 @param editor editor TuSDKTSMovieMixer
 @param status status lsqMovieMixStatus
 */
- (void)onMovieMixer:(TuSDKTSMovieMixer *)editor statusChanged:(lsqMovieMixStatus)status;
{
    NSLog(@"TuSDKTSMovieMixer 的目前的状态是 ： %ld",(long)status);
    if (status == lsqMovieMixStatusCompleted)
    {
         [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_api_splice_movie_success", @"操作完成，请去相册查看保存视频")];
    }else if (status == lsqMovieMixStatusFailed)
    {
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_failed", @"操作失败，无法生成视频文件")];
    }else if(status == lsqMovieMixStatusCancelled)
    {
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_cancelled", @"出现问题，操作被取消")];
    }
}

/**
 结果通知代理

 @param editor editor TuSDKTSMovieMixer
 @param result result TuSDKVideoResult
 */
- (void)onMovieMixer:(TuSDKTSMovieMixer *)editor result:(TuSDKVideoResult *)result;
{
    NSLog(@"保存结果的临时文件路径 : %@",result.videoPath);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  进度改变
 *
 *  @param seekbar  百分比控制条
 *  @param progress 进度百分比
 */
- (void)onTuSDKICSeekBar:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress;
{
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
        _player.volume = progress;
        movieMixer.videoSoundVolume = progress;
    }else if (seekbar.tag == 12)
    {
        firstBGMPlayer.volume = progress;
        firstMixAudio.audioVolume = progress;
    }else if (seekbar.tag == 13)
    {
        secondBGMPlayer.volume = progress;
        secondMixAudio.audioVolume = progress;
    }
}

- (void)playVideoCycling;
{
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
