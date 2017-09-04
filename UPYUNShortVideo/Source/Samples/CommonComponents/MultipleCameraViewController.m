//
//  MultipleCameraViewController.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/23.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MultipleCameraViewController.h"


/**
 多功能相机示例，点击拍照，长按录制
 */
@implementation MultipleCameraViewController

#pragma mark - UI
// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    return YES;
}

// 是否允许旋转 IOS5
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

// 是否允许旋转 IOS6
-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Layout

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self destroyCamera];
    [self destroyVideoPlayer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 获取相机的权限并启动相机
    [self requireCameraPermission];
    // 设置全屏
    self.wantsFullScreenLayout = YES;
    [self setNavigationBarHidden:YES animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

-(void)requireAlbumPermission;
{
    // 测试相册访问权限
    [TuSDKTSAssetsManager testLibraryAuthor:^(NSError *error)
     {
         if (error) {
             [TuSDKTSAssetsManager showAlertWithController:self loadFailure:error];
         }
     }];
}

-(void)requireCameraPermission;
{
    // 开启访问相机权限
    [TuSDKTSDeviceSettings checkAllowWithController:self
                                               type:lsqDeviceSettingsCamera
                                          completed:^(lsqDeviceSettingsType type, BOOL openSetting)
     {
         if (openSetting) {
             lsqLError(@"Can not open camera");
             return;
         }
         [self startCamera];
         // 设置默认滤镜； 对应filterView创建时默认的 currentFilterTag 同样设置为 1；
         [_camera switchFilterWithCode:_videoFilters[0]];
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    // 滤镜列表，获取滤镜前往 TuSDK.bundle/others/lsq_tusdk_configs.json
    // TuSDK 滤镜信息介绍 @see-https://tusdk.com/docs/ios/self-customize-filter
    _videoFilters =  @[@"SkinPink016",@"SkinJelly016",@"Pink016",@"Fair016",@"Forest017",@"Paul016",@"MintGreen016", @"TinyTimes016", @"Year1950016"];
    _videoFilterIndex = 0;   
    _sessionQueue = dispatch_queue_create("org.lasque.tusdkvideo", DISPATCH_QUEUE_SERIAL);
    
    // 获取相册的权限
    [self requireAlbumPermission];
    [self initRecorderView];
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)initRecorderView
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    // 预览view的frame 应与 cameraView 的frame 一致
    _preView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeHeight)];
    _preView.hidden = YES;
    _preView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_preView];

    // 拍照展示IV   注：拍照得到的图片因方向在展示时不能全屏展示，需要设置 contentMode
    _takePictureIV = [[UIImageView alloc]initWithFrame:_preView.bounds];
    _takePictureIV.contentMode = UIViewContentModeScaleAspectFit;
    _takePictureIV.hidden = YES;
    [_preView addSubview:_takePictureIV];
    
    // 默认相机顶部控制栏
    _configBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, 54)];
    [_configBar addTopBarInfoWithTitle:nil
                        leftButtonInfo:@[@"style_default_1.6.0_back_default.png"]
                       rightButtonInfo:@[@"style_default_1.6.0_lens_overturn.png",@"style_default_1.6.0_flash_closed.png"]];
    _configBar.topBarDelegate = self;
    [self.view addSubview:_configBar];
    
    // 默认相机底部控制栏
    _bottomBar = [[ClickPressBottomBar alloc]initWithFrame:CGRectMake(0, self.view.lsqGetSizeHeight-164, rect.size.width , 164)];
    // 该录制模式需和 _camera 中的一致, bottomBar的UI逻辑中，默认为正常模式
    _bottomBar.bottomBarDelegate = self;
    [self.view addSubview:_bottomBar];
    
}

// 初始化贴纸栏
- (void)createStickerViewWithHeight:(CGFloat)viewHeight;
{
    _stickerView = [[StickerScrollView alloc]initWithFrame:CGRectMake(0, self.view.lsqGetSizeHeight, self.view.lsqGetSizeWidth, viewHeight)];
    _stickerView.stickerDelegate = self;
    _stickerView.cameraStickerType = lsqCameraStickersTypeFullScreen;
    _stickerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:_stickerView];
}

// 初始化滤镜栏
- (void)createFilterViewWithHeight:(CGFloat)viewHeight;
{
    _filterButtonView = [[FilterBottomButtonView alloc]initWithFrame:CGRectMake(0, self.view.lsqGetSizeHeight, self.view.lsqGetSizeWidth, viewHeight)];
    _filterButtonView.filterView.filterEventDelegate = self;
    
    // 相机初始化加载的默认的滤镜所对应的下标保持一致
    // 注： currentFilterTag 基于200 即： = 200 + 滤镜列表中某滤镜的对应下标
    _filterButtonView.filterView.currentFilterTag = 200;
    _filterButtonView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_filterButtonView.filterView createFilterWith:_videoFilters];
    [_filterButtonView.filterView refreshAdjustParameterViewWith:_currentFilter.code filterArgs:_currentFilter.filterParameter.args];
    _filterButtonView.filterView.beautyParamView.hidden = NO;
    _filterButtonView.filterView.filterChooseView.hidden = YES;
    [self.view addSubview:_filterButtonView];
}

#pragma mark - setter/getter

- (void)setRecordProgress:(CGFloat)recordProgress
{
    _recordProgress = recordProgress;
    _bottomBar.recordProgress = recordProgress;
}

#pragma mark - Camera
// 初始化camera
- (void)startCamera
{
    if (!_cameraView) {
        _cameraView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeHeight)];
        [self.view insertSubview:_cameraView atIndex:0];
        
        // 使用tapView 做中间的手势响应范围，为了防止和录制按钮的手势时间冲突(偶发)
        _tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 71, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
        _tapView.hidden = YES;
        [self.view addSubview:_tapView];
        // 添加手势方法
        // _tapView 显示会影响手动聚焦手势的响应，开启贴纸和滤镜栏时该 view 显示，关闭贴纸滤镜栏时隐藏，避免影响手动聚焦功能的使用。
        UITapGestureRecognizer *cameraTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cameraTapEvent)];
        [_tapView addGestureRecognizer:cameraTap];
    }
    
    // 启动摄像头
    if (_camera) return;
    _camera = [TuSDKRecordVideoCamera initWithSessionPreset:AVCaptureSessionPresetHigh
                                             cameraPosition:[AVCaptureDevice lsqFirstFrontCameraPosition]
                                                 cameraView:_cameraView];

    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    _camera.fileType = lsqFileTypeMPEG4;
    // 输出视频的画质，主要包含码率、压缩级别等参数 (默认为空，采用系统设置)
    _camera.videoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Medium2];
    // 设置委托
    _camera.videoDelegate = self;
    // 配置相机参数
    // 禁止触摸聚焦功能 (默认: NO)
    _camera.disableTapFocus = NO;
    // 是否禁用持续自动对焦
    _camera.disableContinueFoucs = NO;
    // 视频覆盖区域颜色 (默认：[UIColor blackColor])
    _camera.regionViewColor = [UIColor blackColor];
    // 禁用前置摄像头自动水平镜像 (默认: NO，前置摄像头拍摄结果自动进行水平镜像)
    _camera.disableMirrorFrontFacing = NO;
    // 默认闪光灯模式
    [_camera flashWithMode:AVCaptureFlashModeOff];
    // 相机采集帧率，默认30帧
    _camera.frameRate = 30;
    // 不保存到相册，可在代理方法中获取 result.videoPath（默认：YES，录制完成自动保存到相册）
    _camera.saveToAlbum = NO;
    // 启用智能贴纸
    _camera.enableLiveSticker = YES;
    // 设置水印，默认为空
    _camera.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
    // 设置水印图片的位置
    _camera.waterMarkPosition = lsqWaterMarkTopLeft;
    // 最大录制时长 10s
    _camera.maxRecordingTime = 10;
    // 最小录制时长 0s 在点击拍照、长按录制的UI交互下最小时长设为0
    _camera.minRecordingTime = 0;
    // 正常模式/续拍模式  - 注：Demo中点击拍照、长按录制的UI交互仅适用于正常模式，若需要点击拍照、长按进行续拍，可自行更改
    _camera.recordMode = lsqRecordModeNormal;
    //  设置使用录制相机最小空间限制,开发者可根据需要自行设置（单位：字节 默认：50M）
    _camera.minAvailableSpaceBytes  = 1024.f*1024.f*50.f;
    // 启动相机
    [_camera tryStartCameraCapture];
    
    // 默认为前置摄像头 此时应关闭闪光灯
    _flashModeIndex = 0;
    [self resetFlashBtnStatusWithBtnEnabled:NO];
}

#pragma mark - 自定义处理方法

// 根据value值获得对应的flash类型
- (AVCaptureFlashMode)getFlashModeByValue:(NSInteger)value
{
    if(value == 1){
        return AVCaptureFlashModeOn;
    }
    return AVCaptureFlashModeOff;
}


- (void)resetFlashBtnStatusWithBtnEnabled:(BOOL)enabled
{
    NSString *imageName = @"";
    
    if(_flashModeIndex == 1){
        imageName = @"style_default_1.6.0_flash_open.png";
    }else{
        imageName = @"style_default_1.6.0_flash_closed.png";
    }
    UIImage *image = [UIImage imageNamed:imageName];
    [_configBar changeBtnStateWithIndex:1 isLeftbtn:NO withImage:image withEnabled:enabled];
}

// 保存照片或录制的视频
- (void)savePictureOrVideo;
{
    if (!_takePictureIV.hidden) {
        // 保存照片
        [TuSDKTSAssetsManager saveWithImage:_takePictureIV.image compress:0 metadata:nil toAblum:nil completionBlock:^(id<TuSDKTSAssetInterface> asset, NSError *error) {
            if (!error) {
                _takePictureIV.image = nil;
                _takePictureIV.hidden = YES;
                [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
            }
        } ablumCompletionBlock:nil];
        
    }
    
    if (_videoPlayer && _videoPath) {
        // 保存视频，同时删除临时文件
        [TuSDKTSAssetsManager saveWithVideo:[NSURL fileURLWithPath:_videoPath] toAblum:nil completionBlock:^(id<TuSDKTSAssetInterface> asset, NSError *error) {
            if (!error) {
                [TuSDKTSFileManager deletePath:_videoPath];
                _videoPath = nil;
                [self destroyVideoPlayer];
                [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
            }
        } ablumCompletionBlock:nil];
    }
    _preView.hidden = YES;
}

// 删除照片或录制的视频
- (void)deletePictureOrVideo
{
    if (!_takePictureIV.hidden) {
        //清除图片
        _takePictureIV.image = nil;
        _takePictureIV.hidden = YES;
    }
    
    if (_videoPlayer) {
        // 删除视频临时文件
        [self destroyVideoPlayer];
        if (_videoPath) {
            [TuSDKTSFileManager deletePath:_videoPath];
            _videoPath = nil;
        }
    }
    _preView.hidden = YES;
}

// 获得视频文件后，开始播放视频
- (void)playVideo
{
    if (!_videoPath) return;
    _videoItem = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:_videoPath]];
    _videoPlayer = [[AVPlayer alloc]initWithPlayerItem:_videoItem];
    _videoPlayer.volume = 0.0;
    _videoLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];
    _videoLayer.frame = _cameraView.bounds;
    _videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [_preView.layer addSublayer:_videoLayer];
    _preView.hidden = NO;
    [_videoPlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loopPlayVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)loopPlayVideo:(NSNotification *)noti
{
    if (_videoPlayer) {
        AVPlayerItem *item = [noti object];
        [item seekToTime:kCMTimeZero];
        [_videoPlayer play];
    }
}

#pragma mark - 点击事件方法
- (void)cameraTapEvent
{
    // 恢复主底部栏 同时隐藏 贴纸栏或滤镜栏
    if (_bottomBar && _bottomBar.hidden) {
        if (_filterButtonView && !_filterButtonView.hidden) {
            // 动画隐藏滤镜栏
            [UIView animateWithDuration:0.2 animations:^{
                [_filterButtonView lsqSetOriginY:self.view.lsqGetSizeHeight];
            } completion:^(BOOL finished) {
                _filterButtonView.hidden = YES;
                _bottomBar.hidden = NO;
            }];
        }else if (_stickerView && !_stickerView.hidden) {
            // 动画隐藏贴纸栏
            [UIView animateWithDuration:0.2 animations:^{
                [_stickerView lsqSetOriginY:self.view.lsqGetSizeHeight];
            } completion:^(BOOL finished) {
                _stickerView.hidden = YES;
                _bottomBar.hidden = NO;
            }];
        }else{
            _bottomBar.hidden = NO;
        }
    }
    _tapView.hidden = YES;
}

#pragma mark - TopNavBarDelegate

/**
 左侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onLeftButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
    // 录制过程中，其他按钮禁止点击响应
    if ([_camera isRecording]) {
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 右侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onRightButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
    // 录制过程中，其他按钮禁止点击响应
    if ([_camera isRecording]) {
        return;
    }
    
    switch (btn.tag) {
        case lsqRightTopBtnFirst:
        {
            // 切换前后摄像头
            if (!btn.selected) {
                // 前置摄像头关闭闪光灯
                _flashModeIndex = 0;
                [self resetFlashBtnStatusWithBtnEnabled:NO];
            }else{
                [self resetFlashBtnStatusWithBtnEnabled:YES];
            }
            [_camera rotateCamera];
        }
        break;
        case lsqRightTopBtnSecond:
        {
            // 闪光灯按钮
            _flashModeIndex++;
            if (_flashModeIndex >=2){
                _flashModeIndex = 0;
            }
            [self resetFlashBtnStatusWithBtnEnabled:YES];
            
            dispatch_async(self.sessionQueue, ^{
                [_camera flashWithMode:[self getFlashModeByValue:_flashModeIndex]];
            });
        }
        break;
        default:
            break;
    }

}

#pragma mark - BottomBarDelegate

/**
 按钮点击的代理方法
 
 @param btn 按钮
 */
- (void)onBottomBtnClicked:(UIButton*)btn;
{
    // 录制过程中，其他按钮禁止点击响应
    if ([_camera isRecording]) {
        return;
    }
    
    if (btn == _bottomBar.recordButton)
    {
        //  录制按钮，点击拍照
        [_camera captureImage];
    }
    else if (btn == _bottomBar.stickerButton)
    {
        CGFloat stickerViewHeight = self.view.lsqGetSizeHeight - self.view.lsqGetSizeWidth - 74;
        _bottomBar.hidden = YES;
        if (_stickerView) {
            _stickerView.hidden = NO;
        }else{
            [self createStickerViewWithHeight:stickerViewHeight];
        }
        // 动画出现
        [UIView animateWithDuration:0.2 animations:^{
            [_stickerView lsqSetOriginY:(self.view.lsqGetSizeHeight - stickerViewHeight)];
        }];
        _tapView.hidden = NO;
    }
    else if (btn == _bottomBar.filterButton)
    {
        CGFloat filterViewHeight = self.view.lsqGetSizeHeight - self.view.lsqGetSizeWidth - 74;
        _bottomBar.hidden = YES;
        if (_filterButtonView) {
            _filterButtonView.hidden = NO;
        }else{
            [self createFilterViewWithHeight:filterViewHeight];
        }
        // 动画出现
        [UIView animateWithDuration:0.2 animations:^{
            [_filterButtonView lsqSetOriginY:(self.view.lsqGetSizeHeight - filterViewHeight)];
        }];
        _tapView.hidden = NO;
    }
    else if (btn == _bottomBar.deleteButton)
    {
        _configBar.hidden = NO;
        [_bottomBar deleteAndSaveVisible:NO];
        [self deletePictureOrVideo];
    }
    else if (btn == _bottomBar.saveButton)
    {
        _configBar.hidden = NO;
        [_bottomBar deleteAndSaveVisible:NO];
        [self savePictureOrVideo];
    }
}

/**
 
 按下录制按钮
 
 @param btn 按钮
 */
- (void)onRecordBtnPressStart:(UIButton*)btn;
{
    //  开始录制
    _videoPath = nil;
    if (![_camera isRecording]) {
        dispatch_async(self.sessionQueue, ^{
            [_camera startRecording];
        });
    }
}

/**
 
 松开录制按钮
 
 @param btn 按钮
 */
- (void)onRecordBtnPressEnd:(UIButton*)btn;
{
    //  结束录制
    if (_camera && [_camera isRecording]) {
        dispatch_async(self.sessionQueue, ^{
            [_camera finishRecording];
        });
    }

}

#pragma mark - StickerViewClickDelegate

/**
 贴纸选择

 @param stickerGroup stickerGroup TuSDKPFStickerGroup
 */
- (void)clickStickerViewWith:(TuSDKPFStickerGroup *)stickerGroup
{
    if (!stickerGroup) {
        // 为nil时 移除已有贴纸组
        [_camera removeAllLiveSticker];
        return;
    }
    // 是否正在使用该贴纸
    if (![_camera isGroupStickerUsed:stickerGroup]) {
        // 展示对应贴纸组
        [_camera showGroupSticker:stickerGroup];
    }
}

#pragma mark - FilterEventDelegate

/**
 进度条状态改变

 @param seekbar seekbar seekbar
 @param progress progress progress
 */
- (void)filterViewParamChanged
{
    // 设置滤镜参数
    [_currentFilter submitParameter];
}

- (void)filterViewSwitchFilterWithCode:(NSString *)filterCode
{
    // 切换滤镜
    [_camera switchFilterWithCode:filterCode];
}

#pragma mark - TuSDKVideoCameraDelegate

/**
 *  相机状态改变 (如需操作UI线程， 请检查当前线程是否为主线程)
 *
 *  @param camera 相机对象
 *  @param state  相机运行状态
 */
- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera stateChanged:(lsqCameraState)state{
    if (state == lsqCameraStateStarting) {
        // 开始录制
    }else if (state == lsqCameraStatePaused){
        // 暂停录制
    }
}

/**
 *  相机滤镜改变 (如需操作UI线程， 请检查当前线程是否为主线程)
 *
 *  @param camera    相机对象
 *  @param newFilter 新的滤镜对象
 */
- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera filterChanged:(TuSDKFilterWrap *)newFilter;
{
    // 赋值新滤镜 同时刷新滤镜的参数配置
    _currentFilter = newFilter;
    [_filterButtonView.filterView refreshAdjustParameterViewWith:newFilter.code filterArgs:newFilter.filterParameter.args];
}

#pragma mark - TuSDKRecordVideoCameraDelegate
/**
 *  视频录制完成
 *
 *  @param camerea 相机
 *  @param result  TuSDKVideoResult 对象
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea result:(TuSDKVideoResult *)result;
{
    // 通过相机初始化设置  _camera.saveToAlbum = NO;  result.videoPath 拿到视频的临时文件路径
    if (result.videoPath) {
        // 进行自定义操作，例如保存到相册
        // 因为最小录制时间为0， 故快速操作时会存在刚初始化相机就停止了录制，此时不应该显示录制结果,且同时删除无效的临时文件(设置了最小录制时间，则不需额外删除)
        if (_recordProgress > 0.0) {
            _videoPath = result.videoPath;
            [self playVideo];
            [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_record_complete", @"录制完成")];
            [_bottomBar deleteAndSaveVisible:YES];
            _configBar.hidden = YES;
        }else{
            // 删除视频的临时文件
            if (_videoPath) {
                [TuSDKTSFileManager deletePath:_videoPath];
                _videoPath = nil;
            }
            [_bottomBar deleteAndSaveVisible:NO];
        }
    }else{
        // _camera.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
    }
}

/**
 *  获得拍照结果
 *
 *  @param camerea 相机
 *  @param takedResult  拍照结果对象
 */
- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera takedResult:(TuSDKResult *)result error:(NSError *)error
{
    if (result.image) {
        _takePictureIV.image = result.image;
        _takePictureIV.hidden = NO;
        _preView.hidden = NO;
        _configBar.hidden = YES;
    }
}

/**
 录制进度改变

 @param camerea camerea TuSDKRecordVideoCamera
 @param progress progress description
 @param durationTime durationTime descriptdurationTimeion
 */
-(void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea recordProgressChanged:(CGFloat)progress durationTime:(CGFloat)durationTime
{
    // progress
    self.recordProgress = progress;
}

/**
 相机录制状态

 @param camerea camerea TuSDKRecordVideoCamera
 @param state state lsqRecordState
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea recordStateChanged:(lsqRecordState)state;
{
    if (state == lsqRecordStateRecordingCompleted) {
        // 录制完成
        [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"lsq_record_dealing", @"正在处理...")];
    }else if (state == lsqRecordStateRecording){
        // 正在录制
    }else if (state == lsqRecordStatePaused){
        // 暂停录制
    }else if (state == lsqRecordStateMerging){
        // 正在合成视频
    }else if (state == lsqRecordStateCanceled){
        // 取消录制
        [_bottomBar deleteAndSaveVisible:NO];
    }else if (state == lsqRecordStateSaveing){
        // 正在保存
    }
}

/**
 *  视频录制出错
 *
 *  @param camerea 相机
 *  @param error   错误对象
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea failedWithError:(NSError*)error;
{
    if (error.code == lsqRecordVideoErrorUnknow) {
        NSLog(@"录制失败：未知原因失败");
    }else if (error.code == lsqRecordVideoErrorSaveFailed){
        NSLog(@"录制失败：保存视频失败");
    }else if (error.code == lsqRecordVideoErrorLessMinDuration){
        NSLog(@"录制失败：小于最小时长");
    }else if (error.code == lsqRecordVideoErrorMoreMaxDuration){
        NSLog(@"录制失败：大于最大时长 请保存视频后继续录制");
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_moreMaxDuration", @"大于最大时长，请保存视频后继续录制")];
    }else if (error.code == lsqRecordVideoErrorNotEnoughSpace){
        NSLog(@"手机可用空间不足，请清理手机");
    }
}

#pragma mark - 后台前台切换
// 进入后台
- (void)enterBackFromFront
{
    if (_camera) {
            // 取消录制
        [_camera cancelRecording];
    }

    [self destroyVideoPlayer];
}

// 后台到前台
- (void)enterFrontFromBack
{
    if (_videoPath) {
        [self playVideo];
    }
}

// 销毁相机对象
- (void)destroyCamera
{
    if (_camera) {
        [_camera cancelRecording];
        [_camera destory];
        _camera = nil;
    }
}

// 销毁player相关对象
- (void)destroyVideoPlayer
{
    if (_videoPlayer) {
        [_videoItem.asset cancelLoading];
        [_videoItem cancelPendingSeeks];
        [_videoPlayer cancelPendingPrerolls];
        [_videoPlayer pause];
        [_videoLayer removeFromSuperlayer];
        _videoItem = nil;
        _videoPlayer = nil;
        _videoLayer = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)dealloc
{
    [self destroyCamera];
    [self destroyVideoPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
#if !OS_OBJECT_USE_OBJC
    if (_sessionQueue != NULL)
    {
        dispatch_release(_sessionQueue);
    }
#endif
}

@end
