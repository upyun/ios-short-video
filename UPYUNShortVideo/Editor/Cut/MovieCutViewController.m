//
//  MovieCutViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MovieCutViewController.h"
#import "TuSDKFramework.h"

#import "SegmentButton.h"
#import "VideoTrimmerView.h"
#import "PlayerView.h"
#import "RulerView.h"
#import "TrimmerMaskView.h"

// 最小剪裁时长
static const NSTimeInterval kMinCutDuration = 3.0;

@interface MovieCutViewController ()<VideoTrimmerViewDelegate, UIGestureRecognizerDelegate, TuSDKMediaTimelineAssetMoviePlayerDelegate, TuSDKMediaMovieAssetTranscoderDelegate>

/**
 时间标签
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/**
 时间修整视图
 */
@property (weak, nonatomic) IBOutlet VideoTrimmerView *videoTrimmerView;

/**
 标尺视图
 */
@property (weak, nonatomic) IBOutlet RulerView *rulerView;

/**
 底部面板视图
 */
@property (weak, nonatomic) IBOutlet UIVisualEffectView *bottomPanelView;

/**
 视频预览视图
 */
@property (weak, nonatomic) IBOutlet UIView *playerView;

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;

/**
 多文件播放器
 */
@property (nonatomic, strong) TuSDKMediaMutableAssetMoviePlayer *moviePlayer;

/**
 视频导出管理器
 */
@property (nonatomic, strong) TuSDKMediaMovieAssetTranscoder *saver;

/**
 选取的时间范围
 */
@property (nonatomic, assign) CMTimeRange selectedTimeRange;

/**
 标识是否删除生成的临时文件
 */
@property (nonatomic, assign) BOOL removeTempFileFlag;

@end


@implementation MovieCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];

    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_moviePlayer stop];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_moviePlayer updatePreViewFrame:_playerView.frame];
    [_moviePlayer load];
}

- (void)dealloc;
{
    [_moviePlayer destory];
}

- (void)setupUI {
    [self.topNavigationBar.rightButton setTitle:NSLocalizedStringFromTable(@"tu_下一步", @"VideoDemo", @"下一步") forState:UIControlStateNormal];
    
    [self setupPlayer];
    [self setupUIAfterAssetsPrepared];
}

/**
 创建并配置播放器
 */
- (void)setupPlayer {
    
    NSMutableArray<TuSDKMediaAsset *> *inputMediaAssets = [NSMutableArray arrayWithCapacity:_inputAssets.count];
    [_inputAssets enumerateObjectsUsingBlock:^(AVURLAsset * _Nonnull inputAsset, NSUInteger idx, BOOL * _Nonnull stop) {
        TuSDKMediaAsset *mediaAsset = [[TuSDKMediaAsset alloc] initWithAsset:inputAsset timeRange:kCMTimeRangeInvalid];
        [inputMediaAssets addObject:mediaAsset];
    }];
    
    _moviePlayer = [[TuSDKMediaMutableAssetMoviePlayer alloc] initWithMediaAssets:inputMediaAssets preview:_playerView];
    _moviePlayer.delegate = self;
    _selectedTimeRange = CMTimeRangeMake(kCMTimeZero, _moviePlayer.asset.duration);
}

/**
 配置其他 UI
 */
- (void)setupUIAfterAssetsPrepared {
    NSTimeInterval duration = CMTimeGetSeconds(_moviePlayer.asset.duration);
    // 时间标签
    _timeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_已选择%.1f秒", @"VideoDemo", @"已选择%.1f秒"), duration];
    
    // 标尺
    self.rulerView.rightMargin = self.rulerView.leftMargin = [(TrimmerMaskView *)_videoTrimmerView.trimmerMaskView thumbWidth];
    self.rulerView.duration = CMTimeGetSeconds(_moviePlayer.asset.duration);
    
    // 获取缩略图
    TuSDKVideoImageExtractor *imageExtractor = [TuSDKVideoImageExtractor createExtractor];
    //imageExtractor.isAccurate = YES; // 精确截帧
    imageExtractor.videoAssets = _inputAssets;
    const NSInteger frameCount = 10;
    imageExtractor.extractFrameCount = frameCount;
    _videoTrimmerView.thumbnailsView.thumbnailCount = frameCount;
    // 异步渐进式配置缩略图
    [imageExtractor asyncExtractImageWithHandler:^(UIImage * _Nonnull frameImage, NSUInteger index) {
        [self.videoTrimmerView.thumbnailsView setThumbnail:frameImage atIndex:index];
    }];
    
    // 配置最短截取时长
    _videoTrimmerView.minIntervalProgress = kMinCutDuration / duration;
}

#pragma mark - 后台切换操作

/**
 进入后台
 */
- (void)enterBackFromFront {
    if (_moviePlayer) {
        if (_saver) {
            [_saver cancelExport];
            _saver = nil;
        }
        [_moviePlayer stop];
    }
}

/**
 后台到前台
 */
- (void)enterFrontFromBack {
}

#pragma mark - action

/**
 点击手势事件

 @param sender 点击手势
 */
- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    if (_moviePlayer.status == TuSDKMediaPlayerStatusPlaying) {
        [_moviePlayer pause];
    } else {
        [_moviePlayer play];
    }
}

/**
 播放按钮事件

 @param sender 点击的按钮
 */
- (IBAction)palyButtonAction:(UIButton *)sender {
    [_moviePlayer play];
}


/**
 清除多文件转码后生成的临时文件
 */
- (void)removeTempFile {
    if (!_removeTempFileFlag || !_outputURL) return;
    BOOL result = [[NSFileManager defaultManager] removeItemAtURL:_outputURL error:nil];
    _outputURL = nil;
    lsqLInfo(@"remove temp file %d",result);
}

/**
 右上方按钮事件

 @param sender 右侧按钮
 */
- (void)base_rightButtonAction:(UIButton *)sender {
    [_moviePlayer pause];
    
    // 若截取时间与视频时长一致，则直接返回视频 URL
    if (_inputAssets.count == 1 // 单个视频
        && CMTimeRangeEqual(_selectedTimeRange, CMTimeRangeMake(kCMTimeZero, _moviePlayer.inputDuration)))
    {
        _outputURL = _inputAssets.firstObject.URL;
        
        /** 原始视频卫生处临时文件时不需要删除 */
        self.removeTempFileFlag = NO;
        
        [super base_rightButtonAction:sender];
        
        return;
    }
    
 
    [self removeTempFile];
    
    TuSDKMediaTimeRange *timeRange = [[TuSDKMediaTimeRange alloc] initWithStart:_selectedTimeRange.start duration:_selectedTimeRange.duration];
    TuSDKMediaTimelineSlice *cutTimeRangeSlice = [[TuSDKMediaTimelineSlice alloc] initWithTimeRange:timeRange];

    
    // 否则进行导出
    TuSDKMediaMovieAssetTranscoderSettings *exportSettings = [[TuSDKMediaMovieAssetTranscoderSettings alloc] init];
    exportSettings.saveToAlbum = NO;
    exportSettings.enableExportAssetSound = YES;
    
    // 多文件时裁剪时可以通过 _moviePlayer.videoComposition 获取 videoComposition, 开发者也可以自定义。
    [_moviePlayer appendMediaTimeSlice:cutTimeRangeSlice];
    exportSettings.videoComposition = _moviePlayer.videoComposition;
    
    // 通过 appendMediaTimeSlice 为播放器添加切片，只是为了生成 videoComposition。
    [_moviePlayer removeAllMediaTimeSlices];
    
    _saver = [[TuSDKMediaMovieAssetTranscoder alloc] initWithInputAsset:_moviePlayer.asset exportOutputSettings:exportSettings];
    _saver.delegate = self;
    [_saver appendSlice:cutTimeRangeSlice];
    [_saver startExport];
}

#pragma mark - VideoTrimmerViewDelegate

/**
 时间轴进度更新回调

 @param trimmer 时间轴
 @param progress 播放进度
 @param location 进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer updateProgress:(double)progress atLocation:(TrimmerTimeLocation)location {
    NSTimeInterval duration = CMTimeGetSeconds(_moviePlayer.timelineOutputDuraiton);
    NSTimeInterval targetTime = duration * progress;
    
    [_moviePlayer seekToTime:CMTimeMakeWithSeconds(targetTime, _moviePlayer.timelineOutputDuraiton.timescale)];
    
    CMTimeRange timeRange = [_videoTrimmerView selectedTimeRangeAtDuration:_moviePlayer.timelineOutputDuraiton];
    NSTimeInterval rangeDutaion = CMTimeGetSeconds(timeRange.duration);
    _selectedTimeRange = timeRange;
    
    _timeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_已选择%.1f秒", @"VideoDemo", @"已选择%.1f秒"), rangeDutaion];
}

/**
 时间轴开始滑动回调

 @param trimmer 时间轴
 @param location 进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didStartAtLocation:(TrimmerTimeLocation)location {
    [_moviePlayer pause];
    _playButton.hidden = YES;
}

/**
 时间轴结束滑动回调

 @param trimmer 时间轴
 @param location 进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didEndAtLocation:(TrimmerTimeLocation)location {
    _playButton.hidden = _moviePlayer.status == TuSDKMediaPlayerStatusPlaying;
}

/**
 时间轴到达临界值回调

 @param trimmer 时间轴
 @param reachMaxIntervalProgress 进度最大值
 @param reachMinIntervalProgress 进度最小值
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer reachMaxIntervalProgress:(BOOL)reachMaxIntervalProgress reachMinIntervalProgress:(BOOL)reachMinIntervalProgress {
    if (reachMinIntervalProgress) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_视频时长最少%@秒", @"VideoDemo", @"视频时长最少%@秒"), @(kMinCutDuration)];
        [[TuSDK shared].messageHub showToast:message];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL skip = NO;
    skip = [_bottomPanelView.layer containsPoint:[touch locationInView:_bottomPanelView]];
    
    if (skip) return NO;
    return YES;
}

#pragma mark - TuSDKMediaTimelineAssetMoviePlayerDelegate

/**
 进度改变事件
 
 @param player 当前播放器
 @param percent (0 - 1)
 @param outputTime 当前帧所在持续时间
 @param outputSlice 当前正在输出的切片信息
 @since      v3.0
 */
- (void)mediaTimelineAssetMoviePlayer:(TuSDKMediaTimelineAssetMoviePlayer *_Nonnull)player progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime outputSlice:(TuSDKMediaTimelineSlice * _Nonnull)outputSlice {
    _videoTrimmerView.currentProgress = percent;
}

/**
 播放器状态改变事件
 
 @param player 当前播放器
 @param status 当前播放器状态
 @since      v3.0
 */
- (void)mediaTimelineAssetMoviePlayer:(TuSDKMediaTimelineAssetMoviePlayer *_Nonnull)player statusChanged:(TuSDKMediaPlayerStatus)status {
    if (!_videoTrimmerView.dragging)
        _playButton.hidden = status == TuSDKMediaPlayerStatusPlaying;
}

#pragma mark - TuSDKMediaMovieFilmEditSaverDelegate

/**
 进度改变事件
 
 @param exportSession TuSDKMediaMovieAssetTranscoder
 @param percent (0 - 1)
 @param outputTime 当前帧所在持续时间
 @since      v3.0
 */
- (void)mediaAssetExportSession:(TuSDKMediaMovieAssetTranscoder *_Nonnull)exportSession progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime {
    [TuSDKProgressHUD showProgress:percent status:NSLocalizedStringFromTable(@"tu_正在处理视频", @"VideoDemo", @"正在处理视频") maskType:TuSDKProgressHUDMaskTypeBlack];
}

/**
 导出状态改变事件
 
 @param exportSession TuSDKMediaMovieAssetTranscoder
 @param status 当前播放器状态
 @since      v3.0
 */
- (void)mediaAssetExportSession:(TuSDKMediaMovieAssetTranscoder *_Nonnull)exportSession statusChanged:(TuSDKMediaExportSessionStatus)status {
    switch (status) {
        // 导出时被中途取消
        case TuSDKMediaExportSessionStatusCancelled:{
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_取消保存", @"VideoDemo", @"取消保存")];
        } break;
        // 正在导出
        case TuSDKMediaExportSessionStatusExporting:{} break;
        // 导出失败
        case TuSDKMediaExportSessionStatusFailed:{} break;
        // 导出完成
        case TuSDKMediaExportSessionStatusCompleted:{} break;
        // 导出状态未知
        case TuSDKMediaExportSessionStatusUnknown:{} break;
        default:{} break;
    }
}

/**
 导出结果回调
 
 @param exportSession TuSDKMediaMovieAssetTranscoder
 @param result TuSDKVideoResult
 @param error 错误信息
 @since      v3.0
 */
- (void)mediaAssetExportSession:(TuSDKMediaMovieAssetTranscoder *_Nonnull)exportSession result:(TuSDKVideoResult *_Nonnull)result error:(NSError *_Nonnull)error {
    if (result) {
        
        _outputURL = [NSURL fileURLWithPath:result.videoPath];
        
        /** 转码后生成的时临时需要自行清楚，MovieEditor 不负责清除。*/
        self.removeTempFileFlag = YES;
        _saver = nil;
        if (self.rightButtonActionHandler) self.rightButtonActionHandler(self, nil);
    }
}

@end
