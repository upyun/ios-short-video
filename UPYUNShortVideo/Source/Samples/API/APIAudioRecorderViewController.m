//
//  APIAudioRecorderViewController.m
//  TuSDKVideoDemo
//
//  Created by wen on 27/06/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "TuSDKFramework.h"

#import "APIAudioRecorderViewController.h"
#import "TopNavBar.h"

@interface APIAudioRecorderViewController ()<TopNavBarDelegate, TuSDKTSAudioRecoderDelegate>{

    // 编辑页面顶部控制栏视图
    TopNavBar *_topBar;
    // 录制结果路径
    NSString *_resultPath;
    // 录音对象
    TuSDKTSAudioRecorder *_audioRecorder;
    // 播放对象
    AVAudioPlayer *_audioPlayer;
    UILabel * explainationLabel;
}

@end

@implementation APIAudioRecorderViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lsqClorWithHex:@"#F3F3F3"];
    // 顶部栏初始化
    [self initWithTopBar];
    // 界面布局
    [self layoutView];
    // 顶部说明 label
    [self initWithExplainationLabel];
}

- (void)initWithExplainationLabel;
{
    explainationLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, _topBar.lsqGetSizeHeight, self.view.lsqGetSizeWidth, _topBar.lsqGetSizeHeight*1.5)];
    explainationLabel.backgroundColor = lsqRGB(236, 236, 236);
    explainationLabel.textColor = [UIColor blackColor];
    explainationLabel.text = NSLocalizedString(@"lsq_api_audio_record_explaination",@"请点击「开始录音」按钮开始录制音频，录制完成后点击「结束录音」生成可播放的音频文件，点击「播放录音」播放刚才录制的音频");
    explainationLabel.numberOfLines = 0;
    explainationLabel.textAlignment = NSTextAlignmentCenter;
    explainationLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:explainationLabel];
}

// 界面布局
- (void)layoutView;
{
    CGFloat btnCenterX = self.view.bounds.size.width/2;
    CGFloat sideGapDistance = 50;
    UIButton *startBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    startBtn.center = CGPointMake(btnCenterX, _topBar.lsqGetSizeHeight*3.5);
    startBtn.backgroundColor = lsqRGB(252, 143, 96);
    startBtn.layer.cornerRadius = 3;
    [startBtn setTitle:NSLocalizedString(@"lsq_api_usage_start_recording",@"开始录音") forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startRecordingAudio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    
    UIButton *finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    finishBtn.center = CGPointMake(btnCenterX, _topBar.lsqGetSizeHeight*5.5);
    finishBtn.backgroundColor = lsqRGB(252, 143, 96);
    finishBtn.layer.cornerRadius = 3;
    [finishBtn setTitle:NSLocalizedString(@"lsq_api_usage_finish_recording",@"结束录音") forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishRecordingAudio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    
    
    UIButton *playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    playBtn.center = CGPointMake(btnCenterX, _topBar.lsqGetSizeHeight*7.5);
    playBtn.backgroundColor = lsqRGB(252, 143, 96);
    playBtn.layer.cornerRadius = 3;
    [playBtn setTitle:NSLocalizedString(@"lsq_api_usage_play_result_audio",@"播放录音") forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playResultAudio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
}

// 顶部栏初始化
- (void)initWithTopBar;
{
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [_topBar setBackgroundColor:[UIColor whiteColor]];
    _topBar.topBarDelegate = self;
    [_topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_api_usage_record_audio", @"录制音频")
                     leftButtonInfo:@[[NSString stringWithFormat:@"video_style_default_btn_back.png+%@",NSLocalizedString(@"lsq_go_back", @"返回")]]
                    rightButtonInfo:nil];
    [_topBar.centerTitleLabel lsqSetSizeWidth:_topBar.lsqGetSizeWidth/2];
    _topBar.centerTitleLabel.center = CGPointMake(self.view.lsqGetSizeWidth/2, _topBar.lsqGetSizeHeight/2);
    [self.view addSubview:_topBar];
}

- (void)startRecordingAudio;
{
    // recorder start
    if (!_audioRecorder) {
        _audioRecorder = [[TuSDKTSAudioRecorder alloc]init];
        _audioRecorder.maxRecordingTime = 30;
        _audioRecorder.recordDelegate = self;
    }
    NSLog(@"start recording");
    [_audioRecorder startRecording];
    [[TuSDK shared].messageHub showToast:NSLocalizedString(@"lsq_record_audio_started",@"录音已经开始")];
}

- (void)pauseRecordingAudio;
{
    // recorder pause
    NSLog(@"pause recording");
    [_audioRecorder pauseRecording];
}

- (void)finishRecordingAudio;
{
    // recorder finish
    NSLog(@"finish recording");
    [_audioRecorder finishRecording];
}

- (void)cancelRecordingAudio;
{
    // recorder cancel
    NSLog(@"cancel recording");
    [_audioRecorder cancelRecording];
}


- (void)playResultAudio;
{
    if (!_resultPath) {
        NSLog(@"AudioURL is invalid.");
        return;
    }
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    NSError *playerError = nil;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:_resultPath] error:&playerError];
    if (playerError) {
        NSLog(@"player error : %@",playerError);
        return;
    }
    _audioPlayer.numberOfLoops = 0;
    [_audioPlayer prepareToPlay];
    _audioPlayer.volume = 1;
    [_audioPlayer play];
    
}

#pragma mark - TuSDKTSAudioRecoderDelegate

/**
 状态通知代理

 @param recoder recoder TuSDKTSAudioRecorder
 @param status status lsqAudioRecordingStatus
 */
- (void)onAudioRecoder:(TuSDKTSAudioRecorder *)recoder statusChanged:(lsqAudioRecordingStatus)status;
{
    NSLog(@"changeStatus  :  %ld",status);
    if (status == lsqAudioRecordingStatusCompleted)
    {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_record_audio_finished",@"录音已经完成，请播放录音")];
    }else if (status == lsqAudioRecordingStatusFailed)
    {
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_audio_failed",@"录制失败，请重新录制")];
    }else if(status == lsqAudioRecordingStatusCancelled)
    {
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_audio_cancelled",@"录制已经取消")];
    }
}

/**
 结果通知代理

 @param recoder recoder TuSDKTSAudioRecorder
 @param result result TuSDKAudioResult
 */
- (void)onAudioRecoder:(TuSDKTSAudioRecorder *)recoder result:(TuSDKAudioResult *)result;
{
    NSLog(@"result   path: %@   duration : %f",result.audioPath,result.duration);
    if (result.audioPath) {
        _resultPath = result.audioPath;
    }
}

/**
 录音出现中断

 @param recoder recoder TuSDKTSAudioRecorder
 */
- (void)onAudioRecoderBeginInterruption:(TuSDKTSAudioRecorder *)recoder;
{
    // 有中断时会取消录制内容 可在此做一些其他操作 如来电中断

    NSLog(@"interruption start");
}


/**
 录音中断结束

 @param recoder recoder TuSDKTSAudioRecorder
 */
- (void)onAudioRecoderEndInterruption:(TuSDKTSAudioRecorder *)recoder;
{
    // 中断结束后，可进行恢复操作

    NSLog(@"interruption end");
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

@end
