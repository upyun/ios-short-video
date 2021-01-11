//
//  APIAudioRecordViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/15.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "APIAudioRecordViewController.h"
#import "TuSDKFramework.h"

@interface APIAudioRecordViewController ()<TuSDKTSAudioRecoderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usageLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *actionButtons;

/**
 录音对象
 */
@property (nonatomic, strong) TuSDKTSAudioRecorder *audioRecorder;

/**
 播放对象
 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

/**
 录制结果路径
 */
@property (nonatomic, copy) NSString *resultPath;

@end

@implementation APIAudioRecordViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 国际化
    _usageLabel.text = NSLocalizedStringFromTable(@"tu_APIAudioRecordViewController_usage", @"VideoDemo", @"APIAudioRecordViewController_usage");
    [_actionButtons[0] setTitle:NSLocalizedStringFromTable(@"tu_开始录音", @"VideoDemo", @"开始录音") forState:UIControlStateNormal];
    [_actionButtons[1] setTitle:NSLocalizedStringFromTable(@"tu_结束录音", @"VideoDemo", @"结束录音") forState:UIControlStateNormal];
    [_actionButtons[2] setTitle:NSLocalizedStringFromTable(@"tu_播放录音", @"VideoDemo", @"播放录音") forState:UIControlStateNormal];
}

#pragma mark - 后台切换操作

/**
 进入后台
 */
- (void)enterBackFromFront {
    if (_audioPlayer.isPlaying) {
        [_audioPlayer pause];
    }
    
    if (_audioRecorder.status == lsqAudioRecordingStatusRecording) {
        [_audioRecorder  cancelRecording];
    }
}

/**
 后台到前台
 */
- (void)enterFrontFromBack {
    
   if (_audioPlayer.isPlaying) {
       [_audioPlayer pause];
   }
}

#pragma mark - 录音

- (IBAction)startRecordingAudio {
    // recorder start
    if (!_audioRecorder) {
        _audioRecorder = [[TuSDKTSAudioRecorder alloc] init];
        _audioRecorder.maxRecordingTime = 30;
        _audioRecorder.recordDelegate = self;
    }
    NSLog(@"start recording");
    [_audioRecorder startRecording];
    [[TuSDK shared].messageHub showToast:NSLocalizedStringFromTable(@"tu_录音已经开始", @"VideoDemo", @"录音已经开始")];
}

- (void)pauseRecordingAudio {
    // recorder pause
    NSLog(@"pause recording");
    [_audioRecorder pauseRecording];
}

- (IBAction)finishRecordingAudio {
    // recorder finish
    NSLog(@"finish recording");
    [_audioRecorder finishRecording];
}

- (void)cancelRecordingAudio {
    // recorder cancel
    NSLog(@"cancel recording");
    [_audioRecorder cancelRecording];
}

- (IBAction)playResultAudio {
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
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_resultPath] error:&playerError];
    if (playerError) {
        NSLog(@"player error : %@", playerError);
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
- (void)onAudioRecoder:(TuSDKTSAudioRecorder *)recoder statusChanged:(lsqAudioRecordingStatus)status {
    NSLog(@"changeStatus  :  %ld",(long)status);
    if (status == lsqAudioRecordingStatusCompleted) {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_录音已经完成，请播放录音", @"VideoDemo", @"录音已经完成，请播放录音")];
    } else if (status == lsqAudioRecordingStatusFailed) {
        [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_录制失败，请重新录制", @"VideoDemo", @"录制失败，请重新录制")];
    } else if (status == lsqAudioRecordingStatusCancelled) {
        [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_录制已经取消", @"VideoDemo", @"录制已经取消")];
    }
}

/**
 结果通知代理
 
 @param recoder recoder TuSDKTSAudioRecorder
 @param result result TuSDKAudioResult
 */
- (void)onAudioRecoder:(TuSDKTSAudioRecorder *)recoder result:(TuSDKAudioResult *)result {
    NSLog(@"result   path: %@   duration : %f", result.audioPath, result.duration);
    if (result.audioPath) {
        _resultPath = result.audioPath;
    }
}

/**
 录音出现中断
 
 @param recoder recoder TuSDKTSAudioRecorder
 */
- (void)onAudioRecoderBeginInterruption:(TuSDKTSAudioRecorder *)recoder {
    // 有中断时会取消录制内容 可在此做一些其他操作 如来电中断
    NSLog(@"interruption start");
}

/**
 录音中断结束
 
 @param recoder recoder TuSDKTSAudioRecorder
 */
- (void)onAudioRecoderEndInterruption:(TuSDKTSAudioRecorder *)recoder {
    // 中断结束后，可进行恢复操作
    NSLog(@"interruption end");
}

@end
