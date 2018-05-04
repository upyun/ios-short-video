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
    CGFloat topY = 44;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 88;
    }
    self.videoView = [[UIView alloc]initWithFrame:CGRectMake(0, topY, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
    [self.view addSubview:self.videoScroll];
    [self.view addSubview:self.videoView];
    
    // 设置播放项目
    self.item = [[AVPlayerItem alloc]initWithURL:self.inputURL];
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
