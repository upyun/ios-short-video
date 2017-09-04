//
//  MovieEditorFullScreenController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/15.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditorFullScreenController.h"

@implementation MovieEditorFullScreenController


- (void)lsqInitView
{
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    CGRect rect = [[UIScreen mainScreen] applicationFrame];

    // 滤镜列表    
    self.videoFilters =  @[@"SkinPink016",@"SkinJelly016",@"Pink016",@"Fair016",@"Forest017",@"Paul016",@"MintGreen016", @"TinyTimes016", @"Year1950016"];
    
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
    self.topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, 44)];
    [self.topBar setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    self.topBar.topBarDelegate = self;
    [self.topBar addTopBarInfoWithTitle:NSLocalizedString(@"lsq_movieEditor", @"视频编辑")
                     leftButtonInfo:@[[NSString stringWithFormat:@"video_style_default_btn_back.png+%@",NSLocalizedString(@"lsq_go_back", @"返回")]]
                    rightButtonInfo:@[NSLocalizedString(@"lsq_save_video", @"保存")]];
    self.topBar.centerTitleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.topBar];
    
    // 底部栏控件
    self.bottomBar = [[MovieEditerBottomBar alloc]initWithFrame:CGRectMake(0, rect.size.width + 44, rect.size.width , rect.size.height - rect.size.width - 44)];
    self.bottomBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.bottomBar.bottomBarDelegate = self;
    self.bottomBar.videoFilters = self.videoFilters;
    self.bottomBar.filterView.currentFilterTag = 200;
    self.bottomBar.contentBackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
//    self.bottomBar.mvView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.bottomBar.videoDuration = self.endTime - self.startTime;
    [self.view addSubview:self.bottomBar];
    
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
    
    /*设置贴纸出现的默认时间范围 （开始时间~结束时间，注：基于裁剪范围，如原视频8秒，裁剪2~7秒的内容，此时贴纸时间范围为1~2，即原视频的3~4秒）
     * 注： 应与顶部的缩略图滑动栏的默认范围一致
     */
    // self.movieEditor.mvItemTimeRange = [[TuSDKMVEffectData alloc]initEffectInfoWithStart:_mvStartTime end:_mvEndTime type:lsqMVEffectDataTypeStickerAudio];
    // 保存到系统相册 默认为YES
    self.movieEditor.saveToAlbum = YES;
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    self.movieEditor.fileType = lsqFileTypeMPEG4;
//    // 设置水印，默认为空
//    self.movieEditor.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
//    // 设置水印图片的位置
//    self.movieEditor.waterMarkPosition = lsqWaterMarkTopLeft;
    // 视频播放音量设置，0 ~ 1.0 仅在 enableVideoSound 为 YES 时有效
    self.movieEditor.videoSoundVolume = 0.5;
    // 设置默认镜
    [self.movieEditor switchFilterWithCode:self.videoFilters[0]];
    // 加载视频，显示第一帧
    [self.movieEditor loadVideo];
    
}

@end
