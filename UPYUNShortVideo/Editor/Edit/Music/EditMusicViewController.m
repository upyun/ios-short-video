//
//  EditMusicViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditMusicViewController.h"
#import "MusicListView.h"
#import "ParametersAdjustView.h"

#import "EditAudioRecordController.h"

// 视频原音
static NSString * const kVideoSoundVolumeKey = @"videoSoundVolume";

@interface EditMusicViewController ()<MusicListViewDelegate, EditAudioRecordControllerDelegate>

/**
 配乐列表
 */
@property (weak, nonatomic) IBOutlet MusicListView *musicListView;

/**
 参数面板
 */
@property (weak, nonatomic) IBOutlet ParametersAdjustView *paramtersView;

/**
 配乐音量
 */
@property (nonatomic, assign) double effectAudioVolume;

/**
 原音音量，实际 get/set self.movieEditor.videoSoundVolume
 */
@property (nonatomic, assign) double movieVolume;

/**
 当前声音特效
 */
@property (nonatomic, strong) TuSDKMediaAudioEffect *currentAudioEffect;

/**
 已有录音文件的 URL 地址
 */
@property (nonatomic, strong) NSURL *recordURL;

/**
 录音界面
 */
@property (nonatomic, weak) EditAudioRecordController *audioRecorder;

@end


@implementation EditMusicViewController

+ (CGFloat)bottomPreviewOffset {
    return 132;
}

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
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeAudio];
    for (id<TuSDKMediaEffect> initialEffect in self.initialEffects) {
        [self.movieEditor addMediaEffect:initialEffect];
    }
    if (self.initialInfo.count) {
        self.movieVolume = [self.initialInfo[kVideoSoundVolumeKey] doubleValue];
    }
}

- (BOOL)shouldShowPlayButton {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self.movieEditor startPreview];
}

- (void)setupUI {
    self.title = NSLocalizedStringFromTable(@"tu_配乐", @"VideoDemo", @"配乐");
    
    // 记录初始信息
    self.initialInfo = @{kVideoSoundVolumeKey: @(self.movieVolume)};
    NSMutableArray *initialEffects = [NSMutableArray array];
    self.initialEffects = initialEffects;
    // 若是之前添加了 MV 特效则也需要记录起来
    NSArray *initialMVEffects = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeStickerAudio];
    if (initialMVEffects.count) {
        [initialEffects addObjectsFromArray:initialMVEffects];
    }
    
    // 加载并应用特效数据至 UI
    _currentAudioEffect = (TuSDKMediaAudioEffect *)[self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeAudio].lastObject;
    if (_currentAudioEffect && ![_musicListView.musicURLs containsObject:_currentAudioEffect.audioURL]) {
        _recordURL = _currentAudioEffect.audioURL;
    }
    
    if (_currentAudioEffect) {
        // 记录初始信息-特效
        [initialEffects addObject:_currentAudioEffect.copy];
        [_musicListView selectMusicURL:_currentAudioEffect.audioURL];
        _effectAudioVolume = _currentAudioEffect.audioVolume;
    } else {
        _effectAudioVolume = 0.5;
    }
    _paramtersView.hidden = !_currentAudioEffect;
    
    NSString const *nameKey = @"name";
    NSString const *percentKey = @"percent";
    NSArray<NSDictionary *> const *parameters =
    @[
      @{nameKey: NSLocalizedStringFromTable(@"tu_原音", @"VideoDemo", @"原音"), percentKey: @(self.movieVolume)},
      @{nameKey: NSLocalizedStringFromTable(@"tu_配乐", @"VideoDemo", @"配乐"), percentKey: @(_effectAudioVolume)}
      ];
    __weak typeof(self) weakSelf = self;
    [self.paramtersView setupWithParameterCount:parameters.count config:^(NSUInteger index, ParameterAdjustItemView *itemView, void (^parameterItemConfig)(NSString *name, double percent)) {
        parameterItemConfig(parameters[index][nameKey], [parameters[index][percentKey] doubleValue]);
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
}

#pragma mark - property

- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];
    self.audioRecorder.playbackProgress = playbackProgress;
}

- (void)setMovieVolume:(double)movieVolume {
    // 更新原音音量
    self.movieEditor.videoSoundVolume = movieVolume;
}
- (double)movieVolume {
    // 原音音量
    return self.movieEditor.videoSoundVolume;
}

- (void)setEffectAudioVolume:(double)effectAudioVolume {
    _effectAudioVolume = effectAudioVolume;
    // 更新配乐音量
    _currentAudioEffect.audioVolume = effectAudioVolume;
}

- (void)setCurrentAudioEffect:(TuSDKMediaAudioEffect *)audioEffect {
    // 进行移除特效与添加特效操作
    _currentAudioEffect = audioEffect;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.paramtersView.hidden = !audioEffect;
    });
    
    // 选中配乐列表第一项时，audioEffect 为空，则移除音频特效
    if (!audioEffect) {
        [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeAudio];
        return;
    }
    // 应用音量
    audioEffect.audioVolume = self.effectAudioVolume;
    // 设置应用范围
    audioEffect.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStart:kCMTimeZero duration:self.movieEditor.outputDuraiton];
    // 添加特效
    [self.movieEditor addMediaEffect:audioEffect];
    // 切换音乐后，重新预览视频
    [self.movieEditor stopPreview];
    [self.movieEditor startPreview];
}

- (void)setRecordURL:(NSURL *)recordURL {
    // 删除前一份录制音频
    if (_recordURL && [[NSFileManager defaultManager] fileExistsAtPath:_recordURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:_recordURL error:nil];
    }
    
    _recordURL = recordURL;
}

#pragma mark - MusicListViewDelegate

/**
 录音选中回调，在此处切换对录音界面

 @param listView 音乐列表视图
 */
- (void)musicListDidNeedRecord:(MusicListView *)listView {
    // 开始新的录音
    self.currentAudioEffect = nil;
    EditAudioRecordController *audioRecorder = [[EditAudioRecordController alloc] initWithNibName:nil bundle:nil];
    audioRecorder.delegate = self;
    audioRecorder.movieEditor = self.movieEditor;
    self.audioRecorder = audioRecorder;
    [self.componentNavigator pushEditComponentViewController:audioRecorder];
}

/**
 配乐列表项选中回调

 @param listView 音乐列表视图
 @param musicURL 音乐文件的 URL 地址
 @param tapCount 点击次数
 */
- (void)musicList:(MusicListView *)listView didSelectMusic:(NSURL *)musicURL tapCount:(NSInteger)tapCount {
    _paramtersView.hidden = tapCount <= 1;
    TuSDKMediaAudioEffect *audioEffect = nil;
    if (musicURL) {
        audioEffect = [[TuSDKMediaAudioEffect alloc] initWithAudioURL:musicURL];
    }
    self.currentAudioEffect = audioEffect;
    // 切换其他配乐时，删除已录制的配乐
    self.recordURL = nil;
}

#pragma mark - EditAudioRecordControllerDelegate

/**
 录音结果回调，应用录音为配乐

 @param audioRecorder 声音录制控制器
 @param recordURL 录制音频文件的 URL 地址
 */
- (void)audioRecorder:(EditAudioRecordController *)audioRecorder didFinishRecordingWithURL:(NSURL *)recordURL {
    TuSDKMediaAudioEffect *audioEffect = nil;
    if (recordURL) {
        audioEffect = [[TuSDKMediaAudioEffect alloc] initWithAudioURL:recordURL];
        audioEffect.looping = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.musicListView.selectedIndex = 1;
        });
    }
    self.recordURL = recordURL;
    self.currentAudioEffect = audioEffect;
}

@end
