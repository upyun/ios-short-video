//
//  APIMovieMixViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/15.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "APIMovieMixViewController.h"
#import "TuSDKFramework.h"
#import "PlayerView.h"

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

@interface APIMovieMixViewController ()<TuSDKTSMovieMixerDelegate>

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *audioTitleLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray<UIButton *> *actionButtons;
@property (strong, nonatomic) IBOutletCollection(UISlider) NSArray *volumeSliders;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *volumeLabels;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;

/**
 音乐播放器
 */
@property (nonatomic, strong) AVAudioPlayer *firstMixAudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *secondMixAudioPlayer;

/**
 素材一
 */
@property (nonatomic, strong) TuSDKTSAudio *firstMixAudio;

/**
 素材二
 */
@property (nonatomic, strong) TuSDKTSAudio *secondMixAudio;

/**
 视频混合器
 */
@property (nonatomic, strong) TuSDKTSMovieMixer *movieMixer;

/**
 系统播放器
 */
@property (strong, nonatomic) AVPlayer *player;

@end

@implementation APIMovieMixViewController

- (void)dealloc {
    if (_player) {
        [_player cancelPendingPrerolls];
        [_player.currentItem cancelPendingSeeks];
        [_player.currentItem.asset cancelLoading];
    }
}

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
    [self setupVideoPlayer];
    [self setupAudioPlayer];
    [self setupMovieMixer];
}

- (NSURL *)fileURLWithName:(NSString *)fileName {
    return [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
}

- (UIImage *)drawCircleImageWithSize:(CGSize)size color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 后台切换操作

/**
 进入后台
 */
- (void)enterBackFromFront {
    if (_firstMixAudioPlayer.isPlaying) {
        [_firstMixAudioPlayer pause];
    }
    if (_secondMixAudioPlayer.isPlaying) {
        [_secondMixAudioPlayer pause];
    }
    if (_player.rate != 0) {
        [_player pause];
    }
    if (_movieMixer.status == lsqMovieMixStatusMixing) {
        [_movieMixer cancelMixing];
    }
}

/**
 后台到前台
 */
- (void)enterFrontFromBack {
     if (!_firstMixAudioPlayer.isPlaying) {
         [_firstMixAudioPlayer play];
     }
     if (!_secondMixAudioPlayer.isPlaying) {
         [_secondMixAudioPlayer play];
     }
     if (_player.rate == 0) {
         [_player play];
     }
}

#pragma mark - setup

- (void)setupUI {
    UIImage *thumbImage = [self drawCircleImageWithSize:CGSizeMake(18, 18) color:[UIColor whiteColor]];
    for (UISlider *slider in self.volumeSliders) {
        [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    }
    
    // 国际化
    _audioTitleLabels[0].text = NSLocalizedStringFromTable(@"tu_原音", @"VideoDemo", @"原音");
    _audioTitleLabels[1].text = NSLocalizedStringFromTable(@"tu_素材一", @"VideoDemo", @"素材一");
    _audioTitleLabels[2].text = NSLocalizedStringFromTable(@"tu_素材二", @"VideoDemo", @"素材二");
    [_actionButtons[0] setTitle:NSLocalizedStringFromTable(@"tu_合成视频", @"VideoDemo", @"合成视频") forState:UIControlStateNormal];
}

- (void)setupMovieMixer {
    NSURL *firstAudioURL = [self fileURLWithName:@"sound_cat.mp3"];
    AVURLAsset *firstMixAudioAsset = [AVURLAsset URLAssetWithURL:firstAudioURL options:nil];
    _firstMixAudio = [[TuSDKTSAudio alloc] initWithAsset:firstMixAudioAsset];
    _firstMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:1 endSeconds:6];
    
    NSURL *secondAudioURL = [self fileURLWithName:@"sound_children.mp3"];
    _secondMixAudio = [[TuSDKTSAudio alloc] initWithAudioURL:secondAudioURL];
    _secondMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:1 endSeconds:6];
    
    // 初始化音视频混合器对象
    NSURL *videoURL = [self fileURLWithName:@"tusdk_sample_video.mov"];
    _movieMixer = [[TuSDKTSMovieMixer alloc] initWithMoviePath:videoURL.path];
    _movieMixer.mixDelegate = self;
    _movieMixer.outputFileType = lsqFileTypeMPEG4;
    NSString *path = [TuSDKTSFileManager createDir:[TuSDKTSFileManager pathInCacheWithDirPath:lsqTempDir filePath:@""]];
    path = [NSString stringWithFormat:@"%@-22222-%f.mp4", path, [[NSDate date]timeIntervalSince1970]];
    NSLog(@"path: %@", path);
//    _movieMixer.outputFilePath = path;
    // 是否允许音频循环 默认 NO
    _movieMixer.enableCycleAdd = YES;
    // 是否保留视频原音
    _movieMixer.enableVideoSound = YES;
}

- (void)setupAudioPlayer {
    _firstMixAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self fileURLWithName:@"sound_cat.mp3"] error:nil];
    _firstMixAudioPlayer.numberOfLoops = -1;//循环播放
    _firstMixAudioPlayer.volume = 0.5;
    [_firstMixAudioPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [_firstMixAudioPlayer play];
    
    _secondMixAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self fileURLWithName:@"sound_children.mp3"] error:nil];
    _secondMixAudioPlayer.numberOfLoops = -1;//循环播放
    _secondMixAudioPlayer.volume = 0.5;
    [_secondMixAudioPlayer prepareToPlay];//预先加载音频到内存，播放更流畅
    [_secondMixAudioPlayer play];
}

- (void)setupVideoPlayer {
    _playerView.backgroundColor = [UIColor clearColor];
    // 添加视频资源
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[self fileURLWithName:@"tusdk_sample_video.mov"]];
    // 播放
    _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    _player.volume = 0.5;
    // 播放视频需要在AVPlayerLayer上进行显示
    _playerView.player = _player;
    // 循环播放的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoCycling) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_player play];
}

- (void)playVideoCycling {
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

#pragma mark - action

/**
 开始混合
 */
- (IBAction)mixVideoAndAudio {
    [[TuSDK shared].messageHub setStatus:NSLocalizedStringFromTable(@"tu_开始合成...", @"VideoDemo", @"开始合成...")];
    // 混合的音频
    _movieMixer.mixAudios = @[_firstMixAudio, _secondMixAudio];
    // 开始混合
    [_movieMixer startMovieMixWithCompletionHandler:^(NSString *filePath, CGFloat progress, lsqMovieMixStatus status) {
        if (status == lsqMovieMixStatusCompleted) {
            // 操作成功 保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
        } else if (status != lsqMovieMixStatusMixing) {
            // 提示失败
            NSLog(@"保存失败");
        }
    }];
}

/**
 取消混合
 */
- (IBAction)cancelMovieMixer {
    if (_movieMixer) {
        [_movieMixer cancelMixing];
    }
}

- (IBAction)volumeSliderAction:(UISlider *)sender {
    AudioIndex index = [self.volumeSliders indexOfObject:sender];
    CGFloat volume = sender.value;
    
    // 更新 UI
    NSString *progressText = [NSNumberFormatter localizedStringFromNumber:@(volume) numberStyle:NSNumberFormatterPercentStyle];
    UILabel *volumeLabel = self.volumeLabels[index];
    volumeLabel.text = progressText;
    
    switch (index) {
        case AudioMain:{
            _player.volume = volume;
            _movieMixer.videoSoundVolume = volume;
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

#pragma mark - TuSDKTSMovieMixerDelegate
/**
 状态通知代理
 
 @param editor editor TuSDKTSMovieMixer
 @param status status lsqMovieMixStatus
 */
- (void)onMovieMixer:(TuSDKTSMovieMixer *)editor statusChanged:(lsqMovieMixStatus)status {
    NSLog(@"TuSDKTSMovieMixer 的目前的状态是 ： %ld",(long)status);
    if (status == lsqMovieMixStatusCompleted) {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_操作完成，请前往相册查看视频", @"VideoDemo", @"操作完成，请前往相册查看视频")];
    } else if (status == lsqMovieMixStatusFailed) {
        [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_操作失败，无法生成视频文件", @"VideoDemo", @"操作失败，无法生成视频文件")];
    } else if (status == lsqMovieMixStatusCancelled) {
        [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_出现问题，操作被取消", @"VideoDemo", @"出现问题，操作被取消")];
    }
}

/**
 结果通知代理
 
 @param editor editor TuSDKTSMovieMixer
 @param result result TuSDKVideoResult
 */
- (void)onMovieMixer:(TuSDKTSMovieMixer *)editor result:(TuSDKVideoResult *)result {
    NSLog(@"保存结果的临时文件路径 : %@", result.videoPath);
}

@end
