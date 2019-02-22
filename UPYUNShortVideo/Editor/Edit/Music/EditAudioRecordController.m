//
//  EditAudioRecordController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/2.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditAudioRecordController.h"
#import "MarkableProgressView.h"
#import "PitchSegmentButton.h"

@interface EditAudioRecordController ()<TuSDKMediaAssetAudioRecorderDelegate>

/**
 用途标签
 */
@property (weak, nonatomic) IBOutlet UILabel *usageLabel;

/**
 操作面板
 */
@property (weak, nonatomic) IBOutlet UIView *actionPanel;

/**
 可标记进度视图
 */
@property (weak, nonatomic) IBOutlet MarkableProgressView *progressView;

/**
 底部栏高度布局
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightLayout;

/**
 开始触摸点
 */
@property (nonatomic, assign) CGPoint beginTouchPoint;

/**
 音频录制器
 */
@property (nonatomic, strong) TuSDKMediaAssetAudioRecorder *audioRecorder;

/**
 之前的视频音量
 */
@property (nonatomic, assign) CGFloat previousVideoVolume;

/**
 最大录制时长
 */
@property (nonatomic, assign) NSTimeInterval maxReocrdDuration;

/**
 完成录制
 */
@property (nonatomic, assign) BOOL reachMaxReocrdDuration;

@end

@implementation EditAudioRecordController

+ (CGFloat)bottomPreviewOffset {
    return 199;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupAudioRecorder];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (parent) {
        _progressView.hidden = NO;
        _previousVideoVolume = self.movieEditor.videoSoundVolume;
        self.movieEditor.videoSoundVolume = 0;
    }
}
- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        _progressView.hidden = YES;
        self.movieEditor.videoSoundVolume = _previousVideoVolume;
    }
}

- (void)setupUI {
    [self.bottomNavigationBar removeFromSuperview];
    _actionPanel.hidden = YES;
    _progressView.hidden = YES;
    _usageLabel.text = NSLocalizedStringFromTable(@"tu_长按录音", @"VideoDemo", @"长按录音");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (@available(iOS 11.0, *)) {
        _bottomBarHeightLayout.constant += self.view.safeAreaInsets.bottom;
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)setupAudioRecorder {
    TuSDKMediaAssetAudioRecorder *audioRecorder = [[TuSDKMediaAssetAudioRecorder alloc] init];
    audioRecorder.delegate = self;
    _audioRecorder = audioRecorder;
    
    _maxReocrdDuration = CMTimeGetSeconds(self.movieEditor.outputDuraiton);
    
    // 跳转到开始
    [self.movieEditor seekToTime:kCMTimeZero];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];
}

- (void)updateActionPanel {
    self.actionPanel.hidden = _progressView.progress <= 0.0;
}

#pragma mark - touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (touches.count > 1) return;
    CGRect previewRect = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, [self.class bottomPreviewOffset], 0));
    CGPoint location = [touches.anyObject locationInView:self.view];
    if (CGRectContainsPoint(previewRect, location)) {
        _beginTouchPoint = location;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (touches.count > 1) return;
    UITouch *touch = touches.anyObject;
    if (CGPointEqualToPoint(_beginTouchPoint, [touch locationInView:self.view])) {
        [self cancelAction:touch];
    }
}

#pragma mark - action

/**
 变声分段按钮点击事件
 */
- (IBAction)pitchSegmentButtonAction:(PitchSegmentButton *)sender {
    _audioRecorder.pitchType = sender.pitchType;
}

/**
 录制按钮按下事件

 @param sender 按钮
 */
- (IBAction)touchDownAction:(UIButton *)sender {
    if (_reachMaxReocrdDuration) {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_已到达最大录制时长", @"VideoDemo", @"已到达最大录制时长")];
        return;
    }
    
    // 开始播放视频，并开始录制
    [self.movieEditor startPreview];
    [_audioRecorder startRecord];
    
    // 更新录制操作界面状态 录制时不显示回删和确定按钮
    self.actionPanel.hidden = YES;

}

/**
 录制按钮抬手事件

 @param sender 按钮
 */
- (IBAction)touchEndAction:(UIButton *)sender {
    // 更新录制操作界面
    [self updateActionPanel];
    
    if (_reachMaxReocrdDuration) return;
    // 暂停播放视频，并暂停录制
    [self.movieEditor pausePreView];
    [_audioRecorder pauseRecord];
}

/**
 撤销按钮事件
 */
- (IBAction)undoAction:(UIButton *)sender {
    // 回删
    [_audioRecorder popAudioFragment];
    
    // 更新音频录制操作界面各控件状态
    [_progressView popMark];
    _reachMaxReocrdDuration = NO;

    [self.movieEditor seekToTime:CMTimeMakeWithSeconds(_audioRecorder.outputDuration,USEC_PER_SEC)];
    
    [self updateActionPanel];
}

/**
 完成按钮事件
 */
- (IBAction)confirmAction:(UIButton *)sender {
    // 完成录制
    [_audioRecorder stopRecord];
}

/**
 取消事件
 */
- (void)cancelAction:(id)sender {
    // 暂停录制
    [_audioRecorder pauseRecord];
    
    // 询问是否取消录制
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"tu_取消录制？", @"VideoDemo", @"取消录制？") message:_progressView.progress ? NSLocalizedStringFromTable(@"tu_录制文件将被删除", @"VideoDemo", @"录制文件将被删除"):@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_取消", @"VideoDemo", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_确定", @"VideoDemo", @"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 取消录制
        [self.audioRecorder cancleRecord];
        [self.componentNavigator popEditComponentViewController];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - TuSDKMediaAssetAudioRecorderDelegate

/**
 录制完成
 @param mediaAssetAudioRecorder 录制对象
 @param filePath 录制结果
 @since v3.0
 */
- (void)mediaAssetAudioRecorder:(TuSDKMediaAssetAudioRecorder *)mediaAssetAudioRecorder filePath:(NSString *)filePath {
    NSURL *outputURL = [NSURL fileURLWithPath:filePath];
    
    // 回调 URL，完成后才 pop 视图控制器
    if (outputURL && [self.delegate respondsToSelector:@selector(audioRecorder:didFinishRecordingWithURL:)]) {
        [self.delegate audioRecorder:self didFinishRecordingWithURL:outputURL];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.componentNavigator popEditComponentViewController];
    });
}

/**
 录制状态通知
 @param recoder 录制对象
 @param status 录制状态
 @since v3.0
 */
- (void)mediaAssetAudioRecorder:(TuSDKMediaAssetAudioRecorder *)recoder statusChanged:(lsqAudioRecordingStatus)status {
    switch (status) {
        // 正在进行音频录制
        case lsqAudioRecordingStatusRecording:{
            
        } break;
        // 暂停音频录制
        case lsqAudioRecordingStatusPause:{
            // 暂停是进行记录
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView pushMark];
            });
        } break;
        // 取消音频录制
        case lsqAudioRecordingStatusCancelled:{
            
        } break;
        // 完成音频录制
        case lsqAudioRecordingStatusCompleted:{
            
        } break;
        // 音频录制失败
        case lsqAudioRecordingStatusFailed:{
            
        } break;
        // 未知状态
        case lsqAudioRecordingStatusUnknown:{
            
        } break;
    }
}

/**
 录制时间回调
 @param recoder 录制对象
 @param duration 已录制时长
 @since v3.0
 */
- (void)mediaAssetAudioRecorder:(TuSDKMediaAssetAudioRecorder *)recoder durationChanged:(CGFloat)duration {
//    NSLog(@"duration: %@", @(duration));
    if (duration >= _maxReocrdDuration) {
        _reachMaxReocrdDuration = YES;
        [_audioRecorder pauseRecord];
        [self.movieEditor pausePreView];
        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_已到达最大录制时长", @"VideoDemo", @"已到达最大录制时长")];
    }
    // 更新 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = duration / self.maxReocrdDuration;
    });
}

@end
