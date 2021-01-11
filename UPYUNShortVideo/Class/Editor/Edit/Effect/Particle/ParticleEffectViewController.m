//
//  ParticleEffectViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/10.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "ParticleEffectViewController.h"
#import "ScrollVideoTrimmerView.h"
#import "ParticleEffectListView.h"
#import "ParticleEffectEditAreaView.h"
#import "ColorSlider.h"


@interface ParticleEffectViewController ()<VideoTrimmerViewDelegate, ParticleEffectListViewDelegate, ParticleEffectEditAreaViewDelegate>

/**
 控件标签
 */
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *controlLabels;

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;

/**
 时间修整控件
 */
@property (weak, nonatomic) IBOutlet ScrollVideoTrimmerView *trimmerView;

/**
 参数面板
 */
@property (weak, nonatomic) IBOutlet UIView *parametersPanelView;

/**
 魔法特效列表
 */
@property (weak, nonatomic) IBOutlet ParticleEffectListView *effectListView;

/**
 回删按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

/**
 大小标签
 */
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

/**
 大小 slider
 */
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;

/**
 颜色 slider
 */
@property (weak, nonatomic) IBOutlet ColorSlider *colorSlider;

/**
 魔法特效绘制视图
 */
@property (nonatomic, strong) ParticleEffectEditAreaView *particleEditAreaView;

/**
 当前应用的魔法特效
 */
@property (nonatomic, strong) TuSDKMediaParticleEffect *currentParticleEffect;

@end

@implementation ParticleEffectViewController

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
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeParticle];
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
    _controlLabels[0].text = NSLocalizedStringFromTable(@"tu_颜色", @"VideoDemo", @"颜色");
    _controlLabels[1].text = NSLocalizedStringFromTable(@"tu_大小", @"VideoDemo", @"大小");
    
    [self.bottomNavigationBar removeFromSuperview];
    [_trimmerView.trimmerMaskView removeFromSuperview];
    _parametersPanelView.hidden = YES;
    
    _trimmerView.thumbnailsView.thumbnails = self.thumbnails;
    _playButton.selected = self.movieEditor.isPreviewing;
    
    /// 载入特效并更新 UI
    NSArray *particleEffects = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeParticle];
    self.initialEffects = particleEffects.mutableCopy;
    [_trimmerView addMarksWithCount:particleEffects.count totalDuration:self.movieEditor.inputDuration config:^(NSUInteger index, void (^markItemConfig)(CMTimeRange markItemTimeRange, UIColor *color)) {
        TuSDKMediaParticleEffect *particleEffect = particleEffects[index];
        TuSDKTimeRange *timeRange = particleEffect.atTimeRange;
        markItemConfig(timeRange.CMTimeRange , self.effectListView.particleEffectCodeColors[particleEffect.effectsCode]);
    }];
    
    [self updateUndoButtonState];
    
    // 绘制区域视图
    _particleEditAreaView = [[ParticleEffectEditAreaView alloc] initWithFrame:CGRectZero];
    [self.view insertSubview:_particleEditAreaView atIndex:0];
    _particleEditAreaView.delegate = self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 获取视频在屏幕中的大小
    TuSDKVideoTrackInfo *trackInfo = self.movieEditor.inputAssetInfo.videoInfo.videoTrackInfoArray.firstObject;
    CGRect bounds = self.movieEditor.holderView.bounds;
    CGSize videoSize = trackInfo.presentSize;
    
    /** 计算视频绘制区域 */
    if (self.movieEditor.options.outputSizeOptions.aspectOutputRatioInSideCanvas) {
        CGRect outputRect = AVMakeRectWithAspectRatioInsideRect(self.movieEditor.options.outputSizeOptions.outputSize, bounds);
        _particleEditAreaView.frame = outputRect;
    }else {
        _particleEditAreaView.frame = AVMakeRectWithAspectRatioInsideRect(videoSize, bounds);
    }
}

/**
 重置特效参数栏视图，在切换魔法特效时需要进行重置

 @param effect 添加的魔法特效
 */
- (void)resetParameterViewsWithEffect:(TuSDKMediaParticleEffect *)effect {
    _colorSlider.progress = 0;
    _sizeSlider.value = effect.particleSize;
    [self updatePercentLabel:_sizeLabel percent:_sizeSlider.value];
}

/**
 更新给定的标签文本为百分比值

 @param label 标签
 @param percent 百分比
 */
- (void)updatePercentLabel:(UILabel *)label percent:(double)percent {
    label.text = [NSNumberFormatter localizedStringFromNumber:@(percent) numberStyle:NSNumberFormatterPercentStyle];
}

/**
 停止应用特效，并更新 UI
 */
- (void)endUpdateCurrentParticleEffect {
    // `-unApplyMediaEffect:` 取消应用特效
    [self.movieEditor unApplyMediaEffect:_currentParticleEffect];
    // 置空 currentParticleEffect 属性，以便下次绘制是通过懒加载生成
    _currentParticleEffect = nil;
    
    // 更新 UI
    [_trimmerView endMark];
    [self updateUndoButtonState];
}

#pragma mark - property

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    self.playButton.selected = playing;
    
    // 暂停播放时，中断当前应用的特效
    if (!playing && _currentParticleEffect) {
        // 停止绘制更新 UI
        [self endUpdateCurrentParticleEffect];
    }
}

- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];

    _trimmerView.currentProgress = playbackProgress;
}

- (TuSDKMediaParticleEffect *)currentParticleEffect {
    if (!_currentParticleEffect) {
        NSString *effectCode = _effectListView.selectedCode;
        if (effectCode) {
            _currentParticleEffect = [[TuSDKMediaParticleEffect alloc] initWithEffectsCode:effectCode];
            // 应用设置
            _currentParticleEffect.particleColor = _colorSlider.color;
            _currentParticleEffect.particleSize = _sizeSlider.value;
        }
    }
    return _currentParticleEffect;
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

/**
 撤销按钮事件

 @param sender 撤销按钮
 */
- (IBAction)undoButtonAction:(UIButton *)sender {
    if (![self updateUndoButtonState]) return;
    // 移除最后一个魔法特效
    id<TuSDKMediaEffect> sceneEffect = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeParticle].lastObject;
    [self.movieEditor removeMediaEffect:sceneEffect];
    
    // 更新 UI
    [_trimmerView popMark];
    _trimmerView.animatedNextUpdate = YES;
    [self updateUndoButtonState];
    // 跳转到最后一个标记结尾
    CMTime durationTime = self.movieEditor.inputDuration;
    CMTime lastMarkTime = CMTimeMakeWithSeconds(_trimmerView.lastMaskProgress * CMTimeGetSeconds(durationTime), durationTime.timescale);
    [self.movieEditor seekToInputTime:lastMarkTime];
}

/**
 更新撤销按钮状态，在无特效时，撤销按钮不可用

 @return 是否更新按钮状态
 */
- (BOOL)updateUndoButtonState {
    NSInteger effectCount = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeParticle].count;
    _undoButton.enabled = effectCount > 0;
    return _undoButton.enabled;
}

/**
 特效颜色滑块值变更回调

 @param sender 展示区域的颜色
 */
- (IBAction)colorSliderValueChangeAction:(ColorSlider *)sender {
    // 配置当前魔法特效的颜色
    _currentParticleEffect.particleColor = sender.color;
}

/**
 特效尺寸滑块值变更回调

 @param sender 调节特效素材尺寸大小的控件
 */
- (IBAction)sizeSiliderValueChangeAction:(UISlider *)sender {
    // 配置当前魔法特效的尺寸
    _currentParticleEffect.particleSize = sender.value;
    
    // 更新 UI
    [self updatePercentLabel:_sizeLabel percent:sender.value];
}

#pragma mark - ParticleEffectEditAreaViewDelegate

/**
 编辑区域触摸开始回调

 @param particleEditAreaView 特效添加d区域
 */
- (void)particleEditAreaViewDidBeginEditing:(ParticleEffectEditAreaView *)particleEditAreaView {
    // 跳过末尾
    CMTime outputTime = self.movieEditor.outputTimeAtTimeline;
    CMTime outputDuraiton = self.movieEditor.outputDuraiton;
    CMTime minFrameDuration = self.movieEditor.inputAssetInfo.videoInfo.videoTrackInfoArray.firstObject.minFrameDuration;
    if (CMTIME_COMPARE_INLINE(CMTimeAdd(outputTime,CMTimeMultiply(minFrameDuration, 2)), >=, outputDuraiton)) {
        lsqLError(@"剩余时间太短，无法添加特效。");
        [self.movieEditor stopPreview];
        return;
    }
    
    // 懒加载生成特效
    if (!self.currentParticleEffect) return;
    // 应用当前特效，同时需要播放视频
    [self.movieEditor applyMediaEffect:_currentParticleEffect];
    [self.movieEditor startPreview];
    
    // 更新 UI
    _parametersPanelView.hidden = YES;
    UIColor *markColor = _effectListView.particleEffectCodeColors[_currentParticleEffect.effectsCode];
    [_trimmerView startMarkWithColor:markColor];
}

/**
 编辑区域触摸位移回调

 @param particleEditAreaView 特效添加的区域
 @param percentPoint 特效添加的点坐标
 */
- (void)particleEditAreaView:(ParticleEffectEditAreaView *)particleEditAreaView didUpdatePercentPoint:(CGPoint)percentPoint {
    if (!_currentParticleEffect) return;
    
    // 更新当前魔法特效位置
    [self.movieEditor updateParticleEmitPosition:percentPoint];
}

/**
 编辑区域触摸结束回调

 @param particleEditAreaView 特效添加区域
 */
- (void)particleEditAreaViewDidEndEditing:(ParticleEffectEditAreaView *)particleEditAreaView {
    if (!_currentParticleEffect) return;
    
    // 暂停播放
    [self.movieEditor pausePreView];
}

#pragma mark - VideoTrimmerViewDelegate

/**
 时间轴滑动回调，在此处做 seek 操作

 @param trimmer 魔法特效的时间轴
 @param progress 添加的进度
 @param location 进度的位置
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer updateProgress:(double)progress atLocation:(TrimmerTimeLocation)location {
    NSTimeInterval duration = CMTimeGetSeconds(self.movieEditor.inputDuration);
    NSTimeInterval targetTime = duration * progress;
    [self.movieEditor seekToInputTime:CMTimeMakeWithSeconds(targetTime, self.movieEditor.inputDuration.timescale)];
}

/**
 时间轴开始拖动回调

 @param trimmer 魔法特效的时间轴
 @param location 进度的坐标
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didStartAtLocation:(TrimmerTimeLocation)location {
    [self.movieEditor pausePreView];
}

#pragma mark - ParticleEffectListViewDelegate

/**
 魔法特效列表选中回调

 @param listView 魔法特效展示t区域
 @param code 魔法特效的 code
 @param color 视图展示控件显示的颜色
 @param tapCount 点击的次数  
 */
- (void)particleEffectList:(ParticleEffectListView *)listView didTapWithCode:(NSString *)code color:(UIColor *)color tapCount:(NSInteger)tapCount {
    // 暂存选中的魔法特效，以供后续绘制、编辑使用
    self.currentParticleEffect = [[TuSDKMediaParticleEffect alloc] initWithEffectsCode:code];
    self.currentParticleEffect.particleSize = _sizeSlider.value;
    // 更新 UI
    [self resetParameterViewsWithEffect:self.currentParticleEffect];
    _parametersPanelView.hidden = tapCount <= 1;
}

@end
