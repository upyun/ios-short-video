//
//  APIVideoThumbnailsViewController.m
//  TuSDKVideoDemo
//
//  Created by wen on 27/06/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "APIVideoThumbnailsViewController.h"
#import "TopNavBar.h"
#import "TuSDKFramework.h"

@interface APIVideoThumbnailsViewController ()<TopNavBarDelegate>{
    // 编辑页面顶部控制栏视图
    TopNavBar *_topBar;
    // 视频图像提取器
    TuSDKVideoImageExtractor *imageExtractor;
    // 返回的缩略图
    NSArray<UIImage*> *thumbnailsArr;
    // 距离定点距离
    CGFloat topYDistance;
}

// 系统播放器
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation APIVideoThumbnailsViewController

#pragma mark - 基础配置方法

// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        return NO;
    }

    return YES;
}

#pragma mark - 视图布局方法

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    // 销毁播放器
    [self destroyPlayer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setNavigationBarHidden:YES animated:NO];
    if (![UIDevice lsqIsDeviceiPhoneX]) {
        [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = lsqRGB(217, 217, 217);

    topYDistance = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topYDistance += 44;
    }

    // 顶部栏初始化
    [self initWithTopBar];
    // 视频播放器初始化
    [self initWithVideoPlayer];
    // 界面布局
    [self layoutView];
    // 初始化视频缩略图提取器
    [self initWithVideoThumbnailsExtractor];
}

// 初始化视频缩略图提取器
- (void)initWithVideoThumbnailsExtractor;
{
    NSURL *videoURL  = _inputURL;
    imageExtractor = [TuSDKVideoImageExtractor createExtractor];
    imageExtractor.videoPath = videoURL;
    // 输出缩略图的数量
    imageExtractor.extractFrameCount = 15;
    // 输出缩略图的最大尺寸,(默认设置 ： 80 * 80 )
    imageExtractor.outputMaxImageSize = CGSizeMake(100, 100);
    [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
        // 获取到返回的视频的缩率图
        thumbnailsArr =  images;
    }];
    
    // 获取某一时刻的图片
    // UIImage *image = [imageExtractor frameImageAtTime:CMTimeMake(7, 1)];
}

// 界面布局
- (void)layoutView;
{
    CGFloat sideGapDistance = 50;
    // 获取缩略图
    UIButton *gainThumbButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth - sideGapDistance*2, 40)];
    gainThumbButton.center = CGPointMake(self.view.lsqGetSizeWidth/2, self.view.lsqGetSizeWidth*9/16 + sideGapDistance *2.5 + topYDistance*2);
    gainThumbButton.backgroundColor =  lsqRGB(252, 143, 96);
    gainThumbButton.layer.cornerRadius = 3;
    [gainThumbButton setTitle:NSLocalizedString(@"lsq_api_gain_thumbnail", @"获取缩略图") forState:UIControlStateNormal];
    [gainThumbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [gainThumbButton addTarget:self action:@selector(gainThumbnails) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gainThumbButton];
    
    // 创建 imageView
    CGFloat sideDistance = self.view.lsqGetSizeWidth;
    
    [self initImageViewWithFrameOriginX:sideDistance*1/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *4 imageViewTag:11];
    [self initImageViewWithFrameOriginX:sideDistance*2/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *4 imageViewTag:12];
    [self initImageViewWithFrameOriginX:sideDistance*3/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *4 imageViewTag:13];
    [self initImageViewWithFrameOriginX:sideDistance*4/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *4 imageViewTag:14];
    [self initImageViewWithFrameOriginX:sideDistance*5/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *4 imageViewTag:15];
    
    [self initImageViewWithFrameOriginX:sideDistance*1/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *5.5 imageViewTag:16];
    [self initImageViewWithFrameOriginX:sideDistance*2/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *5.5 imageViewTag:17];
    [self initImageViewWithFrameOriginX:sideDistance*3/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *5.5 imageViewTag:18];
    [self initImageViewWithFrameOriginX:sideDistance*4/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *5.5 imageViewTag:19];
    [self initImageViewWithFrameOriginX:sideDistance*5/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *5.5 imageViewTag:20];
    
    [self initImageViewWithFrameOriginX:sideDistance*1/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *7 imageViewTag:21];
    [self initImageViewWithFrameOriginX:sideDistance*2/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *7 imageViewTag:22];
    [self initImageViewWithFrameOriginX:sideDistance*3/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *7 imageViewTag:23];
    [self initImageViewWithFrameOriginX:sideDistance*4/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *7 imageViewTag:24];
    [self initImageViewWithFrameOriginX:sideDistance*5/6 originY:topYDistance*2 + self.view.lsqGetSizeWidth*9/16 + sideGapDistance *7 imageViewTag:25];
}


/**
 创建展示用的 imageView

 @param originX originX 横坐标
 @param originY originY 纵坐标
 @param viewTag viewTag 视频视图
 */
- (void)initImageViewWithFrameOriginX:(CGFloat)originX originY:(CGFloat)originY imageViewTag:(NSInteger)viewTag;
{
    // 创建展示用的 UImageView
    CGFloat sideGapDistance = self.view.lsqGetSizeWidth/7;
    // 展示缩略图
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, sideGapDistance, sideGapDistance)];
    [imageView setCenter:CGPointMake(originX, originY)];
    [imageView setImage:[UIImage imageNamed:@""]];
    imageView.tag = viewTag;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
}

// 获取缩略图点击事件
- (void)gainThumbnails;
{
    for (UIView*view in self.view.subviews) {
        if (view.tag > 0) {
            if ([view isMemberOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView*)view;
                [imageView setImage:[thumbnailsArr objectAtIndex:imageView.tag - 11]];
            }
        }
    }
}

// 重新获取
- (void)resetGain
{
    for (UIView*view in self.view.subviews) {
        if (view.tag > 0) {
            if ([view isMemberOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView*)view;
                [imageView setImage:[UIImage imageNamed:@""]];
            }
        }
    }
}
// 顶部栏初始化
- (void)initWithTopBar;
{
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topYDistance, self.view.bounds.size.width, 44)];
    [_topBar setBackgroundColor:[UIColor whiteColor]];
    _topBar.topBarDelegate = self;
    [_topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_api_gain_thumbnail", @"获取缩略图")
                     leftButtonInfo:@[@"video_style_default_btn_back.png"]
                    rightButtonInfo:nil];
    [_topBar.centerTitleLabel lsqSetSizeWidth:_topBar.lsqGetSizeWidth/2];
    _topBar.centerTitleLabel.center = CGPointMake(self.view.lsqGetSizeWidth/2, _topBar.lsqGetSizeHeight/2);
    [self.view addSubview:_topBar];
}

// 播放器初始化
- (void)initWithVideoPlayer;
{
    UIView *playerView = [[UIView alloc]initWithFrame:CGRectMake(0, topYDistance/2 + _topBar.lsqGetSizeHeight, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth*9/16)];
    [playerView setBackgroundColor:[UIColor clearColor]];
    playerView.multipleTouchEnabled = NO;
    [self.view addSubview:playerView];
    // 添加视频资源
    _playerItem = [[AVPlayerItem alloc]initWithURL:_inputURL];
    // 播放
    _player = [[AVPlayer alloc]initWithPlayerItem:_playerItem];
    _player.volume = 0.5;
    // 播放视频需要在AVPlayerLayer上进行显示
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = playerView.frame;
    [playerView.layer addSublayer:playerLayer];
    // 循环播放的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playVideoCycling) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_player play];
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

- (void)playVideoCycling;
{
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}


- (void)dealloc
{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    // 销毁播放器
    [self destroyPlayer];
}

- (void)destroyPlayer
{
    if (!_player) {
        return;
    }
    [_player cancelPendingPrerolls];
    [_playerItem cancelPendingSeeks];
    [_playerItem.asset cancelLoading];
    [_player pause];
    _playerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:@""]];
    // 初始化player对象
    self.player = [[AVPlayer alloc]initWithPlayerItem:_playerItem];
    
    _player = nil;
    _playerItem = nil;
}

- (NSURL *)filePathName:(NSString *)fileName
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:fileName ofType:nil]];
}

@end
