//
//  MovieEditorViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/15.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditorViewController.h"
#import "Constants.h"

@interface MovieEditorViewController()

/** 反复慢动作时间特效应用的时间区间 */
@property (nonatomic, assign) CMTimeRange lastTimeEffectRange;

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

    [self lsqInitView];
    // 设置默认数据
    // 设置默认的MV效果覆盖范围，此处应与UI保持一致
    _mvStartTime = 0;
    _mvEndTime = CGFLOAT_MAX;
    _mediaEffectTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_mvStartTime endSeconds:_mvEndTime];
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
    _bottomBar.videoFilters = kVideoFilterCodes;
    _bottomBar.effectsView.effectsCode = kVideoEffectCodes;
    
    [self.view addSubview:_bottomBar];
}

-(lsqMovieEditorStatus)movieEditorStatus;
{
    return [_movieEditor status];
}

#pragma mark - 初始化 movieEditor 

- (void)initSettingsAndPreview
{
    TuSDKMovieEditorOptions *options = [TuSDKMovieEditorOptions defaultOptions];
    // 设置视频地址
    options.inputURL = self.inputURL;
    // 设置视频截取范围
    options.cutTimeRange = [TuSDKTimeRange makeTimeRangeWithStart:self.cutTimeRange.start duration:self.cutTimeRange.duration];
    
    // 设置裁剪范围 注：该参数对应的值均为比例值，即：若视频展示View总高度800，此时截取时y从200开始，则cropRect的 originY = 偏移位置/总高度， 应为 0.25, 其余三个值同理
    options.cropRect = _cropRect;
    // 视频输出尺寸 注：当使用 cropRect 设置了裁剪范围后，该参数不再生效
    // options.outputSize = CGSizeMake(720, 720);
    // 设置编码视频的画质
    options.encodeVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Medium1];
    // 是否保留原音
    options.enableVideoSound = YES;
    // 保存到系统相册 默认为YES
    options.saveToAlbum = NO;
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    options.fileType = lsqFileTypeMPEG4;
    // 设置水印，默认为空
    options.waterMarkImage = [UIImage imageNamed:@"sample_watermark.png"];
    // 设置水印图片的位置
    options.waterMarkPosition = lsqWaterMarkTopRight;

    _movieEditor = [[TuSDKMovieEditor alloc]initWithPreview:_videoView options:options];
    // 监听特效数据信息改变事件 
    _movieEditor.mediaEffectsDelegate = self;
    // 视频事件监听
    _movieEditor.loadDelegate = self;
    // 视频保存事件委托
    _movieEditor.saveDelegate = self;
    // 视频播放进度监听. 可获取监听播放进度及正在播放的切片信息
    _movieEditor.playerDelegate = self;
    
    // 视频播放音量设置，0 ~ 1.0 仅在 enableVideoSound 为 YES 时有效
    _movieEditor.videoSoundVolume = 0.5;
    
    // 加载视频，显示第一帧
    [_movieEditor loadVideo];
}

#pragma mark - 自定义事件方法
// 点击 播放/暂停 按钮事件
- (void)clickPlayerBtn:(UIButton *)sender
{
    if ([_movieEditor isPreviewing]) {
        // 暂停播放
        [self pausePreview];
    }else{
        // 开始播放
        [self startPreview];
    }
}

/**
 开始预览
 */
- (void)startPreview
{
    // 预览视频时验证时间特效区间是否有变化
    if (!CMTimeRangeEqual(_bottomBar.timeEffectThumbnailView.clipTimeRange, _lastTimeEffectRange))
    {
        _lastTimeEffectRange = _bottomBar.timeEffectThumbnailView.clipTimeRange;
        [self updateTimeEffect];
    }
    
    [_movieEditor startPreview];
}

/**
 暂停预览
 */
- (void)pausePreview
{
    [_movieEditor pausePreView];
}

/**
 停止预览
 */
- (void)stopPreview
{
    [_movieEditor stopPreview];
}

#pragma mark - TopNavBarDelegate

/**
 左侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onLeftButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
    [self stopPreview];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 返回按钮
        [weakSelf.navigationController popViewControllerAnimated:YES];
    });
    
}

/**
 右侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onRightButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
    [_movieEditor startRecording];
}

/**
 appendMediaTimeSlice / removeMediaTimeSlice 等操作切片的方法，会影响最终输出的时长，
 调用上述方法后需要修改界面上展示的所有进度
 */
- (void)resetAllProgressViews;
{
    _bottomBar.videoDuration = self.movieEditor.duration;
}

#pragma mark - TuSDKMovieEditorLoadDelegate 视频加载事件委托

/**
 视频加载进度回调

 @param editor 视频编辑器组件
 @param percentage 加载进度百分比 （0-1）
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor loadProgressChanged:(CGFloat)percentage;
{
    [TuSDKProgressHUD showMainThreadProgress:percentage withStatus:@"正在处理视频"];
}

/**
 视频加载完成

 @param editor 视频编辑器组件
 @param movieInfo 视频信息
 @param error 错误信息
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor assetInfoReady:(TuSDKMediaAssetInfo *)movieInfo error:(NSError *)error;
{
//    NSLog(@"[  movieInfo : %@]",movieInfo);
    if (error)
    {
        [TuSDKProgressHUD showWithStatus:@"视频加载失败"];
    }else
    {
        [TuSDKProgressHUD dismiss];
        [self resetAllProgressViews];
    }
}

/**
 加载状态回调
 
 @param editor TuSDKMovieEditor
 @param status 当前加载状态
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor loadStatusChanged:(lsqMovieEditorStatus)status;
{
    NSLog(@"mediaMovieEditor loadStatusChanged : %ld ",status);
    
    _playBtnIcon.hidden = (status == lsqMovieEditorStatusPreviewing);
    
    switch (status)
    {
        case lsqMovieEditorStatusLoading:
        {
            // 禁用所有事件
            self.view.userInteractionEnabled = NO;
            break;
        }
            
        case lsqMovieEditorStatusLoaded:
        {
            self.view.userInteractionEnabled = YES;
            break;
        }
            
        case lsqMovieEditorStatusLoadFailed:
        {
              [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_movie_load_failed", @"视频加载失败")];
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - TuSDKMovieEditorSaveDelegate 视频保存时间委托

/**
 视频保存完成
 
 @param editor TuSDKMovieEditor
 @param result 保存结果
 @param error 错误信息
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor saveResult:(TuSDKVideoResult *_Nullable)result error:(NSError *_Nullable)error;
{
    // 保存失败
    if (error)
    {
    
        [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"lsq_record_failed", @"录制失败")];
    }else
    {
        //保存成功后取消提示框 同时返回到root
        // 通过相机初始化设置  _movieEditor.saveToAlbum = NO;  result.videoPath 拿到视频的临时文件路径
        if (result.videoPath) {
            [[TuSDK shared].messageHub dismiss];
            [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
            // 进行自定义操作，例如保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);

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
                    [self popToRootViewControllerAnimated:YES];
                });

            } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
            }];


            [[TuSDK shared].messageHub dismiss];

        }
        
    }
}

/**
 保存进度改变事件
 
 @param editor TuSDKMovieEditor
 @param percentage 进度百分比 (0 - 1)
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor saveProgressChanged:(CGFloat)percentage;
{

    [TuSDKProgressHUD showMainThreadProgress:percentage withStatus:@"正在保存视频"];
}

/**
 保存状态改变事件
 
 @param editor MovieEditor
 @param status 当前保存状态
 
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor saveStatusChanged:(lsqMovieEditorStatus)status;
{
    NSLog(@"mediaMovieEditor saveStatusChanged : %ld ",status);
    
    switch (status)
    {
        // 正在录制
        case lsqMovieEditorStatusRecording:
        {
            [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"lsq_movie_saving", @"正在保存视频")];
            break;
        }
            
        // 取消录制
        case lsqMovieEditorStatusRecordingCancelled:
        {
            [[TuSDK shared].messageHub dismiss];
            [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_cancelled", @"取消录制")];
            
            [_bottomBar.effectsView setProgress:0.f];
            break;
        }
        default:
            break;
    }
}

#pragma mark - TuSDKMovieEditorPlayerDelegate 视频播放事件委托

/**
 播放进度改变事件
 
 @param player 当前播放器
 @param percent (0 - 1)
 @param outputTime 导出文件后所在输出时间
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime;
{
    if ([self movieEditorStatus] == lsqMovieEditorStatusPreviewing)
    {
        _bottomBar.topThumbnailView.currentTime = CMTimeGetSeconds(outputTime);
        _bottomBar.timeEffectThumbnailView.currentTime = CMTimeGetSeconds(outputTime);
        
        if (!_bottomBar.effectsView.hidden)
            _bottomBar.effectsView.progress = percent;
        
        /** 当前是否正在添加场景特效 */
        if (_bottomBar.effectsView.displayView.isAdding) {
            [_bottomBar.effectsView.displayView updateLastSegmentViewWithProgress:percent];
        }
    }
}

/**
 播放进度改变事件
 
 @param editor MovieEditor
 @param status 当前播放状态
 
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor playerStatusChanged:(lsqMovieEditorStatus)status;
{
    NSLog(@"mediaMovieEditor playerStatusChanged : %ld ",status);
    
    switch (status)
    {
            // 暂停预览
        case lsqMovieEditorStatusPreviewingPause:
        case lsqMovieEditorStatusPreviewingCompleted:
        {
            if (_bottomBar.effectsView.displayView.isAdding)
            {
                [_bottomBar.effectsView.displayView makeFinish];
                [_bottomBar.effectsView backBtnEnabled:_bottomBar.effectsView.displayView.segmentCount > 0];
                
                TuSDKMediaEffectData *mediaEffect = [[_movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeScene] lastObject];
                
                if (mediaEffect)
                    [self.movieEditor unApplyMediaEffect:mediaEffect];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - TuSDKMediaEffectsManagerDelegate 滤镜特效、场景特效、粒子特效、 MV特效、配音特效、文字贴纸特效 相关事件

/**
 当前正在应用的特效
 
 @param editor TuSDKMovieEditor
 @param mediaEffectData 正在预览特效
 @since 2.2.0
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor didApplyingMediaEffect:(TuSDKMediaEffectData *)mediaEffectData;
{
    if (mediaEffectData.effectType == TuSDKMediaEffectDataTypeFilter) {
        TuSDKMediaFilterEffectData *filterMedaiEffectData = (TuSDKMediaFilterEffectData *)mediaEffectData;
        [_bottomBar refreshFilterParameterViewWith:filterMedaiEffectData.effectCode filterArgs:filterMedaiEffectData.filterArgs];
    }
}

/**
 特效被移除通知
 
 @param editor TuSDKMovieEditor
 @param mediaEffects 被移除的特效列表
 @since      v2.2.0
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor didRemoveMediaEffects:(NSArray<TuSDKMediaEffectData *> *)mediaEffects;
{
    // 当特效数据被移除时触发该回调，以下情况将会触发：
    
    // 1. 当特效不支持添加多个时 SDK 内部会自动移除不可叠加的特效
    // 2. 当开发者调用 removeMediaEffect / removeMediaEffectsWithType: / removeAllMediaEffects 移除指定特效时
    
    [mediaEffects enumerateObjectsUsingBlock:^(TuSDKMediaEffectData * _Nonnull mediaEffect, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (mediaEffect.effectType) {
            case TuSDKMediaEffectDataTypeScene:
                if ([editor mediaEffectsWithType:TuSDKMediaEffectDataTypeScene].count == 0)
                    [_bottomBar.effectsView.displayView removeAllSegment];
                break;
                
            default:
                break;
        }
        
    }];
    
}


#pragma mark - MovieEditorBottomBarDelegate
#pragma mark - 时间特效 ( 反复、快慢速、倒序 ）

/**
 时间特效选中回调
 
 @param index 特效索引
 */
- (void)movieEditorBottom_timeEffectSelectedWithIndex:(NSInteger)index
{
    [self updateTimeEffect];
    
    // 播放视频
    [self.movieEditor startPreview];
}

/**
 更新时间特效
 */
- (void)updateTimeEffect
{
    /**
     * 时间特效相关
     * 时间特效 可通过 TuSDKMediaTimelineSlice 对象控制。
     * 每个 TuSDKMediaTimelineSlice 代表一个时间区间切片，可以对该切片指定倒序，快慢速配置。
     *
     */
    NSInteger index = _bottomBar.timeView.selectedIndex;
    switch (index)
    {
        case 0 : // 正常视频
        {
            //step1: 移除所有时间特效
            [self.movieEditor removeAllMediaTimeEffect];
            

             // step2: 时间特效会影响视频输出时长，所以设置时间特效后一定要查下最新的视频输出时长，并更新相关UI
            [_bottomBar.timeEffectThumbnailView setBlockTouchViewHidden:YES];
            [self resetAllProgressViews];
            
            break;
        }
        case 1: // 反复
        {
            // step1: 获取时间特效触发时间范围
            CMTimeRange timeRange = self.bottomBar.timeEffectThumbnailView.clipTimeRange;

            // step2: 构建反复特效对象
            TuSDKMediaRepeatTimeEffect *repeatTimeEffect = [[TuSDKMediaRepeatTimeEffect alloc] initWithTimeRange:timeRange];
            
            // 设置反复次数
            repeatTimeEffect.repeatCount = 2;
            
            // 设置是否丢弃应用特效后累加的视频时长
            repeatTimeEffect.dropOverTime = NO;
            
            // step3: 添加特效
            [self.movieEditor addMediaTimeEffect:repeatTimeEffect];
            
             // step4: 时间特效会影响视频输出时长，所以设置时间特效后一定要查下最新的视频输出时长，并更新相关UI
            [_bottomBar.timeEffectThumbnailView setBlockTouchViewHidden:NO];
            [self resetAllProgressViews];
            
            break;
        }
            
        case 2: // 慢动作
        {
             // step1: 获取时间特效触发时间范围
            CMTimeRange timeRange = self.bottomBar.timeEffectThumbnailView.clipTimeRange;
            
            // step2: 构建速率特效对象
            TuSDKMediaSpeedTimeEffect *speedTimeEffect = [[TuSDKMediaSpeedTimeEffect alloc] initWithTimeRange:timeRange];
            
            // 设置播放速率
            speedTimeEffect.speedRate = 0.5f;
            
            // 设置是否丢弃应用特效后累加的视频时长
            speedTimeEffect.dropOverTime = NO;
            
            // step3: 添加特效
            [self.movieEditor addMediaTimeEffect:speedTimeEffect];

            // step4: 时间特效会影响视频输出时长，所以设置时间特效后一定要查下最新的视频输出时长，并更新相关UI
            [_bottomBar.timeEffectThumbnailView setBlockTouchViewHidden:NO];
            [self resetAllProgressViews];
            
            break;
        }
            
        case 3:// 倒序
        {
            // step1: 获取时间特效触发时间范围
            CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, self.movieEditor.inputDuration);
            
            // step2: 构建倒序特效对象
            TuSDKMediaReverseTimeEffect *reverseTimeEffect = [[TuSDKMediaReverseTimeEffect alloc] initWithTimeRange:timeRange];
            
            // step3: 添加特效
            [self.movieEditor addMediaTimeEffect:reverseTimeEffect];
            
             // step4: 时间特效会影响视频输出时长，所以设置时间特效后一定要查下最新的视频输出时长，并更新相关UI
            [_bottomBar.timeEffectThumbnailView setBlockTouchViewHidden:YES];
            [self resetAllProgressViews];
            
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - 滤镜特效
/**
 滤镜参数改变

 @param seekbar seekbar TuSDKICSeekBar
 @param progress progress progress
 */
- (void)movieEditorBottom_filterViewParamChanged
{
  
    TuSDKMediaFilterEffectData *filterEffectData = (TuSDKMediaFilterEffectData *)[self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
    
    [filterEffectData submitParameters];
}

// 切换滤镜
- (void)movieEditorBottom_filterViewSwitchFilterWithCode:(NSString *)filterCode
{
    // 更换滤镜 (滤镜不可以添加多个 SDK内部会自动移除旧的滤镜)
    TuSDKMediaFilterEffectData *filterEffectData = [[TuSDKMediaFilterEffectData alloc] initWithEffectCode:filterCode];
    [_movieEditor addMediaEffect:filterEffectData];
    
    [_bottomBar refreshFilterParameterViewWith:filterEffectData.effectCode filterArgs:filterEffectData.filterArgs];
}

#pragma mark - 贴纸特效
/**
 切换 MV

 @param mvData mvData TuSDKMVStickerAudioEffectData
 */
- (void)movieEditorBottom_clickStickerMVWith:(TuSDKMediaStickerAudioEffectData *)mvData;
{
    if (!mvData) {
        // 为nil时 不添加贴纸 且移除已有贴纸组
        [_movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerAudio];
        return;
    }
    
    mvData.audioVolume = _dubAudioVolume;
    _currentMediaEffect = mvData;
    _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;

    // 添加贴纸
    [_movieEditor addMediaEffect:_currentMediaEffect];

    // 开始播放
    if ([_movieEditor isPreviewing])
    {
        // 如果你需要 stopPreView 紧接着使用 startPreView 再次启动预览，你首选的方案应为 rePreview，rePreview会根据内部状态在合适的时间启动预览
        [_movieEditor rePreview];
    }
}

#pragma mark - 音频特效

/**
 切换 配音音乐
 
 @param mvData MV 数据
 */
- (void)movieEditorBottom_clickAudioWith:(TuSDKMediaAudioEffectData *)mvData;
{
    if (!mvData)
    {
        // 为nil时 移除已有 音乐特效
        [_movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeAudio];
        return;
    }
    
    mvData.audioVolume = _dubAudioVolume;
    _currentMediaEffect = mvData;
    _currentMediaEffect.atTimeRange = _mediaEffectTimeRange;
    [_movieEditor addMediaEffect:_currentMediaEffect];
    
    // 开始播放
    if ([_movieEditor isPreviewing])
    {
        // 如果你需要 stopPreView 紧接着使用 startPreView 再次启动预览，你首选的方案应为 rePreview，rePreview会根据内部状态在合适的时间启动预览
        [_movieEditor rePreview];
    }

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
                
            }else if ([_currentMediaEffect isMemberOfClass:[TuSDKMediaStickerAudioEffectData class]]){
                ((TuSDKMediaStickerAudioEffectData *)_currentMediaEffect).audioVolume = volume;
            }
        }
    }
}

#pragma mark - 场景特效

/**
 按下特效场景特效

 @param effectCode 场景特效code
 */
- (void)movieEditorBottom_effectsSelectedWithCode:(NSString *)effectsCode;
{
    
    CGFloat currentProgress = CMTimeGetSeconds([_movieEditor outputTimeAtTimeline]) / CMTimeGetSeconds([_movieEditor timelineOutputDuraiton]);
    [_bottomBar.effectsView.displayView addSegmentViewBeginWithProgress:currentProgress WithColor:kVideoEffectColors[[kVideoEffectCodes indexOfObject:effectsCode]]];
    
    TuSDKMediaSceneEffectData *sceneEffect = [[TuSDKMediaSceneEffectData alloc] initWithEffectsCode:effectsCode];
    [_movieEditor applyMediaEffect:sceneEffect];
    
    [self startPreview];

}

/**
 结束选中的特效
 */
- (void)movieEditorBottom_effectsEndWithCode:(NSString *)effectCode;
{
    [self pausePreview];
}

/**
 显示特效栏
 */
- (void)movieEditorBottom_effectsViewDisplay;
{
    [self pausePreview];
    _bottomBar.effectsView.displayView.currentLocation = 0;
}

/**
 移动视频的播放进度条
 */
- (void)movieEditorBottom_effectsMoveVideoProgress:(CGFloat)newProgress;
{
    [self pausePreview];
    
    CMTime outputTime = CMTimeMultiplyByFloat64(self.movieEditor.timelineOutputDuraiton, newProgress);
    [_movieEditor seekToTime:outputTime];
}

/**
 回删添加的特效
 */
- (void)movieEditorBottom_effectsBackEvent;
{
    if ([_movieEditor isPreviewing])
        [_movieEditor pausePreView];
  
    
    [_bottomBar.effectsView backBtnEnabled:_bottomBar.effectsView.displayView.segmentCount > 0];
  
    TuSDKMediaEffectData *mediaEffect = [[_movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeScene] lastObject];
    [_movieEditor removeMediaEffect:mediaEffect];
}

 #pragma mark - bottomThumbnail
/**
 mv、配音缩略图 拖动到某位置处
 
 @param time 拖动的当前位置所代表的时间节点
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 */
- (void)movieEditorBottom_slipThumbnailViewWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus;
{
    if (isStartStatus == lsqClipViewStyleLeft)
    {
        // 调整开始时间
        _mvStartTime = time;
    }else if (isStartStatus == lsqClipViewStyleRight)
    {
        // 调整结束时间
        _mvEndTime = time;
    }
    
    [_movieEditor seekToTime:CMTimeMakeWithSeconds(time, 1*NSEC_PER_SEC)];
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
    [_movieEditor seekToTime:CMTimeMakeWithSeconds(_mvStartTime, 1*NSEC_PER_SEC)];
}

/**
 mv、配音缩略图 拖动开始的事件方法
 */
- (void)movieEditorBottom_slipThumbnailViewSlipBeginEvent;
{
    if ([_movieEditor isPreviewing]) {
        [_movieEditor pausePreView];
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
      [[TuSDK shared].messageHub dismiss];
    [self destroyMovieEditor];
}

@end
