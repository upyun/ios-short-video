//
//  MoviePreviewAndCutRatioAdaptedController.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/27.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MoviePreviewAndCutRatioAdaptedController.h"
#import "MovieEditorRatioAdaptedController.h"
@implementation MoviePreviewAndCutRatioAdaptedController

- (void)initPlayerView
{
    self.videoScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 44, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
    self.videoScroll.bounces = NO;
    self.videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
    [self.view addSubview:self.videoScroll];
    [self.videoScroll addSubview:self.videoView];
    
    // 设置播放项目
    self.item = [[AVPlayerItem alloc]initWithURL:self.inputURL];
    // 注释以下代码，达到比例自适应展示
    /*
    AVAssetTrack *videoTrack = [self.item.asset tracksWithMediaType:AVMediaTypeVideo][0];
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
    
    // 如需比例自适应，需要注释下方代码块
    // 此处的宽高计算仅适用于 1：1 情况下，若有其他的适配，请重新修改计算方案
    if (videoSize.width > videoSize.height) {
        // 定高适配宽
        CGSize newSize = CGSizeMake(self.videoView.lsqGetSizeHeight*videoSize.width/videoSize.height, self.videoView.lsqGetSizeHeight);
        CGFloat offset = (newSize.width - self.videoView.lsqGetSizeWidth)/2;
        [self.videoView lsqSetSize:newSize];
        self.videoScroll.contentSize = newSize;
        self.videoScroll.contentOffset = CGPointMake(offset, 0);
    }else{
        // 定宽适配高
        CGSize newSize = CGSizeMake(self.videoView.lsqGetSizeWidth, self.videoView.lsqGetSizeWidth*videoSize.height/videoSize.width);
        CGFloat offset = (newSize.height - self.videoView.lsqGetSizeHeight)/2;
        [self.videoView lsqSetSize:newSize];
        self.videoScroll.contentSize = newSize;
        self.videoScroll.contentOffset = CGPointMake(0, offset);
    }
    */
    // 初始化player对象
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.item];
    // 设置播放页面
    self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    // 设置播放页面大小
    self.layer.frame = self.videoView.bounds;
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
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
            // 开启视频编辑器
            MovieEditorRatioAdaptedController *vc = [MovieEditorRatioAdaptedController new];
            vc.inputURL = self.inputURL;
            vc.startTime = self.startTime;
            vc.endTime = self.endTime;
            // cropRect 参数不赋值，MovieEditorRatioAdaptedController 将会进行比例自适应展示
            vc.cropRect = CGRectMake(0, 0, 0, 0);
            [self.navigationController pushViewController:vc animated:true];
        }
        break;
            
        default:
            break;
    }
}



@end
