//
//  APIAudioMixViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/15.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "APIAudioMixViewController.h"
#import "TuSDKFramework.h"

/**
 音频索引
 */
typedef NS_ENUM(NSInteger, AudioIndex) {
    // 原音
    AudioMain = 0,
    // 素材一
    Audio1,
    // 素材二
    Audio2
};

@interface APIAudioMixViewController ()<TuSDKTSAudioMixerDelegate>

@property (strong, nonatomic) IBOutletCollection(UISlider) NSArray *volumeSliders;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *volumeLabels;
@property (weak, nonatomic) IBOutlet UILabel *usageLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *audioTitleLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray<UIButton *> *actionButtons;

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;

/**
 音频混合对象
 */
@property (nonatomic, strong) TuSDKTSAudioMixer *audioMixer;

/**
 混合结果 url
 */
@property (nonatomic, strong) NSURL *resultURL;

/**
 播放对象
 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

/**
 原音播放器
 */
@property (nonatomic, strong) AVAudioPlayer *mainAudioPlayer;

/**
 素材一播放器
 */
@property (nonatomic, strong) AVAudioPlayer *firstMixAudioPlayer;

/**
 素材二播放器
 */
@property (nonatomic, strong) AVAudioPlayer *secondMixAudioPlayer;

/**
 原始音乐素材
 */
@property (nonatomic, strong) TuSDKTSAudio *mainAudio;

/**
 混音素材1
 */
@property (nonatomic, strong) TuSDKTSAudio *firstMixAudio;

/**
 混音素材2
 */
@property (nonatomic, strong) TuSDKTSAudio *secondMixAudio;

@end

@implementation APIAudioMixViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self setupUI];
    [self setupAudioPlayer];
    [self setupAudioMixer];
}
#pragma mark - 后台切换操作

/**
 进入后台
 */
- (void)enterBackFromFront {
    if (_resultURL) {
        [_audioPlayer pause];
    }else{
        [self pauseMaterialAudioPlay];
    }
    
    if (_audioMixer.status == lsqAudioMixStatusMixing) {
        [_audioMixer  cancelMixing];
    }
}

/**
 后台到前台
 */
- (void)enterFrontFromBack {
    if (_resultURL) {
          [_audioPlayer play];
      }else{
          [self playMaterialAudio];
      }
}

#pragma mark - setup

- (void)setupUI {
    // 国际化
    _usageLabel.text = NSLocalizedStringFromTable(@"tu_APIAudioMixViewController_usage", @"VideoDemo", @"APIAudioMixViewController_usage");
    _audioTitleLabels[0].text = NSLocalizedStringFromTable(@"tu_原音", @"VideoDemo", @"原音");
    _audioTitleLabels[1].text = NSLocalizedStringFromTable(@"tu_素材一", @"VideoDemo", @"素材一");
    _audioTitleLabels[2].text = NSLocalizedStringFromTable(@"tu_素材二", @"VideoDemo", @"素材二");
    [_actionButtons[0] setTitle:NSLocalizedStringFromTable(@"tu_开始音频混合", @"VideoDemo", @"开始音频混合") forState:UIControlStateNormal];
    [_actionButtons[1] setTitle:NSLocalizedStringFromTable(@"tu_删除混合音频", @"VideoDemo", @"删除混合音频") forState:UIControlStateNormal];
    [_actionButtons[2] setTitle:NSLocalizedStringFromTable(@"tu_播放音频", @"VideoDemo", @"播放音频") forState:UIControlStateNormal];
    [_actionButtons[3] setTitle:NSLocalizedStringFromTable(@"tu_暂停音频", @"VideoDemo", @"暂停音频") forState:UIControlStateNormal];
}

- (void)setupAudioMixer {
    // 原音
    NSURL *mainAudioURL = [self fileURLWithName:@"sound_cat.mp3"];
    _mainAudio = [[TuSDKTSAudio alloc] initWithAudioURL:mainAudioURL];
    _mainAudio.audioVolume = 0;
    _mainAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:6];
    
    // 素材一
    NSURL *firstMixAudioURL = [self fileURLWithName:@"sound_children.mp3"];
    _firstMixAudio = [[TuSDKTSAudio alloc] initWithAudioURL:firstMixAudioURL];
    _firstMixAudio.audioVolume = 0;
    _firstMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:3];
    
    // 素材二
    NSURL *secondMixAudioURL = [self fileURLWithName:@"sound_tangyuan.mp3"];
    _secondMixAudio = [[TuSDKTSAudio alloc] initWithAudioURL:secondMixAudioURL];
    _secondMixAudio.audioVolume = 0;
    _secondMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:3];
    
    // 创建混音
    _audioMixer = [[TuSDKTSAudioMixer alloc] init];
    _audioMixer.mixDelegate = self;
    // 设置主音轨
    _audioMixer.mainAudio = _mainAudio;
    // 是否允许音频循环 默认 NO
    _audioMixer.enableCycleAdd = YES;
}

- (void)setupAudioPlayer {
    // 创建seekBar
    _mainAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self fileURLWithName:@"sound_cat.mp3"] error:nil];
    _mainAudioPlayer.numberOfLoops = -1;//循环播放
    _mainAudioPlayer.volume = 0;
    [_mainAudioPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [_mainAudioPlayer play];

    _firstMixAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self fileURLWithName:@"sound_children.mp3"] error:nil];
    _firstMixAudioPlayer.numberOfLoops = -1;//循环播放
    _firstMixAudioPlayer.volume = 0;
    [_firstMixAudioPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [_firstMixAudioPlayer play];

    _secondMixAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self fileURLWithName:@"sound_tangyuan.mp3"] error:nil];
    _secondMixAudioPlayer.numberOfLoops = -1;//循环播放
    _secondMixAudioPlayer.volume = 0;
    [_secondMixAudioPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [_secondMixAudioPlayer play];
}

- (NSURL *)fileURLWithName:(NSString *)fileName {
    return [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
}

#pragma mark -

// 停止播放原始素材音乐
- (void)pauseMaterialAudioPlay {
    [_mainAudioPlayer pause];
    [_firstMixAudioPlayer pause];
    [_secondMixAudioPlayer pause];
}

// 播放原始素材音乐
- (void)playMaterialAudio {
    [_mainAudioPlayer play];
    [_firstMixAudioPlayer play];
    [_secondMixAudioPlayer play];
}

// 取消录制的方法
- (void)cancelAudiosMixing {
    [_audioMixer cancelMixing];
}

- (void)playTheAudioWithURL:(NSURL *)URL {
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    if (!URL) {
        NSLog(@"AudioURL is invalid.");
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    NSError *playerError = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:&playerError];
    if (playerError) {
        NSLog(@"player error : %@", playerError);
        return;
    }
    _audioPlayer.numberOfLoops = 0;
    [_audioPlayer prepareToPlay];
    _audioPlayer.volume = 1;
    [_audioPlayer play];
}

#pragma mark - Action

/// 开始音频混合
- (IBAction)startAudiosMixing {
    // 暂停播放素材音乐
    [self pauseMaterialAudioPlay];
    // 开始混合
    _audioMixer.mixAudios = @[_firstMixAudio, _secondMixAudio];
    // TODO: 禁用播放按钮
    //playBtn.enabled = NO;
    [[TuSDK shared].messageHub setStatus:NSLocalizedStringFromTable(@"tu_音频开始混合", @"VideoDemo", @"音频开始混合")];
    
    __weak typeof(self) weakSelf = self;
    [_audioMixer startMixingAudioWithCompletion:^(NSURL *fileURL, lsqAudioMixStatus status) {
        weakSelf.resultURL = fileURL;
    }];
}

/// 删除生成的音频临时文件
- (IBAction)deleteMixedAudioAndPlay {
    if (_resultURL) {
        [_audioPlayer pause];
        [TuSDKTSFileManager deletePath:_resultURL.path];
        _resultURL = nil;
    }
    
    NSLog(@"result path:%@", _resultURL.path);
    [[TuSDK shared].messageHub showToast:NSLocalizedStringFromTable(@"tu_请重新调节音量，进行音频混合", @"VideoDemo", @"请重新调节音量，进行音频混合")];
    
    // 更新 UI
    for (int i = 0; i < self.volumeSliders.count; i++) {
        UISlider *slider = self.volumeSliders[i];
        slider.value = 0;
        UILabel *label = self.volumeLabels[i];
        label.text = @"0%";
        [self volumeSliderAction:self.volumeSliders[i]];
    }
    
    // 播放原音
    [self playMaterialAudio];
}

/// 播放混音
- (IBAction)playMixedAudio {
    if (_resultURL) {
        [self playTheAudioWithURL:_resultURL];
    }
}

/// 暂停 audioPlayer
- (IBAction)pauseMixedAudioPlay {
    if (_audioPlayer) {
        [_audioPlayer pause];
    }
}

- (IBAction)volumeSliderAction:(UISlider *)sender {
    AudioIndex index = [self.volumeSliders indexOfObject:sender];
    CGFloat volume = sender.value;
    
    // 更新 UI
    NSString *progressText = [NSNumberFormatter localizedStringFromNumber:@(volume) numberStyle:NSNumberFormatterPercentStyle];
    UILabel *label = self.volumeLabels[index];
    label.text = progressText;
    
    switch (index) {
        case AudioMain:{
            _mainAudioPlayer.volume = volume;
            _mainAudio.audioVolume = volume;
        } break;
        case Audio1:{
            _firstMixAudioPlayer.volume = volume;
            _firstMixAudio.audioVolume = volume;
        } break;
        case Audio2:{
            _secondMixAudioPlayer.volume = volume;
            _secondMixAudio.audioVolume = volume;
        } break;
    }
}

#pragma mark - TuSDKTSAudioMixerDelegate

/**
 状态通知代理
 
 @param editor editor TuSDKTSAudioMixer
 @param status status lsqAudioMixStatus
 */
- (void)onAudioMix:(TuSDKTSAudioMixer *)editor statusChanged:(lsqAudioMixStatus)status {
    if (status == lsqAudioMixStatusCompleted) {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_操作完成，请点击「播放」，播放混合好的音频", @"VideoDemo", @"操作完成，请点击「播放」，播放混合好的音频")];
        
        // TODO: 启用播放按钮
        //playBtn.enabled = YES;
    } else if (status == lsqAudioMixStatusCancelled) {
        
    } else if (status == lsqAudioMixStatusFailed) {
        
    }
}

/**
 结果通知代理
 
 @param editor editor TuSDKTSAudioMixer
 @param result result TuSDKAudioResult
 */
- (void)onAudioMix:(TuSDKTSAudioMixer *)editor result:(TuSDKAudioResult *)result {
    if (result.audioPath) {
        NSLog(@"result path : %@", result.audioPath);
        _resultURL = [NSURL URLWithString:result.audioPath];
    }
}

@end
