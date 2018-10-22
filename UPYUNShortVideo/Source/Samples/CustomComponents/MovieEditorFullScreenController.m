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

#import "Constants.h"
#import "StickerTextEditor.h"


@interface MovieEditorFullScreenController()<MovieEditorFullScreenBottomBarDelegate, ParticleEffectEditViewDelegate>{
    // 粒子特效编辑View
    ParticleEffectEditView *_particleEditView;
    // 当前选中的粒子特效code
    NSString *_selectedParticleCode;
    // 粒子特效 [Code:Color] 对应的字典对象
    NSDictionary *_colorDic;
    
    TuSDKMediaParticleEffectData *_editingParticleEffect;
    //文字特效编辑View
    StickerTextEditor * _stickerTextEditor;
    
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
    self.playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.topBar.lsqGetSizeHeight, rect.size.width, rect.size.height)];
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

    CGFloat bottomHeight = rect.size.width == 320 ? rect.size.height - rect.size.width - 44 : 240;
    CGFloat bottomOrignY = rect.size.height - bottomHeight;
    
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        bottomOrignY -= 34;
    }
    
    self.bottomBar = [[MovieEditerFullScreenBottomBar alloc]initWithFrame:CGRectMake(0, bottomOrignY, rect.size.width , bottomHeight)];
    self.bottomBar.bottomBarDelegate = self;
    self.bottomBar.videoFilters = kVideoFilterCodes;
    self.bottomBar.videoURL = self.inputURL;
    self.bottomBar.effectsView.effectsCode = kVideoEffectCodes;
    [self.bottomBar bottomButton:nil clickIndex:0];
    
    MovieEditerFullScreenBottomBar *bottomBar = (MovieEditerFullScreenBottomBar *)self.bottomBar;
    bottomBar.fullScreenBottomBarDelegate = self;
    [self.view addSubview:bottomBar];
    
    _colorDic = [NSDictionary dictionaryWithObjects:kVideoPaticleColors forKeys:kVideoParticleCodes];
    // 根据不同需求可创建不同的对应颜色  或者使用随机色
//    _colorDic = [self getDicWithParticleCode:particleCods];

    [bottomBar.particleView createParticleEffectsWith:kVideoParticleCodes];
    [self initParticleEditView];
}

- (void)initParticleEditView;
{
    _particleEditView = [[ParticleEffectEditView alloc]initWithFrame:CGRectMake(0, self.bottomBar.lsqGetOriginY, self.view.lsqGetSizeWidth, 80)];
    _particleEditView.displayView.videoURL = self.inputURL;
    _particleEditView.particleDelegate = self;
    [self.view addSubview:_particleEditView];
    _particleEditView.hidden = YES;
}

#pragma mark - TextEffectEdit 文字贴纸特效

/**
 文字贴纸特效: 初始化
 @since     v2.2.0
 */
-(void)initTextEditView
{
    _stickerTextEditor = [[StickerTextEditor alloc] initWithFrame:CGRectZero WithMovieEditor:self];
    _stickerTextEditor.bottomThumbnailView.videoURL  = self.inputURL;
    _stickerTextEditor.bottomThumbnailView.duration = CMTimeGetSeconds(self.movieEditor.timelineOutputDuraiton);
    [self.view addSubview:_stickerTextEditor];
}

/**
 文字贴纸特效：添加文字效果
 @since      v2.2.0
 */
-(void)movieEditorFullScreenBottom_addTextEffect
{
    if (!_stickerTextEditor) {
        // 文字编辑界面初始化
        [self initTextEditView];
    }
    
    self.bottomBar.hidden = YES;
    self.topBar.hidden = YES;
    _particleEditView.hidden = YES;
    
    // 进入后移除文字贴纸效果重新编辑
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerText];
    
    // 重新设置preView大小
    [self.movieEditor updatePreViewFrame:_stickerTextEditor.preViewFrame];
    
    // 暂停预览
    [self pausePreview];
    [self.movieEditor seekToTime:kCMTimeZero];
    
    // 重置缩略栏当前时间
    _stickerTextEditor.bottomThumbnailView.currentTime = 0;
    _stickerTextEditor.isEditTextStatus = YES;
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
    options.cutTimeRange = [TuSDKTimeRange makeTimeRangeWithStart:self.cutTimeRange.start duration:self.cutTimeRange.duration];
    // 设置裁剪范围 注：该参数对应的值均为比例值，即：若视频展示View总高度800，此时截取时y从200开始，则cropRect的 originY = 偏移位置/总高度， 应为 0.25, 其余三个值同理
    // 如需全屏展示，可以注释 options.cropRect = _cropRect; 该行设置，配合 view 的 frame 的更改，即可全屏展示
    // 可以直接设置 options.cropRect = CGRectMake(0, 0, 0, 0);
    options.cropRect = self.cropRect;
    // 设置编码视频的画质
    options.encodeVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Medium1];
    // 是否保留原音
    options.enableVideoSound = YES;
    // 保存到系统相册 默认为YES
    options.saveToAlbum = NO;
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    options.fileType = lsqFileTypeMPEG4;
    // 设置水印，默认为空
    options.waterMarkImage = [UIImage imageNamed:@"sample_watermark.png"];
    // 设置水印图片的位置
    options.waterMarkPosition = lsqWaterMarkTopRight;
    
    self.movieEditor = [[TuSDKMovieEditor alloc]initWithPreview:self.videoView options:options];

    // 监听特效数据信息改变事件
    self.movieEditor.mediaEffectsDelegate = self;
    // 视频加载事件监听
    self.movieEditor.loadDelegate = self;
    // 视频保存事件委托
    self.movieEditor.saveDelegate = self;
    // 视频播放进度监听. 可获取监听播放进度及正在播放的切片信息
    self.movieEditor.playerDelegate = self;
    
    // 视频播放音量设置，0 ~ 1.0 仅在 enableVideoSound 为 YES 时有效
    self.movieEditor.videoSoundVolume = 0.5;
    
    // 加载视频，显示第一帧
    [self.movieEditor loadVideo];
}

#pragma mark - MovieEditorFullScreenBottomBarDelegate 粒子特效

/**
 切换粒子特效
 
 @param filterCode 粒子特效code
 */
- (void)movieEditorFullScreenBottom_particleViewSwitchEffectWithCode:(NSString *)particleEffectCode;
{
    // 暂停预览
    [self pausePreview];
    
    _selectedParticleCode = particleEffectCode;
    // 隐藏底部栏 顶部栏
    self.bottomBar.hidden = YES;
    self.topBar.hidden = YES;
    
    // 点击后 particleEditView 进入编辑模式
    _particleEditView.isEditStatus = YES;
    _particleEditView.selectColor = _colorDic[particleEffectCode];
}

/**
 点击撤销按钮
 */
- (void)movieEditorFullScreenBottom_removeLastParticleEffect;
{
    TuSDKMediaEffectData *mediaEffect = [[self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeParticle] lastObject];
    [self.movieEditor removeMediaEffect:mediaEffect];
    
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
    _editingParticleEffect = [[TuSDKMediaParticleEffectData alloc] initWithEffectsCode:_selectedParticleCode];
    _editingParticleEffect.particleSize = _particleEditView.particleSize;
    _editingParticleEffect.particleColor = _particleEditView.particleColor;
        
    [self.movieEditor applyMediaEffect:_editingParticleEffect];
    
    if (![self.movieEditor isPreviewing])
        [self startPreview];

}

/**
 结束当前的特效
 */
- (void)particleEffectEditView_endParticleEffect;
{
    [self pausePreview];
}

/**
 取消当前正在添加的特效
 */
- (void)particleEffectEditView_cancleParticleEffect;
{
    if (_editingParticleEffect)
        [self.movieEditor removeMediaEffect:_editingParticleEffect];
    
    _editingParticleEffect = nil;
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
    TuSDKMediaEffectData *mediaEffect = [[self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeParticle] lastObject];
    [self.movieEditor removeMediaEffect:mediaEffect];
}

/**
 点击播放按钮  YES：开始播放   NO：暂停播放
 
 @param isStartPreview YES:开始预览
 */
- (void)particleEffectEditView_playVideoEvent:(BOOL)isStartPreview;
{
    if ([self.movieEditor isPreviewing]) {
        // 暂停播放
        [self pausePreview];
    }else{
        // 开始播放
        [self startPreview];
    }
}

/**
 粒子效果界面点击返回按钮
 */
- (void)particleEffectEditView_backViewEvent;
{
    _particleEditView.isEditStatus = NO;
    self.playBtn.hidden = ([self movieEditor].status == lsqMovieEditorStatusPreviewing);
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
        [self pausePreview];
    }
    
    CMTime outputTime = CMTimeMultiplyByFloat64(self.movieEditor.timelineOutputDuraiton, progress);
    [self.movieEditor seekToTime:outputTime];
}


#pragma mark - TuSDKMovieEditorLoadDelegate 视频加载事件委托

/**
 视频加载完成
 
 @param editor TuSDKMovieEditor
 @param movieInfo 视频信息
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor assetInfoReady:(TuSDKMediaAssetInfo *)movieInfo error:(NSError *)error;
{
    [super mediaMovieEditor:editor assetInfoReady:movieInfo error:error];
    self.bottomBar.videoDuration = editor.duration;
}

#pragma mark - TuSDKMovieEditorPlayerDelegate

/**
 播放进度改变事件
 
 @param player 当前播放器
 @param percent (0 - 1)
 @param outputTime 导出文件后所在输出时间
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime;
{
    [super mediaMovieEditor:editor progressChanged:percent outputTime:outputTime];
    
    [_particleEditView setVideoProgress:percent];
    
    if (self.movieEditorStatus == lsqMovieEditorStatusPreviewing)
    {
        // 更新文字贴纸编辑界面时间条位置
        _stickerTextEditor.bottomThumbnailView.currentTime = CMTimeGetSeconds(outputTime);;
        // 显示对应时间的文字贴纸
        [_stickerTextEditor.editorPanel disPlayTextItemViewAtTime:CMTimeGetSeconds(outputTime)];
        
    }
}

/**
 播放进度改变事件
 
 @param editor MovieEditor
 @param status 当前播放状态
 
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor playerStatusChanged:(lsqMovieEditorStatus)status;
{
    [super mediaMovieEditor:editor playerStatusChanged:status];
    
    self.playBtn.hidden = (status == lsqMovieEditorStatusPreviewing);
    _stickerTextEditor.isVideoPlay = (status == lsqMovieEditorStatusPreviewing);
    _particleEditView.playBtn.hidden = (status == lsqMovieEditorStatusPreviewing);
    
    switch (status)
    {
            // 暂停预览
        case lsqMovieEditorStatusPreviewingPause:
        case lsqMovieEditorStatusPreviewingCompleted:
        {
            // 视频暂停后更改粒子视图状态
            [_particleEditView makeFinish];
            [self.movieEditor unApplyMediaEffect:_editingParticleEffect];
            _editingParticleEffect = nil;
            
            break;
        }
        default:
            break;
            
    }
}
#pragma mark - TuSDKMovieEditorSaveDelegate 视频保存时间委托

/**
 保存状态改变事件
 
 @param editor MovieEditor
 @param status 当前保存状态
 
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *)editor saveStatusChanged:(lsqMovieEditorStatus)status;
{
    [super mediaMovieEditor:editor saveStatusChanged:status];
    
    switch (status)
    {
            // 取消录制
        case lsqMovieEditorStatusRecordingCancelled:
        {
            [_particleEditView setVideoProgress:0];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - TuSDKMediaEffectsManagerDelegate

/**
 特效被移除通知
 
 @param editor TuSDKMovieEditor
 @param mediaEffects 被移除的特效列表
 @since      v2.2.0
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor didRemoveMediaEffects:(NSArray<TuSDKMediaEffectData *> *)mediaEffects;
{
    [super onMovieEditor:editor didRemoveMediaEffects:mediaEffects];
    
    // 当特效数据被移除时触发该回调，以下情况将会触发：
    
    // 1. 当特效不支持添加多个时 SDK 内部会自动移除不可叠加的特效
    // 2. 当开发者调用 removeMediaEffect / removeMediaEffectsWithType: / removeAllMediaEffects 移除指定特效时
    
    [mediaEffects enumerateObjectsUsingBlock:^(TuSDKMediaEffectData * _Nonnull mediaEffect, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (mediaEffect.effectType) {
            case TuSDKMediaEffectDataTypeParticle:
                if ([editor mediaEffectsWithType:TuSDKMediaEffectDataTypeParticle].count == 0)
                    [_particleEditView.displayView removeAllSegment];
                
                break;
            case TuSDKMediaEffectDataTypeScene:
                if ([editor mediaEffectsWithType:TuSDKMediaEffectDataTypeScene].count == 0)
                    [self.bottomBar.effectsView.displayView removeAllSegment];
                break;
            default:
                break;
        }
    }];
    
}

@end
