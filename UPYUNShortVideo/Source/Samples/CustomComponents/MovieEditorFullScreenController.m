//
//  MovieEditorFullScreenController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/15.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditorFullScreenController.h"
#import "MovieEditerFullScreenBottomBar.h"
#import "ParticleEffectEditView.h"

@interface MovieEditorFullScreenController()<MovieEditorFullScreenBottomBarDelegate, ParticleEffectEditViewDelegate>{
    // 粒子特效编辑View
    ParticleEffectEditView *_particleEditView;
    // 当前选中的粒子特效code
    NSString *_selectedParticleCode;
    // 粒子特效 [Code:Color] 对应的字典对象
    NSDictionary *_colorDic;
}

@end

@implementation MovieEditorFullScreenController

#pragma mark - override method

- (void)lsqInitView
{
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    CGRect rect = [UIScreen mainScreen].bounds;

    // 视频播放view，将 frame 修改为全屏
    self.previewView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    self.previewView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.previewView];
    self.videoView = [[UIView alloc]initWithFrame:self.previewView.bounds];
    [self.previewView addSubview:self.videoView];
    
    // 播放按钮,  以 self.previewView.frame 进行初始化，如设置全屏，请修改 frame 避免 屏幕视图层级的遮挡
    self.playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.topBar.lsqGetSizeHeight, rect.size.width, rect.size.width)];
    [self.playBtn addTarget:self action:@selector(clickPlayerBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
    
    self.playBtnIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.playBtnIcon.center = CGPointMake(self.view.lsqGetSizeWidth/2, self.view.lsqGetSizeHeight/2);
    self.playBtnIcon.image = [UIImage imageNamed:@"video_style_default_crop_btn_record"];
    [self.playBtn addSubview:self.playBtnIcon];
    
    // 默认相机顶部控制栏
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    
    self.topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topY, rect.size.width, 44)];
    [self.topBar setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    self.topBar.topBarDelegate = self;
    [self.topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_movieEditor", @"视频编辑")
                     leftButtonInfo:@[@"video_style_default_btn_back.png"]
                    rightButtonInfo:@[NSLocalizedString(@"lsq_save_video", @"保存")]];
    self.topBar.centerTitleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.topBar];
    
    // 底部栏控件
    CGFloat bottomHeight = rect.size.height - rect.size.width - 44;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        bottomHeight -= 34;
    }
    
    self.bottomBar = [[MovieEditerFullScreenBottomBar alloc]initWithFrame:CGRectMake(0, rect.size.width + 44, rect.size.width , bottomHeight)];
    self.bottomBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.bottomBar.bottomBarDelegate = self;
    self.bottomBar.videoFilters = self.videoFilterCodes;
    self.bottomBar.filterView.currentFilterTag = 200;
    self.bottomBar.videoURL = self.inputURL;
    self.bottomBar.topThumbnailView.timeInterval = self.endTime - self.startTime;
    self.bottomBar.effectsView.effectsCode = self.videoEffectCodes;
    self.bottomBar.videoDuration = self.endTime - self.startTime;
    
    MovieEditerFullScreenBottomBar *bottomBar = (MovieEditerFullScreenBottomBar *)self.bottomBar;
    bottomBar.fullScreenBottomBarDelegate = self;
    [self.view addSubview:bottomBar];
    
    NSArray *particleCods = @[@"snow01", @"Love", @"Bubbles", @"Music", @"Star", @"Surprise", @"Flower", @"Magic", @"Money", @"Burning", @"Fireball"];
    NSArray *colorArr = @[lsqRGBA(255, 255, 255, 0.7), lsqRGBA(254, 15, 15, 0.7), lsqRGBA(170, 170, 170, 0.7), lsqRGBA(54, 101, 255, 0.7),
                          lsqRGBA(95, 250, 197, 0.7), lsqRGBA(148, 123, 255, 0.7), lsqRGBA(255, 155, 190, 0.7), lsqRGBA(100, 253, 253, 0.7),
                          lsqRGBA(252, 231, 123, 0.7), lsqRGBA(255, 145, 91, 0.7), lsqRGBA(255, 203, 91, 0.7)];
    _colorDic = [NSDictionary dictionaryWithObjects:colorArr forKeys:particleCods];
    // 根据不同需求可创建不同的对应颜色  或者使用随机色
//    _colorDic = [self getDicWithParticleCode:particleCods];

    [bottomBar.particleView createParticleEffectsWith:particleCods];
    [self initParticleEditView];
}

- (void)initParticleEditView;
{
    _particleEditView = [[ParticleEffectEditView alloc]initWithFrame:CGRectMake(0, self.bottomBar.lsqGetOriginY, self.view.lsqGetSizeWidth, 80)];
    _particleEditView.displayView.videoURL = self.inputURL;
    _particleEditView.particleDelegate = self;
    [self.view addSubview:_particleEditView];
}

#pragma mark - private method

- (UIColor *)getRandomColor;
{
    return [UIColor colorWithRed:random()%255/255.0 green:random()%255/255.0 blue:random()%255/255.0 alpha:0.9];
}

- (NSDictionary *)getDicWithParticleCode:(NSArray *)codeArr;
{
    NSMutableArray *colorArr = [NSMutableArray array];
    for (int i = 0; i < codeArr.count; i++) {
        UIColor *randColor = [self getRandomColor];
        [colorArr addObject:randColor];
    }
    
    return [NSDictionary dictionaryWithObjects:colorArr forKeys:codeArr];
}

// 更新删除按钮的是否可点击状态
- (void)updateRemoveBtnEnableState;
{
    if (_particleEditView.displayView.segmentCount > 0) {
       ((MovieEditerFullScreenBottomBar *) self.bottomBar).particleView.removeEffectBtn.enabled = YES;
    }else{
       ((MovieEditerFullScreenBottomBar *) self.bottomBar).particleView.removeEffectBtn.enabled = NO;
    }
}

#pragma mark - 初始化 movieEditor 

- (void)initSettingsAndPreview
{
    TuSDKMovieEditorOptions *options = [TuSDKMovieEditorOptions defaultOptions];
    // 设置视频地址
    options.inputURL = self.inputURL;
    // 设置视频截取范围
    options.cutTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:self.startTime endSeconds:self.endTime];
    // 是否按照时间播放
    options.playAtActualSpeed = YES;
    // 设置裁剪范围 注：该参数对应的值均为比例值，即：若视频展示View总高度800，此时截取时y从200开始，则cropRect的 originY = 偏移位置/总高度， 应为 0.25, 其余三个值同理
    // 如需全屏展示，可以注释 options.cropRect = _cropRect; 该行设置，配合 view 的 frame 的更改，即可全屏展示
    // 可以直接设置 options.cropRect = CGRectMake(0, 0, 0, 0);
    options.cropRect = self.cropRect;
    // 设置编码视频的画质
    options.encodeVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_High1];
    // 是否保留原音
    options.enableVideoSound = YES;

    self.movieEditor = [[TuSDKMovieEditor alloc]initWithPreview:self.videoView options:options];
    self.movieEditor.delegate = self;
    
    // 保存到系统相册 默认为YES
    self.movieEditor.saveToAlbum = YES;
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    self.movieEditor.fileType = lsqFileTypeMPEG4;
    // 设置水印，默认为空
    self.movieEditor.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
    // 设置水印图片的位置
    self.movieEditor.waterMarkPosition = lsqWaterMarkTopRight;
    // 视频播放音量设置，0 ~ 1.0 仅在 enableVideoSound 为 YES 时有效
    self.movieEditor.videoSoundVolume = 0.5;
    // 设置当前生效的特效(滤镜、场景特效、粒子特效)  注：滤镜、场景特效、粒子特效不能同时添加，当 EfficientEffectMode 为Default时 以后添加的特效为准，当Mode进行限定时，则以限定的模式为准
    self.movieEditor.efficientEffectMode = lsqMovieEditorEfficientEffectModeDefault;
    // 设置默认镜
    [self.movieEditor switchFilterWithCode:self.videoFilterCodes[0]];
    // 加载视频，显示第一帧
    [self.movieEditor loadVideo];
}

#pragma mark - MovieEditorFullScreenBottomBarDelegate

/**
 切换粒子特效
 
 @param filterCode 粒子特效code
 */
- (void)movieEditorFullScreenBottom_particleViewSwitchEffectWithCode:(NSString *)particleEffectCode;
{
    _selectedParticleCode = particleEffectCode;
    // 隐藏底部栏 顶部栏
    self.bottomBar.hidden = YES;
    self.topBar.hidden = YES;
    // 视频跳转至progress == 0
    [self.movieEditor seekToPreviewWithTime:kCMTimeZero];
    [self stopPreview];
    
    // 点击后 particleEditView 进入编辑模式
    _particleEditView.isEditStatus = YES;
    _particleEditView.selectColor = _colorDic[particleEffectCode];
}

/**
 点击撤销按钮
 */
- (void)movieEditorFullScreenBottom_removeLastParticleEffect;
{
    [self.movieEditor removeLastEffectWithMode:lsqMovieEditorEffectMode_Particle];
    [_particleEditView removeLastParticleEffect];
    [self updateRemoveBtnEnableState];
}

#pragma mark - ParticleEffectEditViewDelegate

/**
 是否选中粒子特效展示栏
 */
- (void)movieEditorFullScreenBottom_selectParticleView:(BOOL)isParticle;
{
    if (_particleEditView.hidden != !isParticle)
        _particleEditView.hidden = !isParticle;
}

/**
 开始当前的特效
 */
- (void)particleEffectEditView_startParticleEffect;
{
    if (![self.movieEditor isPreviewing]) {
        [self startPreview];
    }
    [self.movieEditor addEffectWithCode:_selectedParticleCode withMode:lsqMovieEditorEffectMode_Particle];
}

/**
 结束当前的特效
 */
- (void)particleEffectEditView_endParticleEffect;
{
    [self stopPreview];
    [self.movieEditor addEndEffectWithMode:lsqMovieEditorEffectMode_Particle];
}

/**
 取消当前正在添加的特效
 */
- (void)particleEffectEditView_cancleParticleEffect;
{
    [self.movieEditor cancleAddingEffectWithMode:lsqMovieEditorEffectMode_Particle];
}

/**
 更新粒子轨迹位置
 
 @param newPoint 粒子轨迹的点
 */
- (void)particleEffectEditView_particleViewUpdatePoint:(CGPoint)newPoint;
{
    [self.movieEditor updateParticleEmitPosition:newPoint];
}

/**
 更新粒子大小size
 
 @param newSize 粒子大小
 */
- (void)particleEffectEditView_particleViewUpdateSize:(CGFloat)newSize;
{
    [self.movieEditor updateParticleEmitSize:newSize];
}

/**
 更新粒子颜色
 
 @param newColor 粒子颜色
 */
- (void)particleEffectEditView_particleViewUpdateColor:(UIColor *)newColor;
{
    [self.movieEditor updateParticleEmitColor:newColor];
}

/**
 移除上一个粒子特效
 */
- (void)particleEffectEditView_removeLastParticleEffect;
{
    [self.movieEditor removeLastEffectWithMode:lsqMovieEditorEffectMode_Particle];
}

/**
 点击播放按钮  YES：开始播放   NO：暂停播放
 
 @param isStartPreview YES:开始预览
 */
- (void)particleEffectEditView_playVideoEvent:(BOOL)isStartPreview;
{
    if (isStartPreview) {
        [self startPreview];
    }else{
        [self stopPreview];
    }
}

/**
 点击返回按钮
 */
- (void)particleEffectEditView_backViewEvent;
{
    _particleEditView.isEditStatus = NO;
    self.bottomBar.hidden = NO;
    self.topBar.hidden = NO;
    [self updateRemoveBtnEnableState];
}

/**
 手势移动缩略图的进度展示条
 
 @param progress 移动到某一 progress
 */
- (void)particleEffectEditView_moveLocationWithProgress:(CGFloat)progress;
{
    if ([self.movieEditor isPreviewing]) {
        [self.movieEditor stopPreview];
    }
    CMTime newTime = CMTimeMakeWithSeconds(progress * (self.endTime - self.startTime), 1*USEC_PER_SEC);
    [self.movieEditor seekToPreviewWithTime:newTime];
}

#pragma mark - TuSDKMovieEditorDelegate

/**
 播放进度通知
 
 @param editor editor TuSDKMovieEditor
 @param progress progress description
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor progress:(CGFloat)progress
{
    [super onMovieEditor:editor progress:progress];
    if (self.movieEditorStatus == lsqMovieEditorStatusPreviewing) {
        // 注意：UI相关修改需要确认在主线程中进行
        dispatch_async(dispatch_get_main_queue(), ^{
            _particleEditView.videoProgress = progress;
        });
    }
}

@end
