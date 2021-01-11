//
//  EditTransitionViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/5/30.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "EditTransitionViewController.h"
#import "ScrollVideoTrimmerView.h"
#import "SceneEffectListView.h"
#import "TransitionEffectListView.h"
#import "Constants.h"


#define kDefaultTransitionEffectDuration 1.0

/**
 转场特效页面
 */
@interface EditTransitionViewController ()<VideoTrimmerViewDelegate, TransitionEffectListViewDelegate>

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;

/**
 时间修整控件
 */
@property (weak, nonatomic) IBOutlet ScrollVideoTrimmerView *trimmerView;

/**
 场景特效列表
 */
@property (weak, nonatomic) IBOutlet TransitionEffectListView *effectListView;

/**
 回删按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

/**
 当前应用的场景特效
 */
@property (nonatomic, strong) id<TuSDKMediaEffect> currentTransitionEffect;

@end

@implementation EditTransitionViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.movieEditor seekToTime:kCMTimeZero];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.movieEditor seekToTime:kCMTimeZero];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"tu_转场", @"VideoDemo", @"转场");
    [self setupUI];
}

- (void)setupUI {
    
    _trimmerView.thumbnailsView.thumbnails = self.thumbnails;
    [_trimmerView.trimmerMaskView removeFromSuperview];
    
    _playButton.selected = self.movieEditor.isPreviewing;
    
    /// 载入特效并同步 UI
    NSArray *transitionEffects = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeTransition];
    self.initialEffects = transitionEffects.mutableCopy;
    [_trimmerView addMarksWithCount:transitionEffects.count totalDuration:self.movieEditor.inputDuration config:^(NSUInteger index, void (^markItemConfig)(CMTimeRange markItemTimeRange, UIColor *color)) {
        TuSDKMediaTransitionEffect *transition = transitionEffects[index];
        TuSDKTimeRange *timeRange = transition.atTimeRange;
        markItemConfig(timeRange.CMTimeRange, self.effectListView.transitionEffectCodeColors[@(transition.transitionType)]);
    }];
    [self updateUndoButtonState];
}


/**
 取消按钮事件
 
 @param sender 取消按钮
 */
- (void)cancelButtonAction:(UIButton *)sender {
    [super cancelButtonAction:sender];
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeTransition];
    if (self.initialEffects.count) {
        for (TuSDKMediaTransitionEffect *effect in self.initialEffects) {
            [self.movieEditor addMediaEffect:effect];
        }
    }
}

- (IBAction)play:(UIButton *)sender {
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


- (IBAction)undo:(UIButton *)sender {
    if (![self updateUndoButtonState]) return;
    // 移除最后添加的场景特效
    id<TuSDKMediaEffect> transitionEffect = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeTransition].lastObject;
    [self.movieEditor removeMediaEffect:transitionEffect];
    
    // update UI
    [_trimmerView popMark];
    _trimmerView.animatedNextUpdate = YES;
    [self updateUndoButtonState];
    // 跳转到最后一个标记结尾
    CMTime durationTime = self.movieEditor.inputDuration;
    CMTime lastMarkTime = CMTimeMakeWithSeconds(_trimmerView.lastMaskProgress * CMTimeGetSeconds(durationTime), durationTime.timescale);
    [self.movieEditor seekToInputTime:lastMarkTime];
}


- (BOOL)updateUndoButtonState {
    NSInteger effectCount = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeTransition].count;
    _undoButton.enabled = effectCount > 0;
    return _undoButton.enabled;
}


- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];
    
    _trimmerView.currentProgress = playbackProgress;
}


- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    self.playButton.selected = playing;
}

#pragma mark - SceneEffectListViewDelegate

- (void)transitionEffectList:(TransitionEffectListView *)listView didTapWithType:(TuSDKMediaTransitionType)transitionType color:(UIColor *)color {
    
    
    CMTime duration = self.movieEditor.inputDuration;
    
    // 设置默认的时间范围
    CMTime startTime = self.movieEditor.outputTimeAtSlice;
    NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    if (durationInterval - CMTimeGetSeconds(startTime) < kDefaultTransitionEffectDuration) {
        startTime = CMTimeMakeWithSeconds(durationInterval - kDefaultTransitionEffectDuration, duration.timescale);
    }
    
    if (CMTimeGetSeconds(startTime) < 0) {
        startTime = kCMTimeZero;
    }
    
    CMTimeRange timeRange = CMTimeRangeMake(startTime, CMTimeMakeWithSeconds(kDefaultTransitionEffectDuration, duration.timescale));
    
    // `-applyMediaEffect:` 应用特效
    TuSDKMediaTransitionEffect *transitionEffect = [[TuSDKMediaTransitionEffect alloc] initWithTransitionType:transitionType atTimeRange:[TuSDKTimeRange makeTimeRangeWithStart:startTime duration:timeRange.duration]];
    transitionEffect.animationDuration = kDefaultTransitionEffectDuration * 1000;
    [self.movieEditor addMediaEffect:transitionEffect];
    
    // 同步更新 UI
    [_trimmerView addMarkWithColor:color timeRange:timeRange atDuration:duration];
    [self.movieEditor startPreview];
    [self updateUndoButtonState];
}




#pragma mark - VideoTrimmerViewDelegate

/**
 时间轴滑动回调，在此处做 seek 操作
 
 @param trimmer 展示时间轴
 @param progress 场景特效添加的进度
 @param location 进度位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer updateProgress:(double)progress atLocation:(TrimmerTimeLocation)location {
    NSTimeInterval duration = CMTimeGetSeconds(self.movieEditor.inputDuration);
    NSTimeInterval targetTime = duration * progress;
    [self.movieEditor seekToInputTime:CMTimeMakeWithSeconds(targetTime, self.movieEditor.inputDuration.timescale)];
}

/**
 时间轴开始滑动回调
 
 @param trimmer 时间轴
 @param location 时间轴上的位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didStartAtLocation:(TrimmerTimeLocation)location {
    [self.movieEditor pausePreView];
}

@end
