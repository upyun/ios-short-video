//
//  MoviePreviewViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2018/9/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MoviePreviewViewController.h"
#import "TuSDKFramework.h"

@interface MoviePreviewViewController ()<TuSDKMediaTimelineAssetMoviePlayerDelegate>

/**
 视图加载后的操作
 */
@property (nonatomic, strong) NSMutableArray<void (^)(void)> *actionsAfterViewDidLoad;

/**
 播放器
 */
@property (nonatomic, strong) TuSDKMediaMutableAssetMoviePlayer *moviePlayer;

/**
 视频预览视图
 */
@property (nonatomic, strong) UIView *videoPreviewView;

/**
 播放按钮
 */
@property (nonatomic, weak) UIButton *playButton;

/**
 添加按钮
 */
@property (nonatomic, weak) UIButton *addButton;

/**
 视频请求 ID
 */
@property (nonatomic, assign) PHImageRequestID assetRequestId;

@end

@implementation MoviePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置 UI
    [self setupUI];
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 执行 _actionsAfterViewDidLoad 存储的任务
    for (void (^action)(void) in _actionsAfterViewDidLoad) {
        action();
    }
    _actionsAfterViewDidLoad = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_moviePlayer stop];
    // 取消资源请求
    [[PHImageManager defaultManager] cancelImageRequest:_assetRequestId];
    _assetRequestId = -1;
    [[TuSDK shared].messageHub dismiss];
}

- (void)dealloc;
{
    [_moviePlayer destory];
    _moviePlayer = nil;
}

- (void)setupPlayerWithAsset:(AVAsset *)avAsset {
    TuSDKMediaAsset *asset = [[TuSDKMediaAsset alloc] initWithAsset:avAsset timeRange:kCMTimeRangeInvalid];
    _moviePlayer = [[TuSDKMediaMutableAssetMoviePlayer alloc] initWithMediaAssets:@[asset] preview:_videoPreviewView];
    _moviePlayer.delegate = self;
    [_moviePlayer load];
}

- (void)setupUI {
    // 配置右上方按钮
    [self.topNavigationBar.rightButton setTitle:NSLocalizedStringFromTable(@"tu_下一步", @"VideoDemo", @"下一步") forState:UIControlStateNormal];
    
    // 视频预览视图
    UIView *videoPreviewView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:videoPreviewView atIndex:0];
    _videoPreviewView = videoPreviewView;
    
    // 播放按钮
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:playButton];
    [playButton setImage:[UIImage imageNamed:@"list_ic_play"] forState:UIControlStateNormal];
    [playButton sizeToFit];
    [playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _playButton = playButton;
    
    // 添加按钮
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addButton];
    [addButton setBackgroundImage:[UIImage imageNamed:@"edit_heckbox_unsel_max"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"edit_heckbox_sel_max"] forState:UIControlStateSelected];
    [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    addButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _addButton = addButton;
    self.selectedIndex = _selectedIndex;
    self.disableSelect = _disableSelect;
    
    // 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize size = self.view.bounds.size;
    _playButton.center = CGPointMake(size.width / 2, size.height / 2);
    
    CGRect safeBounds = self.view.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.view.safeAreaInsets);
    }
    const CGFloat addButtonWidth = 32;
    const CGFloat addButtonMargin = 16;
    const CGRect addButtonFrame = CGRectMake(CGRectGetMaxX(safeBounds) - addButtonWidth - addButtonMargin,
                                             CGRectGetMaxY(safeBounds) - addButtonWidth - addButtonMargin,
                                             addButtonWidth, addButtonWidth);
    _addButton.frame = addButtonFrame;
}

#pragma mark - 后台切换操作

/**
 进入后台
 */
- (void)enterBackFromFront {
    if (_moviePlayer) {
        [_moviePlayer stop];
        _playButton.hidden = NO;
    }
}

/**
 后台到前台
 */
- (void)enterFrontFromBack {
    
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

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    NSString *addButtonTitle = selectedIndex >= 0 ? @(selectedIndex + 1).description : nil;
    [_addButton setTitle:addButtonTitle forState:UIControlStateSelected];
    _addButton.selected = selectedIndex >= 0;
}

- (void)setPhAsset:(PHAsset *)phAsset {
    _phAsset = phAsset;
    _assetRequestId = -1;
    
    if (_avAsset) return;
    __weak typeof(self) weakSelf = self;
    [self addActionAfterViewDidLoad:^{
        [weakSelf preparePhAsset:phAsset completion:^(AVAsset *avAsset) {
            [weakSelf setupPlayerWithAsset:avAsset];
        }];
    }];
}

- (void)setAvAsset:(AVAsset *)avAsset {
    _avAsset = avAsset;
    
    if (_phAsset) return;
    __weak typeof(self) weakSelf = self;
    [self addActionAfterViewDidLoad:^{
        [weakSelf setupPlayerWithAsset:avAsset];
    }];
}


/**
 当文件数量达到最大可选数时禁止选择操作

 @param disableSelect 是否禁止选择
 */
- (void)setDisableSelect:(BOOL)disableSelect {
    _disableSelect = disableSelect;
    _addButton.hidden = disableSelect;
}

#pragma mark - action

/**
 点击手势事件

 @param sender 点击手势
 */
- (void)tapAction:(UITapGestureRecognizer *)sender {
    if (_moviePlayer.status == TuSDKMediaPlayerStatusPlaying) {
        [_moviePlayer pause];
    } else {
        [_moviePlayer play];
    }
}

/**
 添加按钮事件

 @param sender 添加按钮
 */
- (void)addButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.addButtonActionHandler) self.addButtonActionHandler(self, sender);
}

/**
 播放按钮事件

 @param sender 播放按钮
 */
- (void)playButtonAction:(UIButton *)sender {
    [_moviePlayer play];
}

#pragma mark - 获取视频资源

/**
 请求 PHAsset 为 AVAsset

 @param phAsset 输入 PHAsset
 @param completion 完成回调
 */
- (void)preparePhAsset:(PHAsset *)phAsset completion:(void (^)(AVAsset *avAsset))completion {
    __weak typeof(self) weakSelf = self;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        if (weakSelf.assetRequestId <= 0) return;
        
        if (progress == 1.0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TuSDK shared].messageHub dismiss];
            });
        } else {
            [[TuSDK shared].messageHub showProgress:progress status:@"iCloud 同步中"];
            weakSelf.view.userInteractionEnabled = NO;
        }
    };
    _assetRequestId = [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        weakSelf.assetRequestId = -1;
         weakSelf.view.userInteractionEnabled = YES;
        if (!asset) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(asset);
        });
    }];
}

#pragma mark - TuSDKMediaTimelineAssetMoviePlayerDelegate

/**
 进度改变事件
 
 @param player 当前播放器
 @param percent (0 - 1)
 @param outputTime 当前帧所在持续时间
 @param outputSlice 当前正在输出的切片信息
 @since      v3.0
 */
- (void)mediaTimelineAssetMoviePlayer:(TuSDKMediaTimelineAssetMoviePlayer *_Nonnull)player progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime outputSlice:(TuSDKMediaTimelineSlice * _Nonnull)outputSlice {

}

/**
 播放器状态改变事件
 
 @param player 当前播放器
 @param status 当前播放器状态
 @since      v3.0
 */
- (void)mediaTimelineAssetMoviePlayer:(TuSDKMediaTimelineAssetMoviePlayer *_Nonnull)player statusChanged:(TuSDKMediaPlayerStatus)status {
    _playButton.hidden = status == TuSDKMediaPlayerStatusPlaying;
}

@end
