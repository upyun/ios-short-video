//
//  APIMovieClipperViewController.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/27.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "APIMovieClipperViewController.h"
#import "TuSDKFramework.h"
#import "CutVideoBottomView.h"
#import "TopNavBar.h"

/**
 视频时间选取示例：视频预览，选取裁剪时间范围
 */
@interface APIMovieClipperViewController ()<TopNavBarDelegate,TuSDKMovieClipperDelegate>
{
    // 播放按钮iv
    UIImageView *_playerIV;
    // 视频播放player的视图layer
    AVPlayerLayer *layer;
    // 展示的scrollView
    UIScrollView *_videoScroll;
    // 视频播放view
    UIView *_videoView;
    // 记录视频的宽高比
    CGFloat _ratioWH;
    // 视频裁剪对象
    TuSDKMovieClipper *_movieClipper;
    // 说明 label
    UILabel * explainationLabel;
    // 距离定点距离
    CGFloat topYDistance;
}

// 编辑页面顶部控制栏视图
@property (nonatomic, strong) TopNavBar *configBar;
// 底部裁剪view
@property (nonatomic, strong) CutVideoBottomView *cutVideoView;
// 视频播放player
@property (nonatomic, strong) AVPlayer *player;
// 视频播放item
@property (nonatomic, strong) AVPlayerItem *item;
// 记录开始时间
@property (nonatomic, assign) CGFloat startTime;
// 记录结束时间
@property (nonatomic, assign) CGFloat endTime;
// 当前时间
@property (nonatomic, assign) CGFloat currentTime;
// 播放点击记录，若点击播放，为YES，再点击暂定，为NO
@property (nonatomic, assign) BOOL playSelected;

@end

@implementation APIMovieClipperViewController

#pragma mark - setter/getter
- (void)setCurrentTime:(CGFloat)currentTime
{
    _currentTime = currentTime;
    
    if (_cutVideoView) {
        _cutVideoView.currentTime = currentTime;
    }
}


#pragma mark - 基础配置方法
// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        return NO;
    }

    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self setNavigationBarHidden:YES animated:NO];
    if (![UIDevice lsqIsDeviceiPhoneX]) {
        [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
}

#pragma mark - 布局方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1];
    topYDistance = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topYDistance += 44;
    }

    [self lsqInitView];
    [self initPlayerView];
}


- (void)lsqInitView
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    // 默认相机顶部控制栏
    _configBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topYDistance, rect.size.width, 44)];
    [_configBar setBackgroundColor:[UIColor whiteColor]];
    _configBar.topBarDelegate = self;
    [_configBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_video_timecut_save", @"视频时间裁剪")
                        leftButtonInfo:@[@"video_style_default_btn_back.png"]
                       rightButtonInfo:@[NSLocalizedString(@"lsq_clip_video", @"裁剪")]];
    
    [_configBar.centerTitleLabel lsqSetSizeWidth:self.view.lsqGetSizeWidth/2];
    _configBar.centerTitleLabel.center = CGPointMake(self.view.lsqGetSizeWidth/2, _configBar.lsqGetSizeHeight/2);
    [self.view addSubview:_configBar];
    
    // 底部裁剪栏
    self.cutVideoView = [[CutVideoBottomView alloc]initWithFrame:CGRectMake(0, topYDistance + rect.size.width + 44, rect.size.width , rect.size.height - rect.size.width - 44)];
    self.cutVideoView.clipView.center = CGPointMake(self.cutVideoView.lsqGetSizeWidth/2, self.cutVideoView.lsqGetSizeHeight/2);
    self.cutVideoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.cutVideoView];
    self.cutVideoView.userInteractionEnabled = false;
    // 底部说明 label
    [self initWithExplainationLabel];
    // 修改播放时间的block
    __weak APIMovieClipperViewController * wSelf = self;
    self.cutVideoView.slipChangeTimeBlock = ^(CGFloat time, lsqClipViewStyle isStartStatus){
        if (wSelf.item) {
            [wSelf.player pause];
            int32_t timescale = wSelf.item.duration.timescale;
            CMTime time2 = CMTimeMake(time*timescale, timescale);
            [wSelf.item seekToTime:time2 toleranceBefore:CMTimeMake(0, timescale) toleranceAfter:CMTimeMake(0, timescale)];
            
            if (isStartStatus == lsqClipViewStyleLeft) {
                wSelf.startTime = time;
            }else if(isStartStatus == lsqClipViewStyleRight){
                wSelf.endTime = time;
            }
        }
    };
    
    // 拖动结束的block
    __weak APIMovieClipperViewController * wSelf2 = self;
    self.cutVideoView.slipEndBlock = ^{
        if (!wSelf2.playSelected) {
            // 做这个判断，因为当playBtn在选中状态下视频是在播放，若此时还能调用end 说明有点击(不是拖动)发生，此时不做响应；而若为拖动，则拖动开始时即会暂停播放，依然不会冲突.
            int32_t timescale = wSelf2.item.duration.timescale;
            CMTime time2 = CMTimeMake(wSelf2.startTime*timescale, timescale);
            [wSelf2.item seekToTime:time2 toleranceBefore:CMTimeMake(0, timescale) toleranceAfter:CMTimeMake(0, timescale)];
        }
    };
    
    // 拖动开始的block 解决拖动和播放冲突
    self.cutVideoView.slipBeginBlock = ^(){
        // 拖动开始就暂定视频播放
        wSelf.playSelected = false;
        [wSelf pauseTheVideo];
    };
    
    // 获取视频缩略图
    __weak APIMovieClipperViewController * wSelf3 = self;
    TuSDKVideoImageExtractor *imageExtractor = [TuSDKVideoImageExtractor createExtractor];
    imageExtractor.videoPath = wSelf3.inputURL;
    // 缩略图个数结合滑动栏宽高计算，若需求不同，可另外更改
    int num = (int)ceilf((_cutVideoView.lsqGetSizeWidth-40)/(64*3/5));
    imageExtractor.extractFrameCount = num + 1;
    [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
        wSelf3.cutVideoView.thumbnails = images;
    }];
}
- (void)initWithExplainationLabel;
{
    explainationLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, self.cutVideoView.lsqGetSizeHeight - 50 - topYDistance, self.cutVideoView.lsqGetSizeWidth, 50)];
    explainationLabel.backgroundColor = lsqRGB(236, 236, 236);
    explainationLabel.textColor = [UIColor blackColor];
    explainationLabel.text = NSLocalizedString(@"lsq_api_movie_clipper_explaination",@"请在缩略图预览区域选择裁剪的时间范围，选定后请点击「裁剪」按钮，生成视频");
    explainationLabel.numberOfLines = 0;
    explainationLabel.textAlignment = NSTextAlignmentCenter;
    explainationLabel.font = [UIFont systemFontOfSize:15];
    [self.cutVideoView addSubview:explainationLabel];
}

- (void)initPlayerView
{
    _videoScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 44 + topYDistance, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
    _videoScroll.bounces = NO;
    _videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
    [self.view addSubview:_videoScroll];
    [_videoScroll addSubview:_videoView];
    
    // 设置播放项目
    _item = [[AVPlayerItem alloc]initWithURL:_inputURL];
    
    
    // 初始化player对象
    self.player = [[AVPlayer alloc]initWithPlayerItem:_item];
    // 设置播放页面
    layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    // 设置播放页面大小
    layer.frame = _videoView.bounds;
    layer.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1].CGColor;
    // 设置播放显示比例
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加播放视图
    [_videoView.layer addSublayer:layer];
    // 播放设置
    self.player.volume = 1.0;
    
    // 监听status
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 设置通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
}


#pragma mark - 自定义点击事件
// 点击屏幕中间的播放按钮
- (void)clickPlayerBtn:(UIGestureRecognizer *)gesture;
{
    self.playSelected = !self.playSelected;
    if (self.playSelected) {
        [self playTheVideo];
    }else{
        [self pauseTheVideo];
    }
}

// 播放视频
- (void)playTheVideo{
    if (self.player) {
        _playerIV.hidden = YES;
        [self.player play];
    }
}

// 暂停播放
- (void)pauseTheVideo{
    if (self.player) {
        _playerIV.hidden = NO;
        [self.player pause];
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
    [self destroyPlayer];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 右侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onRightButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
    // 视频裁剪 API
    NSMutableArray *dropArr = [[NSMutableArray alloc]init];
    if (_startTime >= 0) {
        TuSDKTimeRange *cutTimeRange1 = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:_startTime];
        [dropArr addObject:cutTimeRange1];
    }
    if (_endTime < CMTimeGetSeconds(_item.duration)) {
        TuSDKTimeRange *cutTimeRange2 = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_endTime endSeconds:CMTimeGetSeconds(_item.duration)];
        [dropArr addObject:cutTimeRange2];
    }

    if (!_movieClipper) {
        _movieClipper =  [[TuSDKMovieClipper alloc] initWithMovieURL:_inputURL];
        _movieClipper.enableVideoSound = YES;
        _movieClipper.clipDelegate = self;
        _movieClipper.outputFileType = lsqFileTypeQuickTimeMovie;
    }
    
    [[TuSDK shared].messageHub setStatus:NSLocalizedString(@"正在裁剪...", @"正在裁剪...")];

    _movieClipper.dropTimeRangeArr = dropArr;
    [_movieClipper startClippingWithCompletionHandler:^(NSString *outputFilePath, lsqMovieClipperSessionStatus status) {
        if (status == lsqMovieClipperSessionStatusCompleted){
            // 操作成功 保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(outputFilePath, nil, nil, nil);
        }else if(status == lsqMovieClipperSessionStatusFailed || status == lsqMovieClipperSessionStatusCancelled || status == lsqMovieClipperSessionStatusUnknown){
            
        }
    }];
}

#pragma mark - TuSDKMovieClipperDelegate

/**
 状态通知代理

 @param editor editor TuSDKMovieClipper
 @param status status lsqMovieClipperSessionStatus
 */
- (void)onMovieClipper:(TuSDKMovieClipper *)editor statusChanged:(lsqMovieClipperSessionStatus)status;
{
    NSLog(@"TuSDKMovieClipper 的目前的状态是 ： %ld",(long)status);
    
    if (status == lsqMovieClipperSessionStatusCompleted)
    {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_api_splice_movie_success", @"操作完成，请去相册查看视频")];
    }else if (status == lsqMovieClipperSessionStatusFailed)
    {
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_failed", @"操作失败，无法生成视频文件")];
    }else if(status == lsqMovieClipperSessionStatusCancelled)
    {
        [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_api_splice_movie_cancelled", @"出现问题，操作被取消")];
    }else if (status == lsqMovieClipperSessionStatusClipping)
    {
        // 正在剪裁
    }
}

/**
 结果通知代理

 @param editor editor TuSDKMovieClipper
 @param result result TuSDKVideoResult
 */
- (void)onMovieClipper:(TuSDKMovieClipper *)editor result:(TuSDKVideoResult *)result;
{
    NSLog(@"视频的临时文件的路径 ：%@",result.videoPath);
}

#pragma mark - 检测通知的响应方法
// 播放结束的通知
- (void)playerEnd:(AVPlayerItem *)playerItem
{
    [_item seekToTime:CMTimeMake(self.startTime*_item.duration.timescale, _item.duration.timescale)];
    self.playSelected = !self.playSelected;
    _playerIV.hidden = false;
}

/**
 KVO回调 视频加载状态改变

 @param keyPath keyPath description
 @param object object description
 @param change change description
 @param context context description
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            if (_playerIV == nil) {
                // 播放按钮
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickPlayerBtn:)];
                [_videoScroll addGestureRecognizer:tap];
                
                _playerIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
                _playerIV.center = CGPointMake(_videoScroll.lsqGetSizeWidth/2, _videoScroll.lsqGetOriginY+_videoScroll.lsqGetSizeHeight/2);
                _playerIV.image = [UIImage imageNamed:@"video_style_default_crop_btn_record"];
                [self.view addSubview:_playerIV];
                
                // 视频信息
                _cutVideoView.timeInterval = _item.duration.value*1.0/_item.duration.timescale;
                _cutVideoView.userInteractionEnabled = true;
                self.endTime = _cutVideoView.timeInterval;
                
                
                if (_cutVideoView.timeInterval < 3 || _cutVideoView.timeInterval > 60) {
                    [[TuSDK shared].messageHub showToast:NSLocalizedString(@"lsq_cut_durationTime", @"建议选择大于3秒，小于60秒的视频")];
                }
                
                // 检测播放进度
                __weak APIMovieClipperViewController * wSelf = self;
                [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, _item.duration.timescale) queue:NULL usingBlock:^(CMTime time) {
                    CGFloat currentSecond = playerItem.currentTime.value*1.0/playerItem.currentTime.timescale;
                    wSelf.currentTime = currentSecond;
                    if (_currentTime>_endTime) {
                        [wSelf pauseTheVideo];
                        int32_t timescale = wSelf.item.duration.timescale;
                        CMTime time = CMTimeMake(wSelf.startTime*timescale, timescale);
                        [wSelf.item seekToTime:time toleranceBefore:CMTimeMake(0, timescale) toleranceAfter:CMTimeMake(0, timescale)];
                    }
                }];
            }
        }else if (playerItem.status == AVPlayerItemStatusFailed){
            NSLog(@"视频加载出错");
        }
    }
}

- (void)destroyPlayer
{
    if (!_player) {
        return;
    }
    [_player cancelPendingPrerolls];
    // 销毁KVO
    [_item removeObserver:self forKeyPath:@"status" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_item cancelPendingSeeks];
    [_item.asset cancelLoading];
    [_player pause];
    _item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:@""]];
    // 初始化player对象
    self.player = [[AVPlayer alloc]initWithPlayerItem:_item];
    
    _player = nil;
    _item = nil;
}

- (void)dealloc
{
    [self destroyPlayer];
}

- (NSURL *)filePathName:(NSString *)fileName
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:fileName ofType:nil]];
}

@end
