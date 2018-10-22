//
//  RecorderView.m
//  TuSDKVideoDemo
//
//  Created by wen on 06/07/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "RecorderView.h"

@interface RecorderView ()<TuSDKTSAudioRecoderDelegate>{
    // 录音按钮
    UIView *_recorderView;
    // 剩余时间 label
    UILabel *_timeLabel;
    // 删除按钮
    UIButton *_deleteBtn;
    // 保存按钮
    UIButton *_saveBtn;
    
    // 录音对象
    TuSDKTSAudioRecorder *_audioRecorder;
}

@end

@implementation RecorderView


- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        [self initRecorderView];
    }
    return self;
}

- (void)initRecorderView;
{
    self.backgroundColor = [UIColor redColor];
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, 150)];
    backView.center = CGPointMake(self.lsqGetSizeWidth/2, self.lsqGetSizeHeight - 75);
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    
    // 录音 view
    _recorderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
    _recorderView.center = CGPointMake(backView.lsqGetSizeWidth/2, backView.lsqGetSizeHeight/2);
    _recorderView.backgroundColor = [UIColor lsqClorWithHex:@"#F6A623"];
    _recorderView.layer.cornerRadius = 32;
    [backView addSubview:_recorderView];
    
    // 添加长按手势
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressEvent:)];
    longPressGesture.minimumPressDuration = 0.2;
    [_recorderView addGestureRecognizer:longPressGesture];

    // 删除按钮
    _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    _deleteBtn.center = CGPointMake((self.lsqGetSizeWidth - _recorderView.lsqGetSizeWidth)/4, _recorderView.center.y);
    [_deleteBtn setImage:[UIImage imageNamed:@"style_default_1.7.0_cancel"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteRecorderResult) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_deleteBtn];
    
    // 保存按钮
    _saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 42, 42)];
    _saveBtn.center = CGPointMake((self.lsqGetSizeWidth - _recorderView.lsqGetSizeWidth)*3/4 + _recorderView.lsqGetSizeWidth, _recorderView.center.y);
    [_saveBtn setImage:[UIImage imageNamed:@"style_default_1.7.0_save"] forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(saveRecorderResult) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_saveBtn];

    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 16)];
    _timeLabel.center = CGPointMake(_recorderView.center.x, _recorderView.lsqGetOriginY/2);
    _timeLabel.textColor = [UIColor lsqClorWithHex:@"#4A4A4A"];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.text = NSLocalizedString(@"lsq_movieEditor_reminder_text",@"长按进行录制");
    [backView addSubview:_timeLabel];
    
}

#pragma mark - 长按手势方法

- (void)longPressEvent:(UILongPressGestureRecognizer *)gestureRecognizer;
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self finishRecordingAudio];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self startRecordingAudio];
    }
}

#pragma mark - click method

- (void)deleteRecorderResult;
{
    if (_resultAudioPath) {
        [TuSDKTSFileManager deletePath:_resultAudioPath];
    }
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    _timeLabel.text = NSLocalizedString(@"lsq_movieEditor_reminder_text",@"长按进行录制");
    if (_recorderCompletedHandler) {
        _recorderCompletedHandler(nil);
    }
    [self removeFromSuperview];
}

- (void)saveRecorderResult;
{
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    _timeLabel.text = NSLocalizedString(@"lsq_movieEditor_reminder_text",@"长按进行录制");
    if (_recorderCompletedHandler) {
        _recorderCompletedHandler(_resultAudioPath);
    }

    [self removeFromSuperview];
}

#pragma mark - recorder method

- (void)startRecordingAudio;
{
    if (_resultAudioPath) {
        [TuSDKTSFileManager deletePath:_resultAudioPath];
    }

    // recorder start
    if (!_audioRecorder) {
        _audioRecorder = [[TuSDKTSAudioRecorder alloc]init];
        _audioRecorder.maxRecordingTime = _recorderDuration;
        _audioRecorder.recordDelegate = self;
    }
    [_audioRecorder startRecording];
    _deleteBtn.enabled = NO;
    _saveBtn.enabled = NO;
    [[TuSDK shared].messageHub showToast:NSLocalizedString(@"lsq_record_audio_started",@"录音已经开始")];
    _timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"lsq_movieEditor_remainSecond_text",@"剩余%ld秒"),(long)_recorderDuration];
    [self performSelector:@selector(changeRecorderTime) withObject:nil afterDelay:1];
}

- (void)finishRecordingAudio;
{
    // recorder finish
    [_audioRecorder finishRecording];
    _deleteBtn.enabled = YES;
    _saveBtn.enabled = YES;
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    _timeLabel.text = NSLocalizedString(@"lsq_api_usage_finish_recording",@"结束录音");
}

- (void)changeRecorderTime;
{
    NSInteger time = (NSInteger)(self.recorderDuration - _audioRecorder.duration);
    time = time < 0 ? 0 : time;
    _timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"lsq_movieEditor_remainSecond_text",@"剩余%ld秒"),(long)time];
    [self performSelector:@selector(changeRecorderTime) withObject:nil afterDelay:1];
}

#pragma mark - TuSDKTSAudioRecoderDelegate

// 状态通知代理
- (void)onAudioRecoder:(TuSDKTSAudioRecorder *)recoder statusChanged:(lsqAudioRecordingStatus)status;
{
    if (status == lsqAudioRecordingStatusCompleted)
    {
        _deleteBtn.enabled = YES;
        _saveBtn.enabled = YES;
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_record_complete",@"录制完成")];
    }else if (status == lsqAudioRecordingStatusFailed)
    {
        _deleteBtn.enabled = YES;
        _saveBtn.enabled = YES;
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_record_audio_failed",@"录制失败，请重新录制")];
    }else if(status == lsqAudioRecordingStatusCancelled)
    {
        _deleteBtn.enabled = YES;
        _saveBtn.enabled = YES;
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_record_audio_cancelled",@"录制已经取消")];
    }
}

// 结果通知代理
- (void)onAudioRecoder:(TuSDKTSAudioRecorder *)recoder result:(TuSDKAudioResult *)result;
{
    if (result.audioPath) {
        _resultAudioPath = result.audioPath;
    }
}


@end
