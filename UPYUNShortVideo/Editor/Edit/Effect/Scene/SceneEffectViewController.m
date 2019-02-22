//
//  SceneEffectViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/10.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "SceneEffectViewController.h"
#import "ScrollVideoTrimmerView.h"
#import "SceneEffectListView.h"

@interface SceneEffectViewController ()<VideoTrimmerViewDelegate, SceneEffectListViewDelegate>

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
@property (weak, nonatomic) IBOutlet SceneEffectListView *effectListView;

/**
 回删按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

/**
 当前应用的场景特效
 */
@property (nonatomic, strong) id<TuSDKMediaEffect> currentSceneEffect;

@end

@implementation SceneEffectViewController

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
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeScene];
    if (self.initialEffects.count) {
        for (TuSDKMediaSceneEffect *effect in self.initialEffects) {
            [self.movieEditor addMediaEffect:effect];
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
    [_trimmerView.trimmerMaskView removeFromSuperview];
    
    _trimmerView.thumbnailsView.thumbnails = self.thumbnails;
    _playButton.selected = self.movieEditor.isPreviewing;
    
    /// 载入特效并同步 UI
    NSArray *sceneEffects = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeScene];
    self.initialEffects = sceneEffects.mutableCopy;
    [_trimmerView addMarksWithCount:sceneEffects.count totalDuration:self.movieEditor.inputDuration config:^(NSUInteger index, void (^markItemConfig)(CMTimeRange markItemTimeRange, UIColor *color)) {
        TuSDKMediaSceneEffect *sceneEffect = sceneEffects[index];
        TuSDKTimeRange *timeRange = sceneEffect.atTimeRange;
        markItemConfig(timeRange.CMTimeRange, self.effectListView.sceneEffectCodeColors[sceneEffect.effectsCode]);
    }];
    
    [self updateUndoButtonState];
}

/**
 停止应用特效，并更新 UI
 */
- (void)endUpdateCurrentSceneEffect {
    // `-unApplyMediaEffect:` 取消应用特效
    [self.movieEditor unApplyMediaEffect:_currentSceneEffect];
    _currentSceneEffect = nil;
    
    // 更新 UI
    [_trimmerView endMark];
    [self updateUndoButtonState];
}

#pragma mark - property

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    self.playButton.selected = playing;
    
    // 暂停播放时，中断当前应用的特效
    if (!playing && _currentSceneEffect) {
        // 停止更新绘制 UI
        [self endUpdateCurrentSceneEffect];
    }
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
        [self.movieEditor startPreview];
    } else {
        [self.movieEditor pausePreView];
    }
}

/**
 撤销按钮事件

 @param sender 撤销按钮
 */
- (IBAction)undoButtonAction:(UIButton *)sender {
    if (![self updateUndoButtonState]) return;
    // 移除最后添加的场景特效
    id<TuSDKMediaEffect> sceneEffect = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeScene].lastObject;
    [self.movieEditor removeMediaEffect:sceneEffect];
    
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
    NSInteger effectCount = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeScene].count;
    _undoButton.enabled = effectCount > 0;
    return _undoButton.enabled;
}

#pragma mark - SceneEffectListViewDelegate

/**
 场景特效列表项按下回调，开始应用场景特效

 @param listView 场景特效视图
 @param code 场景特效 code
 @param color 场景特效控件展示的颜色
 */
- (void)sceneEffectList:(SceneEffectListView *)listView didTouchDownWithCode:(NSString *)code color:(UIColor *)color {
    // 跳过末尾
    CMTime outputTime = self.movieEditor.outputTimeAtTimeline;
    CMTime outputDuraiton = self.movieEditor.outputDuraiton;
    CMTime minFrameDuration = self.movieEditor.inputAssetInfo.videoInfo.videoTrackInfoArray.firstObject.minFrameDuration;
    if (CMTIME_COMPARE_INLINE(CMTimeAdd(outputTime, minFrameDuration), >=, outputDuraiton)) {
        lsqLError(@"剩余时间太短，无法添加特效。");
        [self.movieEditor stopPreview];
        return;
    }
    
    // 同步更新 UI
    [_trimmerView startMarkWithColor:color];
    
    // `-applyMediaEffect:` 应用特效
    TuSDKMediaSceneEffect *sceneEffect = [[TuSDKMediaSceneEffect alloc] initWithEffectsCode:code];
    [self.movieEditor applyMediaEffect:sceneEffect];
    _currentSceneEffect = sceneEffect;
    
    [self.movieEditor startPreview];
}

/**
 场景特效列表项抬手回调，结束该场景特效

 @param listView 场景特效列表展示视图
 @param code 场景特效 code
 @param color 展示控件遮罩颜色
 */
- (void)sceneEffectList:(SceneEffectListView *)listView didTouchUpWithCode:(NSString *)code color:(UIColor *)color {
    if (!_currentSceneEffect) return;

    // 暂停播放
    [self.movieEditor pausePreView];
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
