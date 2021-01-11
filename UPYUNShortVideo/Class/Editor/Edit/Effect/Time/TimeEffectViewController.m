//
//  TimeEffectViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/10.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TimeEffectViewController.h"
#import "ScrollVideoTrimmerView.h"
#import "TimeEffectListView.h"

// 默认时间特效时长
static const NSTimeInterval kDefaultTimeEffectDuration = 2.0;
// 最大时间特效时长
static const NSTimeInterval kMaxTimeEffectDuration = 3.0;
// 最小时间特效时长
static const NSTimeInterval kMinTimeEffectDuration = 1.0;

@interface TimeEffectViewController ()<VideoTrimmerViewDelegate, TimeEffectListViewDelegate>

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;

/**
 时间修整控件
 */
@property (weak, nonatomic) IBOutlet ScrollVideoTrimmerView *trimmerView;

/**
 时间特效列表
 */
@property (weak, nonatomic) IBOutlet TimeEffectListView *effectListView;

/**
 更新时间特效标记
 */
@property (nonatomic, assign) BOOL shouldUpdateTimeEffect;

/**
 上次选中的特效类型
 */
@property (nonatomic, assign) TimeEffectType lastEffectType;

@end

@implementation TimeEffectViewController

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
    
    // 恢复之前的特效
    [self.movieEditor removeAllMediaTimeEffect];
    if (self.initialEffects.count) {
        for (id<TuSDKMediaTimeEffect> timeEffect in self.initialEffects) {
            [self.movieEditor addMediaTimeEffect:timeEffect];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.movieEditor seekToTime:kCMTimeZero];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];
}

- (void)setupUI {
    [self.bottomNavigationBar removeFromSuperview];
    _shouldUpdateTimeEffect = YES;
    _playButton.selected = self.movieEditor.isPreviewing;
    _trimmerView.thumbnailsView.thumbnails = self.thumbnails;
    _trimmerView.trimmerMaskView.hidden = YES;
    
    // 配置最大、最小选取时长
    CMTime movieDuration = self.movieEditor.inputDuration;
    _trimmerView.maxIntervalProgress = kMaxTimeEffectDuration / CMTimeGetSeconds(movieDuration);
    _trimmerView.minIntervalProgress = kMinTimeEffectDuration / CMTimeGetSeconds(movieDuration);
    
    // 获取已添加的时间特效
    id<TuSDKMediaTimeEffect> timeEffect = self.movieEditor.mediaTimeEffects.lastObject;
    if (timeEffect) {
        self.initialEffects = @[timeEffect];
        CMTimeRange timeRange = timeEffect.timeRange.cmTimeRange;
        [_trimmerView setSelectedTimeRange:timeRange atDuration:self.movieEditor.inputDuration];
        
        BOOL trimmerMaskHidden = YES;
        TimeEffectType effectType = TimeEffectTypeNone;
        if ([timeEffect isKindOfClass:[TuSDKMediaRepeatTimeEffect class]]) {
            effectType = TimeEffectTypeRepeat;
            trimmerMaskHidden = NO;
        } else if ([timeEffect isKindOfClass:[TuSDKMediaSpeedTimeEffect class]]) {
            effectType = TimeEffectTypeSlow;
            trimmerMaskHidden = NO;
        } else if ([timeEffect isKindOfClass:[TuSDKMediaReverseTimeEffect class]]) {
            effectType = TimeEffectTypeReverse;
            trimmerMaskHidden = YES;
        }
        _effectListView.selectedType = effectType;
        _trimmerView.trimmerMaskView.hidden = trimmerMaskHidden;
        _shouldUpdateTimeEffect = NO;
        _lastEffectType = effectType;
    }
}

/**
 更新时间特效
 */
- (void)updateTimeEeffect {
    _shouldUpdateTimeEffect = NO;
    BOOL shouldSeekTime = NO;
    
    // 获取时间特效触发时间范围
    CMTimeRange timeRange = [_trimmerView selectedTimeRangeAtDuration:self.movieEditor.inputDuration];
    CMTime previewTime = timeRange.start;
    
    switch (_effectListView.selectedType) {
        // 时间特效：无效果
        case TimeEffectTypeNone:{
            // 移除所有时间特效
            [self.movieEditor removeAllMediaTimeEffect];
            
            shouldSeekTime = NO;
        } break;
        // 时间特效：反复
        case TimeEffectTypeRepeat:{
            // 构建反复时间特效
            TuSDKMediaRepeatTimeEffect *repeatTimeEffect = [[TuSDKMediaRepeatTimeEffect alloc] initWithTimeRange:timeRange];
            
            // 设置反复次数
            repeatTimeEffect.repeatCount = 2;
            
            // 设置是否丢弃应用特效后累加的视频时长
            repeatTimeEffect.dropOverTime = NO;
            
            // 添加特效
            [self.movieEditor addMediaTimeEffect:repeatTimeEffect];
            
            shouldSeekTime = YES;
        } break;
        // 时间特效：慢动作
        case TimeEffectTypeSlow:{
            // 构建速率特效对象
            TuSDKMediaSpeedTimeEffect *speedTimeEffect = [[TuSDKMediaSpeedTimeEffect alloc] initWithTimeRange:timeRange];
            
            // 设置播放速率
            speedTimeEffect.speedRate = 0.5f;
            
            // 设置是否丢弃应用特效后累加的视频时长
            speedTimeEffect.dropOverTime = NO;
            
            // step3: 添加特效
            [self.movieEditor addMediaTimeEffect:speedTimeEffect];
            
            shouldSeekTime = YES;
        } break;
        // 时间特效：倒序
        case TimeEffectTypeReverse:{
            // 获取时间特效触发时间范围
            timeRange = CMTimeRangeMake(kCMTimeZero, self.movieEditor.inputDuration);
            
            // 构建倒序特效对象
            TuSDKMediaReverseTimeEffect *reverseTimeEffect = [[TuSDKMediaReverseTimeEffect alloc] initWithTimeRange:timeRange];
            
            // 添加特效
            [self.movieEditor addMediaTimeEffect:reverseTimeEffect];
            
            previewTime = CMTimeRangeGetEnd(timeRange);
            shouldSeekTime = YES;
        } break;
    }
    
    if (!shouldSeekTime) return;
    // 更新时间轴控件时间进度为当前时间特效的开始
    [self.movieEditor seekToInputTime:previewTime];
}

#pragma mark - property

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    self.playButton.selected = playing;
}

- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];
    // 应用时间特效播放进度到时间轴控件
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
 时间轴滑动回调，在此处做 seek 操作

 @param trimmer 时间特效时间轴
 @param progress 时间特效添加进度
 @param location 进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer updateProgress:(double)progress atLocation:(TrimmerTimeLocation)location {
    NSTimeInterval duration = CMTimeGetSeconds(self.movieEditor.inputDuration);
    NSTimeInterval targetTime = duration * progress;
    // 使用原始时间跳转
    [self.movieEditor seekToInputTime:CMTimeMakeWithSeconds(targetTime, self.movieEditor.inputDuration.timescale)];
}

/**
 时间轴开始拖动回调

 @param trimmer 时间特效时间轴
 @param location 进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didStartAtLocation:(TrimmerTimeLocation)location {
    [self.movieEditor pausePreView];
}

/**
 时间轴拖动结束回调

 @param trimmer 时间特效时间轴
 @param location 进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didEndAtLocation:(TrimmerTimeLocation)location {
    switch (location) {
        case TrimmerTimeLocationLeft:
        case TrimmerTimeLocationRight:{
            [self updateTimeEeffect];
        } break;
        default:{} break;
    }
}

/**
 时间轴选取范围到达临界值

 @param trimmer 时间特效时间轴
 @param reachMaxIntervalProgress 特效添加最大进度
 @param reachMinIntervalProgress 特效添加最小进度
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer reachMaxIntervalProgress:(BOOL)reachMaxIntervalProgress reachMinIntervalProgress:(BOOL)reachMinIntervalProgress {
    if (reachMaxIntervalProgress) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_特效时长最多%@秒", @"VideoDemo", @"特效时长最多%@秒"), @(kMaxTimeEffectDuration)];
        [[TuSDK shared].messageHub showToast:message];
    } else if (reachMinIntervalProgress) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_特效时长最少%@秒", @"VideoDemo", @"特效时长最少%@秒"), @(kMinTimeEffectDuration)];
        [[TuSDK shared].messageHub showToast:message];
    }
}

#pragma mark - TimeEffectListViewDelegate

/**
 时间特效列表选中回调

 @param listView 时间特效展示视图
 @param type 时间特效类型
 */
- (void)timeEffectList:(TimeEffectListView *)listView didSelectType:(TimeEffectType)type {
    _shouldUpdateTimeEffect = (_lastEffectType != type) || _shouldUpdateTimeEffect;
    _lastEffectType = type;
    switch (type) {
        // 时间特效：无效果
        case TimeEffectTypeNone:{
            // 更新 UI
            _trimmerView.trimmerMaskView.hidden = YES;
        } break;
        // 时间特效：反复
        case TimeEffectTypeRepeat:{
            // 更新 UI
            _trimmerView.trimmerMaskView.hidden = NO;
        } break;
        // 时间特效：慢动作
        case TimeEffectTypeSlow:{ 
            // 更新 UI
            _trimmerView.trimmerMaskView.hidden = NO;
        } break;
        // 时间特效：倒序
        case TimeEffectTypeReverse:{
            // 更新 UI
            _trimmerView.trimmerMaskView.hidden = YES;
        } break;
    }
    [self.movieEditor pausePreView];
    //[self.movieEditor removeAllMediaTimeEffect];
    
    if (!_shouldUpdateTimeEffect) return;
    
    // 设置默认的时间范围
    CMTime duration = self.movieEditor.inputDuration;
    CMTime startTime = self.movieEditor.outputTimeAtSlice;
    NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    if (durationInterval - CMTimeGetSeconds(startTime) < kDefaultTimeEffectDuration) {
        startTime = CMTimeMakeWithSeconds(durationInterval - kDefaultTimeEffectDuration, duration.timescale);
    }
    if (CMTimeGetSeconds(startTime) < 0) {
        startTime = kCMTimeZero;
    }
    CMTimeRange timeEffectRange = CMTimeRangeMake(startTime, CMTimeMakeWithSeconds(kDefaultTimeEffectDuration, duration.timescale));
    [_trimmerView setSelectedTimeRange:timeEffectRange atDuration:duration];
    [self updateTimeEeffect];
}

@end
