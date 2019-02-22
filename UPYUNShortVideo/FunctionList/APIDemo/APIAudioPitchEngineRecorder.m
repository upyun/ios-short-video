//
//  APIAudioPitchEngineRecorder.m
//  TuSDKVideo
//
//  Created by sprint on 2018/11/28.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "APIAudioPitchEngineRecorder.h"

@interface  APIAudioPitchEngineRecorder()<AVCaptureAudioDataOutputSampleBufferDelegate, TuSDKAudioPitchEngineDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureDeviceInput *_audioInput;
    AVCaptureAudioDataOutput *_audioOutput;
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_microphone;
    dispatch_queue_t audioProcessingQueue;
    
    AVAssetWriterInput *_audioWitreInput;
    AVAssetWriter *_writer;
    NSDictionary *_audioSetting;
    
    CMTime _startTime;
  
    // 音频变调处理引擎
    TuSDKAudioPitchEngine *_audioPitch;
}


@end

@implementation APIAudioPitchEngineRecorder

- (instancetype)init
{
    if (self = [super init]) {
        
        [self createCaptureSession];
     
    }
    return self;
}

#pragma mark  ------------------------------------ TuSDKAudioPitchEngine 核心 API BEGIN ------------------------------------

/**
 step1: 创建音频变调 API
 */
- (void)createAudioEnginePitch:(TuSDKAudioTrackInfo *)trackInfo;
{
    // step1: 创建变声 API
    
    _audioPitch = [[TuSDKAudioPitchEngine alloc] initWithInputAudioInfo:trackInfo];
    _audioPitch.delegate = self;
    _audioPitch.pitchType = self.pitchType;
}

/**
 step2: 设置音效类型
 */
- (void)setPitchType:(TuSDKSoundPitchType)pitchType;
{
    _pitchType = pitchType;
    _audioPitch.pitchType = pitchType;
}

/**
 step3: 将数据送入 TuSDKAudioPitchEngine
 @param sampleBuffer CMSampleBufferRef
 */
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;
{
    if (!_audioPitch) {
        
        /** 获取 CMSampleBufferRef 音频信息 */
        TuSDKAudioTrackInfo *trackInfo = [[TuSDKAudioTrackInfo alloc] initWithCMAudioFormatDescriptionRef:CMSampleBufferGetFormatDescription(sampleBuffer)];
        
        // 创建 TuSDKAudioPitchEngine 引擎
        [self createAudioEnginePitch:trackInfo];
    }
    _isRecording = YES;
    
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
    
    if (CMTIME_IS_INVALID(_startTime))
    {
        if (_writer.status != AVAssetWriterStatusWriting)
        {
            [_writer startWriting];
        }
        [_writer startSessionAtSourceTime:CMTimeMake(1, USEC_PER_SEC)];
        _startTime = currentSampleTime;
    }

    /**  调整 CMSampleBufferRef 写入时间 */
    CMSampleBufferRef tempSampleBuffer = [TuSDKMediaSampleBufferAssistant adjustPTS:sampleBuffer byOffset:_startTime];
    CMSampleBufferRef copyBuffer = [TuSDKMediaSampleBufferAssistant sampleBufferCreateCopyWithDeep:tempSampleBuffer];
    CMSampleBufferInvalidate(tempSampleBuffer);
    CFRelease(tempSampleBuffer);
    tempSampleBuffer = NULL;
    
    
    // 将音频数据送入处理引擎处理
    [_audioPitch processInputBuffer:copyBuffer];

}

#pragma mark TuSDKAudioPitchEngineDelegate

/**
 step4: 接收 TuSDKAudioPitchEnginec 处理后的数据
 @param pitchEngine 音频处理对象
 @param outputBuffer 变调变速后的音频数据
 @param autoRelease 是否释放音频数据，默认为NO
 @since v3.0
 */
- (void)pitchEngine:(TuSDKAudioPitchEngine *)pitchEngine syncAudioPitchOutputBuffer:(CMSampleBufferRef)outputBuffer autoRelease:(BOOL *)autoRelease;
{
    if (outputBuffer && _isRecording) {
        // NSLog(@"outputBuffer： %@",outputBuffer);
        if (_writer.status == AVAssetWriterStatusWriting)
        {
            CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(outputBuffer);
            
            while(!_audioWitreInput.readyForMoreMediaData) {
                NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
                [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
            }
            
            if (!_audioWitreInput.readyForMoreMediaData)
            {
                NSLog(@"2: Had to drop an audio frame %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, currentSampleTime)));
            }
            else {
                
                if (![_audioWitreInput appendSampleBuffer:outputBuffer])
                    NSLog(@"Problem appending audio buffer at time: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, currentSampleTime)));
            }
        }

    }
    
    // 标识 syncAudioPitchOutputBuffer 回调处理完成后  TuSDKAudioPitchEngine 是否自动回收 outputBuffer
    // 如果后续需要对 outputBuffer 异步处理，可以将 autoRelease 设为 NO,或对 outputBuffer 进行 deep copy，防止 syncAudioPitchOutputBuffer 处理完成后被回收。
    *autoRelease = YES;
}


#pragma mark  ------------------------------------ TuSDKAudioPitchEngine 核心 API END ------------------------------------


/**
 录音配置
 @return BOOL
 @since v3.0
 */
- (BOOL)createCaptureSession;
{
    if (_audioOutput)
        return NO;
    
    // Create the capture session
    _captureSession = [[AVCaptureSession alloc] init];
    
    [_captureSession beginConfiguration];
    
    _microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    _audioInput = [AVCaptureDeviceInput deviceInputWithDevice:_microphone error:nil];
    if ([_captureSession canAddInput:_audioInput])
    {
        [_captureSession addInput:_audioInput];
    }
    
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    if ([_captureSession canAddOutput:_audioOutput])
    {
        [_captureSession addOutput:_audioOutput];
    }
    else
    {
        NSLog(@"Couldn't add audio output");
    }
    
    audioProcessingQueue = dispatch_get_global_queue(0, 0);
    [_audioOutput setSampleBufferDelegate:self queue:audioProcessingQueue];
    
    [_captureSession commitConfiguration];
    return YES;
}

/**
 创建 writer
 @since v3.0
 */
- (void)createWriter;
{
    if (_writer) {
        [_writer cancelWriting];
        _writer = nil;
    }
    
    NSString *tempFilePath= [self generateTempFile];
    _outputFilePath = tempFilePath;
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:tempFilePath] fileType:AVFileTypeAppleM4A error:nil];
    _writer = writer;
    
    AVAssetWriterInput *audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:self.audioOutputSetting];
    if ([writer canAddInput:audioInput]) {
        [writer addInput:audioInput];
    }
    _audioWitreInput = audioInput;
    _audioWitreInput.expectsMediaDataInRealTime = NO;
    
    [writer startWriting];
}

/**
 音频输出设置

 @return NSDictionary
 */
- (NSDictionary *)audioOutputSetting;
{
    AVAudioSession *sharedAudioSession = [AVAudioSession sharedInstance];
    double preferredHardwareSampleRate;
    
    if ([sharedAudioSession respondsToSelector:@selector(sampleRate)])
    {
        preferredHardwareSampleRate = [sharedAudioSession sampleRate];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        preferredHardwareSampleRate = [[AVAudioSession sharedInstance] currentHardwareSampleRate];
#pragma clang diagnostic pop
    }
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSDictionary *audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                         [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                                         [ NSNumber numberWithFloat: preferredHardwareSampleRate], AVSampleRateKey,
                                         [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                                         [ NSNumber numberWithInt: 64000], AVEncoderBitRateKey,
                                         nil];
    
    return audioOutputSettings;
}

#pragma mark Manage the camera audio stream

/**
 开始录音
 @since  v3.0
 */
- (void)startRecord;
{
    if (![_captureSession isRunning] && ! _isRecording)
    {
        [self createWriter];
        [_captureSession startRunning];
    }
}

/**
 停止录音
 @since  v3.0
 */
- (void)stopRecord;
{
    if (![_captureSession isRunning]) return;
    
    [_captureSession stopRunning];
    _isRecording = NO;
    _startTime = kCMTimeInvalid;
    
    /** 通知 TuSDKAudioPitchEngine 数据输入完成，将队列中的数据吐出 */
    [_audioPitch processInputBufferEnd];
    
    typeof (self)weakSelf = self;
    [_writer finishWritingWithCompletionHandler:^{
        weakSelf->_writer = nil;
        [weakSelf.delegate mediaAssetAudioRecorder:weakSelf filePath:weakSelf->_outputFilePath];
    }];
}

/**
 取消录音
 @since  v3.0
 */
- (void)cancelRecord;
{
    if (![_captureSession isRunning]) return;
    [_captureSession stopRunning];
    _isRecording = NO;
    _startTime = kCMTimeInvalid;
    [_writer cancelWriting];
    _writer = nil;
}


/**
 清除临时文件
 @since v3.0
 */
- (void)clearMovieTempFiles;
{
    if (_outputFilePath)
        [TuSDKTSFileManager deletePath:_outputFilePath];
    _outputFilePath = nil;
}

/**
 移除录制声音配置
 @since v3.0
 */
- (void)removeInputsAndOutputs;
{
    [_captureSession beginConfiguration];
    if (_microphone != nil)
    {
        [_captureSession removeInput:_audioInput];
        [_captureSession removeOutput:_audioOutput];
        _audioInput = nil;
        _audioOutput = nil;
        _microphone = nil;
    }
    [_captureSession commitConfiguration];
}


#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
{
    if (!_captureSession.isRunning)
    {
        return;
    }
    else if (output == _audioOutput)
    {
        [self processSampleBuffer:sampleBuffer];
    }
}

/**
 生成临时文件路径
 @return 文件路径
 */
- (NSString *)generateTempFile;
{
    NSString *path = [TuSDKTSFileManager createDir:[TuSDKTSFileManager pathInCacheWithDirPath:lsqTempDir filePath:@""]];
    path = [NSString stringWithFormat:@"%@%f.m4v", path, [[NSDate date]timeIntervalSince1970]];
    
    unlink([path UTF8String]);
    
    return path;
}

/**
 销毁
 */
- (void)destory;
{
    [_audioOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
    [self removeInputsAndOutputs];
    
    if (_writer) {
        [_writer cancelWriting];
        _writer = nil;
    }
    if (_audioPitch) {
        [_audioPitch destory];
        _audioPitch = nil;
    }
}

- (void)dealloc
{
    [self destory];
}

@end
