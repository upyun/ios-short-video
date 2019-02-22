//
//  MovieEditViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MovieEditViewController.h"
#import "TuSDKFramework.h"

#import "EditCollectionViewDataSource.h"
#import "BaseEditComponentViewController.h"

#import "EditFilterViewController.h"
#import "EditMVViewController.h"
#import "EditMusicViewController.h"
#import "EditTextViewController.h"
#import "EditEffectViewController.h"

#import "AspectVideoPreviewView.h"
#import "Constants.h"
#import "FilterSwipeView.h"

@interface MovieEditViewController ()<
UICollectionViewDelegate,
TuSDKMovieEditorLoadDelegate, TuSDKMovieEditorPlayerDelegate, TuSDKMovieEditorSaveDelegate,
EditComponentNavigatorDelegate, FilterSwipeViewDelegate
>

/**
 预览视图
 */
@property (weak, nonatomic) IBOutlet AspectVideoPreviewView *previewView;

/**
 底部标签栏视图
 */
@property (weak, nonatomic) IBOutlet UICollectionView *effectCollectionView;

/**
 底部标签栏视图数据源
 */
@property (strong, nonatomic) IBOutlet EditCollectionViewDataSource *effectCollectionViewDataSource;

/**
 滤镜滑动切换视图
 */
@property (weak, nonatomic) IBOutlet FilterSwipeView *filterSwipeView;

/**
 预览视图底部布局
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewBottomLayout;

/**
 底部标签栏高度布局
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabHeightLayout;

/**
 底部标签栏布局
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBottomLayout;

/**
 编辑器
 */
@property (nonatomic, strong) TuSDKMovieEditor *movieEditor;

/**
 播放进度
 */
@property (nonatomic, assign) double playbackProgress;

/**
 子操作页面引用
 */
@property (nonatomic, weak) BaseEditComponentViewController *currentEditComponentViewController;

/**
 缩略图数组
 */
@property (nonatomic, strong) NSArray<UIImage *> *thumbnails;

/**
 当前的滤镜 code（filterCode）
 */
@property (nonatomic, copy) NSString *currentFilterCode;

/**
 播放按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *playButton;

/**
 当前功能标签索引
 */
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation MovieEditViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 设置屏幕常亮，默认是NO
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 如需跳转其他页面操作再返回，需要注释销毁代码，或在`-dealloc` 中调用
    [self destroyMovieEditor];
    // 关闭屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_inputURL) _inputURL = [[NSBundle mainBundle] URLForResource:@"tusdk_sample_video" withExtension:@"mov"];
    [self setupUI];
    // 初始化视频编辑器
    [self setupMovieEditor];
    // 加载时间轴展示的缩略图
    [self setupThumbnails];
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setupThumbnails {
    // 输入
    AVAsset *asset = [AVAsset assetWithURL:_inputURL];
    // 配置
    TuSDKVideoImageExtractor *videoFrameExtractor = [TuSDKVideoImageExtractor createExtractor];
    videoFrameExtractor.videoAsset = asset;
    videoFrameExtractor.extractFrameCount = 20;
    // 获取结果
    [videoFrameExtractor asyncExtractImageList:^(NSArray<UIImage *> *thumbnails) {
        self.thumbnails = thumbnails;
    }];
}

#pragma mark - UI

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setupUI {
    UIButton *rightButton = self.topNavigationBar.rightButton;
    [rightButton setTitle:NSLocalizedStringFromTable(@"tu_保存", @"VideoDemo", @"保存") forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _playButton.alpha = .0;
}

/**
 更新预览视图底部偏移

 @param bottomHeight 底部偏移
 @param animated 是否动画更新
 */
- (void)updatePreviewBottomOffset:(CGFloat)bottomHeight animated:(BOOL)animated {
    if (bottomHeight < 0) return;
    
    if (animated) {
        [self.view updateConstraintsIfNeeded];
        self.previewBottomLayout.constant = bottomHeight;
        [UIView animateWithDuration:kNavigationAnimationDuration animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    } else {
        [self.view setNeedsUpdateConstraints];
    }
}

/**
 设置顶部导航栏和底部功能栏的显示/隐藏

 @param hidden 是否隐藏
 @param animated 是否动画更新
 */
- (void)setBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self setTabHidden:hidden animated:animated];
    CGFloat alpha = hidden ? .0 : 1.0;
    void (^animations)(void) = ^{
        self.effectCollectionView.alpha = alpha;
        self.topNavigationBar.alpha = alpha;
    };
    
    if (animated) {
        [UIView animateWithDuration:kNavigationAnimationDuration animations:animations];
    } else {
        animations();
    }
}

/**
 设置底部标签栏隐藏

 @param hidden 是否隐藏
 @param animated 是否动画更新
 */
- (void)setTabHidden:(BOOL)hidden animated:(BOOL)animated {
    NSTimeInterval animationDuration = animated ? kNavigationAnimationDuration : 0;
    CGFloat tabBottomConstant = hidden ? self.tabHeightLayout.constant : 0;
    self.tabBottomLayout.constant = tabBottomConstant;
    
    if (animated) {
        [UIView animateWithDuration:animationDuration animations:^{
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.view setNeedsUpdateConstraints];
    }
}

#pragma mark - property

- (void)setThumbnails:(NSArray<UIImage *> *)thumbnails {
    _thumbnails = thumbnails;
    _currentEditComponentViewController.thumbnails = thumbnails;
}

- (void)setPlaybackProgress:(double)playbackProgress {
    _playbackProgress = playbackProgress;
    _currentEditComponentViewController.playbackProgress = playbackProgress;
}

- (EditComponentNavigator *)componentNavigator {
    if (!_componentNavigator) {
        _componentNavigator = [[EditComponentNavigator alloc] initWithRootViewController:self];
        _componentNavigator.delegate = self;
    }
    return _componentNavigator;
}

- (void)setCurrentEditComponentViewController:(BaseEditComponentViewController *)currentEditComponentViewController {
    _currentEditComponentViewController = currentEditComponentViewController;
    // 同步信息
    currentEditComponentViewController.movieEditor = _movieEditor;
    currentEditComponentViewController.thumbnails = _thumbnails;
    currentEditComponentViewController.playbackProgress = _playbackProgress;
    currentEditComponentViewController.playing = _movieEditor.isPreviewing;
}

- (void)setCurrentFilterCode:(NSString *)currentFilterCode {
    _currentFilterCode = currentFilterCode;
    
    TuSDKMediaFilterEffect *filterEffect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:currentFilterCode];
    
    [_movieEditor addMediaEffect:filterEffect];
}

#pragma mark - MoviewEditor 初始化

- (void)setupMovieEditor {
    TuSDKMovieEditorOptions *option = [TuSDKMovieEditorOptions defaultOptions];
    // 设置视频地址
    option.inputURL = self.inputURL;
    // 保存到系统相册 默认为YES
    option.saveToAlbum = NO;
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    option.fileType = lsqFileTypeMPEG4;
    // 设置视频截取范围
    //option.cutTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_startTime endSeconds:_endTime];
    // 是否按照时间播放
    //option.playAtActualSpeed = YES;
    // 设置裁剪范围 注：该参数对应的值均为比例值，即：若视频展示View总高度800，此时截取时y从200开始，则cropRect的 originY = 偏移位置/总高度， 应为 0.25, 其余三个值同理
    // option.cropRect = CGRectMake(1.0, 1.0, 1.0, 1.0);
    // 视频输出尺寸 注：当使用 cropRect 设置了裁剪范围后，该参数不再生效
    // option.outputSize = CGSizeMake(720, 720);
    // 设置编码视频的画质
    option.encodeVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Medium1];
    // 是否保留原音
    option.enableVideoSound = YES;
    // 视频底色
    option.regionViewColor = lsqRGB(18, 18, 18);
    // 设置水印，默认为空
    option.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
    // 设置水印图片的位置
    option.waterMarkPosition = lsqWaterMarkTopRight;
    // 设置画面特效输出时间轴
    option.pictureEffectOptions.referTimelineType = TuSDKMediaEffectReferInputTimelineType;
    // 视频预览的视频底色
    _previewView.backgroundColor = lsqRGB(18, 18, 18);
    
    __weak typeof(self) weakSelf = self;
    _movieEditor = [[TuSDKMovieEditor alloc] initWithPreview:_previewView.videoView options:option];
    
    _previewView.resizeHandler = ^(AspectVideoPreviewView * _Nonnull previewView) {
        [weakSelf.movieEditor updatePreViewFrame:previewView.videoView.bounds];
    };
    
    // 播放状态监听
    _movieEditor.playerDelegate = self;
    // 加载状态监听
    _movieEditor.loadDelegate = self;
    // 保存状态监听
    _movieEditor.saveDelegate = self;
    // 输出音量调节
    _movieEditor.videoSoundVolume = 1;
    // 加载视频，显示第一帧
    [_movieEditor loadVideo];
}

#pragma mark - 后台切换操作

/**
 进入后台
 */
- (void)enterBackFromFront {
    if (_movieEditor) {
        if ([_movieEditor isRecording]) {
            // 调用 stopRecording 会将已处理的视频保存下来；cancelRecording 会取消已录制的内容
            [_movieEditor cancelRecording];
        }
        if ([_movieEditor isPreviewing]) {
            [_movieEditor seekToTime:kCMTimeZero];
            [_movieEditor stopPreview];
        }
    }
}

/**
 后台到前台
 */
- (void)enterFrontFromBack {
    [[TuSDK shared].messageHub dismiss];
}

#pragma mark - action

/**
 预览点击事件

 @param sender 点击手势
 */
- (IBAction)previewTapAction:(UITapGestureRecognizer *)sender {
    if (_movieEditor.isPreviewing) {
        [_movieEditor pausePreView];
    } else {
        [_movieEditor startPreview];
    }
}

/**
 播放按钮事件

 @param sender 播放按钮
 */
- (IBAction)playButtonAction:(UIButton *)sender {
    [_movieEditor startPreview];
}

/**
 保存按钮事件

 @param sender 保存按钮
 */
- (void)saveButtonAction:(UIButton *)sender {
    if (![_movieEditor isRecording]) {
        [_movieEditor startRecording];
    }
}

#pragma mark - EditComponentNavigatorDelegate

/**
 顶部视图控制器更新回调
 
 @param navigator 页面导航管理器
 @param topViewController 顶层视图控制器
 */
- (void)navigator:(EditComponentNavigator *)navigator didChangeTopViewController:(UIViewController<EditComponentNavigationProtocol> *)topViewController {
    BOOL shouldShowPlayButton = [topViewController respondsToSelector:@selector(shouldShowPlayButton)] && topViewController.shouldShowPlayButton;
    
    _playButton.hidden = !shouldShowPlayButton;
}

#pragma mark - EditComponentNavigationProtocol

/**
 是否应显示播放按钮
 */
- (BOOL)shouldShowPlayButton {
    return YES;
}

/**
 控制器调用 `-pushEditComponentViewController:` 后，跳转页面前的回调
 可在这里进行 UI 的更新
 
 @param controllerWillPushTo 即将跳转的控制器
 */
- (void)actionBeforePushToViewController:(UIViewController<EditComponentNavigationProtocol> *)controllerWillPushTo {
    [self setBarHidden:YES animated:YES];
    CGFloat bottomOffset = [controllerWillPushTo.class bottomPreviewOffset];
    if (@available(iOS 11.0, *)) {
        bottomOffset += self.view.safeAreaInsets.bottom;
    }
    [self updatePreviewBottomOffset:bottomOffset animated:YES];
    _filterSwipeView.hidden = YES;
}

/**
 其他页面控制器 `-pushEditComponentViewController:`  弹栈后回到当前页面控制器时，调用当前控制器的该方法
 
 @param controllerDidPop 弹栈的页面控制
 */
- (void)actionAfterPopFromViewController:(UIViewController<EditComponentNavigationProtocol> *)controllerDidPop {
    // 更新 UI
    [self setBarHidden:NO animated:YES];
    [self updatePreviewBottomOffset:0 animated:YES];
    _playButton.alpha = _movieEditor.status != lsqMovieEditorStatusPreviewing;
    _filterSwipeView.hidden = NO;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    EditComponentIndex index = indexPath.item;
    _selectIndex = index;
    BaseEditComponentViewController *editComponentViewController = nil;
    switch (index) {
        // 进入滤镜页面
        case EditComponentIndexFilter:{
            EditFilterViewController *filterViewController = [[EditFilterViewController alloc] initWithNibName:nil bundle:nil];
            editComponentViewController = filterViewController;
        } break;
        // 进入 MV 页面
        case EditComponentIndexMV:{
            EditMVViewController *mvViewController = [[EditMVViewController alloc] initWithNibName:nil bundle:nil];
            editComponentViewController = mvViewController;
        } break;
        // 进入配音页面
        case EditComponentIndexMusic:{
            EditMusicViewController *musicViewController = [[EditMusicViewController alloc] initWithNibName:nil bundle:nil];
            editComponentViewController = musicViewController;
        } break;
        // 进入文字贴纸页面
        case EditComponentIndexText:{
            EditTextViewController *textViewController = [[EditTextViewController alloc] initWithNibName:nil bundle:nil];
            editComponentViewController = textViewController;
        } break;
        // 进入特效页面
        case EditComponentIndexEffect:{
            EditEffectViewController *effectViewController = [[EditEffectViewController alloc] initWithNibName:nil bundle:nil];
            editComponentViewController = effectViewController;
        } break;
    }

    self.currentEditComponentViewController = editComponentViewController;
    [self.componentNavigator pushEditComponentViewController:editComponentViewController];
    
    [self.view bringSubviewToFront:_playButton];
}

#pragma mark - FilterSwipeViewDelegate

/**
 响应手势滑动时回调
 
 @param filterSwipeView 滤镜滑动切换视图
 @param filterCode 即将切换到的滤镜码
 @return 是否更新显示的滤镜名称
 */
- (BOOL)filterSwipeView:(FilterSwipeView *)filterSwipeView shouldChangeFilterCode:(NSString *)filterCode {
    if (!filterCode.length) {
        [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeFilter];
    } else {
        // 应用滤镜
        TuSDKMediaFilterEffect *filterEffect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:filterCode];
        [_movieEditor addMediaEffect:filterEffect];
    }
    
    /** 切换滤镜时 如果当前视频没有正在播放开启预览。 */
    if (!_movieEditor.isPreviewing)
        [_movieEditor startPreview];
    
    
    return YES;
}

#pragma mark - TuSDKMovieEditorLoadDelegate

/**
 加载进度改变事件
 
 @param editor TuSDKMovieEditor
 @param percentage 进度百分比 (0 - 1)
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor loadProgressChanged:(CGFloat)percentage {
    [[TuSDK shared].messageHub showProgress:percentage status:NSLocalizedStringFromTable(@"tu_正在处理视频", @"VideoDemo", @"正在处理视频")];
}

/**
 加载状态回调
 
 @param editor 视频编辑器
 @param status 视频编辑器运行状态
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor loadStatusChanged:(lsqMovieEditorStatus)status {
    switch (status) {
        // 正在加载
        case lsqMovieEditorStatusLoading:{
            // 禁用界面交互
            self.view.userInteractionEnabled = NO;
        } break;
        // 加载完成
        case lsqMovieEditorStatusLoaded:{
            // 启用界面交互事件
            self.view.userInteractionEnabled = YES;
            NSLog(@"加载完成");
            // 自动播放
            [editor startPreview];
        } break;
        // 加载失败
        case lsqMovieEditorStatusLoadFailed:{
            NSLog(@"加载失败");
        } break;
        default: {} break;
    }
}

/**
 视频加载完成
 
 @param editor TuSDKMovieEditor
 @param assetInfo 视频信息
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor assetInfoReady:(TuSDKMediaAssetInfo * _Nullable)assetInfo error:(NSError *_Nullable)error {
    if (error) {
        [[TuSDK shared].messageHub showError:@"视频加载失败"];
        NSLog(@"加载失败，error: %@", error);
    } else {
        [[TuSDK shared].messageHub dismiss];
        _previewView.videoSize = assetInfo.videoInfo.videoTrackInfoArray.firstObject.presentSize;
    }
}

#pragma mark - TuSDKMovieEditorPlayerDelegate

/**
 播放进度改变事件
 
 @param editor MovieEditor
 @param percent (0 - 1)
 @param outputTime 导出文件后所在输出时间
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime {
    // 预览时 更新UI
    self.playbackProgress = CMTimeGetSeconds(editor.outputTimeAtSlice) / CMTimeGetSeconds(editor.inputDuration);
}

/**
 播放状态改变事件
 
 @param editor MovieEditor
 @param status 当前播放状态
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor playerStatusChanged:(lsqMovieEditorStatus)status {
    BOOL playing = NO;
    switch (status) {
        // 正在预览
        case lsqMovieEditorStatusPreviewing:{
            // 正在播放
            playing = YES;
            NSLog(@"正在播放");
        } break;
        // 预览暂停
        case lsqMovieEditorStatusPreviewingPause:{
            // 暂停播放
            playing = NO;
            NSLog(@"暂停播放");
        } break;
        // 预览完成
        case lsqMovieEditorStatusPreviewingCompleted:{
            NSLog(@"播放完成");
        } break;
        default:{} break;
    }
    _currentEditComponentViewController.playing = playing;
    _playButton.alpha = !playing;
}

#pragma mark - TuSDKMovieEditorSaveDelegate

/**
 保存进度改变事件
 
 @param editor TuSDKMovieEditor
 @param percentage 进度百分比 (0 - 1)
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor saveProgressChanged:(CGFloat)percentage {
    [TuSDKProgressHUD showProgress:percentage status:NSLocalizedStringFromTable(@"tu_正在保存...", @"VideoDemo", @"正在保存...") maskType:TuSDKProgressHUDMaskTypeBlack];
}

/**
 视频保存完成
 
 @param editor TuSDKMovieEditor
 @param result 保存结果
 @param error 错误信息
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor saveResult:(TuSDKVideoResult *_Nullable)result error:(NSError *_Nullable)error {
    if (error) {
        NSLog(@"保存失败，error: %@", error);
        [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_保存失败", @"VideoDemo", @"保存失败")];
        return;
    }
    
    // 通过 result.videoPath 拿到视频的临时文件路径
    if (result.videoPath) {
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
                [[TuSDK shared].messageHub showSuccess:@"上传失败"];
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


        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_保存成功", @"VideoDemo", @"保存成功")];


    } else {
        // _movieEditor.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_保存成功", @"VideoDemo", @"保存成功")];
    }
    
    // 保存成功后取消提示框 同时返回到root
    [self popToRootViewControllerAnimated:true];
}

/**
 保存状态改变事件
 
 @param editor MovieEditor
 @param status 当前保存状态
 
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor saveStatusChanged:(lsqMovieEditorStatus)status {
    NSLog(@"mediaMovieEditor saveStatusChanged : %ld ", status);
    
    switch (status) {
        // 正在保存
        case lsqMovieEditorStatusRecording:{
            
        } break;
        // 取消保存
        case lsqMovieEditorStatusRecordingCancelled:{
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_取消保存", @"VideoDemo", @"取消保存")];
        } break;
        // 保存失败
        case lsqMovieEditorStatusRecordingFailed:{
            
        } break;
        // 完成保存
        case lsqMovieEditorStatusRecordingCompleted:{
            
        } break;
        default:{} break;
    }
}

#pragma mark - 销毁操作

- (void)destroyMovieEditor {
    [_movieEditor destroy];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
