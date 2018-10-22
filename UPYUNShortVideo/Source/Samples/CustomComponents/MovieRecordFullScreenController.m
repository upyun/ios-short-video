//
//  MovieRecordFullScreenController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieRecordFullScreenController.h"
#import "SpeedSegmentView.h"

/**
 *  视频全屏录制相机示例  完整代码可参考父类
 */
@interface MovieRecordFullScreenController()<SpeedSegmentViewDelegate>{
    // 速率选择控件对象
    SpeedSegmentView *_speedSegment;
    
    // 屏幕比例数组
    NSArray<NSNumber *> *_cameraRatioArr;
    NSInteger _currentRatioIndex;
}

@end


@implementation MovieRecordFullScreenController

#pragma mark - 视图布局方法

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSpeedSegmentView];
}

- (void)initRecorderView;
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    CGFloat buttonWidth = 40;
    CGFloat buttonHeight = 40;
    CGFloat labelHeight = 26;
    
    // 默认相机顶部控制栏
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    self.topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, topY + 4, self.view.lsqGetSizeWidth, 44)];
    [self.topBar addTopBarInfoWithTitle:nil
                     leftButtonInfo:@[@"style_default_2.0_back_default.png"]
                    rightButtonInfo:@[@"style_default_2.0_lens_overturn.png",@"style_default_2.0_flash_closed.png",@"nav_ic_scale9-16_w.png"]];
    self.topBar.topBarDelegate = self;
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    
    // 默认相机底部控制栏
    topY = rect.size.width + 74;
    CGFloat height = rect.size.height - rect.size.width - 74;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY += 44;
        height -= 34;
    }
    
    self.bottomBackView = [[UIView alloc]initWithFrame:CGRectMake(0, topY, rect.size.width , height)];
    self.bottomBackView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bottomBackView];
    self.bottomBar = [[RecordVideoBottomBar alloc]initWithFrame:self.bottomBackView.bounds];
    // 该录制模式需和 self.camera 中的一致, bottomBar的UI逻辑中，默认为正常模式
    self.bottomBar.recordMode = self.inputRecordMode;
    self.bottomBar.bottomBarDelegate = self;
    [self.bottomBar setBackgroundColor:[UIColor clearColor]];
    [self.bottomBackView addSubview:self.bottomBar];
    self.bottomBar.albumButton.hidden = YES;
    self.bottomBar.albumLabel.hidden = YES;
    
    [self.bottomBar.recordButton setCenter:CGPointMake(self.bottomBar.frame.size.width/2, self.bottomBar.frame.size.height*0.7)];
    [self.bottomBar.touchView setCenter:CGPointMake(self.bottomBar.frame.size.width/2, self.bottomBar.frame.size.height*0.7)];
    [self.bottomBar.recordButton setImage:[UIImage imageNamed:@"style_default_btn_record_b_1.11.png"] forState:UIControlStateSelected];
    [self.bottomBar.recordButton setImage:[UIImage imageNamed:@"style_default_btn_record_s_1.11.png"] forState:UIControlStateNormal];
    
    [self.bottomBar.stickerButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [self.bottomBar.stickerButton setImage:[UIImage imageNamed:@"style_default_btn_sticker_w_1.11"] forState:UIControlStateNormal];
    [self.bottomBar.stickerButton setCenter:CGPointMake(self.bottomBar.frame.size.width*0.12, self.bottomBar.frame.size.height*0.7)];
    
    [self.bottomBar.filterButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [self.bottomBar.filterButton setCenter:CGPointMake(self.bottomBar.frame.size.width*0.28, self.bottomBar.frame.size.height*0.7)];
    [self.bottomBar.filterButton setImage:[UIImage imageNamed:@"style_default_1.7.1_btn_filter_w_1.11"] forState:UIControlStateNormal];
    
    [self.bottomBar.cancelButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [self.bottomBar.cancelButton setCenter:CGPointMake(self.bottomBar.frame.size.width*0.72, self.bottomBar.frame.size.height*0.7)];
    [self.bottomBar.cancelButton setImage:[UIImage imageNamed:@"style_default_btn_back_w_1.11"] forState:UIControlStateNormal];
    
    [self.bottomBar.completeButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [self.bottomBar.completeButton setCenter:CGPointMake(self.bottomBar.frame.size.width*0.88, self.bottomBar.frame.size.height*0.7)];
    [self.bottomBar.completeButton setImage:[UIImage imageNamed:@"style_default_btn_finish_w_1.11"] forState:UIControlStateNormal];
    
    [self.bottomBar.stickerLabel setCenter:CGPointMake(self.bottomBar.stickerButton.center.x, self.bottomBar.stickerButton.center.y + buttonHeight/2 + labelHeight/2)];
    self.bottomBar.stickerLabel.hidden = YES;
//    text = @"贴纸";
//    self.bottomBar.stickerLabel.textColor = [UIColor whiteColor];
    
    [self.bottomBar.filterLabel setCenter:CGPointMake(self.bottomBar.filterButton.center.x, self.bottomBar.stickerButton.center.y + buttonHeight/2 + labelHeight/2)];
    self.bottomBar.filterLabel.hidden = YES;
//    text = @"滤镜";
//    self.bottomBar.filterLabel.textColor = [UIColor whiteColor];
    
    [self.bottomBar.cancelLabel setCenter:CGPointMake(self.bottomBar.cancelButton.center.x, self.bottomBar.stickerButton.center.y + buttonHeight/2 + labelHeight/2)];
    self.bottomBar.cancelLabel.hidden = YES;
//    text = @"回删";
//    self.bottomBar.cancelLabel.textColor = [UIColor whiteColor];
    
    [self.bottomBar.completeLabel setCenter:CGPointMake(self.bottomBar.completeButton.center.x, self.bottomBar.stickerButton.center.y + buttonHeight/2 + labelHeight/2)];
    self.bottomBar.completeLabel.hidden = YES;
//    text = @"完成";
//    self.bottomBar.completeLabel.textColor = [UIColor whiteColor];
    
}

- (void)initSpeedSegmentView;
{
    _speedSegment = [[SpeedSegmentView alloc]initWithFrame:CGRectMake(28, self.view.lsqGetSizeHeight - 168, self.view.lsqGetSizeWidth - 56, 32)];
    _speedSegment.titleArr = @[@"极慢", @"慢", @"标准", @"快", @"极快"];
    _speedSegment.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    _speedSegment.eventDelegate = self;
    [self.view addSubview:_speedSegment];
}

- (void)initProgressView;
{
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    
    if (!self.camera) return;
    
    // 添加时间进度条
    self.underView = [[UIView alloc]initWithFrame:CGRectMake(0, topY, self.view.lsqGetSizeWidth, 4)];
    [self.underView setBackgroundColor:[UIColor colorWithRed:0.87 green:0.82 blue:0.76 alpha:0.2]];
    [self.view addSubview:self.underView];
    
    // 显示view的进度
    self.aboveView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.underView.lsqGetSizeHeight)];
    self.aboveView.backgroundColor = lsqRGB(244, 161, 24);
    [self.underView addSubview:self.aboveView];
    
    // 显示最小时间位置view
    self.minSecondView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, self.underView.lsqGetSizeHeight)];
    self.minSecondView.center = CGPointMake(self.underView.lsqGetSizeWidth*(self.camera.minRecordingTime*1.0/self.camera.maxRecordingTime), self.underView.lsqGetSizeHeight/2);
    self.minSecondView.backgroundColor = [UIColor clearColor];
    [self.underView addSubview:self.minSecondView];
}

- (void)resetFlashBtnStatusWithBtnEnabled:(BOOL)enabled
{
    NSString *imageName = @"";
    
    if(self.flashModeIndex == 1){
        imageName = @"style_default_2.0_flash_open.png";
    }else{
        imageName = @"style_default_2.0_flash_closed.png";
    }
    UIImage *image = [UIImage imageNamed:imageName];
    [self.topBar changeBtnStateWithIndex:1 isLeftbtn:NO withImage:image withEnabled:enabled];
}


#pragma mark - TuSDK Camera

// 初始化camera
- (void)startCamera
{
    _cameraRatioArr = @[@(lsqRatioOrgin), @(lsqRatio_1_1), @(lsqRatio_3_4)];
    
    if (!self.cameraView) {
        self.cameraView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeHeight)];
        [self.view insertSubview:self.cameraView atIndex:0];

        // 使用tapView 做中间的手势响应范围，为了防止和录制按钮的手势时间冲突(偶发)
        self.tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 74, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
        self.tapView.hidden = YES;
        [self.view addSubview:self.tapView];
        // 添加手势方法
        // self.tapView 显示会影响手动聚焦手势的响应，开启贴纸和滤镜栏时该 view 显示，关闭贴纸滤镜栏时隐藏，避免影响手动聚焦功能的使用。
        UITapGestureRecognizer *cameraTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cameraTapEvent)];
        [self.tapView addGestureRecognizer:cameraTap];
    }

    // 启动摄像头
    if (self.camera) return;
    self.camera = [TuSDKRecordVideoCamera initWithSessionPreset:AVCaptureSessionPresetHigh
                                             cameraPosition:[AVCaptureDevice lsqFirstFrontCameraPosition]
                                                 cameraView:self.cameraView];

    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    self.camera.fileType = lsqFileTypeMPEG4;
    // 设置委托
    self.camera.videoDelegate = self;
    // 配置相机参数
    // 相机预览画面区域显示算法
    CGFloat offset = 74/self.view.lsqGetSizeHeight;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        offset = 118/self.view.lsqGetSizeHeight;
    }
    self.camera.regionHandler.offsetPercentTop = offset;
    // 输出 全屏画幅视频
    self.camera.cameraViewRatio = 0;
    // 指定比例后，如不指定尺寸，SDK 会根据设备情况自动输出适应比例的尺寸
    // self.camera.outputSize = CGSizeMake(640, 640);

    // 输出视频的画质，主要包含码率、分辨率等参数 (默认为空，采用系统设置)
    self.camera.videoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Medium1];
    // 禁止触摸聚焦功能 (默认: NO)
    self.camera.disableTapFocus = NO;
    // 是否禁用持续自动对焦
    self.camera.disableContinueFoucs = NO;
    // 视频覆盖区域颜色 (默认：[UIColor blackColor])
    self.camera.regionViewColor = [UIColor clearColor];
    // 禁用前置摄像头自动水平镜像 (默认: NO，前置摄像头拍摄结果自动进行水平镜像)
    self.camera.disableMirrorFrontFacing = NO;
    // 默认闪光灯模式
    [self.camera flashWithMode:AVCaptureFlashModeOff];
    // 相机采集帧率，默认30帧
    self.camera.frameRate = 30;
    // 不保存到相册，可在代理方法中获取 result.videoPath（默认：YES，录制完成自动保存到相册）
    self.camera.saveToAlbum = NO;
    // 启用智能贴纸
    self.camera.enableLiveSticker = YES;
    // 设置水印，默认为空
    self.camera.waterMarkImage = [UIImage imageNamed:@"sample_watermark.png"];
    // 设置水印图片的位置
    self.camera.waterMarkPosition = lsqWaterMarkBottomRight;
    // 最大录制时长 8s
    self.camera.maxRecordingTime = 15;
    // 最小录制时长 2s
    self.camera.minRecordingTime = 1;
    // 正常模式/续拍模式  - 注：该录制模式需和 self.bottomBar 中的一致, 若不使用这套UI逻辑，可进行自定义交互操作
    self.camera.recordMode = self.inputRecordMode;
    // 设置使用录制相机最小空间限制,开发者可根据需要自行设置（单位：字节 默认：50M）
    self.camera.minAvailableSpaceBytes  = 1024.f*1024.f*50.f;
    // 设置视频速率 默认：标准  包含：标准、慢速、极慢、快速、极快
    self.camera.speedMode = lsqSpeedMode_Normal;
    /** 设置检测框最小倍数 [取值范围: 0.1 < x < 0.5, 默认: 0.2] 值越大性能越高距离越近 */
    [self.camera setDetectScale:0.2f];
    // 启动相机
    [self.camera tryStartCameraCapture];

    // 默认为前置摄像头 此时应关闭闪光灯
    self.flashModeIndex = 0;
    [self resetFlashBtnStatusWithBtnEnabled:NO];
}

#pragma mark - 事件处理

- (void)onBottomBtnClicked:(UIButton*)btn;
{
    if (btn == self.bottomBar.stickerButton || btn == self.bottomBar.filterButton)
    {
        _speedSegment.hidden = YES;
    }
    
    [super onBottomBtnClicked:btn];
}

- (void)cameraTapEvent;
{
    _speedSegment.hidden = NO;
    [super cameraTapEvent];
}

// 点击相机比例按钮
- (void)clickChangeRatioBtn;
{
    _currentRatioIndex = _currentRatioIndex+1 >= _cameraRatioArr.count ? 0 : _currentRatioIndex + 1;
    lsqRatioType ratioType = (lsqRatioType)_cameraRatioArr[_currentRatioIndex].integerValue;
    
    [self updateCameraRatioStateWithType:ratioType];

    // 修改选区的顶部偏移
    if (ratioType == lsqRatio_1_1) {
        self.camera.regionHandler.offsetPercentTop = 0.1;
    }else {
        self.camera.regionHandler.offsetPercentTop = 0;
    }

    [self.camera changeCameraViewRatio:[TuSDKRatioType ratio:ratioType]];
}

// 更新相机比例按钮状态
- (void)updateCameraRatioStateWithType:(lsqRatioType)ratioType;
{
    NSString *imageName;
    switch (ratioType) {
        case lsqRatio_3_4:
            imageName = @"nav_ic_scale3-4_w";
            break;
        case lsqRatio_1_1:
            imageName = @"nav_ic_scale1-1_w";
            break;
        default:
            imageName = @"nav_ic_scale9-16_w";
            break;
    }
    [self updateButtonImage:imageName];
}

/**
 更新按钮显示
 
 @param type 按钮类型
 @param imageName 新的按钮图片
 @param title 新的按钮title
 */
- (void)updateButtonImage:(NSString *)imageName;
{
    [self.topBar changeBtnStateWithIndex:2 isLeftbtn:NO withImage:[UIImage imageNamed:imageName] withEnabled:YES];
}

/**
 右侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onRightButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
    [super onRightButtonClicked:btn navBar:navBar];
    
    // 开始录制后不可更改比例
    if (!self.camera.canChangeRatio) return;
    
    switch (btn.tag) {
        case lsqRightTopBtnThird:
        {
            [self clickChangeRatioBtn];
        }
            break;
        default:
            break;
    }
}

#pragma mark - SpeedSegmentViewDelegate

/**
 选择某个title的回调
 */
- (void)speedSegmentView:(SpeedSegmentView *)segmentView withIndex:(NSInteger)index;
{
    if (index == 0) {
        self.camera.speedMode = lsqSpeedMode_Slow2;
    }else if (index == 1){
        self.camera.speedMode = lsqSpeedMode_Slow1;
    }else if (index == 2){
        self.camera.speedMode = lsqSpeedMode_Normal;
    }else if (index == 3){
        self.camera.speedMode = lsqSpeedMode_Fast1;
    }else if (index == 4){
        self.camera.speedMode = lsqSpeedMode_Fast2;
    }
}

@end
