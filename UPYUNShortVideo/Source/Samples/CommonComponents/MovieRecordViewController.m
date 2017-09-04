//
//  MovieRecordViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieRecordViewController.h"

/**
 *  视频录制相机示例
 */
@implementation MovieRecordViewController

#pragma mark - 基础配置方法
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

#pragma mark - 视图布局方法

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 进行页面跳转的时候，需要注释下方销毁相机的方法。
    // 相机页面销毁，不要忘记销毁相机
    // [self destroyCamera];
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
         // 设置默认滤镜  对应filterView创建时默认的 currentFilterTag 同样设置为 1
         [_camera switchFilterWithCode:_videoFilters[0]];

         // 进度条view依赖于camer中的最小以及最大录制时间的设置，故应先调用 startCamera 方法
         [self initProgressView];
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 滤镜列表，获取滤镜前往 TuSDK.bundle/others/lsq_tusdk_configs.json
    // TuSDK 滤镜信息介绍 @see-https://tusdk.com/docs/ios/self-customize-filter
    _videoFilters =  @[@"SkinPink016",@"SkinJelly016",@"Pink016",@"Fair016",@"Forest017",@"Paul016",@"MintGreen016", @"TinyTimes016", @"Year1950016"];
    _videoFilterIndex = 0;
    
    self.view.backgroundColor = lsqRGB(255, 255, 255);
    
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
    
    // 默认相机顶部控制栏
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, 44)];
    [_topBar addTopBarInfoWithTitle:nil
                     leftButtonInfo:@[[NSString stringWithFormat:@"video_style_default_btn_back.png+%@",NSLocalizedString(@"lsq_go_back", @"返回")]]
                    rightButtonInfo:@[@"video_style_default_btn_switch.png",@"video_style_default_btn_flash_off.png"]];
    _topBar.topBarDelegate = self;
    _topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topBar];
    
    // 默认相机底部控制栏
    _bottomBackView = [[UIView alloc]initWithFrame:CGRectMake(0, rect.size.width + 74, rect.size.width , rect.size.height - rect.size.width - 74)];
    _bottomBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomBackView];
    _bottomBar = [[RecordVideoBottomBar alloc]initWithFrame:_bottomBackView.bounds];
    // 该录制模式需和 _camera 中的一致, bottomBar的UI逻辑中，默认为正常模式
    _bottomBar.recordMode = _inputRecordMode;
    _bottomBar.bottomBarDelegate = self;
    [_bottomBar setBackgroundColor:[UIColor whiteColor]];
    [_bottomBackView addSubview:_bottomBar];
    _bottomBar.albumButton.hidden = YES;
    _bottomBar.albumLabel.hidden = YES;
}

- (void)initProgressView
{
    if (!_camera) return;
    
    // 添加时间进度条
    _underView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, self.view.lsqGetSizeWidth, 30)];
    [_underView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
    [self.view addSubview:_underView];
    
    // 显示view的进度
    _aboveView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, _underView.lsqGetSizeHeight)];
    _aboveView.backgroundColor = HEXCOLOR(0x22bbf4);
    [_underView addSubview:_aboveView];
    
    // 显示最小时间位置view
    _minSecondView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, _underView.lsqGetSizeHeight)];
    _minSecondView.center = CGPointMake(_underView.lsqGetSizeWidth*(_camera.minRecordingTime*1.0/_camera.maxRecordingTime), _underView.lsqGetSizeHeight/2);
    _minSecondView.backgroundColor = [UIColor whiteColor];
    [_underView addSubview:_minSecondView];
}

// 初始化滤镜栏
- (void)createFilterView
{
    if (!_filterBottomView) {
        CGFloat filterViewHeight = _bottomBackView.lsqGetSizeHeight;
        _filterBottomView = [[FilterBottomButtonView alloc]initWithFrame:CGRectMake(0, (_bottomBackView.lsqGetSizeHeight - filterViewHeight)/2, self.view.lsqGetSizeWidth, filterViewHeight)];
        _filterBottomView.filterView.filterEventDelegate = self;
        
        // 应与 相机初始化加载的默认滤镜所 对应的下标保持一致
        _filterBottomView.filterView.currentFilterTag = 200;
        _filterBottomView.backgroundColor = [UIColor whiteColor];
        [_filterBottomView.filterView createFilterWith:_videoFilters];
        [_filterBottomView.filterView refreshAdjustParameterViewWith:_currentFilter.code filterArgs:_currentFilter.filterParameter.args];
        _filterBottomView.filterView.beautyParamView.hidden = NO;
        _filterBottomView.filterView.filterChooseView.hidden = YES;
        
        [_bottomBackView addSubview:_filterBottomView];
    }
}

// 初始化贴纸栏
- (void)createStikerView
{
    if (!_stickerView) {
        CGFloat stickerViewHeight = _bottomBackView.lsqGetSizeHeight - 10;
        _stickerView = [[StickerScrollView alloc]initWithFrame:CGRectMake(0, (_bottomBackView.lsqGetSizeHeight - stickerViewHeight), self.view.lsqGetSizeWidth, stickerViewHeight)];
        _stickerView.stickerDelegate = self;
        _stickerView.cameraStickerType = lsqCameraStickersTypeSquare;
        _stickerView.backgroundColor = [UIColor whiteColor];
        [_bottomBackView addSubview:_stickerView];
    }
}

// 重置录制的UI界面
- (void)resetRecordUI
{
    // 恢复进度条
    [self changeNodeViewWithLocation:0];
    // 恢复录制按钮
    [_bottomBar recordBtnIsRecordingStatu:NO];
}

#pragma mark - setter getter方法

- (void)setRecoderProgress:(CGFloat)recoderProgress
{
    if (_recoderProgress == recoderProgress) return;
    
    _recoderProgress = recoderProgress;
    if (_camera) {
        [_aboveView lsqSetSizeWidth:_underView.lsqGetSizeWidth*recoderProgress];
        [_bottomBar enabledBtnWithComplete: ([_aboveView lsqGetSizeWidth]>_minSecondView.center.x ? YES : NO)];
        if (_camera.recordMode == lsqRecordModeKeep && (_camera.videoCameraStatue == lsqRecordStatePaused || _recoderProgress == 1)) {
            // 续拍模式下，中间的暂停状态为 lsqRecordStatePaused，此时手势已经松开，但是松开后会有一次progress的调用，故在此新节点
            // 注：SDK中的续拍模式下，是会在 pauseRecording 调用之后(此时state 为 lsqRecordStatePaused)还有一次progress的校对通知，Demo中以暂停后的校对progress为准
            [self changeNodeViewWithLocation:_aboveView.lsqGetSizeWidth + _aboveView.lsqGetOriginX];
        }

    }
}

/*
   noteX 为-1:  代表 从大至小减一个
   noteX 为0 : 移除所有已有noteView
   noteX 大于0: 增加noteView，但须大于数组中已有的最后一个元素
*/
- (void)changeNodeViewWithLocation:(CGFloat)noteX
{
    if (!_aboveView) return;
    if (!_nodesLocation)
    {
        _nodesLocation = [[NSMutableArray alloc]init];
    }
    
    if (noteX > 0) {
        // 增一个
        UIView *noteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, _underView.lsqGetSizeHeight)];
        noteView.center = CGPointMake(noteX, _underView.lsqGetSizeHeight/2);
        noteView.backgroundColor = lsqRGB(217, 217, 217);
        noteView.tag = 300 + _nodesLocation.count;
        [_underView addSubview:noteView];
        [_nodesLocation addObject:@(noteX)];
    }
    
    if (noteX == -1) {
        if (_nodesLocation.count == 0) {
            return;
        }
        // 减一个
        for (UIView *view in _underView.subviews) {
            if (view.tag == _nodesLocation.count-1 + 300) {
                [view removeFromSuperview];
            }
        }
        [_nodesLocation removeObjectAtIndex:_nodesLocation.count-1];
    }
    
    if (noteX == 0) {
        if (_camera && _camera.recordMode == lsqRecordModeNormal) {
            // 正常模式下 恢复进度条
            [_aboveView lsqSetSizeWidth:0];
            return;
        }
        if (_nodesLocation.count == 0) {
            return;
        }
        // 清空； 注意: 若再当前VC中其他UIview的tag设置了300以上的值，需注意这一处的判断
        for (UIView *view in _underView.subviews) {
            if (view.tag >= 300) {
                [view removeFromSuperview];
            }
        }
        [_nodesLocation removeAllObjects];
    }
    
    // 设置进度条的值
    _newProgressLocation = _nodesLocation.count>0?_nodesLocation[_nodesLocation.count -1].floatValue:0.0;
    [_aboveView lsqSetSizeWidth: _newProgressLocation];

    // 设置后退和确认按钮
    [_bottomBar enabledBtnWithCancle: (_nodesLocation.count>0 ? YES : NO)];
    [_bottomBar enabledBtnWithComplete: ([_aboveView lsqGetSizeWidth]>_minSecondView.center.x ? YES : NO)];

}

#pragma mark - TuSDK Camera

// 初始化camera
- (void)startCamera
{
    if (!_cameraView) {
        _cameraView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeHeight)];
        [self.view insertSubview:_cameraView atIndex:0];
        
        // 使用tapView 做中间的手势响应范围，为了防止和录制按钮的手势时间冲突(偶发)
        _tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 74, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
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
    // 设置委托
    _camera.videoDelegate = self;
    // 配置相机参数
    // 相机预览画面区域显示算法
    _camera.regionHandler = [[CustomTuSDKCPRegionDefaultHandler alloc]init];

    // 输出 1:1 画幅视频
    _camera.cameraViewRatio = 1.0;
    // 指定比例后，如不指定尺寸，SDK 会根据设备情况自动输出适应比例的尺寸
    // _camera.outputSize = CGSizeMake(640, 640);
    
    // 输出视频的画质，主要包含码率、分辨率等参数 (默认为空，采用系统设置)
    _camera.videoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Medium2];
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
    // 最大录制时长 8s
    _camera.maxRecordingTime = 8;
    // 最小录制时长 2s
    _camera.minRecordingTime = 1;
    // 正常模式/续拍模式  - 注：该录制模式需和 _bottomBar 中的一致, 若不使用这套UI逻辑，可进行自定义交互操作
    _camera.recordMode = _inputRecordMode;
    //  设置使用录制相机最小空间限制,开发者可根据需要自行设置（单位：字节 默认：50M）
     _camera.minAvailableSpaceBytes  = 1024.f*1024.f*50.f;
    
    // 启动相机
    [_camera tryStartCameraCapture];
    
    // 默认为前置摄像头 此时应关闭闪光灯
    _flashModeIndex = 0;
    [self resetFlashBtnStatusWithBtnEnabled:NO];
}

// 开始录制
- (void)startRecording
{
    dispatch_async(self.sessionQueue, ^{
        [_camera startRecording];
    });
}

// 暂停录制
- (void)pauseRecording
{
    dispatch_async(self.sessionQueue, ^{
        [_camera pauseRecording];
    });
}

// 结束录制
- (void)finishRecording
{
    dispatch_async(self.sessionQueue, ^{
        [_camera finishRecording];
    });
}

// 取消录制
- (void)cancelRecording
{
    dispatch_async(self.sessionQueue, ^{
        [_camera cancelRecording];
    });
}

#pragma mark - 自定义配置方法

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
        imageName = @"video_style_default_btn_flash_on";
    }else{
        imageName = @"video_style_default_btn_flash_off";
    }
    UIImage *image = [UIImage imageNamed:imageName];
    [_topBar changeBtnStateWithIndex:1 isLeftbtn:NO withImage:image withEnabled:enabled];
}

#pragma mark - CameraView TapEvent

- (void)cameraTapEvent
{
    // 恢复主底部栏 同时隐藏 贴纸栏或滤镜栏
    if (!_bottomBar) return;
    
    if (_bottomBar.hidden) {
        _bottomBar.hidden = NO;
        if (_filterBottomView) {
            _filterBottomView.hidden = YES;
        }
        if (_stickerView) {
            _stickerView.hidden = YES;
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
    
    // 返回按钮
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
            if (!btn.selected) {  // YES 为后置， NO为后置
                // 前置摄像头是关闭闪光灯
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
    if (btn != _bottomBar.recordButton) {
        // 录制过程中，其他按钮禁止点击响应
        if ([_camera isRecording]) {
            return;
        }
    }
    
    if (btn == _bottomBar.recordButton)
    {
        if (_camera && _camera.recordMode == lsqRecordModeNormal)
        {
            // 正常模式事件响应
            if (![_camera isRecording]) {
                [_bottomBar recordBtnIsRecordingStatu:YES];
                [self startRecording];
            }else{
                // 判断是否大于最小时间
                if (_aboveView.lsqGetSizeWidth < _minSecondView.center.x) {
                    [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_error_too_short", @"不能低于最小时间")];
                    return;
                }
                [_bottomBar recordBtnIsRecordingStatu:NO];
                [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"lsq_movie_saving", @"正在保存...")];
                [self finishRecording];
            }
        }
    }
    else if (btn == _bottomBar.stickerButton)
    {
        _bottomBar.hidden = YES;
        _tapView.hidden = NO;
        if (_stickerView) {
            _stickerView.hidden = NO;
        }else{
            [self createStikerView];
        }

    }
    else if (btn == _bottomBar.albumButton)
    {
        btn.hidden = YES;
    }
    else if (btn == _bottomBar.filterButton)
    {
        _tapView.hidden = NO;
        _bottomBar.hidden = YES;
        if (_filterBottomView) {
            _filterBottomView.hidden = NO;
        }else{
            [self createFilterView];
        }
    }
    else if (btn == _bottomBar.cancelButton)
    {
        // 后退按钮
        // 删除最后一段录制的视频片段
        [_camera popMovieFragment];
        [self changeNodeViewWithLocation:-1];
    }
    else if (btn == _bottomBar.completeButton)
    {
        // 结束录制
        if (_aboveView.lsqGetSizeWidth >= _minSecondView.center.x) {
            [self finishRecording];
        }else{
            [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_save_error_too_short", @"不能低于最小时间")];
        }
    }
}

/**
 
 按下录制按钮
 
 @param btn 按钮
 */
- (void)onRecordBtnPressStart:(UIButton*)btn;
{
    // 按下
    if (![_camera isRecording]) {
        [self startRecording];
    }
}

/**
 
 松开录制按钮
 
 @param btn 按钮
 */
- (void)onRecordBtnPressEnd:(UIButton*)btn;
{
    // 松开
    [self pauseRecording];
}

#pragma mark -- 贴纸栏点击事件 StickerViewClickDelegate
- (void)clickStickerViewWith:(TuSDKPFStickerGroup *)stickerGroup
{
    if (!stickerGroup) {
        // 为nil时 移除已有贴纸组
        [_camera removeAllLiveSticker];
        return;
    }
    // 是否正在使用
    if (![_camera isGroupStickerUsed:stickerGroup])
    {
        // 展示对应贴纸组
        [_camera showGroupSticker:stickerGroup];
    }
}

#pragma mark - FilterEventDelegate

/**
 滤镜参数改变
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
        // 开始相机
    }else if (state == lsqCameraStatePaused){
        // 暂停相机
    }else if (state == lsqCameraStateStarted){
        // 相机启动完成
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
    
    [_filterBottomView.filterView refreshAdjustParameterViewWith:newFilter.code filterArgs:newFilter.filterParameter.args];
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
        UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
    }else{
        // _camera.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
    }
    
    if (_camera && _camera.recordMode == lsqRecordModeNormal) {
        [_bottomBar recordBtnIsRecordingStatu:NO];
    }

    // 自动保存后设置为 恢复进度条状态
    [self changeNodeViewWithLocation:0];
}


/**
 相机录制进度改变

 @param camerea camerea TuSDKRecordVideoCamera
 @param progress progress description
 @param durationTime durationTime durationTime
 */
-(void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea recordProgressChanged:(CGFloat)progress durationTime:(CGFloat)durationTime
{
    // 调整录制过程中的progress
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recoderProgress = progress ;
    });
}


/**
 视频状态改变

 @param camerea camerea TuSDKRecordVideoCamera
 @param state state lsqRecordState
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea recordStateChanged:(lsqRecordState)state;
{
    
    if (state == lsqRecordStateRecordingCompleted) {
        // 录制完成
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_record_complete", @"录制完成")];
    }else if (state == lsqRecordStateRecording){
        // 正在录制
    }else if (state == lsqRecordStatePaused){
        // 暂停录制
    }else if (state == lsqRecordStateMerging){
        // 正在合成视频
    }else if (state == lsqRecordStateCanceled){
        // 取消录制 同时 重置UI
        [self resetRecordUI];
    }else if (state == lsqRecordStateSaveing){
        // 正在保存
    }else if (state == lsqRecordStateSaveingCompleted){
        // 保存完成
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
        NSLog(@"可用空间不足，请清理手机");
    }
}

#pragma mark - 后台前台切换
// 进入后台
- (void)enterBackFromFront
{
    if (_camera) {
        // 取消录制
        [self cancelRecording];
    }
}

// 后台到前台
- (void)enterFrontFromBack
{
    // 恢复UI界面
    [self resetRecordUI];
}

// 销毁对象
- (void)destroyCamera
{
    if (_camera) {
        [_camera cancelRecording];
        [_camera destory];
        _camera = nil;
    }
}

- (void)dealloc
{
    [self destroyCamera];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
#if !OS_OBJECT_USE_OBJC
    if (_sessionQueue != NULL)
    {
        dispatch_release(_sessionQueue);
    }
#endif
}


@end
