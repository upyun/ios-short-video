//
//  MovieEditorViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/15.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditorViewController.h"

@interface MovieEditorViewController() {
    // 视频当前预览进度
    CGFloat _videoProgress;
    // 当前选中的场景特效code
    NSString *_currentEffectCode;
    // 场景特效对应的颜色数组
    NSArray<UIColor *> *_effectColors;
}
@end

@implementation MovieEditorViewController

#pragma mark - 基础配置方法
// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        return NO;
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES animated:NO];
    if (![UIDevice lsqIsDeviceiPhoneX]) {
        [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
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

    [self lsqInitData];
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

- (void)lsqInitData
{
    // Warning: Demo 中相机录制中已默认添加美颜滤镜，视频编辑中不推荐使用美颜滤镜，否则滤镜效果叠加会影响最终视频的效果
    // 滤镜列表
    _videoFilterCodes =@[@"Olympus_1",@"Leica_1",@"Gold_1",@"Cheerful_1",@"White_1",@"s1950_1",@"Blurred_1",@"Newborn_1",@"Fade_1",@"NewYork_1"];
    // 场景特效code
    _videoEffectCodes = @[@"LiveShake01",@"LiveMegrim01",@"EdgeMagic01",@"LiveFancy01_1",@"LiveSoulOut01",@"LiveSignal01"];
    // 特效颜色数组
    _effectColors = @[lsqRGBA(250, 118, 82, 0.7), lsqRGBA(244, 161, 26, 0.7), lsqRGBA(255, 253, 80, 0.7),lsqRGBA(91, 242, 84, 0.7), lsqRGBA(22, 206, 252, 0.7), lsqRGBA(110, 160, 242, 0.7)];
}

- (void)lsqInitView
{
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect rect = [UIScreen mainScreen].bounds;

    // 默认相机顶部控制栏
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topY, rect.size.width, 44)];
    [_topBar setBackgroundColor:[UIColor whiteColor]];
    _topBar.topBarDelegate = self;
    [_topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_movieEditor", @"视频编辑")
                     leftButtonInfo:@[@"video_style_default_btn_back.png"]
                    rightButtonInfo:@[NSLocalizedString(@"lsq_save_video", @"保存")]];
    [self.view addSubview:_topBar];
    
    // 视频播放view
    _previewView = [[UIView alloc]initWithFrame:CGRectMake(0, _topBar.lsqGetOriginY+_topBar.lsqGetSizeHeight, rect.size.width, rect.size.width)];
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
    
    topY = rect.size.width + 44;
    CGFloat height = rect.size.height - rect.size.width - 44;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY += 44;
        height -= 78;
    }
    // 底部栏控件
    _bottomBar = [[MovieEditerBottomBar alloc]initWithFrame:CGRectMake(0, topY, rect.size.width , height)];
    _bottomBar.bottomBarDelegate = self;
    _bottomBar.videoDuration = self.endTime - self.startTime;
    _bottomBar.videoFilters = _videoFilterCodes;
    _bottomBar.filterView.currentFilterTag = 200;
    _bottomBar.videoURL = _inputURL;
    _bottomBar.topThumbnailView.timeInterval = _endTime - _startTime;
    _bottomBar.effectsView.effectsCode = _videoEffectCodes;
    
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
    // 视频输出尺寸 注：当使用 cropRect 设置了裁剪范围后，该参数不再生效
    // options.outputSize = CGSizeMake(720, 720);
    // 设置编码视频的画质
    options.encodeVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Low1];
    // 是否保留原音
    options.enableVideoSound = YES;

    _movieEditor = [[TuSDKMovieEditor alloc]initWithPreview:_videoView options:options];
    _movieEditor.delegate = self;
    
    // 保存到系统相册 默认为YES
    _movieEditor.saveToAlbum = NO;
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    _movieEditor.fileType = lsqFileTypeMPEG4;
    // 设置水印，默认为空
    _movieEditor.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
    // 设置水印图片的位置
    _movieEditor.waterMarkPosition = lsqWaterMarkTopRight;
    // 视频播放音量设置，0 ~ 1.0 仅在 enableVideoSound 为 YES 时有效
    _movieEditor.videoSoundVolume = 0.5;
    // 设置当前生效的特效(滤镜、场景特效、粒子特效)  注：滤镜、场景特效、粒子特效不能同时添加，当 EfficientEffectMode 为Default时 以后添加的特效为准，当Mode进行限定时，则以限定的模式为准
    _movieEditor.efficientEffectMode = lsqMovieEditorEfficientEffectModeDefault;
    // 设置默认镜
    [_movieEditor switchFilterWithCode:_videoFilterCodes[0]];
    // 加载视频，显示第一帧
    [_movieEditor loadVideo];
}

#pragma mark - 自定义事件方法
// 点击 播放/暂停 按钮事件
- (void)clickPlayerBtn:(UIButton *)sender
{
    if ([_movieEditor isPreviewing]) {
        // 暂停播放
        [self stopPreview];
    }else{
        // 开始播放
        [self startPreview];
    }
}

- (void)stopPreview
{
    _playBtnIcon.hidden = false;
    if ([_movieEditor isPreviewing])
        [_movieEditor stopPreview];
}

- (void)startPreview
{
    _playBtnIcon.hidden = true;
    [_movieEditor startPreview];
}

#pragma mark - 预览时场景特效处理
/**
 注：切换场景特效
*/
- (void)switchSceneEffectWithCode:(NSString *)effectCode;
{
    //...  切换时可做其他操作
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
        // 设置场景特效
        // 注： demo 中实现的交互逻辑仅一种，接口本身可支持多种，同样预览时设定该参数，预览画面也同样生效
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
    if (_movieEditorStatus == lsqMovieEditorStatusPreviewing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 预览时 更新UI
            _videoProgress = progress;
            _bottomBar.topThumbnailView.currentTime = progress*(_endTime-_startTime);
            if (!_bottomBar.effectsView.hidden)
                _bottomBar.effectsView.progress = progress;
            if (_currentEffectCode)
                [_bottomBar.effectsView.displayView addSegmentViewMoveToLocation:progress];
        });
    }

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
    if (result.videoPath) {
        // 进行自定义操作，例如保存到相册
        UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
        [[TuSDK shared].messageHub dismiss];
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
        
        
        /// 上传到UPYUN 存储空间
        NSString *saveKey = [NSString stringWithFormat:@"short_video_edit_%d.mp4", arc4random() % 10];
        NSString *imgSaveKey = [NSString stringWithFormat:@"short_video_edit_jietu_%d.jpg", arc4random() % 10];
        [[UPYUNConfig sharedInstance] uploadFilePath:result.videoPath saveKey:saveKey success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
            NSLog(@"file url：http://%@.b0.upaiyun.com/%@",[UPYUNConfig sharedInstance].DEFAULT_BUCKET, saveKey);
            //            [[TuSDK shared].messageHub showSuccess:@"上传成功"];
            /// 视频同步截图方法
            //            /// 相对地址前需要加上'/'表示根目录   source 需截图的视频相对地址,   save_as 保存截图的相对地址, point 截图时间点 hh:mm:ss 格式
            //            NSDictionary *task = @{@"source": [NSString stringWithFormat:@"/%@", saveKey], @"save_as": [NSString stringWithFormat:@"/%@", imgSaveKey], @"point": @"00:00:00"};
            //            [[UPYUNConfig sharedInstance] fileTask:task success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
            //                NSLog(@"截图成功--%@", responseBody);
            //                NSLog(@"截图 图片 url：http://%@.b0.upaiyun.com/%@",[UPYUNConfig sharedInstance].DEFAULT_BUCKET, imgSaveKey);
            //            } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
            //                NSLog(@"截图失败-error==%@--response==%@, responseBody==%@", error,  response, responseBody);
            //            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TuSDK shared].messageHub showSuccess:@"上传成功"];
                [self popToRootViewControllerAnimated:YES];
            });
            
        } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
            
            NSLog(@"上传失败 error：%@", error);
            NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
            NSLog(@"上传失败 message：%@", responseBody);
            
            //            [[TuSDK shared].messageHub showSuccess:@"上传失败"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TuSDK shared].messageHub showSuccess:@"上传失败"];
                //                [self popToRootViewControllerAnimated:YES];
            });
            
        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
            
        }];

        
        
        
    }else{
        // _movieEditor.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
        [[TuSDK shared].messageHub dismiss];
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
    }
    
    [self popToRootViewControllerAnimated:true];
}

/**
 视频处理状态

 @param editor editor TuSDKMovieEditor
 @param status status lsqMovieEditorStatus
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor statusChanged:(lsqMovieEditorStatus)status
{
    _movieEditorStatus = status;

    if (status == lsqMovieEditorStatusPreviewingCompleted){
        [self stopPreview];
        // 重置播放进度记录
        _videoProgress = 0;
        // 若此时在添加特效，则结束当前的添加，该操作方式只针对Demo中的逻辑，若需要其他交互逻辑，可根据要实现的操作进行修改
        if (_bottomBar.effectsView.displayView.segmentCount > 0)
            [_movieEditor addEndEffectWithMode:lsqMovieEditorEffectMode_Scene];
    }else if (status == lsqMovieEditorStatusPreviewingPause){
        // 注：此处进行是否正在预览判断，防止stopPreview后立即startPreview,造成按钮显示错乱
        if (![_movieEditor isPreviewing]) {
            _playBtnIcon.hidden = NO;
        }
    }else if (status == lsqMovieEditorStatusLoaded){
        NSLog(@"加载完成");
        [self clickPlayerBtn:_playBtn];
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
#pragma mark -- filter
/**
 滤镜参数改变

 @param seekbar seekbar TuSDKICSeekBar
 @param progress progress progress
 */
- (void)movieEditorBottom_filterViewParamChanged
{
    [_currentFilter submitParameter];
}

// 切换滤镜
- (void)movieEditorBottom_filterViewSwitchFilterWithCode:(NSString *)filterCode
{
    // 更换滤镜
    [_movieEditor switchFilterWithCode:filterCode];
}

#pragma mark -- mv
/**
 切换 MV

 @param mvData mvData TuSDKMVStickerAudioEffectData
 */
- (void)movieEditorBottom_clickStickerMVWith:(TuSDKMVStickerAudioEffectData *)mvData;
{
    if (!mvData) {
        // 为nil时 不添加贴纸 且移除已有贴纸组  注：removeAllEffect 方法更改为 removeAllMediaEffect
//        [_movieEditor removeAllEffect];
        [_movieEditor removeAllMediaEffect];
        return;
    }
    
    // 移除已有贴纸组  注：removeAllEffect 方法更改为 removeAllMediaEffect
    [_movieEditor removeAllMediaEffect];
    mvData.audioVolume = _dubAudioVolume;
    _currentMediaEffect = mvData;
    _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;
    // 添加贴纸
    [_movieEditor addMediaEffect:_currentMediaEffect];
    
    // 开始播放
    if ([_movieEditor isPreviewing]) {
        [_movieEditor stopPreview];
    }
    
    [self startPreview];
}

#pragma mark -- audio

/**
 切换 配音音乐
 
 @param mvData MV 数据
 */
- (void)movieEditorBottom_clickAudioWith:(TuSDKMediaAudioEffectData *)mvData;
{
    if (!mvData) {
        // 为nil时 移除已有 音乐特效  注：removeAllEffect 方法更改为 removeAllMediaEffect
        [_movieEditor removeAllMediaEffect];
        return;
    }
    
    [_movieEditor removeAllMediaEffect];
    mvData.audioVolume = _dubAudioVolume;
    _currentMediaEffect = mvData;
    _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;
    [_movieEditor addMediaEffect:_currentMediaEffect];
    
    // 开始播放
    if ([_movieEditor isPreviewing]) {
        [_movieEditor stopPreview];
    }
    [self startPreview];

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

#pragma mark -- effects

/**
 选中特效
 */
- (void)movieEditorBottom_effectsSelectedWithCode:(NSString *)effectCode;
{
    _currentEffectCode = effectCode;
    CMTime startTime = CMTimeMakeWithSeconds(_videoProgress * (_endTime - _startTime), 1*USEC_PER_SEC);
    [_movieEditor seekToPreviewWithTime:startTime];
    [self startPreview];
    [self switchSceneEffectWithCode:effectCode];
    [_bottomBar.effectsView.displayView addSegmentViewBeginWithStartLocation:_videoProgress WithColor:_effectColors[[_videoEffectCodes indexOfObject:effectCode]]];
    // 添加场景特效 begin 和 end 成对调用
    [_movieEditor addEffectWithCode:effectCode withMode:lsqMovieEditorEffectMode_Scene];
}

/**
 结束选中的特效
 */
- (void)movieEditorBottom_effectsEndWithCode:(NSString *)effectCode;
{
    _currentEffectCode = nil;
    [self stopPreview];
    [self switchSceneEffectWithCode:nil];
    [_bottomBar.effectsView.displayView addSegmentViewEnd];
    // 结束当前添加的场景特效 begin 和 end 成对调用
    [_movieEditor addEndEffectWithMode:lsqMovieEditorEffectMode_Scene];
    if (_bottomBar.effectsView.displayView.segmentCount > 0) {
        [_bottomBar.effectsView backBtnEnabled:YES];
    }
}

/**
 显示特效栏
 */
- (void)movieEditorBottom_effectsViewDisplay;
{
    [self stopPreview];
    CMTime time = CMTimeMakeWithSeconds(0, 1*USEC_PER_SEC);
    [_movieEditor seekToPreviewWithTime:time];
    _videoProgress = 0;
    _bottomBar.effectsView.displayView.currentLocation = 0;
}

/**
 移动视频的播放进度条
 */
- (void)movieEditorBottom_effectsMoveVideoProgress:(CGFloat)newProgress;
{
    [self stopPreview];
    _videoProgress = newProgress;
    CMTime newTime = CMTimeMakeWithSeconds(newProgress * (_endTime - _startTime), 1*USEC_PER_SEC);
    [_movieEditor seekToPreviewWithTime:newTime];
}

/**
 回删添加的特效
 */
- (void)movieEditorBottom_effectsBackEvent;
{
    if ([_movieEditor isPreviewing])
        [_movieEditor stopPreview];
    [_movieEditor removeLastEffectWithMode:lsqMovieEditorEffectMode_Scene];
    
    if (_bottomBar.effectsView.displayView.segmentCount == 0) {
        [_bottomBar.effectsView backBtnEnabled:NO];
    }
}

 #pragma mark -- bottomThumbnail
/**
 mv、配音缩略图 拖动到某位置处
 
 @param time 拖动的当前位置所代表的时间节点
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 */
- (void)movieEditorBottom_slipThumbnailViewWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus;
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
 mv、配音缩略图 拖动结束的事件方法
 */
- (void)movieEditorBottom_slipThumbnailViewSlipEndEvent;
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
 mv、配音缩略图 拖动开始的事件方法
 */
- (void)movieEditorBottom_slipThumbnailViewSlipBeginEvent;
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
    
    _bottomBar = nil;
}

- (void)dealloc
{
    [self destroyMovieEditor];
}

@end
