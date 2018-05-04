//
//  APIAudioMixViewController.m
//  TuSDKVideoDemo
//
//  Created by wen on 27/06/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "TuSDKFramework.h"

#import "APIAudioMixViewController.h"
#import "TopNavBar.h"

@interface APIAudioMixViewController ()<TopNavBarDelegate, TuSDKTSAudioMixerDelegate,TuSDKICSeekBarDelegate>{
    // 编辑页面顶部控制栏视图
    TopNavBar *_topBar;
    // 音频混合对象
    TuSDKTSAudioMixer *_audiomixer;
    // 播放对象
    AVAudioPlayer *_audioPlayer;
    // 混合结果 url
    NSURL *_resultURL;
   
    // 播放混音视频
    UIButton *playBtn;
    
    // 音乐播放器
    AVAudioPlayer *firstBGMPlayer;
    AVAudioPlayer *secondBGMPlayer;
    AVAudioPlayer *thirdBGMPlayer;
    // 原始音乐，混音1和混音2 的音频
    TuSDKTSAudio *mainAudio;
    TuSDKTSAudio *firstMixAudio;
    TuSDKTSAudio *secondMixAudio;
    UILabel * explainationLabel;
    
    // 距离定点距离
    CGFloat topYDistance;
}

@end

@implementation APIAudioMixViewController

#pragma mark - 基础配置方法

// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        return NO;
    }
    return YES;
}

- (NSURL *)filePathName:(NSString *)fileName
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:fileName ofType:nil]];
}

#pragma mark - 视图布局方法

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
    self.view.backgroundColor = [UIColor lsqClorWithHex:@"#F3F3F3"];
    
    topYDistance = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topYDistance += 44;
    }

    // 顶部栏初始化
    [self initWithTopBar];
    // 顶部说明 label
    [self initWithExplainationLabel];
    // 界面布局
    [self layoutView];
    // 音频播放器初始化
    [self initWithAudioPlayer];
    // 音频混合器初始化
    [self initWithAudioMixer];
}

- (void)initWithExplainationLabel;
{
    explainationLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, _topBar.lsqGetSizeHeight + topYDistance, self.view.lsqGetSizeWidth, _topBar.lsqGetSizeHeight*1.5)];
    explainationLabel.backgroundColor = lsqRGB(236, 236, 236);
    explainationLabel.textColor = [UIColor blackColor];
    explainationLabel.text = NSLocalizedString(@"lsq_api_mixed_audio_explaination", @"请分别调节以下音乐音量大小，调节完毕后，点击「生成音频」即可生成一段新的混合音乐。记得要打开系统音量哟~");
    explainationLabel.numberOfLines = 0;
    explainationLabel.textAlignment = NSTextAlignmentCenter;
    explainationLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:explainationLabel];
}

// 创建混音生成器
- (void)initWithAudioMixer;
{
    // mainAudio
    NSURL *mainAudioURL = [self filePathName:@"sound_cat.mp3"];
    mainAudio = [[TuSDKTSAudio alloc]initWithAudioURL:mainAudioURL];
    mainAudio.audioVolume = 0;
    mainAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:6];
    
    // 混音1
    NSURL *firstMixAudioURL = [self filePathName:@"sound_children.mp3"];
    firstMixAudio = [[TuSDKTSAudio alloc]initWithAudioURL:firstMixAudioURL];
    firstMixAudio.audioVolume = 0;
    firstMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:3];
    
    // audio2
    NSURL *secondMixAudioURL = [self filePathName:@"sound_tangyuan.mp3"];
    secondMixAudio = [[TuSDKTSAudio alloc]initWithAudioURL:secondMixAudioURL];
    secondMixAudio.audioVolume = 0;
    secondMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:3];
    
    _audiomixer = [[TuSDKTSAudioMixer alloc]init];
    _audiomixer.mixDelegate = self;
    // 设置主音轨
    _audiomixer.mainAudio = mainAudio;
    // 是否允许音频循环 默认 NO
    _audiomixer.enableCycleAdd = YES;
}

// 音频播放器初始化
- (void)initWithAudioPlayer;
{
    // 创建seekBar
    CGFloat sideGapDistance = 50;
    [self initWithSeekBarAndLabels:NSLocalizedString(@"lsq_api_origin_audio", @"原音") originY:topYDistance + _topBar.lsqGetSizeHeight*2.5 tag:11];
    [self initWithSeekBarAndLabels:NSLocalizedString(@"lsq_api_first_mix_audio", @"混音一") originY:topYDistance + _topBar.lsqGetSizeHeight*2.5 + sideGapDistance*1 tag:12];
    [self initWithSeekBarAndLabels:NSLocalizedString(@"lsq_api_second_mix_audio", @"混音二")  originY:topYDistance + _topBar.lsqGetSizeHeight*2.5 + sideGapDistance*2 tag:13];
    firstBGMPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[self filePathName:@"sound_cat.mp3"] error:nil];
    firstBGMPlayer.numberOfLoops = -1;//循环播放
    firstBGMPlayer.volume = 0;
    [firstBGMPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [firstBGMPlayer play];
    
    secondBGMPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[self filePathName:@"sound_children.mp3"] error:nil];
    secondBGMPlayer.numberOfLoops = -1;//循环播放
    secondBGMPlayer.volume = 0;
    [secondBGMPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [secondBGMPlayer play];
    
    thirdBGMPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[self filePathName:@"sound_tangyuan.mp3"] error:nil];
    thirdBGMPlayer.numberOfLoops = -1;//循环播放
    thirdBGMPlayer.volume = 0;
    [thirdBGMPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [thirdBGMPlayer play];
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


// 顶部栏初始化
- (void)initWithTopBar;
{
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topYDistance, self.view.bounds.size.width, 44)];
    [_topBar setBackgroundColor:[UIColor whiteColor]];
    _topBar.topBarDelegate = self;
    [_topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_audio_mixed", @"多音轨混合")
                     leftButtonInfo:@[@"video_style_default_btn_back.png"]
                    rightButtonInfo:nil];
    [_topBar.centerTitleLabel lsqSetSizeWidth:_topBar.lsqGetSizeWidth/2];
    _topBar.centerTitleLabel.center = CGPointMake(self.view.lsqGetSizeWidth/2, _topBar.lsqGetSizeHeight/2);
    [self.view addSubview:_topBar];
}

// 界面布局
- (void)layoutView;
{
    CGFloat sideGapDistance = 50;
    // 开始混合
    UIButton *testBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    testBtn.center = CGPointMake(self.view.lsqGetSizeWidth/2, sideGapDistance *6 + topYDistance);
    testBtn.backgroundColor = lsqRGB(252, 143, 96);
    testBtn.layer.cornerRadius = 3;
    [testBtn setTitle:NSLocalizedString(@"lsq_api_start_mix_audio", @"开始音频混合") forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(startAudiosMixing) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    
    // 删除混音
    UIButton *cancelPlayBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    cancelPlayBtn.center = CGPointMake(self.view.lsqGetSizeWidth/2, sideGapDistance *7.5 + topYDistance);
    cancelPlayBtn.backgroundColor = lsqRGB(252, 143, 96);
    cancelPlayBtn.layer.cornerRadius = 3;
    [cancelPlayBtn setTitle:NSLocalizedString(@"lsq_api_delete_mixed_audio", @"删除混和音频") forState:UIControlStateNormal];
    [cancelPlayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelPlayBtn addTarget:self action:@selector(deleteMixedAudioPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelPlayBtn];

    // 播放结果
    playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, sideGapDistance*2, 40)];
    playBtn.center = CGPointMake(sideGapDistance*2, sideGapDistance* 9 + topYDistance);
    playBtn.backgroundColor = lsqRGB(252, 143, 96);
    playBtn.layer.cornerRadius = 3;
    [playBtn setTitle:NSLocalizedString(@"lsq_api_play_mixed_audio", @"播放混合音频") forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playMixedAudio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    playBtn.enabled = YES;
    
    // 暂停播放音乐素材
    UIButton *cancelPlayAudiosBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, sideGapDistance*2, 40)];
    cancelPlayAudiosBtn.center = CGPointMake(self.view.lsqGetSizeWidth - sideGapDistance*2, sideGapDistance *9 + topYDistance);
    cancelPlayAudiosBtn.backgroundColor = lsqRGB(252, 143, 96);
    cancelPlayAudiosBtn.layer.cornerRadius = 3;
    [cancelPlayAudiosBtn setTitle:NSLocalizedString(@"lsq_api_pause_mixed_music", @"暂停") forState:UIControlStateNormal];
    [cancelPlayAudiosBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelPlayAudiosBtn addTarget:self action:@selector(pauseMixedAudioPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelPlayAudiosBtn];
}

// 删除生成的音频临时文件
- (void)deleteMixedAudioPlay;
{
    if (_resultURL) {
        [_audioPlayer pause];
        [TuSDKTSFileManager deletePath:_resultURL.path];
        _resultURL = nil;
    }
    
    NSLog(@"result path:%@",_resultURL.path);
    [[TuSDK shared].messageHub showToast:NSLocalizedString(@"lsq_api_reset_volume_mix_again", @"请重新调节音量，进行音频混合")];
    for (TuSDKICSeekBar *seekBar in self.view.subviews) {
        if ([seekBar isMemberOfClass:[TuSDKICSeekBar class]]) {
            if (seekBar.tag == 13 || seekBar.tag == 11 || seekBar.tag == 12) {
                [seekBar setProgress:0];
                [self onTuSDKICSeekBar:seekBar changedProgress:0];
            }
        }
    }
    [self playMaterialAudio];
}

// 停止播放原始素材音乐
- (void)pauseMaterialAudioPlay;
{
    [firstBGMPlayer pause];
    [secondBGMPlayer pause];
    [thirdBGMPlayer pause];
}

// 播放原始素材音乐
- (void)playMaterialAudio;
{
    [firstBGMPlayer play];
    [secondBGMPlayer play];
    [thirdBGMPlayer play];
}

// 开始音频混合
- (void)startAudiosMixing;
{
    // 暂停播放素材音乐
    [self pauseMaterialAudioPlay];
    // 开始混合
    _audiomixer.mixAudios = [NSArray arrayWithObjects:firstMixAudio, secondMixAudio,nil];
    playBtn.enabled = NO;
    [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"lsq_api_start_mixing_audio", @"音频开始混合")];
    
    [_audiomixer startMixingAudioWithCompletion:^(NSURL *fileURL, lsqAudioMixStatus status) {
        _resultURL = fileURL;
    }];
}

// 取消录制的方法
- (void)cancelAudiosMixing;
{
    [_audiomixer cancelMixing];
}

- (void)playMixedAudio;
{
    if (_resultURL) {
        [self playTheAudioWithURL:_resultURL];
    }
}

- (void)pauseMixedAudioPlay;
{
    if (_audioPlayer) {
        [_audioPlayer pause];
    }
}

- (void)playTheAudioWithURL:(NSURL *)url;
{
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    if (!url) {
        NSLog(@"AudioURL is invalid.");
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    NSError *playerError = nil;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&playerError];
    if (playerError) {
        NSLog(@"player error : %@",playerError);
        return;
    }
    _audioPlayer.numberOfLoops = 0;
    [_audioPlayer prepareToPlay];
    _audioPlayer.volume = 1;
    [_audioPlayer play];

}

#pragma mark - TuSDKTSAudioMixerDelegate

/**
 状态通知代理

 @param editor editor TuSDKTSAudioMixer
 @param status status lsqAudioMixStatus
 */
- (void)onAudioMix:(TuSDKTSAudioMixer *)editor statusChanged:(lsqAudioMixStatus)status;
{
    if (status == lsqAudioMixStatusCompleted)
    {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_api_status_play_mixed_audio", @"操作完成，请点击「播放」，播放混合好的音频")];
        
        playBtn.enabled = YES;
    }else if (status == lsqAudioMixStatusCancelled)
    {
    
    }else if (status == lsqAudioMixStatusFailed)
    {
    
    }
}

/**
 结果通知代理

 @param editor editor TuSDKTSAudioMixer
 @param result result TuSDKAudioResult
 */
- (void)onAudioMix:(TuSDKTSAudioMixer *)editor result:(TuSDKAudioResult *)result;
{
    if (result.audioPath) {
        NSLog(@"result path : %@",result.audioPath);
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
        firstBGMPlayer.volume = progress;
        mainAudio.audioVolume = progress;
    }else if (seekbar.tag == 12)
    {
        secondBGMPlayer.volume = progress;
        firstMixAudio.audioVolume = progress;
    }else if (seekbar.tag == 13)
    {
        thirdBGMPlayer.volume = progress;
        secondMixAudio.audioVolume = progress;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
