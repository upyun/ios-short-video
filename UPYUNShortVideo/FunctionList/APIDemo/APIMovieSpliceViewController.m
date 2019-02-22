//
//  APIMovieSpliceViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/15.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "APIMovieSpliceViewController.h"
#import "TuSDKFramework.h"
#import "PlayerView.h"

@interface APIMovieSpliceViewController ()<TuSDKAssetVideoComposerDelegate>

@property (nonatomic, strong) NSMutableArray<void (^)(void)> *actionsAfterViewDidLoad;

@property (weak, nonatomic) IBOutlet UILabel *usageLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray<UIButton *> *actionButtons;
@property (weak, nonatomic) IBOutlet PlayerView *firstPlayerView;
@property (weak, nonatomic) IBOutlet PlayerView *secondPlayerView;

// 系统播放器
@property (nonatomic, strong) AVPlayer *firstPlayer;
@property (nonatomic, strong) AVPlayer *secondPlayer;

// 拼接对象
@property (nonatomic, strong) TuSDKAssetVideoComposer *movieComposer;

@end

@implementation APIMovieSpliceViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_firstPlayer) {
        [_firstPlayer cancelPendingPrerolls];
        [_firstPlayer.currentItem cancelPendingSeeks];
        [_firstPlayer.currentItem.asset cancelLoading];
    }
    if (_secondPlayer) {
        [_secondPlayer cancelPendingPrerolls];
        [_secondPlayer.currentItem cancelPendingSeeks];
        [_secondPlayer.currentItem.asset cancelLoading];
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
    
    // 执行 _actionsAfterViewDidLoad 存储的任务
    for (void (^action)(void) in _actionsAfterViewDidLoad) {
        action();
    }
    _actionsAfterViewDidLoad = nil;
    
    // 国际化
    _usageLabel.text = NSLocalizedStringFromTable(@"tu_APIMovieSpliceViewController_usage", @"VideoDemo", @"APIMovieSpliceViewController_usage");
    [_actionButtons[0] setTitle:NSLocalizedStringFromTable(@"tu_视频拼接", @"VideoDemo", @"视频拼接") forState:UIControlStateNormal];
}

/**
 添加在视图加载后的操作
 
 @param action 操作 Block
 */
- (void)addActionAfterViewDidLoad:(void (^)(void))action {
    if (!action) return;
    if (self.viewLoaded) {
        action();
    } else {
        if (!_actionsAfterViewDidLoad) {
            _actionsAfterViewDidLoad = [NSMutableArray array];
        }
        [_actionsAfterViewDidLoad addObject:action];
    }
}

#pragma mark - setup

- (void)setupFirstPlayer {
    // 添加视频资源
    AVPlayerItem *firstPlayerItem = [[AVPlayerItem alloc] initWithURL:_firstInputURL];
    // 播放
    _firstPlayer = [[AVPlayer alloc] initWithPlayerItem:firstPlayerItem];
    _firstPlayer.volume = 0.5;
    // 播放视频需要在AVPlayerLayer上进行显示
    _firstPlayerView.player = _firstPlayer;
    // 循环播放的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSampleOneVideoCycling) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_firstPlayer play];
}

- (void)setupSecondPlayer {
    // 添加视频资源
    AVPlayerItem *secondPlayerItem = [[AVPlayerItem alloc] initWithURL:_secondInputURL];
    // 播放
    _secondPlayer = [[AVPlayer alloc] initWithPlayerItem:secondPlayerItem];
    _secondPlayer.volume = 0.5;
    // 播放视频需要在AVPlayerLayer上进行显示
    _secondPlayerView.player = _secondPlayer;
    // 循环播放的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSampleTwoVideoCycling) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_secondPlayer play];
}

#pragma mark - property

- (void)setFirstInputURL:(NSURL *)firstInputURL {
    _firstInputURL = firstInputURL;
    if (!firstInputURL) {
        [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_无输入视频", @"VideoDemo", @"无输入视频")];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self addActionAfterViewDidLoad:^{
        [weakSelf setupFirstPlayer];
    }];
}

- (void)setSecondInputURL:(NSURL *)secondInputURL {
    _secondInputURL = secondInputURL;
    if (!secondInputURL) {
        [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_无输入视频", @"VideoDemo", @"无输入视频")];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self addActionAfterViewDidLoad:^{
        [weakSelf setupSecondPlayer];
    }];
}

#pragma mark - 后台前台切换
// 进入后台
- (void)enterBackFromFront {
    [self cancelComposing];
}

// 后台到前台
- (void)enterFrontFromBack {
    [[TuSDK shared].messageHub dismiss];
}

#pragma mark - setup

- (void)playSampleOneVideoCycling {
    [_firstPlayer seekToTime:kCMTimeZero];
    [_firstPlayer play];
}

- (void)playSampleTwoVideoCycling {
    [_secondPlayer seekToTime:kCMTimeZero];
    [_secondPlayer play];
}

#pragma mark - 合成

/**
 启动视频合成
 */
- (IBAction)startComposing {
    if (!_movieComposer && _movieComposer.status == TuSDKAssetVideoComposerStatusStarted) return;
    
    [_firstPlayer pause];
    [_secondPlayer pause];
    
    if (!_movieComposer) {
        _movieComposer = [[TuSDKAssetVideoComposer alloc] initWithAsset:nil];
        _movieComposer.delegate = self;
        // 指定输出文件格式
        _movieComposer.outputFileType = lsqFileTypeMPEG4;
        // 指定输出文件的码率
        _movieComposer.outputVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Low1];
        // 指定输出文件的尺寸，设定后会根据输出尺寸对原视频进行裁剪
        // _movieComposer.outputSize = CGSizeMake(720, 1280);
        
        // 添加待拼接的视频源
        [_movieComposer addInputAsset:[AVAsset assetWithURL:_firstInputURL]];
        
        // 添加待拼接的视频源
        [_movieComposer addInputAsset:[AVAsset assetWithURL:_secondInputURL]];
        
        // 移除已添加的视频源
        // [_movieComposer removeInputAsset:(AVAsset * _Nonnull)];
    }
    
    [_movieComposer startComposing];
}

/**
 取消视频合成
 */
- (void)cancelComposing {
    if (_movieComposer)
        [_movieComposer cancelComposing];
    
    _movieComposer = nil;
}

#pragma mark - TuSDKAssetVideoComposerDelegate

/**
 合成状态改变事件
 
 @param composer TuSDKAssetVideoComposer
 @param status lsqAssetVideoComposerStatus 当前状态
 */
-(void)assetVideoComposer:(TuSDKAssetVideoComposer *)composer statusChanged:(TuSDKAssetVideoComposerStatus)status {
    switch (status) {
        case TuSDKAssetVideoComposerStatusStarted:
            break;
        case TuSDKAssetVideoComposerStatusCompleted:
            [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_操作完成，请前往相册查看视频", @"VideoDemo", @"操作完成，请前往相册查看视频")];
            break;
        case TuSDKAssetVideoComposerStatusFailed:
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_操作失败，无法生成视频文件", @"VideoDemo", @"操作失败，无法生成视频文件")];
            break;
        case TuSDKAssetVideoComposerStatusCancelled:
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_出现问题，操作被取消", @"VideoDemo", @"出现问题，操作被取消")];
            break;
        default:
            break;
    }
}

/**
 合成进度事件
 
 @param composer TuSDKAssetVideoComposer
 @param progress 处理进度
 @param index 当前正在处理的视频索引
 */
-(void)assetVideoComposer:(TuSDKAssetVideoComposer *)composer processChanged:(float)progress assetIndex:(NSUInteger)index {
    NSLog(@"progress : %f", progress);
    [[TuSDK shared].messageHub showProgress:progress status:NSLocalizedStringFromTable(@"tu_正在拼接...", @"VideoDemo", @"正在拼接...")];
}

/**
 视频合成完毕
 
 @param composer TuSDKAssetVideoComposer
 @param result TuSDKVideoResult
 */
-(void)assetVideoComposer:(TuSDKAssetVideoComposer *)composer saveResult:(TuSDKVideoResult *)result {
    // 视频处理结果
    NSLog(@"result path: %@ ", result.videoPath);
}

@end
