//
//  MovieEditorViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/15.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditorViewController.h"

#import "UPYUNConfig.h"

@implementation MovieEditorViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置全屏
    self.wantsFullScreenLayout = YES;
    [self setNavigationBarHidden:YES animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    
    

    
}

#pragma mark - 视图布局方法

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self destroyMovieEditor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self lsqInitView];
    // 设置默认数据
    // 设置默认的MV效果覆盖范围，此处应与UI保持一致
    _mvStartTime = 0;
    _mvEndTime = _endTime - _startTime;
    _mediaEffectTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_mvStartTime endSeconds:_endTime];
    _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;
    _dubAudioVolume = 0.5;
    [self initSettingsAndPreview];
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)lsqInitView
{
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect rect = [[UIScreen mainScreen] applicationFrame];

    // 滤镜列表
    _videoFilters =  @[@"Original04",@"Fair04",@"Pink005",@"Forest04",@"Sundown04",@"Sakura04",@"Paul04", @"Lavender04", @"Manhattan04", @"Dusk05", @"TinyTimes04", @"Vivid04", @"Year195004",@"Missing04",@"Grapefruit04",@"BabyPink004"];

    
    // 默认相机顶部控制栏
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, 44)];
    [_topBar setBackgroundColor:[UIColor whiteColor]];
    _topBar.topBarDelegate = self;
    [_topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_movieEditor", @"视频编辑")
                     leftButtonInfo:@[[NSString stringWithFormat:@"video_style_default_btn_back.png+%@",NSLocalizedString(@"lsq_go_back", @"返回")]]
                    rightButtonInfo:@[NSLocalizedString(@"lsq_save_video", @"保存")]];
    [self.view addSubview:_topBar];
    
    // 视频播放view
    _previewView = [[UIView alloc]initWithFrame:CGRectMake(0, _topBar.lsqGetSizeHeight, rect.size.width, rect.size.width)];
    _previewView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_previewView];
    _videoView = [[UIView alloc]initWithFrame:_previewView.bounds];
    [_previewView addSubview:_videoView];
    
    // 播放按钮
    _playBtn = [[UIButton alloc]initWithFrame:_previewView.frame];
    [_playBtn addTarget:self action:@selector(clickPlayerBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];
    
    _playBtnIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _playBtnIcon.center = CGPointMake(_playBtn.lsqGetSizeWidth/2, _playBtn.lsqGetSizeHeight/2);
    _playBtnIcon.image = [UIImage imageNamed:@"video_style_default_crop_btn_record"];
    [_playBtn addSubview:_playBtnIcon];
    
    // 底部栏控件
    _bottomBar = [[MovieEditerBottomBar alloc]initWithFrame:CGRectMake(0, rect.size.width + 44, rect.size.width , rect.size.height - rect.size.width - 44)];
    _bottomBar.bottomBarDelegate = self;
    _bottomBar.videoDuration = self.endTime - self.startTime;
    _bottomBar.videoFilters = _videoFilters;
    _bottomBar.filterView.currentFilterTag = 200;
    [self.view addSubview:_bottomBar];


}

#pragma mark - 初始化 movieEditor 

- (void)initSettingsAndPreview
{
    TuSDKMovieEditorOptions *options = [TuSDKMovieEditorOptions defaultOptions];
    // 设置视频地址
    options.inputURL = self.inputURL;
    // 设置视频截取范围
    options.cutTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_startTime endSeconds:_endTime];
    // 是否按照时间播放
    options.playAtActualSpeed = YES;
    // 设置裁剪范围 注：该参数对应的值均为比例值，即：若视频展示View总高度800，此时截取时y从200开始，则cropRect的 originY = 偏移位置/总高度， 应为 0.25, 其余三个值同理
    options.cropRect = _cropRect;
    // 设置编码视频的画质
    options.encodeVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_High1];
    // 是否保留原音
    options.enableVideoSound = YES;

    _movieEditor = [[TuSDKMovieEditor alloc]initWithPreview:_videoView options:options];
    
    

    
    
    _movieEditor.delegate = self;
    
    /*设置贴纸出现的默认时间范围 （开始时间~结束时间，注：基于裁剪范围，如原视频8秒，裁剪2~7秒的内容，此时贴纸时间范围为1~2，即原视频的3~4秒）
     * 注： 应与顶部的缩略图滑动栏的默认范围一致
     */
//    _movieEditor.mvItemTimeRange = [[TuSDKMVEffectData alloc]initEffectInfoWithStart:_mvStartTime end:_mvEndTime type:lsqMVEffectDataTypeStickerAudio];
    // 保存到系统相册 默认为YES
    _movieEditor.saveToAlbum = NO;
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    _movieEditor.fileType = lsqFileTypeMPEG4;
    // 是否开启美颜
    _movieEditor.enableBeauty = YES;
    // 设置水印，默认为空
    _movieEditor.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
    // 设置水印图片的位置
    _movieEditor.waterMarkPosition = lsqWaterMarkTopLeft;
    // 视频播放音量设置，0 ~ 1.0 仅在 enableVideoSound 为 YES 时有效
    _movieEditor.videoSoundVolume = 0.5;
    // 设置默认镜
    [_movieEditor switchFilterWithCode:_videoFilters[0]];
    // 加载视频，显示第一帧
    [_movieEditor loadVideo];
}

#pragma mark - 自定义事件方法
// 点击 播放/暂停 按钮事件
- (void)clickPlayerBtn:(UIButton *)sender
{
    if ([_movieEditor isPreviewing]) {
        // 暂停播放
        _playBtnIcon.hidden = false;
        [_movieEditor stopPreview];
    }else{
        // 开始播放
        _playBtnIcon.hidden = true;
        [_movieEditor startPreview];
    }
}

#pragma mark - TopNavBarDelegate

/**
 左侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onLeftButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
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
    // 保存按钮
    if([_movieEditor isPreviewing] ) [_movieEditor stopPreview];
    
    if ([_movieEditor isRecording]){
        // do nothing
    }else{
        [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"lsq_movie_saving", @"正在保存...")];
        [_movieEditor startRecording];
    }
}

#pragma mark - TuSDKMovieEditorDelegate

/**
 播放进度通知

 @param editor editor TuSDKMovieEditor
 @param progress progress description
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor progress:(CGFloat)progress
{
    // 注意：UI相关修改需要确认在主线程中进行
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_movieEditorStatus == lsqMovieEditorStatusPreviewing) {
            // 预览时
            _topThumbnailView.currentTime = progress*(_endTime-_startTime);
        }
    });
}

/**
 视频保存时间

 @param editor editor TuSDKMovieEditor
 @param result result TuSDKVideoResult
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor result:(TuSDKVideoResult *)result
{
    //保存成功后取消提示框 同时返回到root
    // 通过相机初始化设置  _movieEditor.saveToAlbum = NO;  result.videoPath 拿到视频的临时文件路径
//    NSLog(@"保存地址---%@", result.videoPath);

    
    if (result.videoPath) {
        // 进行自定义操作，例如保存到相册
        //UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
        /// 上传到UPYUN 存储空间
        NSString *saveKey = [NSString stringWithFormat:@"short_video_test_%d.mp4", arc4random() % 10];
        [[UPYUNConfig sharedInstance] uploadFilePath:result.videoPath saveKey:saveKey success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
            [[TuSDK shared].messageHub showSuccess:@"上传成功"];

            NSLog(@"file url：http://%@.b0.upaiyun.com/%@",[UPYUNConfig sharedInstance].DEFAULT_BUCKET, saveKey);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self popToRootViewControllerAnimated:YES];
            });
            
        } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
            
            NSLog(@"上传失败 error：%@", error);
            NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
            NSLog(@"上传失败 message：%@", responseBody);
            
            [[TuSDK shared].messageHub showSuccess:@"上传失败"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self popToRootViewControllerAnimated:YES];
            });
            
        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
        }];
        
        
        [[TuSDK shared].messageHub dismiss];
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
        
        
        
        
    }else{
        // _movieEditor.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
        [[TuSDK shared].messageHub dismiss];
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
    }
    
    
    
//    [self popToRootViewControllerAnimated:YES];

}

/**
 视频处理状态

 @param editor editor TuSDKMovieEditor
 @param status status lsqMovieEditorStatus
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor statusChanged:(lsqMovieEditorStatus)status
{
    _movieEditorStatus = status;
    
    
    for (UIView *aaview in _videoView.subviews) {
        for (id view222 in aaview.subviews) {
            NSLog(@"subview subview is %@", [view222 class]);
            NSString *classStr = [NSString stringWithFormat:@"%@", [view222 class]];
            
            if ([classStr isEqualToString:@"TuSDKLogoView"]) {
                UIView *bbview = view222;
                bbview.hidden = YES;
                [bbview removeFromSuperview];
                break;
            }
        }
    }
    
    if (status == lsqMovieEditorStatusPreviewingCompleted){
        [_movieEditor startPreview];
    }else if (status == lsqMovieEditorStatusPreviewingPause){
        // 注：此处进行是否正在预览判断，防止stopPreview后立即startPreview,造成按钮显示错乱
        if (![_movieEditor isPreviewing]) {
            _playBtnIcon.hidden = NO;
        }
    }else if (status == lsqMovieEditorStatusLoaded){
        NSLog(@"加载完成");
    }else if (status == lsqMovieEditorStatusLoadFailed) {
        NSLog(@"加载失败");
    }else if (status == lsqMovieEditorStatusRecordingCompleted){
        NSLog(@"录制完成");
    }else if (status == lsqMovieEditorStatusRecordingFailed){
        NSLog(@"录制失败");
        [[TuSDK shared].messageHub dismiss];
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_failed", @"录制失败")];
    }else if (status == lsqMovieEditorStatusRecordingCancelled){
        NSLog(@"取消录制");
        [[TuSDK shared].messageHub dismiss];
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_cancelled", @"取消录制")];
    }else if (status == lsqMovieEditorStatusPreviewing){
        NSLog(@"正在播放");
    }else if (status == lsqMovieEditorStatusRecording){
        NSLog(@"正在录制");
    }
}

/**
 视频处理出错

 @param editor editor TuSDKMovieEditor
 @param error error description
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor failedWithError:(NSError *)error;
{
    [[TuSDK shared].messageHub dismiss];
    [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_failed", @"录制失败")];
    
}

/**
 滤镜改变方法

 @param editor editor TuSDKMovieEditor
 @param newFilter newFilter TuSDKFilterWrap
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor filterChanged:(TuSDKFilterWrap *)newFilter;
{
    _currentFilter = newFilter;
    [_bottomBar refreshFilterParameterViewWith:newFilter.code filterArgs:newFilter.filterParameter.args];
}

#pragma mark - MovieEditorBottomBarDelegate

/**
 滤镜参数改变

 @param seekbar seekbar TuSDKICSeekBar
 @param progress progress progress
 */
- (void)movieEditorBottom_filterViewParamChangedWith:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress
{
    // 调整滤镜参数 根据tag判断是当前滤镜的哪一个参数
    NSInteger index = seekbar.tag;
    TuSDKFilterArg *arg = _currentFilter.filterParameter.args[index];
    arg.precent = progress;
    
    [_currentFilter submitParameter];
}

// 切换滤镜
- (void)movieEditorBottom_filterViewSwitchFilterWithCode:(NSString *)filterCode
{
    // 更换滤镜
    [_movieEditor switchFilterWithCode:filterCode];
}

// 改变美颜效果参数
- (void)movieEditorBottom_filterViewChangeBeautyLevel:(CGFloat)beautyLevel
{
    _movieEditor.beautyLevel = beautyLevel;
}

// 调整了bottom的整体的frame

/**
 调整 bottom 整体 frame

 @param mvViewDisplayed mvViewDisplayed description
 @param lastFrame lastFrame description
 @param newFrame newFrame description
 */
- (void)movieEditorBottom_adjustFrameWithMVDisplayed:(BOOL)mvViewDisplayed lastFrame:(CGRect)lastFrame newFrame:(CGRect)newFrame;
{
    CGFloat adjustHeight = newFrame.origin.y - lastFrame.origin.y;

    // 展示 MV View，此时需要移动camera的位置，同事现实缩略图；
    if (!_topThumbnailView) {
        _topThumbnailView = [[MovieEditorClipView alloc]initWithFrame:CGRectMake(0, 44 + 3, self.view.lsqGetSizeWidth, adjustHeight - 6)];
        _topThumbnailView.timeInterval = CMTimeGetSeconds(_movieEditor.cutTimeRange.duration);
        _topThumbnailView.clipDelegate = self;
        _topThumbnailView.minCutTime = 0.0;
        _topThumbnailView.clipsToBounds = YES;
        [self.view addSubview:_topThumbnailView];
        
        // 获取视频缩略图
        __weak MovieEditorViewController * wSelf = self;
        TuSDKVideoImageExtractor *imageExtractor = [TuSDKVideoImageExtractor createExtractor];
        imageExtractor.videoPath = wSelf.inputURL;
        // 缩略图个数结合滑动栏宽高计算，若需求不同，可另外更改
        int num = (int)ceilf(_topThumbnailView.lsqGetSizeWidth/(_topThumbnailView.lsqGetSizeHeight*3/5));
        NSLog(@"thumbnails number：%d",num);
        imageExtractor.extractFrameCount = num + 1;
        [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
            NSLog(@"get thumbnails = %@",images);
            _topThumbnailView.thumbnails = images;
        }];
        
        [_topThumbnailView lsqSetSizeHeight:0];
        _topThumbnailView.hidden = YES;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [_previewView lsqSetOriginY:_previewView.lsqGetOriginY + adjustHeight];
        _playBtn.frame = _previewView.frame;
        if (mvViewDisplayed) {
            _topThumbnailView.hidden = NO;
            [_topThumbnailView lsqSetSizeHeight:adjustHeight - 6];
        }else{
            [_topThumbnailView lsqSetSizeHeight:0];
        }
    } completion:^(BOOL finished) {
        if (!mvViewDisplayed) {
            _topThumbnailView.hidden = YES;
        }
    }];
    
}

/**
 切换 MV

 @param mvData mvData TuSDKMVStickerAudioEffectData
 */
- (void)movieEditorBottom_clickStickerMVWith:(TuSDKMVStickerAudioEffectData *)mvData;
{
    if (!mvData) {
        // 注：removeAllMVItem 方法即将废弃，建议使用 removeAllEffect 代替
        //        [_movieEditor removeAllMVItem];
        // 为nil时 移除已有贴纸组
        [_movieEditor removeAllEffect];
        return;
    }
    
    // 注： isMVItemUsed showMVItem 两个方法即将废弃，依然使用该方法时，请按照屏蔽的内容进行修改； 建议使用 addMediaEffect 代替
//    // 是否正在使用
//    if (![_movieEditor isMVItemUsed:mvData]){
//        // 展示对应贴纸组
//        _currentMediaEffect = mvData;
//        _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;
//        [_movieEditor showMVItem:mvData];
//    }
    
    [_movieEditor removeAllEffect];
    mvData.audioVolume = _dubAudioVolume;
    _currentMediaEffect = mvData;
    _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;
    [_movieEditor addMediaEffect:_currentMediaEffect];
    
    // 开始播放
    if ([_movieEditor isPreviewing]) {
        [_movieEditor stopPreview];
    }
    _playBtnIcon.hidden = YES;
    [_movieEditor startPreview];
}

/**
 切换 配音音乐
 
 @param mvData MV 数据
 */
- (void)movieEditorBottom_clickAudioWith:(TuSDKMediaAudioEffectData *)mvData;
{
    if (!mvData) {
        // 为nil时 移除已有 音乐特效
        [_movieEditor removeAllEffect];
        return;
    }
    
    [_movieEditor removeAllEffect];
    mvData.audioVolume = _dubAudioVolume;
    _currentMediaEffect = mvData;
    _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;
    [_movieEditor addMediaEffect:_currentMediaEffect];
    
    // 开始播放
    if ([_movieEditor isPreviewing]) {
        [_movieEditor stopPreview];
    }
    _playBtnIcon.hidden = YES;
    [_movieEditor startPreview];

}

/**
 改变音量调节栏参数
 
 @param volume 音量值
 @param index 调节栏的index
 */
- (void)movieEditorBottom_changeVolumeLevel:(CGFloat)volume  index:(NSInteger)index;
{
    if (index == 0) {
        if (_movieEditor) {
            _movieEditor.videoSoundVolume = volume;
        }
    }else if (index == 1){
        _dubAudioVolume = volume;
        if (_currentMediaEffect) {
            
            if ([_currentMediaEffect isMemberOfClass:[TuSDKMediaAudioEffectData class]]) {
                ((TuSDKMediaAudioEffectData *)_currentMediaEffect).audioVolume = volume;
                
            }else if ([_currentMediaEffect isMemberOfClass:[TuSDKMVStickerAudioEffectData class]]){
                ((TuSDKMVStickerAudioEffectData *)_currentMediaEffect).audioVolume = volume;
            }
        }
    }
}

#pragma mark - VideoClipViewDelegate
/**
 拖动到某位置处
 
 @param time 拖动的当前位置所代表的时间节点
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 */
- (void)chooseTimeWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus;
{
    if (isStartStatus == lsqClipViewStyleLeft) {
        // 调整开始时间
        _mvStartTime = time;
    }else if (isStartStatus == lsqClipViewStyleRight){
        // 调整结束时间
        _mvEndTime = time;
    }
    [_movieEditor seekToPreviewWithTime:CMTimeMakeWithSeconds(time, 1*NSEC_PER_SEC)];
}

/**
 拖动结束的事件方法
 */
- (void)slipEndEvent;
{
    // 设置贴纸出现的时间范围 （开始时间~结束时间，注：基于裁剪范围，如原视频8秒，裁剪2~7秒的内容，此时贴纸时间范围为1~2，即原视频的3~4秒）
    _mediaEffectTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_mvStartTime endSeconds:_mvEndTime];
    if (_currentMediaEffect) {
        _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;
    }
    // 恢复到开始的选择时间节点
    [_movieEditor seekToPreviewWithTime:CMTimeMakeWithSeconds(_mvStartTime, 1*NSEC_PER_SEC)];
}

/**
 拖动开始的事件方法
 */
- (void)slipBeginEvent;
{
    if ([_movieEditor isPreviewing]) {
        [_movieEditor stopPreview];
    }
}

#pragma mark - 后台前台切换
// 进入后台
- (void)enterBackFromFront
{
    if (_movieEditor) {
        if ([_movieEditor isRecording]) {
            // 调用 stopRecording 会将已处理的视频保存下来 cancelRecording 会取消已录制的内容
            [_movieEditor cancelRecording];
        }
        if ([_movieEditor isPreviewing]) {
            _playBtnIcon.hidden = false;
            [_movieEditor stopPreview];
        }
    }
}

// 后台到前台
- (void)enterFrontFromBack
{
    [[TuSDK shared].messageHub dismiss];
}

- (void)destroyMovieEditor
{
    if (_movieEditor) {
        [_movieEditor destroy];
        _movieEditor = nil;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_playBtn removeAllTargets];
    _topBar.topBarDelegate = nil;
    _bottomBar.bottomBarDelegate = nil;
    [_bottomBar removeFromSuperview];
    [_topThumbnailView removeFromSuperview];
    
    _bottomBar = nil;
    _topThumbnailView = nil;
}

- (void)dealloc
{
    [self destroyMovieEditor];
}

@end
