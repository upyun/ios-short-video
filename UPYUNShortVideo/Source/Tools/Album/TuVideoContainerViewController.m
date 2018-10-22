//
//  TuVideoContainerViewController.m
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import "TuVideoContainerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TuVideoContainerViewController (){
    NSURL *_videoURL;
}
@property (assign, nonatomic) BOOL ifAddVideo;
@property (weak, nonatomic) UIImageView *imageView;

// 视频播放player
@property (nonatomic, strong) AVPlayer *player;
// 视频播放item
@property (nonatomic, strong) AVPlayerItem *item;
// 视频播放view
@property (nonatomic, strong) UIView *videoView;
// 视频播放player的视图layer
@property (nonatomic, strong) AVPlayerLayer *layer;

@property (weak, nonatomic) UIButton *playBtn;
@property (weak, nonatomic) UIButton *rightBtn;

@end

@implementation TuVideoContainerViewController

#pragma mark - init method

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPlayer];
    [self setup];
}

- (void)setup
{
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    _imageView = imageView;
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height - 80, width, 80)];
    bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:bottomView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitle:NSLocalizedString(@"lsq_albumComponent_cancelButton", @"取消") forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.frame = CGRectMake(0, 0, 100, 80);
    [bottomView addSubview:leftBtn];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setImage:[UIImage imageNamed:@"video_style_album_player_pause_default"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"video_style_album_player_play_default"] forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(playVideoClick:) forControlEvents:UIControlEventTouchUpInside];
    playBtn.frame = CGRectMake(0, 0, playBtn.currentImage.size.width, playBtn.currentImage.size.height);
    playBtn.center = CGPointMake(width / 2, 40);
    [bottomView addSubview:playBtn];
    _playBtn = playBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:NSLocalizedString(@"lsq_albumComponent_chooseButton", @"选取") forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(selectVideoClick:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(width - 100, 0, 100, 80);
    [bottomView addSubview:rightBtn];
    _rightBtn = rightBtn;
}

#pragma mark - click method

- (void)playVideoClick:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (button.selected) {
        [self playTheVideo];
    }else {
        [self pauseTheVideo];
    }
}

- (void)selectVideoClick:(UIButton *)button
{
    // 点击选区 通过_model 传递
    [self destroyPlayer];
    [self selecteTheModel:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backClick
{
    [self destroyPlayer];
    [self selecteTheModel:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selecteTheModel:(BOOL)isSelected;
{
    if (_didSelectedBlock) {
        if (isSelected) {
            _didSelectedBlock(_model);
        }else{
            _didSelectedBlock(nil);
        }
    }
}

#pragma mark - player method

- (void)initPlayer;
{
    _videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:_videoView];
    
    // 设置播放项目
    _item = [[AVPlayerItem alloc]initWithURL:_model.url];
    
    // 初始化player对象
    self.player = [[AVPlayer alloc]initWithPlayerItem:_item];
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
    
    // 设置通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
}

// 播放视频
- (void)playTheVideo
{
    if (self.player) {
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
    }
}

// 暂停播放
- (void)pauseTheVideo
{
    if (self.player) {
        [self.player pause];
    }
}

// 播放结束的通知
- (void)playerEnd:(AVPlayerItem *)playerItem
{
    _playBtn.selected = !_playBtn.selected;
}

- (void)destroyPlayer
{
    if (!_player) {
        return;
    }
//    [_player cancelPendingPrerolls];
//    [_item cancelPendingSeeks];
//    [_item.asset cancelLoading];
    [_player pause];
//    _item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:@""]];
//    // 初始化player对象
//    self.player = [[AVPlayer alloc]initWithPlayerItem:_item];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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

