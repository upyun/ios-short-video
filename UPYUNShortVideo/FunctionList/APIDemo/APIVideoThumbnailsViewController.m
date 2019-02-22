//
//  APIVideoThumbnailsViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/15.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "APIVideoThumbnailsViewController.h"
#import "TuSDKFramework.h"
#import "PlayerView.h"

static const CGFloat kMargin = 16;
static const int kCountAtRow = 5;

@interface APIVideoThumbnailsViewController ()

@property (nonatomic, strong) NSMutableArray<void (^)(void)> *actionsAfterViewDidLoad;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray<UIButton *> *actionButtons;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIScrollView *thumbnailScrollView;

@property (nonatomic, assign) CGFloat imageWidth;

/**
 视频图像提取器
 */
@property (nonatomic, strong) TuSDKVideoImageExtractor *imageExtractor;

/**
 返回的缩略图
 */
@property (nonatomic, strong) NSArray<UIImage*> *thumbnails;

/**
 系统播放器
 */
@property (strong, nonatomic) AVPlayer *player;

@end

@implementation APIVideoThumbnailsViewController

- (void)dealloc {
    if (_player) {
        [_player cancelPendingPrerolls];
        [_player.currentItem cancelPendingSeeks];
        [_player.currentItem.asset cancelLoading];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageWidth = (CGRectGetWidth([UIScreen mainScreen].bounds) - kMargin) / kCountAtRow - kMargin;
    
    // 执行 _actionsAfterViewDidLoad 存储的任务
    for (void (^action)(void) in _actionsAfterViewDidLoad) {
        action();
    }
    _actionsAfterViewDidLoad = nil;
    
    // 国际化
    [_actionButtons[0] setTitle:NSLocalizedStringFromTable(@"tu_获取缩略图", @"VideoDemo", @"获取缩略图") forState:UIControlStateNormal];
}

/**
 添加在视图加载后的操作
 
 @param action 操作 Block
 */
- (void)addActionAfterViewDidLoad:(void (^)(void))action {
    if (!action) return;
    if (self.viewLoaded) {
        action();
    } else {
        if (!_actionsAfterViewDidLoad) {
            _actionsAfterViewDidLoad = [NSMutableArray array];
        }
        [_actionsAfterViewDidLoad addObject:action];
    }
}

#pragma mark - property

- (void)setInputURL:(NSURL *)inputURL {
    _inputURL = inputURL;
    if (!inputURL) {
        [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_无输入视频", @"VideoDemo", @"无输入视频")];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self addActionAfterViewDidLoad:^{
        [weakSelf setupVideoPlayer];
        [weakSelf setupVideoThumbnailsExtractor];
    }];
}

#pragma mark - setup

/// 初始化视频缩略图提取器
- (void)setupVideoThumbnailsExtractor {
    _imageExtractor = [TuSDKVideoImageExtractor createExtractor];
    _imageExtractor.videoPath = _inputURL;
    // 输出缩略图的数量
    _imageExtractor.extractFrameCount = 15;
    // 输出缩略图的最大尺寸,(默认设置 ： 80 * 80 )
    _imageExtractor.outputMaxImageSize = CGSizeMake(_imageWidth, _imageWidth);
}

- (void)setupVideoPlayer {
    _playerView.backgroundColor = [UIColor clearColor];
    // 添加视频资源
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:_inputURL];
    // 播放
    _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    _player.volume = 0.5;
    // 播放视频需要在AVPlayerLayer上进行显示
    _playerView.player = _player;
    // 循环播放的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoCycling) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_player play];
}

- (void)playVideoCycling {
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

#pragma mark - action

/**
 异步获取缩略图
 */
- (IBAction)gainThumbnails {
    [_imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
        // 获取到返回的视频的缩略图
        self.thumbnails = images;
    }];
    
    // 获取某一时刻的图片
    // UIImage *image = [imageExtractor frameImageAtTime:CMTimeMake(7, 1)];
}

/**
 重新获取
 */
- (IBAction)resetGain {
    self.thumbnails = nil;
}

#pragma mark - property

- (void)setThumbnails:(NSArray<UIImage *> *)thumbnails {
    _thumbnails = thumbnails;
    
    if (_thumbnailScrollView.subviews.count) {
        for (UIImageView *view in _thumbnailScrollView.subviews) {
            [view removeAllSubviews];
        }
    }
    
    if (!thumbnails.count) return;
    const CGSize thumbnailSize = thumbnails.firstObject.size;
    CGFloat imageHeight = _imageWidth / thumbnailSize.width * thumbnailSize.height;
    CGFloat x = 0, y = 0;
    for (int i = 0; i < thumbnails.count; i++) {
        x = kMargin + (_imageWidth + kMargin) * (i % kCountAtRow);
        y = kMargin + (imageHeight + kMargin) * floor(i / kCountAtRow);
        
        UIImage *image = thumbnails[i];
        
        UIImageView *imageView = [self imageViewWithImage:image];
        imageView.frame = CGRectMake(x, y, _imageWidth, imageHeight);
    }
    self.thumbnailScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.thumbnailScrollView.bounds), y + _imageWidth + kMargin);
}

- (UIImageView *)imageViewWithImage:(UIImage *)image {
    if (!image) return nil;
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 1;
    [self.thumbnailScrollView addSubview:imageView];
    return imageView;
}

@end
