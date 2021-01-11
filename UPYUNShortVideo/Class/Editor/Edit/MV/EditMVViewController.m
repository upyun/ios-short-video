//
//  EditMVViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditMVViewController.h"
#import "ScrollVideoTrimmerView.h"
#import "MVListView.h"
#import "ParametersAdjustView.h"

// 视频原音
static NSString * const kVideoSoundVolumeKey = @"videoSoundVolume";
// MV 最小时长
static const NSTimeInterval kMinMvEffectDuration = 1.0;

@interface EditMVViewController ()<VideoTrimmerViewDelegate, MVListViewDelegate>

/**
 时间修整控件
 */
@property (weak, nonatomic) IBOutlet ScrollVideoTrimmerView *trimmerView;

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;

/**
 MV 列表
 */
@property (weak, nonatomic) IBOutlet MVListView *mvListView;

/**
 参数面板
 */
@property (weak, nonatomic) IBOutlet ParametersAdjustView *paramtersView;

/**
 MV 效果音量，设置时同时也设置 `currentMvEffect` 的音量
 */
@property (nonatomic, assign) double effectAudioVolume;

/**
 原音音量，设置时同时也设置了 `self.movieEditor` 的音量
 */
@property (nonatomic, assign) double movieVolume;

/**
 MV 时间范围，设置时也设置了 `currentMvEffect` 的时间范围
 */
@property (nonatomic, strong) TuSDKTimeRange *effectTimeRange;

/**
 当前操作的 MV 效果
 */
@property (nonatomic, strong) TuSDKMediaStickerAudioEffect *currentMvEffect;

@end


@implementation EditMVViewController

/**
 完成按钮事件

 @param sender 完成按钮
 */
- (void)doneButtonAction:(UIButton *)sender {
    [super doneButtonAction:sender];
}

/**
 取消按钮事件

 @param sender 取消按钮
 */
- (void)cancelButtonAction:(UIButton *)sender {
    [super cancelButtonAction:sender];
    // 恢复先前记录的状态
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerAudio];
    for (id<TuSDKMediaEffect> initialEffect in self.initialEffects) {
        [self.movieEditor addMediaEffect:initialEffect];
    }
    if (self.initialInfo.count) {
        self.movieVolume = [self.initialInfo[kVideoSoundVolumeKey] doubleValue];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复到首帧
    [self.movieEditor seekToTime:kCMTimeZero];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    self.title = @"MV";
    _trimmerView.trimmerMaskView.hidden = YES;
    
    // 配置最小选取时长
    CMTime movieDuration = self.movieEditor.inputDuration;
    _trimmerView.minIntervalProgress = kMinMvEffectDuration / CMTimeGetSeconds(movieDuration);
    
    // 记录初始信息
    self.initialInfo = @{kVideoSoundVolumeKey: @(self.movieVolume)};
    NSMutableArray *initialEffects = [NSMutableArray array];
    self.initialEffects = initialEffects;
    NSArray *initialAudioEffects = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeAudio];
    if (initialAudioEffects.count) {
        [initialEffects addObjectsFromArray:initialAudioEffects];
    }
    
    // 加载并应用特效数据至 UI
    _currentMvEffect = (TuSDKMediaStickerAudioEffect *)[self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeStickerAudio].lastObject;
    if (_currentMvEffect) {
        // 记录初始信息 - MV 特效
        [initialEffects addObject:_currentMvEffect.copy];
        
        _effectTimeRange = _currentMvEffect.atTimeRange;
        _effectAudioVolume = _currentMvEffect.audioVolume;
        [_trimmerView setSelectedTimeRange:_effectTimeRange.CMTimeRange atDuration:self.movieEditor.inputDuration];
        _trimmerView.trimmerMaskView.hidden = NO;
        _paramtersView.hidden = NO;
        [_mvListView selectMVWithEffect:_currentMvEffect];
    } else {
        _effectTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 durationSeconds:CMTimeGetSeconds(self.movieEditor.inputDuration)];
        _effectAudioVolume = 0.5;
    }
    // 时间轴展示缩略图
    _trimmerView.thumbnailsView.thumbnails = self.thumbnails;
    _playButton.selected = self.movieEditor.isPreviewing;
    
    NSString const *nameKey = @"name";
    NSString const *percentKey = @"percent";
    NSArray<NSDictionary *> const *parameters =
    @[
      @{nameKey: NSLocalizedStringFromTable(@"tu_原音", @"VideoDemo", @"原音"), percentKey: @(self.movieVolume)},
      @{nameKey: NSLocalizedStringFromTable(@"tu_配乐", @"VideoDemo", @"配乐"), percentKey: @(_effectAudioVolume)}
      ];
    __weak typeof(self) weakSelf = self;
    [self.paramtersView setupWithParameterCount:parameters.count config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent, double defaultValue)) {
        parameterItemConfig(parameters[index][nameKey], [parameters[index][percentKey] doubleValue], [parameters[index][percentKey] doubleValue]);
    } valueChange:^(NSUInteger index, double percent) {
        switch (index) {
            case 0:{
                weakSelf.movieVolume = percent;
            } break;
            case 1:{
                weakSelf.effectAudioVolume = percent;
            } break;
        }
    }];
    self.paramtersView.hidden = YES;
    
    if ([self.movieEditor isPreviewing]) {
        [self.movieEditor pausePreView];
    }
    [self.movieEditor seekToTime:kCMTimeZero];
}

#pragma mark - property

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    self.playButton.selected = playing;
}

- (void)setMovieVolume:(double)movieVolume {
    self.movieEditor.videoSoundVolume = movieVolume;
}
- (double)movieVolume {
    return self.movieEditor.videoSoundVolume;
}

- (void)setEffectTimeRange:(TuSDKTimeRange *)effectTimeRange {
    _effectTimeRange = effectTimeRange;
    _currentMvEffect.atTimeRange = effectTimeRange;
}

- (void)setEffectAudioVolume:(double)effectAudioVolume {
    _effectAudioVolume = effectAudioVolume;
    _currentMvEffect.audioVolume = effectAudioVolume;
}

- (void)setCurrentMvEffect:(TuSDKMediaStickerAudioEffect *)mvEffect {
    // 进行移除特效与添加特效操作
    _currentMvEffect = mvEffect;
    
    // 更新 MV 时间轴和参数列表
    _paramtersView.hidden = !mvEffect;
    _trimmerView.trimmerMaskView.hidden = !mvEffect;
    
    // 选中 MV 列表第一项，mvEffect 为空，移除滤镜
    if (!mvEffect) {
        // 移除 MV 特效
        [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerAudio];
        return;
    };
    
    // 应用音量、时间范围
    mvEffect.audioVolume = self.effectAudioVolume;
    mvEffect.atTimeRange = self.effectTimeRange;
    // 应用 MV 特效
    [self.movieEditor addMediaEffect:mvEffect];
}

- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];
    _trimmerView.currentProgress = playbackProgress;
}

#pragma mark - action

/**
 播放按钮事件

 @param sender 播放按钮
 */
- (IBAction)playButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (self.trimmerView.currentProgress >= 1.0) {
            [self.movieEditor seekToTime:kCMTimeZero];
        }
        [self.movieEditor startPreview];
    } else {
        [self.movieEditor pausePreView];
    }
}

#pragma mark - VideoTrimmerViewDelegate

/**
 时间轴范围变更回调，在此更新当前特效的时间范围

 @param trimmer 时间轴协议
 @param progress 时间进度
 @param location 时间进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer updateProgress:(double)progress atLocation:(TrimmerTimeLocation)location {
    NSTimeInterval duration = CMTimeGetSeconds(self.movieEditor.inputDuration);
    NSTimeInterval targetTime = duration * progress;
    [self.movieEditor seekToInputTime:CMTimeMakeWithSeconds(targetTime, self.movieEditor.inputDuration.timescale)];
    
    switch (location) {
        // 左滑块
        case TrimmerTimeLocationLeft:
        // 右滑块
        case TrimmerTimeLocationRight:{
            CMTimeRange selectedTimeRange = [_trimmerView selectedTimeRangeAtDuration:self.movieEditor.inputDuration];
            self.effectTimeRange = [TuSDKTimeRange makeTimeRangeWithStart:selectedTimeRange.start duration:selectedTimeRange.duration];
        } break;
        default:{} break;
    }
}

/**
 时间轴开始拖动回调

 @param trimmer 时间轴协议
 @param location 时间进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didStartAtLocation:(TrimmerTimeLocation)location {
    [self.movieEditor pausePreView];
}

/**
 时间轴选取范围到达临界值

 @param trimmer 时间轴协议
 @param reachMaxIntervalProgress 时间轴最大进度
 @param reachMinIntervalProgress 时间轴最小进度
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer reachMaxIntervalProgress:(BOOL)reachMaxIntervalProgress reachMinIntervalProgress:(BOOL)reachMinIntervalProgress {
    if (reachMinIntervalProgress) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_特效时长最少%@秒", @"VideoDemo", @"特效时长最少%@秒"), @(kMinMvEffectDuration)];
        [[TuSDK shared].messageHub showToast:message];
    }
}

#pragma mark - MVListViewDelegate

/**
  MV 效果选中回调

 @param listView MV 列表视图
 @param mvEffect MV 效果
 @param tapCount 点击次数
 */
- (void)mvlist:(MVListView *)listView didSelectEffect:(TuSDKMediaStickerAudioEffect *)mvEffect tapCount:(NSInteger)tapCount {
    // 点第2次MV项时显示参数面板
    _paramtersView.hidden = tapCount <= 1;
    self.currentMvEffect = mvEffect;
}

@end
