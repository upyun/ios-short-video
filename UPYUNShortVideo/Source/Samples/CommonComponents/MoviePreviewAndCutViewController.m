//
//  MoviePreviewAndCutViewController.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/27.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MoviePreviewAndCutViewController.h"

@implementation MoviePreviewAndCutViewController

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
    
    [self initPlayer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
}

#pragma mark - 布局方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self lsqInitView];
    [self initPlayerView];
}

- (void)lsqInitView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    // 默认相机顶部控制栏
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    _configBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topY, rect.size.width, 44)];
    [_configBar setBackgroundColor:[UIColor whiteColor]];
    _configBar.topBarDelegate = self;
    [_configBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_cut_video", @"剪辑")
                        leftButtonInfo:@[@"video_style_default_btn_back.png"]
                       rightButtonInfo:@[NSLocalizedString(@"lsq_next_step", @"下一步")]];
    [self.view addSubview:_configBar];
    
    // 底部裁剪栏
    self.cutVideoView = [[CutVideoBottomView alloc]initWithFrame:CGRectMake(0, rect.size.width + _configBar.lsqGetOriginY + _configBar.lsqGetSizeHeight, rect.size.width , rect.size.height - rect.size.width - (_configBar.lsqGetOriginY + _configBar.lsqGetSizeHeight))];
    self.cutVideoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.cutVideoView];
    self.cutVideoView.userInteractionEnabled = false;
    
    // 修改播放时间的block
    __weak MoviePreviewAndCutViewController * wSelf = self;
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
    __weak MoviePreviewAndCutViewController * wSelf2 = self;
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
    __weak MoviePreviewAndCutViewController * wSelf3 = self;
    TuSDKVideoImageExtractor *imageExtractor = [TuSDKVideoImageExtractor createExtractor];
    imageExtractor.videoPath = self.inputURL;
    // 缩略图个数结合滑动栏宽高计算，若需求不同，可另外更改
    int num = (int)ceilf((_cutVideoView.lsqGetSizeWidth-40)/(64*3/5));
    imageExtractor.extractFrameCount = num + 1;
    [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
        wSelf3.cutVideoView.thumbnails = images;
    }];
}

- (void)initPlayerView
{
    _videoScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _configBar.lsqGetOriginY + _configBar.lsqGetSizeHeight, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
    _videoScroll.bounces = NO;
    _videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
    [self.view addSubview:_videoScroll];
    [_videoScroll addSubview:_videoView];
    
    // 设置播放项目
    _item = [[AVPlayerItem alloc]initWithURL:_inputURL];
    
    AVAssetTrack *videoTrack = [_item.asset tracksWithMediaType:AVMediaTypeVideo][0];
    CGSize videoSize = videoTrack.naturalSize;
    // 根据朝向判断是否需要交换宽高
    CGAffineTransform transform = videoTrack.preferredTransform;
    BOOL isNeedSwopWH = NO;
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
        // Right
        isNeedSwopWH = YES;
    }else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0){
        // Left
        isNeedSwopWH = YES;
    }else if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0){
        // Down
        isNeedSwopWH = NO;
    }else{
        // Up
        isNeedSwopWH = NO;
    }
    
    if (isNeedSwopWH) {
        // 交换宽高
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    
    // 此处的宽高计算仅适用于 1：1 情况下，若有其他的适配，请重新修改计算方案
    if (videoSize.width > videoSize.height) {
        // 定高适配宽
        CGSize newSize = CGSizeMake(_videoView.lsqGetSizeHeight*videoSize.width/videoSize.height, _videoView.lsqGetSizeHeight);
        CGFloat offset = (newSize.width - _videoView.lsqGetSizeWidth)/2;
        [_videoView lsqSetSize:newSize];
        _videoScroll.contentSize = newSize;
        _videoScroll.contentOffset = CGPointMake(offset, 0);
    }else{
        // 定宽适配高
        CGSize newSize = CGSizeMake(_videoView.lsqGetSizeWidth, _videoView.lsqGetSizeWidth*videoSize.height/videoSize.width);
        CGFloat offset = (newSize.height - _videoView.lsqGetSizeHeight)/2;
        [_videoView lsqSetSize:newSize];
        _videoScroll.contentSize = newSize;
        _videoScroll.contentOffset = CGPointMake(0, offset);
    }
    
}

- (void)initPlayer
{
    if (!_item) {
         _item = [[AVPlayerItem alloc]initWithURL:_inputURL];
    }
    // 初始化player对象
    self.player = [[AVPlayer alloc] initWithPlayerItem:_item];
    // 设置播放页面
    _layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    // 设置播放页面大小
    _layer.frame = _videoView.bounds;
    _layer.backgroundColor = [UIColor blackColor].CGColor;
    // 设置播放显示比例
    _layer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加播放视图
    [_videoView.layer addSublayer:_layer];
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
- (void)playTheVideo
{
    if (self.player) {
        _playerIV.hidden = YES;
        [self.player play];
    }
}

// 暂停播放
- (void)pauseTheVideo
{
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
    switch (btn.tag) {
        case lsqRightTopBtnFirst:
        {
            // 下一步按钮
            self.playSelected = false;
            [self pauseTheVideo];
            [self destroyPlayer];
            
            MovieEditorViewController *vc = [MovieEditorViewController new];
            vc.inputURL = _inputURL;
            vc.cutTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(_startTime, USEC_PER_SEC), CMTimeMakeWithSeconds(_endTime - _startTime, USEC_PER_SEC));
            vc.cropRect = CGRectMake(_videoScroll.contentOffset.x/_videoScroll.contentSize.width,
                                     _videoScroll.contentOffset.y/_videoScroll.contentSize.height,
                                     _videoScroll.lsqGetSizeWidth/_videoScroll.contentSize.width,
                                     _videoScroll.lsqGetSizeHeight/_videoScroll.contentSize.height);
            [self.navigationController pushViewController:vc animated:true];
        }
        break;
            
        default:
            break;
    }

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
                [_videoView addGestureRecognizer:tap];
                
                _playerIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
                if (_videoScroll) {
                    _playerIV.center = CGPointMake(_videoScroll.lsqGetSizeWidth/2, _videoScroll.lsqGetOriginY+_videoScroll.lsqGetSizeHeight/2);
                }else{
                    _playerIV.center = CGPointMake(self.videoView.lsqGetSizeWidth/2, self.videoView.lsqGetOriginY + self.videoView.lsqGetSizeHeight/2);
                }
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
                __weak MoviePreviewAndCutViewController * wSelf = self;
                [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, wSelf.item.duration.timescale) queue:NULL usingBlock:^(CMTime time) {
                    CGFloat currentSecond = playerItem.currentTime.value*1.0/playerItem.currentTime.timescale;
                    wSelf.currentTime = currentSecond;
                    if (wSelf.currentTime>wSelf.endTime) {
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
    // 销毁KVO
    [_item removeObserver:self forKeyPath:@"status" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player replaceCurrentItemWithPlayerItem:nil];
    [_layer removeFromSuperlayer];
    _layer = nil;
    _player = nil;
    _item = nil;
}

- (void)dealloc
{
    [self destroyPlayer];
}


@end
