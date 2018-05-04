//
//  MoviePreviewAndCutFullScreenController.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/27.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MoviePreviewAndCutFullScreenController.h"
#import "TuSDKFramework.h"
#import "MovieEditorFullScreenController.h"

/**
 视频时间选取示例：视频预览，选取裁剪时间范围
 */
@implementation MoviePreviewAndCutFullScreenController

#pragma mark - 布局方法

- (void)lsqInitView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    // 默认相机顶部控制栏
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    self.configBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topY, rect.size.width, 44)];
    [self.configBar setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    self.configBar.topBarDelegate = self;
    NSString *backBtnTitle = @"video_style_default_btn_back.png";
    [self.configBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_cut_video", @"剪辑")
                        leftButtonInfo:@[backBtnTitle]
                       rightButtonInfo:@[NSLocalizedString(@"lsq_next_step", @"下一步")]];
    self.configBar.centerTitleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.configBar];
    
    // 底部裁剪栏
    self.cutVideoView = [[CutVideoBottomView alloc]initWithFrame:CGRectMake(0, rect.size.width + 44, rect.size.width , rect.size.height - rect.size.width - 44)];
    self.cutVideoView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:self.cutVideoView];
    self.cutVideoView.userInteractionEnabled = false;
    
    // 修改播放时间的block
    __weak MoviePreviewAndCutFullScreenController * wSelf = self;
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
    __weak MoviePreviewAndCutFullScreenController * wSelf2 = self;
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
    __weak MoviePreviewAndCutFullScreenController * wSelf3 = self;
    TuSDKVideoImageExtractor *imageExtractor = [TuSDKVideoImageExtractor createExtractor];
    imageExtractor.videoPath = wSelf3.inputURL;
    // 缩略图个数结合滑动栏宽高计算，若需求不同，可另外更改
    int num = (int)ceilf((self.cutVideoView.lsqGetSizeWidth-40)/(64*3/5));
    imageExtractor.extractFrameCount = num + 1;
    [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
        wSelf3.cutVideoView.thumbnails = images;
    }];
}

- (void)initPlayerView
{
    // 设置全屏，需要修改以下两个 view 的 frame
    self.videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeHeight)];
    self.videoView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.videoView];
    [self.view sendSubviewToBack:self.videoView];
    
    // 设置播放项目
    self.item = [[AVPlayerItem alloc]initWithURL:self.inputURL];
    
    // 初始化player对象
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.item];
    // 设置播放页面
    self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    // 设置播放页面大小
    self.layer.frame = self.videoView.bounds;
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    // 设置播放显示比例
    self.layer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加播放视图
    [self.videoView.layer addSublayer:self.layer];
    // 播放设置
    self.player.volume = 1.0;
    
    // 监听status
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 设置通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.item];
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
            
            MovieEditorFullScreenController *vc = [MovieEditorFullScreenController new];
            vc.inputURL = self.inputURL;
            vc.startTime = self.startTime;
            vc.endTime = self.endTime;
            // 区域设置为 CGRectMake(0, 0, 0, 0) movieEditor 将不会进行区域限制
            vc.cropRect = CGRectMake(0, 0, 0, 0);
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
    [self.item seekToTime:CMTimeMake(self.startTime*self.item.duration.timescale, self.item.duration.timescale)];
    self.playSelected = !self.playSelected;
    self.playerIV.hidden = false;
}

@end
