//
//  APIAudioPitchEngineViewController.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2018/11/28.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "APIAudioPitchEngineViewController.h"
#import "APIAudioPitchEngineRecorder.h"
#import "PitchSegmentButton.h"
#import "TuSDKFramework.h"

@interface APIAudioPitchEngineViewController ()<APIAudioPitchEngineRecorderDelegate>
{
    // APIAudioPitchEngineRecorder 用以演示音频采集和音频变声处理 API
    APIAudioPitchEngineRecorder *_audioPitchRecoder;
    
    // AVPlayer 用以演示音频播放
    AVPlayer *_audioPlayer;
}
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *actionButtons;
@property (weak, nonatomic) IBOutlet UILabel *usageLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAudioRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopAudioRecordBtn;

@end

@implementation APIAudioPitchEngineViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // AVPlayer 用以演示音频播放
    _audioPlayer = [[AVPlayer alloc] init];
    
    // APIAudioPitchEngineRecorder 用以演示音频采集和音频变声处理 API
    _audioPitchRecoder = [[APIAudioPitchEngineRecorder alloc] init];
    _audioPitchRecoder.delegate = self;
    
    // 国际化
    _usageLabel.text = NSLocalizedStringFromTable(@"tu_APIAudioPitchEngineViewController_usage", @"VideoDemo", @"APIAudioPitchEngineViewController_usage");
    [_actionButtons[0] setTitle:NSLocalizedStringFromTable(@"tu_开始录音", @"VideoDemo", @"开始录音") forState:UIControlStateNormal];
    [_actionButtons[1] setTitle:NSLocalizedStringFromTable(@"tu_结束并播放录音", @"VideoDemo", @"结束并播放录音") forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [_audioPlayer pause];
    [_audioPitchRecoder cancelRecord];
    
    [super viewWillDisappear:animated];
}
#pragma mark - 后台切换操作

/**
 进入后台
 */
- (void)enterBackFromFront {
    if (_audioPlayer.rate != 0) {
        [_audioPlayer pause];
    }
    
    if (_audioPitchRecoder.isRecording) {
        [_audioPitchRecoder cancelRecord];
    }
}

/**
 后台到前台
 */
- (void)enterFrontFromBack {
    
   if (_audioPlayer.rate == 0) {
       [_audioPlayer play];
       
       _startAudioRecordBtn.enabled = YES;
       _stopAudioRecordBtn.enabled = YES;
   }
}
/**
 启动音频采集及音频变声处理
 */
- (IBAction)startRecordingAudio;
{
    [_audioPlayer pause];
    
    _startAudioRecordBtn.enabled = NO;
    _stopAudioRecordBtn.enabled = YES;
    
    [_audioPitchRecoder startRecord];
    [[TuSDK shared].messageHub showToast:NSLocalizedStringFromTable(@"tu_录音已经开始", @"VideoDemo", @"录音已经开始")];
}

/**
 停止音频采集并播放音效
 */
- (IBAction)finishRecordingAudio;
{
    /** - (void)mediaAssetAudioRecorder:(APIAudioPitchEngineRecorder *)mediaAssetAudioRecorder filePath:(NSString *)filePath */
    if (_audioPitchRecoder.isRecording) {
        
        [_audioPitchRecoder stopRecord];
        
        _startAudioRecordBtn.enabled = YES;
        _stopAudioRecordBtn.enabled = NO;
    }
}


#pragma mark - action

/**
 变声分段按钮点击事件
 */
- (IBAction)pitchSegmentButtonAction:(PitchSegmentButton *)sender {
    _audioPitchRecoder.pitchType = sender.pitchType;
}

#pragma mark APIAudioPitchEngineRecorderDelegate

/**
 录制完成
 @param mediaAssetAudioRecorder 录制对象
 @param filePath 录制结果
 @since v3.0
 */
- (void)mediaAssetAudioRecorder:(APIAudioPitchEngineRecorder *)mediaAssetAudioRecorder filePath:(NSString *)filePath;
{
    [_audioPlayer pause];
    _audioPlayer =  [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    [_audioPlayer play];
}

@end
