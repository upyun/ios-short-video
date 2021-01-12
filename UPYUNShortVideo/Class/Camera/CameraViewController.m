//
//  CameraViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "CameraViewController.h"
#import "MovieCutViewController.h"
#import "TuSDKFramework.h"
// 相机模式
#import "LongPressCaptureMode.h"
#import "TapCaptureMode.h"
#import "PhotoCaptureMode.h"
// 资源配置列表
#import "Constants.h"
#import "CameraFilterPanelView.h"
#import "TuCameraFilterPackage.h"
#import "TuCosmeticConfig.h"

#define kNormalFilterCodes @[@"Normal", kCameraNormalFilterCodes]
#define kComicsFilterCodes @[@"Normal", kCameraComicsFilterCodes]

// 轻易不要动，产品让改才改
// 精准美肤参数
#define kSkinFaceSmothingMaxDefault 1.0
#define kSkinFaceWhiteningMaxDefault 1.0
#define kSkinFaceRuddyMaxDefault 1.0

// 极致美肤参数
#define kSkinMoistFaceSmothingMaxDefault 1.0
#define kSkinMoistFaceWhiteningMaxDefault 1.0
#define kSkinMoistFaceRuddyMaxDefault 1.0

// 新美肤参数
#define kSkinBeautyFaceSmothingMaxDefault 1.0
#define kSkinBeautyFaceWhiteningMaxDefault 1.0
#define kSkinBeautyFaceRuddyMaxDefault 1.0

// 顶部工具栏高度
static const CGFloat kTopBarHeight = 64.0;
// 滤镜参数默认值键
static NSString * const kFilterParameterDefaultKey = @"default";
// 滤镜参数最大值键
static NSString * const kFilterParameterMaxKey = @"max";

@interface CameraViewController (UIDelegate) <
CameraControlMaskViewDelegate,
CameraMoreMenuViewDelegate,
CameraFilterPanelDelegate,
PropsPanelViewDelegate,
UIGestureRecognizerDelegate,
TuSDKCPFocusTouchViewDelegate,
LSQGPUImageVideoCameraDelegate
>
@end
@interface CameraViewController (State) <TuSDKVideoCameraDelegate>
@end
@interface CameraViewController (Record) <TuSDKRecordVideoCameraDelegate>
@end
@interface CameraViewController (Capture) <TuSDKVideoCameraDelegate>
@end
@interface CameraViewController (Effect) <TuSDKVideoCameraEffectDelegate>
@end

@interface CameraViewController ()
{
    UISlider *_exposureSlider;
    UIImageView *_lightImageView;
        
    BOOL _isSetDefaultEffect;
    BOOL _isSetUIAfterCamera;
    
    BOOL _isOpenSetting;
}

/**
 录制相机对象
 */
@property (nonatomic, strong) TuSDKRecordVideoCamera *camera;

/**
 当前获取的滤镜对象索引
 */
@property (nonatomic) NSUInteger currentFilterIndex;

/**
 相机预览
 */
@property (weak, nonatomic) IBOutlet UIView *cameraView;

/**
 滤镜码 filterCode
 */
@property (nonatomic, strong) NSArray *filterCodes;

/**
 默认滤镜码
 */
@property (nonatomic, copy) NSString *defaultFilterCode;

/**
 滤镜参数默认值
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *filterParameterDefaultDic;


/** screenKeyView */
@property (nonatomic, strong) UIView *screenKeyingView;

/** screenLengthSlider */
@property (nonatomic, strong) UISlider *screenLengthSlider;

/** rangeOffsetSlider */
@property (nonatomic, strong) UISlider *rangeOffsetSlider;

/** 打开ScreenKeying特效开关 */
@property (nonatomic, strong) UIButton *openButton;

/** screenKeyingEffect */
@property (nonatomic, strong) TuSDKMediaScreenKeyingEffect *screenKeyingEffect;

@property (nonatomic, assign) double brightness;
/**标题数组*/
@property (nonatomic, strong) NSMutableArray *titleSource;

@end


@implementation CameraViewController

#pragma mark - 界面

+ (instancetype)recordController {
    return [[CameraViewController alloc] initWithNibName:nil bundle:nil];
}

- (void)openScreenKeyingEffect:(UIButton *)open {
    _openButton.selected = !_openButton.selected;
    self.screenKeyingView.hidden = !_openButton.selected;
    if (_openButton.selected) {
        [self.camera addMediaEffect:_screenKeyingEffect];
    } else {
        [self.camera removeMediaEffect:_screenKeyingEffect];
    }
}

- (void)testView {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 30;
    _screenKeyingView = [[UIView alloc] initWithFrame:CGRectMake(15, [UIScreen mainScreen].bounds.size.height - 250, width, 90)];
    _screenKeyingView.backgroundColor = [UIColor clearColor];
    
    UILabel *strength = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    strength.font = [UIFont systemFontOfSize:11];
    strength.textColor = [UIColor whiteColor];
    strength.text = @"strength: ";
    UIView *strengthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 45)];
    [strengthView addSubview:strength];
    _screenLengthSlider = [[UISlider alloc] initWithFrame:CGRectMake(80, 0, width-80, 45)];
    _screenLengthSlider.maximumValue = 1.0;
    _screenLengthSlider.minimumValue = 0.0;
    _screenLengthSlider.value = 0.0;
    [_screenLengthSlider addTarget:self action:@selector(screenKeyingValueChanged:) forControlEvents:UIControlEventValueChanged];
    [strengthView addSubview:_screenLengthSlider];
    
    UILabel *rangeOffset = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    rangeOffset.font = [UIFont systemFontOfSize:11];
    rangeOffset.textColor = [UIColor whiteColor];
    rangeOffset.text = @"rangeOffset: ";
    UIView *rangeView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, width, 45)];
    [rangeView addSubview:rangeOffset];
    
    _rangeOffsetSlider = [[UISlider alloc] initWithFrame:CGRectMake(80, 0, width-80, 45)];
    _rangeOffsetSlider.maximumValue = 1.0;
    _rangeOffsetSlider.minimumValue = 0.0;
    _rangeOffsetSlider.value = 0.0;
    [_rangeOffsetSlider addTarget:self action:@selector(screenKeyingValueChanged:) forControlEvents:UIControlEventValueChanged];
    [rangeView addSubview:_rangeOffsetSlider];
    
    [_screenKeyingView addSubview:strengthView];
    [_screenKeyingView addSubview:rangeView];
    [self.view addSubview:_screenKeyingView];
    _screenKeyingView.hidden = YES;
    
    _openButton = [[UIButton alloc] initWithFrame:CGRectMake(15, [UIScreen mainScreen].bounds.size.height - 150, 50, 50)];
    [_openButton setTitle:@"开关" forState:UIControlStateNormal];
    [_openButton addTarget:self action:@selector(openScreenKeyingEffect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_openButton];
    
    
    _screenKeyingEffect = [[TuSDKMediaScreenKeyingEffect alloc] init];
    _screenKeyingEffect.strength = 0.0;
    _screenKeyingEffect.rangeOffset = 0.0;
}

- (void)screenKeyingValueChanged:(UISlider *)slider {
    if (_screenLengthSlider == slider) {
        _screenKeyingEffect.strength = slider.value;
    } else if (_rangeOffsetSlider == slider) {
        _screenKeyingEffect.rangeOffset = slider.value;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 滤镜列表，获取滤镜前往 TuSDK.bundle/others/lsq_tusdk_configs.json
    // TuSDK 滤镜信息介绍 @see-https://tutucloud.com/docs/ios/self-customize-filter
//    _filterCodes = kNormalFilterCodes;
    _filterParameterDefaultDic = [NSMutableDictionary dictionary];
    
    // 获取相册的权限
    [self requestAlbumPermission];
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 设置UI
    [self setupUI];
    
    // 相机权限
    [self requestCameraPermission];
    
    //目前进入相机会默认将手机亮度调到最大
    self.brightness = [UIScreen mainScreen].brightness;
}

- (void)viewDidLayoutSubviews {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取相机的权限并启动相机
        if(self->_isOpenSetting) [self requestCameraPermission];
        
        [self->_camera updateCameraViewBounds:self->_cameraView.bounds];
        
        self->_exposureSlider.frame = CGRectMake(self.view.bounds.size.width - 45, (self.view.bounds.size.height-220)*0.5, 40, 220);
        self->_lightImageView.frame = CGRectMake(self.view.bounds.size.width - 40, (self.view.bounds.size.height-220)*0.5 - 35, 30, 30);

        // 更新其他 UI
        [self setupUIAfterCameraSetup];
    });
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 当从别的页面返回相机页面时，需要判断相机状态
    // [_camera resumeCameraCapture];
    // 设置屏幕常亮，默认是NO
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [UIScreen mainScreen].brightness = 1.f;
    
    //NSLog(@"屏幕亮度2 === %.f", [UIScreen mainScreen].brightness);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 相机跳转至其他页面，操作后如需返回相机界面，需要暂停相机
    // [_camera pauseCameraCapture];
    // 关闭屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [UIScreen mainScreen].brightness = self.brightness;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ruddy"])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ruddy"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 界面配置
 */
- (void)setupUI {
    [self setNavigationBarHidden:YES animated:NO];
    if (![UIDevice lsqIsDeviceiPhoneX]) {
        [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    [_controlMaskView.speedSegmentButton addTarget:self
                                            action:@selector(speedSegmentValueChangeAction:)
                                  forControlEvents:UIControlEventValueChanged];
    [self configSlider];
    
    // [self testView];
}

/**
 配置相机摄像头和闪光灯信息
 */
- (void)setupUIAfterCameraSetup {
    
    //确保录制相机最小录制时间占位图只会添加一次
    if (_isSetUIAfterCamera) return;
    if (_camera) {
        
        // 同步相机镜头位置
        _controlMaskView.moreMenuView.disableFlashSwitching = _camera.cameraPosition == AVCaptureDevicePositionFront;
        [_controlMaskView.markableProgressView addPlaceholder:_camera.minRecordingTime / _camera.maxRecordingTime markWidth:4];
        _isSetUIAfterCamera = YES;
    }
}


#pragma mark - 曝光控制
// 曝光
- (void)configSlider {
    
    _lightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _lightImageView.image = [UIImage imageNamed:@"ic_light"];
    [self.controlMaskView addSubview:_lightImageView];
    
    _exposureSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [self.controlMaskView addSubview:_exposureSlider];
    _exposureSlider.transform = CGAffineTransformMakeRotation(-M_PI/2);
    _exposureSlider.maximumValue = 1.0;
    _exposureSlider.minimumValue = 0.0;
    _exposureSlider.value = 0.5;
    _exposureSlider.minimumTrackTintColor = [UIColor whiteColor];
    _exposureSlider.maximumTrackTintColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:0.3];
    [_exposureSlider setThumbImage:[UIImage imageNamed:@"slider_thum_icon"] forState:UIControlStateNormal];
    [_exposureSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [_exposureSlider addTarget:self action:@selector(sliderEnd:) forControlEvents:UIControlEventTouchUpInside];
    [_exposureSlider addTarget:self action:@selector(sliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)sliderEnd:(UISlider *)slider {
    // 录制过程中不能自动切换到运行重置曝光模式
    if (self.camera.isRecording) {
        return;
    }
}

- (void)updateValue:(UISlider *)slider {
    float value = slider.value;

    float bias = (value - 0.5) * 8;
    [self.camera exposureWithBias:bias];
}


#pragma mark - TuSDKCPFocusTouchViewDelegate
// 点击聚焦曝光点后的回调 ----- 内部已经添加了聚焦和曝光，这里不需要再设置
- (void)focusTouchView:(id<TuSDKVideoCameraExtendViewInterface>)focusTouchView didTapPoint:(CGPoint)point
{
    _exposureSlider.value = 0.5; // 重置到中间
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 录制过程中不能自动切换到运行重置曝光模式
        if (self.camera.isRecording)
        {
            return;
        }
    });
}


#pragma mark - LSQGPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
}



#pragma mark - 后台前台切换

/**
 进入后台
 */
- (void)enterBackFromFront {
    
    // 进入后台暂停录制，保留之前录制的信息
//    if (_camera) {
//        if (_camera.isRecording) {
//            [_captureMode recordButtonDidTouchDown:_controlMaskView.captureButton];
//        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self->_camera pauseCameraCapture];
//        });
//    }
    
    [UIScreen mainScreen].brightness = self.brightness;
    //NSLog(@"进入后台屏幕亮度 === %.f", [UIScreen mainScreen].brightness);
    
    // 进入后台后取消录制，舍弃之前录制的信息
    if (_camera) {
        // 取消录制
        [self cancelRecording];
        // 暂停捕捉画面
        [_camera stopCameraCapture];
    }
    // 关闭闪光灯
    _controlMaskView.moreMenuView.enableFlash = NO;
    // 同步相机闪光和和摄像头信息
    _controlMaskView.moreMenuView.disableFlashSwitching = _camera.cameraPosition == AVCaptureDevicePositionFront;
}

/**
 恢复前台
 */
- (void)enterFrontFromBack {
    // 为匹配：进入后台暂停录制，保留之前录制的信息   , 回复到前台后回复相机开启
//    [_camera resumeCameraCapture];
    
    // 为匹配：进入后台后取消录制，舍弃之前录制的信息  , 回复到前台后重启相机，回复UI页面
    if (_camera) {
        [_camera startCameraCapture];
    }
    // 恢复UI界面
    [_captureMode resetUI];
    
    [UIScreen mainScreen].brightness = 1.f;
    //NSLog(@"恢复前台屏幕亮度 === %.f", [UIScreen mainScreen].brightness);
}

#pragma mark - 权限请求

/**
 相册权限请求
 */
-(void)requestAlbumPermission {
    // 测试相册访问权限
    [TuSDKTSAssetsManager testLibraryAuthor:^(NSError *error) {
        if (error) {
            [TuSDKTSAssetsManager showAlertWithController:self loadFailure:error];
        }
    }];
}

/**
 获取相机相关权限，并启动相机
 */
-(void)requestCameraPermission {
    // 开启访问相机权限
    // 查看有没有相机访问权限
    [TuSDKTSDeviceSettings checkAllowWithController:self type:lsqDeviceSettingsCamera completed:^(lsqDeviceSettingsType type, BOOL openSetting) {
        self->_isOpenSetting = openSetting;

        if (openSetting) {
            lsqLError(@"Can not open camera");
            return;
        }
        [self setupCamera];
        // 启动相机
        [self.camera tryStartCameraCapture];
    }];
}

/** 注意： 特效必须在相机启动后添加 */
- (void)addDefaultEffect {
    if (_isSetDefaultEffect) {
        return;
    }
    _isSetDefaultEffect = YES;
    /** 初始化滤镜特效 */
//    if (self.defaultFilterCode == nil)
//    {
//        self.defaultFilterCode = @"Portrait_Bright_1";
//    }
//    TuSDKMediaFilterEffect *filterEffect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:self.defaultFilterCode];
//    [self.camera addMediaEffect:filterEffect];
    
    /** 初始化微整形特效 */
    TuSDKMediaPlasticFaceEffect *plasticFaceEffect = [[TuSDKMediaPlasticFaceEffect alloc] init];
    [self.camera addMediaEffect:plasticFaceEffect];
    
    /** 添加默认美颜效果 */
    [self applySkinFaceEffect];
    
    /** 添加默认变脸特效（哈哈镜） */
    // TuSDKMediaMonsterFaceEffect *monsterEfffect = [[TuSDKMediaMonsterFaceEffect alloc]initWithMonsterFaceType:TuSDKMonsterFaceTypePapayaFace];
    // [self.camera addMediaEffect:monsterEfffect];
}

#pragma mark - 启动相机

/**
 初始化相机
 */
- (void)setupCamera {
    // 启动摄像头
    if (_camera) return;
    _camera = [TuSDKRecordVideoCamera initWithSessionPreset:AVCaptureSessionPresetHigh
                                             cameraPosition:[AVCaptureDevice lsqFirstFrontCameraPosition]
                                                 cameraView:_cameraView];
    
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
    _camera.fileType = lsqFileTypeMPEG4;
    // 设置委托
    _camera.videoDelegate = self;
    // 设置特效时间委托
    _camera.effectDelegate = self;
    
    // 设置聚焦点击委托
    _camera.focusTouchDelegate = self;
    
    // 数据委托
    _camera.delegate = self;
    
    // 配置相机参数
    // 相机预览画面区域显示算法
    //CGFloat offset = 64/self.view.lsqGetSizeHeight;
    //if ([UIDevice lsqIsDeviceiPhoneX]) {
    //    offset = 108/self.view.lsqGetSizeHeight;
    //}
    //_camera.regionHandler.offsetPercentTop = offset;
    
    
    // 指定比例后，如不指定尺寸，输出裁剪尺寸
//     _camera.outputSize = CGSizeMake(1080, 1920);
    // 输出全屏视频画面
    // _camera.cameraViewRatio = _camera.outputSize.width/_camera.outputSize.height;
    
    // 输出视频的画质，主要包含码率、分辨率等参数 (默认为空，采用系统设置)
    _camera.videoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Medium2];
    // 禁止触摸聚焦功能（默认: NO）
    _camera.disableTapFocus = NO;
    // 禁止触摸曝光功能（默认: NO）
    _camera.disableTapExposure = NO;
    // 是否禁用持续自动对焦
    _camera.disableContinueFoucs = NO;
    // 是否启用手动变焦功能（默认: NO）
    _camera.enableFocalDistance = YES;
    // 视频覆盖区域颜色 (默认：[UIColor blackColor])
    _camera.regionViewColor = [UIColor clearColor];
    // 禁用前置摄像头自动水平镜像 (默认: NO，前置摄像头拍摄结果自动进行水平镜像)
    _camera.disableMirrorFrontFacing = NO;
    // 默认闪光灯模式
    [_camera flashWithMode:AVCaptureFlashModeOff];
    // 相机采集帧率，默认30帧
    _camera.frameRate = 30;
    // 不保存到相册，可在代理方法中获取 result.videoPath（默认：YES，录制完成自动保存到相册）
    _camera.saveToAlbum = NO;
    // 启用动态贴纸权限
    _camera.enableLiveSticker = YES;
    // 设置是否启用人脸检测。 如果使用人脸贴纸及微整形功能，该项需置为 YES。 （注：须在相机启动之前调用）
    _camera.enableFaceDetection = YES;
    // 设置水印，默认为空
    _camera.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
    // 设置水印图片的位置
    _camera.waterMarkPosition = lsqWaterMarkBottomRight;
    // 最大录制时长 15s
    _camera.maxRecordingTime = 15;
    // 最小录制时长 3s
    _camera.minRecordingTime = 3;
    // 相机录制模式：续拍模式
    _camera.recordMode = lsqRecordModeKeep;
    //  设置使用录制相机最小空间限制，开发者可根据需要自行设置（单位：字节 默认：50M）
    _camera.minAvailableSpaceBytes  = 1024.f*1024.f*50.f;
    // 设置视频速率 默认：标准  包含：标准、慢速、极慢、快速、极快
    _camera.speedMode = lsqSpeedMode_Normal;
    // 设置检测框最小倍数 [取值范围: 0.1 < x < 0.5, 默认: 0.2] 值越大性能越高距离越近
    [_camera setDetectScale:0.2f];
}

#pragma mark - 界面按钮事件

/**
 返回按钮事件
 
 @param sender 返回按钮事件
 */
- (IBAction)backButtonAction:(id)sender {
    // 取消录制状态
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 相机模式切换控件事件
 
 @param sender 相机模式切换按钮
 */
- (IBAction)captureModeChangeAction:(TextPageControl *)sender {
    switch (sender.selectedIndex) {
        case 0:{
            // 拍照模式
            self.captureMode = [[PhotoCaptureMode alloc] initWithCameraController:self];
        } break;
        case 1:{
            // 长按录制模式
            self.captureMode = [[LongPressCaptureMode alloc] initWithCameraController:self];
        } break;
        case 2:{
            // 点按录制模式
            self.captureMode = [[TapCaptureMode alloc] initWithCameraController:self];
        } break;
    }
    // 相机模式状态更新
    [_captureMode updateModeUI];
}

/**
 速率分段按钮值变更事件
 
 @param sender 录制速率改变按钮
 */
- (void)speedSegmentValueChangeAction:(CameraSpeedSegmentButton *)sender {
    lsqSpeedMode speedMode = _camera.speedMode;
    switch (sender.selectedIndex) {
        case 0:{
            // 极慢模式  原始速度 0.5 倍率
            speedMode = lsqSpeedMode_Slow2;
        } break;
        case 1:{
            // 慢速模式 原始速度 0.7 倍率
            speedMode = lsqSpeedMode_Slow1;
        } break;
        case 2:{
            // 标准模式 原始速度
            speedMode = lsqSpeedMode_Normal;
        } break;
        case 3:{
            // 快速模式 原始速度 1.5 倍率
            speedMode = lsqSpeedMode_Fast1;
        } break;
        case 4:{
            // 极快模式 原始速度 2.0 倍率
            speedMode = lsqSpeedMode_Fast2;
        } break;
    }
    _camera.speedMode = speedMode;
}

/**
 切换摄像头按钮事件
 
 @param sender 切换摄像头位置按钮
 */
- (IBAction)switchCameraButtonAction:(UIButton *)sender {
    [_camera rotateCamera];
    _controlMaskView.moreMenuView.enableFlash = NO;
    _controlMaskView.moreMenuView.disableFlashSwitching = _camera.cameraPosition == AVCaptureDevicePositionFront;
}

/**
 左滑手势响应事件z
 
 @param sender 左滑手势
 */
- (IBAction)leftSwipeAction:(UISwipeGestureRecognizer *)sender {
    [self switchToNextFilter];
}

/**
 右滑手势响应事件
 
 @param sender 右滑手势
 */
- (IBAction)rightSwipeAction:(UISwipeGestureRecognizer *)sender {
    [self switchToPreviousFilter];
}



/**
 切换前一个滤镜
 */
- (void)switchToPreviousFilter {
    
    if (_filterCodes.count == 0) {
        _filterCodes = _controlMaskView.filterPanelView.filtersGroups[0];
    }
    if (self.currentFilterIndex == 0)
    {
        //处于第一位的时候不处理
        if (_controlMaskView.filterPanelView.selectedTabIndex == 0) {
            
            _controlMaskView.filterPanelView.selectedIndex = self.titleSource.count - 1;
            _filterCodes = @[kCameraComicsFilterCodes];
            self.currentFilterIndex = _filterCodes.count - 1;
            
        } else {
            _controlMaskView.filterPanelView.selectedIndex = _controlMaskView.filterPanelView.selectedTabIndex - 1;
            _filterCodes = self.controlMaskView.filterPanelView.filtersGroups[self.controlMaskView.filterPanelView.selectedTabIndex];
            self.currentFilterIndex = _filterCodes.count - 1;
        }
    }
    else
    {
        self.currentFilterIndex = self.currentFilterIndex - 1;
    }
        
    
    if (self.currentFilterIndex >= self.filterCodes.count) {
        return;
    }
    
    // 漫画
    if (_controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 1)
    {
        
        TuSDKMediaComicEffect *comicEffect = [[TuSDKMediaComicEffect alloc] initWithEffectCode:_filterCodes[self.currentFilterIndex]];
        [_camera addMediaEffect:comicEffect];
        
    }
    else
    {
        
        // 滤镜
        NSLog(@"当前滤镜代码 == %@", _filterCodes[self.currentFilterIndex]);
        TuSDKMediaFilterEffect *comicEffect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:_filterCodes[self.currentFilterIndex]];
        [_camera addMediaEffect:comicEffect];
        
    }
    _controlMaskView.filterPanelView.selectedFilterCode = _filterCodes[self.currentFilterIndex];
    
}

/**
 切换至后一个滤镜
 */
- (void)switchToNextFilter {
    
    if (_filterCodes.count == 0) {
        _filterCodes = self.controlMaskView.filterPanelView.filtersGroups[self.controlMaskView.filterPanelView.selectedTabIndex];
    }
    
//    self.currentFilterIndex = (self.currentFilterIndex + 1) % _filterCodes.count;
    self.currentFilterIndex++;
    
    if (self.currentFilterIndex >= _filterCodes.count) {
        
        //漫画滤镜时暂时不处理
        if (_controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 1)
        {
            _controlMaskView.filterPanelView.selectedIndex = 0;
            _filterCodes = self.controlMaskView.filterPanelView.filtersGroups[self.controlMaskView.filterPanelView.selectedTabIndex];
            self.currentFilterIndex = 0;
        }
        //准备切换到漫画滤镜时
        else if (_controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 2)
        {
            _controlMaskView.filterPanelView.selectedIndex = _controlMaskView.filterPanelView.selectedTabIndex + 1;
            _filterCodes = @[kCameraComicsFilterCodes];
            self.currentFilterIndex = 0;
        }
        else
        {
            _controlMaskView.filterPanelView.selectedIndex = _controlMaskView.filterPanelView.selectedTabIndex + 1;
            _filterCodes = self.controlMaskView.filterPanelView.filtersGroups[self.controlMaskView.filterPanelView.selectedTabIndex];
            self.currentFilterIndex = 0;
        }

    }
    // 漫画
    if (_controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 1) {
        
        TuSDKMediaComicEffect *comicEffect = [[TuSDKMediaComicEffect alloc] initWithEffectCode:_filterCodes[self.currentFilterIndex]];
        [_camera addMediaEffect:comicEffect];
        
    }else
    {
        // 滤镜
        TuSDKMediaFilterEffect *comicEffect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:_filterCodes[self.currentFilterIndex]];
        [_camera addMediaEffect:comicEffect];
    }
    
    _controlMaskView.filterPanelView.selectedFilterCode = _filterCodes[self.currentFilterIndex];
    
}

/**
 获取图片
  */
- (void)capturePhotoAsImageCompletionHandler:(void (^)(UIImage * _Nullable, NSError * _Nullable))block;{
    [_camera capturePhotoAsImageCompletionHandler:block];
}

/**
 获取相机预览比例
 
 @return 预览界面比例
 */
- (CGFloat)ratio {
    return _camera.cameraViewRatio;
}

#pragma mark - 相机操作

/**
 开始录制
 */
- (void)startRecording {
    [_camera startRecording];
}

/**
 暂停录制
 */
- (void)pauseRecording {
    [_camera pauseRecording];
}

/**
 结束录制
 */
- (void)finishRecording {
    [_camera finishRecording];
}

/**
 取消录制
 */
- (void)cancelRecording {
    [_camera cancelRecording];
}

/**
 撤销上一段
 */
- (void)undoLastRecordedFragment {
    // 删除最后一段录制的视频片段
    [_camera popMovieFragment];
}

#pragma mark - 销毁操作

/**
 销毁相机对象
 */
- (void)destroyCamera {
    if (_camera) {
        // 取消录制状态
        [_camera cancelRecording];
        // 销毁并置空相机
        [_camera destory];
        _camera = nil;
    }
}

- (void)dealloc {
    [self destroyCamera];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


#pragma mark - 界面事件回调

@implementation CameraViewController (UIDelegate)

#pragma mark - CameraControlMaskViewDelegate

/**
 滤镜，美颜栏点击回调
 
 @param controlMask 相机界面遮罩视图
 @param filterPanel 滤镜回调事件
 */
- (void)controlMask:(CameraControlMaskView *)controlMask didShowFilterPanel:(id<CameraFilterPanelProtocol>)filterPanel {

}

/**
 变焦操作回调，在该方法中实现对相机的变焦
 
 @param controlMask 相机遮罩视图
 @param zoomDelta 变焦倍数增量
 */
- (void)controlMask:(CameraControlMaskView *)controlMask didChangeZoomDelta:(CGFloat)zoomDelta {
    //NSLog(@"zoom delta: %f", zoomDelta);
    CGFloat scale = _camera.focalDistanceScale;
    scale += zoomDelta;
    scale = MIN(10, scale);
    _camera.focalDistanceScale = scale;
}

#pragma mark - RecordMoreMenuViewDelegate

/**
 更多菜单切换预览画面比率回调
 
 @param moreMenu 更多菜单视图
 @param ratio 相机视图比例
 */
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSelectedRatio:(CGFloat)ratio {
    // 相机预览画面区域显示算法
    NSLog(@"-------%f",ratio);
    CGFloat percentOffset = 0;
    if (ratio == 1.0 || ratio == 3.0/4) {
        if (ratio == 1.0) percentOffset = kTopBarHeight / self.view.lsqGetSizeHeight;
        if (@available(iOS 11.0, *)) {
            CGFloat topOffset = self.view.safeAreaInsets.top;
            if (topOffset > 0) percentOffset = (kTopBarHeight + topOffset) / self.view.lsqGetSizeHeight;
        }
    }
    _camera.regionHandler.offsetPercentTop = percentOffset;
    // 更新画面比率
    [_camera changeCameraViewRatio:ratio];
}

/**
 更多菜单切换自动聚焦回调
 
 @param moreMenu 更多菜单视图
 @param autoFocus 自动聚焦
 */
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchAutoFocus:(BOOL)autoFocus {
    _camera.disableContinueFoucs = !autoFocus;
}

/**
 更多菜单切换闪光灯回调
 
 @param moreMenu 更多菜单视图
 @param enableFlash 闪光灯开启状态
 */
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchFlashMode:(BOOL)enableFlash {
    [_camera flashWithMode:enableFlash ? AVCaptureFlashModeOn : AVCaptureFlashModeOff];
}

/**
 更多菜单切换变声回调
 
 @param moreMenu 更多菜单视图
 @param pitchType 变声类型
 */
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchPitchType:(lsqSoundPitch)pitchType {
    _camera.soundPitch = pitchType;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (_screenKeyingView != nil && [_screenKeyingView.layer containsPoint:[touch locationInView:_screenKeyingView]])
    {
        return NO;
    }
    
    // 当美颜面板出现时则禁用左滑、右滑手势
    if (_controlMaskView.beautyPanelView.display)
    {
        return NO;
    }
    
    // 在滤镜面板上禁止滑动
    if ([_controlMaskView.filterPanelView.layer containsPoint:[touch locationInView:_controlMaskView.filterPanelView]])
    {
        return NO;
    }
    
    return YES;
}

@end


#pragma mark - TuSDKVideoCameraDelegate

@implementation CameraViewController (State)

/**
 相机状态 (如需操作UI线程， 请检查当前线程是否为主线程)
 
 @param camera 录制相机
 @param state 相机运行状态
 */
- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera stateChanged:(lsqCameraState)state
{
    switch (state)
    {
        case lsqCameraStateStarting:
            // 相机正在启动
            NSLog(@"TuSDKRecordVideoCamera state: 相机正在启动");
            break;
        case lsqCameraStatePaused:
            // 相机录制暂停
            NSLog(@"TuSDKRecordVideoCamera state: 相机录制暂停");
            break;
        case lsqCameraStateStarted:
            // 相机启动完成
            NSLog(@"TuSDKRecordVideoCamera state: 相机启动完成");
            _exposureSlider.value = 0.5;
            [self addDefaultEffect];
            break;
        case lsqCameraStateCapturing:
            // 相机正在拍摄
            NSLog(@"TuSDKRecordVideoCamera state: 相机正在拍摄");
            break;
        case lsqCameraStateUnknow:
            // 相机状态未知
            NSLog(@"TuSDKRecordVideoCamera state: 相机状态未知");
            break;
        case lsqCameraStateCaptured:
            // 相机拍摄完成
            NSLog(@"TuSDKRecordVideoCamera state: 相机拍摄完成");
            break;
        default:
            break;
    }
}

/**
 相机滤镜改变 (如需操作UI线程， 请检查当前线程是否为主线程)
 
 @param camera 录制相机
 @param newFilter 新的滤镜对象
 */
- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera filterChanged:(TuSDKFilterWrap *)newFilter {
    // 在该滤镜变更回调中，更像滤镜属性，以方便在参数面板中配置参数
    
    /** 该方法已废弃 请使用 ：
     - (void)onVideoCamera:(TuSDKVideoCameraBase *_Nonnull)videoCamera didApplyingMediaEffect:(id<TuSDKMediaEffect>_Nonnull)mediaEffectData;
     */
    
}

@end


#pragma mark - TuSDKRecordVideoCameraDelegate

@implementation CameraViewController (Record)

/**
 录制结果回调
 
 @param camerea 录制相机
 @param result 录制结果
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea result:(TuSDKVideoResult *)result;{
    // 通过相机初始化设置  _camera.saveToAlbum = NO;   result.videoPath 拿到视频的临时文件路径
    // 通过相机初始化设置  _camera.saveToAlbum = YES;  result.videoAsset.asset （PHAsset）拿到视频在相册中的文件路径
    if (result.videoPath) {
        // 进行自定义操作，例如保存到相册（系统方法）
        UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_保存成功", @"VideoDemo", @"保存成功")];

        //UPYUN短视频 上传到云存储
        NSString *saveKey = [NSString stringWithFormat:@"short_video_record_test_%d.mp4", arc4random() % 10];

        NSString *imgSaveKey = [NSString stringWithFormat:@"short_video_record_jietu_%d.jpg", arc4random() % 10];
        [[UPYUNConfig sharedInstance] uploadFilePath:result.videoPath saveKey:saveKey success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
            [[TuSDK shared].messageHub showSuccess:@"上传成功"];

            NSLog(@"file url：http://%@.test.upcdn.net/%@",[UPYUNConfig sharedInstance].DEFAULT_BUCKET, saveKey);
            //            视频同步截图方法
            //            /// source   需截图的视频相对地址,   save_as 保存截图的相对地址, point 截图时间点 hh:mm:ss 格式
            NSDictionary *task = @{@"source": [NSString stringWithFormat:@"/%@", saveKey], @"save_as": [NSString stringWithFormat:@"/%@", imgSaveKey], @"point": @"00:00:00"};

            [[UPYUNConfig sharedInstance] fileTask:task success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
                NSLog(@"截图成功--%@", responseBody);

                NSLog(@"截图 图片 url：http://%@.test.upcdn.net/%@",[UPYUNConfig sharedInstance].DEFAULT_BUCKET, imgSaveKey);
            } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
                NSLog(@"截图失败-error==%@--response==%@, responseBody==%@", error,  response, responseBody);
            }];


        } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
            [[TuSDK shared].messageHub showSuccess:@"上传失败"];
            NSLog(@"上传失败 error：%@", error);
            NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
            NSLog(@"上传失败 message：%@", responseBody);
        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
        }];





        /**
        // 如需相机跳转时间裁剪进入编辑需要进行 input 赋值
        // MovieCutViewController.inputAssets，NSArray<AVAsset *> *inputAssets;为不可变数组类型
        // 需要将文件处理后的 videoAsset 对象加入到数组中
         
         NSURL *videoPathURL = [NSURL fileURLWithPath:result.videoPath];
         AVAsset *videoAsset = [AVAsset assetWithURL:videoPathURL];
         NSArray *assets = [NSArray arrayWithObjects:videoAsset, nil];
         // array add object
         // 跳转代码
         MovieCutViewController *cutter = [[MovieCutViewController alloc] initWithNibName:nil bundle:nil];
        // input 赋值
         cutter.inputAssets = assets;
        
        [self.navigationController pushViewController:cutter animated:YES];
        **/        
        
    } else {
        [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_保存成功", @"VideoDemo", @"保存成功")];
    }
    NSLog(@"保存完成，result: %@", result);
    
    // 自动保存后设置为 恢复进度条状态
    [_captureMode resetUI];
}

/**
 进度条改变
 
 @param camerea 录制相机
 @param progress 进度条百分比
 @param durationTime 录制时长
 */
-(void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea recordProgressChanged:(CGFloat)progress durationTime:(CGFloat)durationTime {
    // 更新进度条 UI 信息
    if ([self.captureMode respondsToSelector:@selector(recordProgressDidChange:)]) {
        [self.captureMode recordProgressDidChange:progress];
    }
}

/**
 录制状态
 
 @param camerea 录制相机
 @param state 相机录制操作状态
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea recordStateChanged:(lsqRecordState)state {
    if ([_captureMode respondsToSelector:@selector(recordStateDidChange:)]) {
        [_captureMode recordStateDidChange:state];
    }
    switch (state) {
        case lsqRecordStateRecordingCompleted:
            // 录制完成
            NSLog(@"TuSDKRecordVideoCamera record state: 录制完成");
            [[TuSDK shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_完成录制", @"VideoDemo", @"完成录制")];
            break;
        case lsqRecordStateRecording:
            // 正在录制
            NSLog(@"TuSDKRecordVideoCamera record state: 正在录制");
            break;
        case lsqRecordStatePaused:
            // 暂停录制
            NSLog(@"TuSDKRecordVideoCamera record state: 暂停录制");
            break;
        case lsqRecordStateMerging:
            // 正在合成视频
            NSLog(@"TuSDKRecordVideoCamera record state: 正在合成");
            [[TuSDK shared].messageHub setStatus:NSLocalizedStringFromTable(@"tu_正在合成...", @"VideoDemo", @"正在合成...")];
            break;
        case lsqRecordStateCanceled:
            // 取消录制 同时 重置UI
            [_captureMode resetUI];
            break;
        case lsqRecordStateSaveing:
            // 正在保存
            NSLog(@"TuSDKRecordVideoCamera record state: 正在保存");
            [[TuSDK shared].messageHub setStatus:NSLocalizedStringFromTable(@"tu_正在保存...", @"VideoDemo", @"正在保存...")];
            break;
        default:
            break;
    }
}

/**
 录制错误信息
 
 @param camerea 录制相机
 @param error 错误信息
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea failedWithError:(NSError*)error {
    switch (error.code) {
        case lsqRecordVideoErrorUnknow:
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_录制失败：未知原因失败", @"VideoDemo", @"录制失败：未知原因失败")];
            break;
        case lsqRecordVideoErrorSaveFailed:
            // 取消录制 同时 重置UI
            [_captureMode resetUI];
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_录制失败", @"VideoDemo", @"录制失败")];
            break;
        case lsqRecordVideoErrorLessMinDuration:
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_不能低于最小时间", @"VideoDemo", @"不能低于最小时间")];
            break;
        case lsqRecordVideoErrorMoreMaxDuration:
            [_controlMaskView showViewsWhenPauseRecording];
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_大于最大时长，请保存视频后继续录制", @"VideoDemo", @"大于最大时长，请保存视频后继续录制")];
            break;
        case lsqRecordVideoErrorNotEnoughSpace:
            [[TuSDK shared].messageHub showError:NSLocalizedStringFromTable(@"tu_手机可用空间不足，请清理手机", @"VideoDemo", @"手机可用空间不足，请清理手机")];
            break;
        default:
            break;
    }
}

@end

#pragma mark - TuSDKVideoCameraDelegate

@implementation CameraViewController (Capture)

/**
 获取拍摄图片 (如需操作UI线程， 请检查当前线程是否为主线程)
 
 @param camera 相机对象
 @param result 获取的结果
 @param error 错误信息
 */
- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera takedResult:(TuSDKResult *)result error:(NSError *)error {
    if (result.image) {
        NSLog(@"result.image: %@",result.image);
        // 进行自定义操作，例如保存到相册
        // UIImageWriteToSavedPhotosAlbum(result.image, NULL, NULL, NULL);
        
   
    }
}

@end

#pragma mark - Tusdkvieo

@implementation CameraViewController (Effect)

/**
 当前正在应用的特效
 
 @param videoCamera 相机对象
 @param mediaEffectData 正在预览特效
 @since v3.2.0
 */
- (void)onVideoCamera:(TuSDKVideoCameraBase *_Nonnull)videoCamera didApplyingMediaEffect:(id<TuSDKMediaEffect>_Nonnull)mediaEffectData; {
    
    switch (mediaEffectData.effectType) {
            // 滤镜特效
        case TuSDKMediaEffectDataTypeFilter: {
            
            
            // 更新在相机界面上显示的滤镜名称
            NSString *filterName = [NSString stringWithFormat:@"lsq_filter_%@", mediaEffectData.filterWrap.code];
            
            self.controlMaskView.filterName = NSLocalizedStringFromTable(filterName, @"TuSDKConstants", @"无需国际化");
            [self.controlMaskView.filterPanelView reloadFilterParamters];
            
        }
            break;
        case TuSDKMediaEffectDataTypeComic: {
            // 更新在相机界面上显示的滤镜名称
            NSString *filterName = [NSString stringWithFormat:@"lsq_filter_%@", mediaEffectData.filterWrap.code];
            self.controlMaskView.filterName = NSLocalizedStringFromTable(filterName, @"TuSDKConstants", @"无需国际化");
            
            break;
        }
            // 微整形特效
        case TuSDKMediaEffectDataTypePlasticFace: {
            [self updatePlasticFaceDefaultParameters];
            [self.controlMaskView.propsItemPanelView reloadPanelView:TuSDKMediaEffectDataTypeMonsterFace];
        }
            break;
        case TuSDKMediaEffectDataTypeMonsterFace: {
            // 添加哈哈镜后重置微整形特效（哈哈镜特效无法和其他人脸特效共存：动态贴纸，人脸微整形效果）
            [self.controlMaskView.beautyPanelView resetPlasticFaceEffect];
        }
            break;
        default:
            break;
    }
    
}

/**
 特效被移除通知
 
 @param videoCamera 相机对象
 @param mediaEffects 被移除的特效列表
 @since v3.2.0
 */
- (void)onVideoCamera:(TuSDKVideoCameraBase *_Nonnull)videoCamera didRemoveMediaEffects:(NSArray<id<TuSDKMediaEffect>> *_Nonnull) mediaEffects {
    
    
}

#pragma mark - CameraFilterPanelDataSource

/**
 滤镜/微整形 参数个数
 
 @return  滤镜/微整形参数数量
 */
- (NSInteger)numberOfParamter:(id<CameraFilterPanelProtocol>)filterPanel {
    
    // 美颜视图面板
    if (filterPanel == _controlMaskView.beautyPanelView)
    {
        switch (_controlMaskView.beautyPanelView.selectedTabIndex)
        {
            case 0: // 美颜
            {
                return [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].count > 0 ? 1 : 0;
            }
                break;
            case 1:
            {
                // 微整形特效
                TuSDKMediaPlasticFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
                return effect.filterArgs.count;
            }
                break;
            default:
            {
                return 1;
            }
                break;
        }
        
    }
    else
    {
        // 滤镜视图面板
        if (_controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 1)
        {
            //漫画
            return 0;
        }
        else
        {
            TuSDKMediaFilterEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            return effect.filterArgs.count;
        }
    }
    
    return 0;
    
}

/**
 滤镜/微整形参数名称
 
 @param index 滤镜索引
 @return  滤镜/微整形参数名称
 */
- (NSString *)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel paramterNameAtIndex:(NSUInteger)index {
    
    // 美颜视图面板
    if (filterPanel == _controlMaskView.beautyPanelView)
    {
        switch (_controlMaskView.beautyPanelView.selectedTabIndex)
        {
            case 0: // 精准美颜、极度美颜
            {
                return _controlMaskView.beautyPanelView.selectedSkinKey;
            }
                break;
            case 1:
            {
                // 微整形
                TuSDKMediaPlasticFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
                return effect.filterArgs[index].key;
            }
                break;;
            default:
            {

            }
        }
    }
    else
    {
        // 滤镜视图面板
        if (_controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 1)
        {
            return 0;
        }
        else
        {
            TuSDKMediaFilterEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            return effect.filterArgs[index].key;
        }
    }
    
    return @"";
}

/**
 滤镜/微整形参数值
 
 @param index  滤镜/微整形参数索引
 @return  滤镜/微整形参数百分比
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel percentValueAtIndex:(NSUInteger)index {
    
    // 美颜视图面板
    if (filterPanel == _controlMaskView.beautyPanelView)
    {
        switch (_controlMaskView.beautyPanelView.selectedTabIndex)
        {
            case 0: // 精准美颜，极度美颜
            {
                TuSDKMediaSkinFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
                return [effect argWithKey:_controlMaskView.beautyPanelView.selectedSkinKey].precent;
            }
                break;
            case 1:
            {
                // 微整形
                TuSDKMediaPlasticFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
                return effect.filterArgs[index].precent;
            }
                break;
            default:
            {
                
                
            }
                break;
        }
    }
    else
    {
        // 滤镜视图面板
        if (self.controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 1)
        {
            return 0;
        }
        else
        {
            TuSDKMediaFilterEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            return effect.filterArgs[index].precent;
        }
    }
    
    return 0;
}

/**
 滤镜/微整形参数默认值
 
 @param index  滤镜/微整形参数索引
 @return  滤镜/微整形参数百分比
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel defaultPercentValueAtIndex:(NSUInteger)index
{
    
    // 美颜视图面板
    if (filterPanel == _controlMaskView.beautyPanelView)
    {
        switch (_controlMaskView.beautyPanelView.selectedTabIndex)
        {
            case 0: // 精准美颜，极度美颜
            {
                TuSDKMediaSkinFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
                TuSDKFilterArg *arg = [effect argWithKey:_controlMaskView.beautyPanelView.selectedSkinKey];
                return arg.defaultValue;
            }
                break;
            case 1:
            {
                // 微整形
                TuSDKMediaPlasticFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
                return effect.filterArgs[index].defaultValue;
            }
                break;
            default:
            {
            }
                break;
        }
    }
    else
    {
        // 滤镜视图面板
        if (self.controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 1)
        {
            return 0;
        }
        else
        {
            TuSDKMediaFilterEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            return effect.filterArgs[index].defaultValue;
        }
    }
    
    return 0;
}

/**
 美妆参数值
 
 @param index  美妆参数索引
 @param cosmeticIndex  美妆参数类型
 @return  美妆参数百分比
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel  cosmeticPercentValueAtIndex:(NSUInteger)index cosmeticIndex:(NSInteger)cosmeticIndex
{
    if([_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].count != 0)
    {
        // 美妆
        TuSDKMediaCosmeticEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].firstObject;
        return effect.filterArgs[cosmeticIndex].value;
    }
    else
    {
        TuSDKMediaCosmeticEffect *effect = [[TuSDKMediaCosmeticEffect alloc] init];
        [_camera addMediaEffect:effect];
        [self updateCosmeticDefaultParameters];
        return effect.filterArgs[cosmeticIndex].value;
    }
}

- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel  cosmeticDefaultValueAtIndex:(NSUInteger)index cosmeticIndex:(NSInteger)cosmeticIndex
{
    if([_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].count != 0)
    {
        // 美妆
        TuSDKMediaCosmeticEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].firstObject;
        return effect.filterArgs[cosmeticIndex].defaultValue;
    }
    else
    {
        TuSDKMediaCosmeticEffect *effect = [[TuSDKMediaCosmeticEffect alloc] init];
        [_camera addMediaEffect:effect];
        [self updateCosmeticDefaultParameters];
        return effect.filterArgs[cosmeticIndex].defaultValue;
    }
}

- (void)filterPanel:(id<CameraFilterPanelProtocol>_Nullable)filterPanel didChangeValue:(double)percent cosmeticIndex:(NSInteger)cosmeticIndex
{
    TuSDKMediaCosmeticEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].firstObject;
    switch (cosmeticIndex) {
        case 3:
        {
            //眼影
            [effect submitParameterWithKey:@"eyeshadowAlpha" argPrecent:percent];
        }
            break;
        case 4:
        {
            //眼线
            [effect submitParameterWithKey:@"eyelineAlpha" argPrecent:percent];
        }
            break;
        case 5:
        {
            //睫毛
            [effect submitParameterWithKey:@"eyeLashAlpha" argPrecent:percent];
        }
            break;
        default:
            break;
    }
}

/**
 重置美妆参数默认值
 */
- (void)updateCosmeticDefaultParameters
{
    TuSDKMediaCosmeticEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].firstObject;
    NSArray<TuSDKFilterArg *> *args = effect.filterArgs;

    for (TuSDKFilterArg *arg in args) {
        NSString *parameterName = arg.key;

        // Attention:可对参数效果强弱进行自定义调节，请用户自行测试选择最适宜强度 ！！！
        // Attention:参数效果调节强度并非效果强度越大越好，请用户根据实际情况对强度进行控制 ！！！

        // 是否需要更新参数值
        BOOL updateValue = NO;
        // 默认值的百分比，用于指定美妆初始的效果（参数默认值 = 最小值 + (最大值 - 最小值) * defaultValueFactor）
        CGFloat defaultValueFactor = 1;
        // 最大值的百分比，用于限制美妆参数变化的幅度（参数最大值 = 最小值 + (最大值 - 最小值) * maxValueFactor）
        CGFloat maxValueFactor = 1;

        if ([parameterName isEqualToString:@"lipAlpha"]) {
            //口红
//            maxValueFactor = 0.8;
            defaultValueFactor = 0.4;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"blushAlpha"]) {
            //腮红
//            maxValueFactor = 0.8;
            defaultValueFactor = 0.5;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"eyebrowAlpha"]) {
            //眉毛
//            maxValueFactor = 0.7;
            defaultValueFactor = 0.4;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"eyeshadowAlpha"]) {
            //眼影
            defaultValueFactor = 0.5;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"eyelineAlpha"]) {
            //眼线
            defaultValueFactor = 0.5;
            updateValue = YES;
        } else {
            //睫毛
            defaultValueFactor = 0.5;
            updateValue = YES;
        }

        if (updateValue) {
            if (defaultValueFactor != 1)
                arg.defaultValue = defaultValueFactor;

            if (maxValueFactor != 1)
                arg.maxFloatValue = maxValueFactor;
            
            // 把当前值重置为默认值
            NSLog(@"%@: %f", parameterName, arg.minFloatValue);
            [arg reset];
        }
    }
    [effect submitParameters];
}

#pragma mark - RecordFilterPanelDelegate

- (void)applySkinFaceEffect;
{
    /** 上次应用的特效 */
    TuSDKMediaSkinFaceEffect *oldSkinFaceEffect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
    NSArray<TuSDKFilterArg *> *filterArgs = oldSkinFaceEffect.filterArgs;

    /** 初始化美肤特效 默认 极致美颜 */
    TuSDKMediaSkinFaceEffect *skinFaceEffect = [[TuSDKMediaSkinFaceEffect alloc] initUseSkinFaceType:self.controlMaskView.beautyPanelView.faceType];
    [_camera addMediaEffect:skinFaceEffect];

    // 使用上次的值
    [filterArgs enumerateObjectsUsingBlock:^(TuSDKFilterArg * _Nonnull arg, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (self.controlMaskView.beautyPanelView.faceType == TuSkinFaceTypeMoist)
        {
            if ([arg.key isEqualToString:@"smoothing"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinMoistFaceSmothingMaxDefault;
            } else if ([arg.key isEqualToString:@"whitening"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinMoistFaceWhiteningMaxDefault;
            } else if ([arg.key isEqualToString:@"ruddy"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinMoistFaceRuddyMaxDefault;
            } else if ([arg.key isEqualToString:@"sharpen"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinMoistFaceRuddyMaxDefault;
            }
        }
        else if (self.controlMaskView.beautyPanelView.faceType == TuSkinFaceTypeNatural)
        {
            if ([arg.key isEqualToString:@"smoothing"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinFaceSmothingMaxDefault;
            } else if ([arg.key isEqualToString:@"whitening"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinFaceWhiteningMaxDefault;
            } else if ([arg.key isEqualToString:@"ruddy"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinMoistFaceRuddyMaxDefault;
            } else if ([arg.key isEqualToString:@"sharpen"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinMoistFaceRuddyMaxDefault;
            }
        }
        else
        {
            if ([arg.key isEqualToString:@"smoothing"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinBeautyFaceSmothingMaxDefault;
            } else if ([arg.key isEqualToString:@"whitening"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinBeautyFaceWhiteningMaxDefault;
            } else if ([arg.key isEqualToString:@"ruddy"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinMoistFaceRuddyMaxDefault;
            } else if ([arg.key isEqualToString:@"sharpen"]) {
                [skinFaceEffect argWithKey:arg.key].maxFloatValue = kSkinMoistFaceRuddyMaxDefault;
            }
        }
        [skinFaceEffect argWithKey:arg.key].precent = arg.precent;
    }];
    
    
    if (oldSkinFaceEffect)
    {
        [skinFaceEffect submitParameters];
    }
    else
    {
        [self updateSkinFaceDefaultParameters];
    }
    
    //设置标题
    if (_controlMaskView.beautyPanelView.faceType == TuSkinFaceTypeNatural)
    {
        NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", @"skin_precision"];
        [_controlMaskView setFilterName: NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化")];
    }
    else if (_controlMaskView.beautyPanelView.faceType == TuSkinFaceTypeMoist)
    {
        NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", @"skin_extreme"];
        [_controlMaskView setFilterName: NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化")];
    }
    else
    {
        NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", @"skin_beauty"];
        [_controlMaskView setFilterName: NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化")];
    }
}

/**
 滤镜面板切换标签回调
 
 @param filterPanel 滤镜面板
 @param tabIndex 标签索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSwitchTabIndex:(NSInteger)tabIndex {
    if ([filterPanel isKindOfClass:[CameraFilterPanelView class]]) {
        if (tabIndex == self.titleSource.count - 1)
        {
            _filterCodes = kComicsFilterCodes;
        }
        else
        {
            _filterCodes = _controlMaskView.filterPanelView.filtersGroups[tabIndex];
        }
        self.currentFilterIndex = 0;
    }
}

-(void)setCurrentFilterIndex:(NSUInteger)currentFilterIndex;{
    _currentFilterIndex = currentFilterIndex;
}

/**
 滤镜面板选中回调
 
 @param filterPanel 滤镜面板
 @param code 滤镜码
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedFilterCode:(NSString *)code {
    
    // 美颜视图面板
    if (filterPanel == _controlMaskView.beautyPanelView)
    {
        switch (_controlMaskView.beautyPanelView.selectedTabIndex)
        {
            case 0: // 精准美颜、 极度美颜
            {
                // 如果是切换美颜
                if ([code isEqualToString:@[kBeautySkinKeys][0]])
                {
                    [self applySkinFaceEffect];
                    
                } else {
                    
                    if ([_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].count == 0)
                        [self applySkinFaceEffect];
                }
        
                break;
            }
            case 1:
            {
                // 微整形
                if ([_camera mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].count == 0)
                {
                    TuSDKMediaPlasticFaceEffect *plasticFaceEffect = [[TuSDKMediaPlasticFaceEffect alloc] init];
                    [_camera addMediaEffect:plasticFaceEffect];
                    [self updatePlasticFaceDefaultParameters];
                    return;
                }
            }
                break;
            default:
            {
                
            }
                break;
        }
        
    } else {

        // 滤镜视图面板
        // 漫画
        if (_controlMaskView.filterPanelView.selectedTabIndex == self.titleSource.count - 1)
        {
            TuSDKMediaComicEffect *effect = [[TuSDKMediaComicEffect alloc] initWithEffectCode:code];
            [_camera addMediaEffect:effect];
            self.currentFilterIndex = [_filterCodes indexOfObject:code];
        }
        else
        {
            // 滤镜
            TuSDKMediaFilterEffect *effect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:code];
            [_camera addMediaEffect:effect];
            self.currentFilterIndex = [_filterCodes indexOfObject:code];
        }
    }
}

/**
 美妆面板选中回调
 
 @param filterPanel 美妆面板
 @param code 美妆类型码
 @param stickerCode 美妆效果code
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedCosmeticCode:(NSString *)code stickerCode:(nonnull NSString *)stickerCode;
{

    NSArray<TuSDKPFStickerGroup *> *allLocalStickers = [[TuSDKPFStickerLocalPackage package] getSmartStickerGroups];
    for (TuSDKPFStickerGroup *groups in allLocalStickers)
    {
        if (groups.idt == stickerCode.integerValue)
        {
            TuSDKPFSticker *sticker = groups.stickers.firstObject;
            
            if ([_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].count == 0)
            {
                TuSDKMediaCosmeticEffect *comsticEffect = [[TuSDKMediaCosmeticEffect alloc] init];
                [_camera addMediaEffect:comsticEffect];
                
                TuSDKStickerPositionInfo *positionInfo = sticker.positionInfo;
                switch (positionInfo.posType) {
                    case CosEyeShadow:
                        [comsticEffect updateEyeshadow:sticker];
                        break;
                    case CosEyeLine:
                        [comsticEffect updateEyeline:sticker];
                        break;
                    case CosEyeLash:
                        [comsticEffect updateEyelash:sticker];
                        break;
                    case CosBrows:
                        [comsticEffect updateEyebrow:sticker];
                        break;
                    case CosBlush:
                        [comsticEffect updateBlush:sticker];
                    default:
                        break;
                }
            }
            else
            {
                TuSDKMediaCosmeticEffect *comsticEffect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].lastObject;
                [_camera addMediaEffect:comsticEffect];

                TuSDKStickerPositionInfo *positionInfo = sticker.positionInfo;
                switch (positionInfo.posType) {
                    case CosEyeShadow:
                        [comsticEffect updateEyeshadow:sticker];
                        break;
                    case CosEyeLine:
                        [comsticEffect updateEyeline:sticker];
                        break;
                    case CosEyeLash:
                        [comsticEffect updateEyelash:sticker];
                        break;
                    case CosBrows:
                        [comsticEffect updateEyebrow:sticker];
                        break;
                    case CosBlush:
                        [comsticEffect updateBlush:sticker];
                    default:
                        break;
                }
                
            }
        }
    }
}
/**
 美妆口红面板选中回调
 
 @param filterPanel 美妆面板
 @param lipStickType 口红类型
 @param stickerName 美妆贴纸名称
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedLipStickType:(NSInteger)lipStickType stickerName:(NSString *)stickerName
{
    CosmeticLipType lipType = COSMETIC_SHUIRUN_TYPE;
    switch (lipStickType) {
        case 1:  // 滋润
            lipType = COSMETIC_ZIRUN_TYPE;
            break;
        case 2:  // 雾面
            lipType = COSMETIC_WUMIAN_TYPE;
            break;
        default: // 水润
            lipType = COSMETIC_SHUIRUN_TYPE;
            break;
    }
    int RGBValue = [TuCosmeticConfig stickLipParamByStickerName:stickerName];
    
    if ([_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].count == 0)
    {
        TuSDKMediaCosmeticEffect *comsticEffect = [[TuSDKMediaCosmeticEffect alloc] init];
        [comsticEffect updateLip:lipType colorRGB:RGBValue];
        [_camera addMediaEffect:comsticEffect];
    }
    else
    {
        TuSDKMediaCosmeticEffect *comsticEffect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].lastObject;
        [comsticEffect updateLip:lipType colorRGB:RGBValue];
        [_camera addMediaEffect:comsticEffect];
    }
}

/**
 滤镜面板值变更回调
 
 @param filterPanel 滤镜面板
 @param percentValue 滤镜参数变更数值
 @param index 滤镜参数索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didChangeValue:(double)percentValue paramterIndex:(NSUInteger)index {
    
    // 美颜视图面板
    if (filterPanel == _controlMaskView.beautyPanelView)
    {
        switch (_controlMaskView.beautyPanelView.selectedTabIndex)
        {
            case 0: // 精准美颜,极致美颜
            {
                TuSDKMediaSkinFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
                [effect submitParameterWithKey:_controlMaskView.beautyPanelView.selectedSkinKey argPrecent:percentValue];
            
            }
                break;
            case 1:
            {
                // 微整形
                TuSDKMediaPlasticFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
                [effect submitParameter:index argPrecent:percentValue];
            }
                break;
            default:
            {
                //美妆
                TuSDKMediaCosmeticEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].firstObject;
                [effect submitParameter:index argPrecent:percentValue];
                
                //NSLog(@"设置透明度 == %.2f", percentValue);
                
            }
                break;
        }
    }
    else
    {
        // 滤镜视图面板
        if (self.controlMaskView.filterPanelView.selectedTabIndex == self.controlMaskView.filterPanelView.filterTitles.count - 1)
        {
            //漫画
            //漫画滤镜无值改变
        }
        else
        {
            TuSDKMediaFilterEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            [effect submitParameter:index argPrecent:percentValue];
            
        }
    }
}

/**
 美妆面板重置回调
 
 @param filterPanel 滤镜面板
 @param code 美妆效果码
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel closeCosmetic:(NSString *)code
{
    TuSDKMediaCosmeticEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic].firstObject;
    
    if ([code isEqualToString:@"cosmeticReset"])
    {
        typeof(self)weakSelf = self;
        NSString *title = NSLocalizedStringFromTable(@"tu_美妆", @"VideoDemo", @"美妆");
        NSString *msg = NSLocalizedStringFromTable(@"tu_确定删除所有美妆效果?", @"VideoDemo", @"美妆");
        TuSDKICAlertView *alert = [TuSDKICAlertView alertWithController:self
                                                                  title:title
                                                                message:msg];

        [alert addAction:[TuSDKICAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_确定", @"VideoDemo", @"确定") handler:^(TuSDKICAlertAction * _Nonnull action)
                          {
            
            [effect closeLip];
            [effect closeBlush];
            [effect closeEyebrow];
            [effect closeEyeshadow];
            [effect closeEyeline];
            [effect closeEyelash];
            
            [weakSelf->_camera removeMediaEffectsWithType:TuSDKMediaEffectDataTypeCosmetic];
            
            weakSelf->_controlMaskView.beautyPanelView.resetCosmetic = YES;

        }]];
        
        [alert addAction:[TuSDKICAlertAction actionCancelWithTitle:LSQString(@"lsq_nav_cancel", @"取消") handler:nil]];
        
        [alert show];

    }
    else if ([code isEqualToString:@"lipstick"])
    {
        [effect closeLip];
        //NSLog(@"关闭口红效果");
    }
    else if ([code isEqualToString:@"blush"])
    {
        [effect closeBlush];
        //NSLog(@"关闭腮红效果");
    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        [effect closeEyebrow];
        //NSLog(@"关闭眉毛效果");
    }
    else if ([code isEqualToString:@"eyeshadow"])
    {
        [effect closeEyeshadow];
        //NSLog(@"关闭眼影效果");
    }
    else if ([code isEqualToString:@"eyeliner"])
    {
        [effect closeEyeline];
        //NSLog(@"关闭眼线效果");
    }
    else
    {
        [effect closeEyelash];
        //NSLog(@"关闭睫毛效果");
    }
}

/**
 重置滤镜参数回调
 
 @param filterPanel 滤镜面板
 @param paramterKeys 滤镜参数
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel resetParamterKeys:(NSArray *)paramterKeys {

    if (filterPanel == _controlMaskView.beautyPanelView)
    {
        typeof(self)weakSelf = self;
        void (^resetBlock)(void) = ^{
            
            // 微整形
            NSString *title = NSLocalizedStringFromTable(@"tu_重置", @"VideoDemo", @"重置");
            NSString *message = NSLocalizedStringFromTable(@"tu_将所有参数恢复默认吗？", @"VideoDemo", @"将所有参数恢复默认吗？");
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_取消", @"VideoDemo", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_确定", @"VideoDemo", @"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [weakSelf->_camera removeMediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace];
                
                /** 添加初始微整形特效 */
                TuSDKMediaPlasticFaceEffect *plasticFaceEffect = [[TuSDKMediaPlasticFaceEffect alloc] init];
                [weakSelf->_camera addMediaEffect:plasticFaceEffect];
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
        };
        
        switch (_controlMaskView.beautyPanelView.selectedTabIndex) {
            case 0:
            {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ruddy"])
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ruddy"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                [_camera removeMediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace];
            }
                
                break;
            case 1:
                resetBlock();
                break;
            default:
                break;
        }
        
    }else if(filterPanel == _controlMaskView.filterPanelView)
    {
        [_camera removeMediaEffectsWithType:TuSDKMediaEffectDataTypeFilter];
    }
}

#pragma mark PropsPanelViewDelegate

/**
 贴纸选中回调
 
 @param propsPanelView 相机贴纸协议
 @param propsItem 贴纸组
 */
- (void)propsPanel:(PropsPanelView *)propsPanelView didSelectPropsItem:(__kindof PropsItem *)propsItem {
    if (!propsItem) {
        // 为nil时 移除已有贴纸组
        [_camera removeMediaEffectsWithType:TuSDKMediaEffectDataTypeSticker];
        return;
    }
    
    // 添加贴纸特效
    [_camera addMediaEffect:propsItem.effect];
}

/**
 取消选中某类道具

 @param propsPanel 道具视频
 @param propsItemCategory 道具分类
 */
- (void)propsPanel:(PropsPanelView *)propsPanel unSelectPropsItemCategory:(__kindof PropsItemCategory *)propsItemCategory {
    [_camera removeMediaEffectsWithType:propsItemCategory.categoryType];
}

/**
 道具移除事件

 @param propsPanel 道具视图
 @param propsItem 被移除的特效
 */
- (void)propsPanel:(PropsPanelView *)propsPanel didRemovePropsItem:(__kindof PropsItem *)propsItem {
    [_camera removeMediaEffect:propsItem.effect];
}

#pragma mark - 滤镜相关

/**
 重置美颜参数默认值
 */
- (void)updateSkinFaceDefaultParameters;
{
    TuSDKMediaSkinFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
    NSArray<TuSDKFilterArg *> *args = effect.filterArgs;
    BOOL needSubmitParameter = NO;
    
    
    for (TuSDKFilterArg *arg in args) {
        NSString *parameterName = arg.key;
        // NSLog(@"调节的滤镜参数名称 parameterName: %@",parameterName)
        // 应用保存的参数默认值、最大值
        NSDictionary *savedDefaultDic = _filterParameterDefaultDic[parameterName];
        if (savedDefaultDic) {
            if (savedDefaultDic[kFilterParameterDefaultKey])
                arg.defaultValue = [savedDefaultDic[kFilterParameterDefaultKey] doubleValue];
            
            if (savedDefaultDic[kFilterParameterMaxKey])
                arg.maxFloatValue = [savedDefaultDic[kFilterParameterMaxKey] doubleValue];
            
            // 把当前值重置为默认值
            [arg reset];
            needSubmitParameter = YES;
            continue;
        }
        
        // Attention:可对参数效果强弱进行自定义调节，请用户自行测试选择最适宜强度 ！！！
        // Attention:参数效果调节强度并非效果强度越大越好，请用户根据实际情况对强度进行控制 ！！！
        
        // 是否需要更新参数值
        BOOL updateValue = NO;
        // 默认值的百分比，用于指定滤镜初始的效果（参数默认值 = 最小值 + (最大值 - 最小值) * defaultValueFactor）
        CGFloat defaultValueFactor = 1;
        // 最大值的百分比，用于限制滤镜参数变化的幅度（参数最大值 = 最小值 + (最大值 - 最小值) * maxValueFactor）
        CGFloat maxValueFactor = 1;
        
        if ([parameterName isEqualToString:@"smoothing"]) {
            // 磨皮
            maxValueFactor = kSkinFaceSmothingMaxDefault;
            defaultValueFactor = 0.8;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"whitening"]) {
            // 美白
            maxValueFactor = kSkinFaceWhiteningMaxDefault;
            defaultValueFactor = 0.3;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"ruddy"]) {
            // 红润
            maxValueFactor = kSkinFaceWhiteningMaxDefault;
            defaultValueFactor = 0.2;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"sharpen"]) {
            // 锐化
            maxValueFactor = kSkinFaceRuddyMaxDefault;
            defaultValueFactor = 0.6;
            updateValue = YES;
        }
        if (updateValue) {
            if (defaultValueFactor != 1)
                arg.defaultValue = arg.minFloatValue + (arg.maxFloatValue - arg.minFloatValue) * defaultValueFactor * maxValueFactor;
            
            if (maxValueFactor != 1)
                arg.maxFloatValue = arg.minFloatValue + (arg.maxFloatValue - arg.minFloatValue) * maxValueFactor;
            // 把当前值重置为默认值
            NSLog(@"%@: %f", parameterName, arg.minFloatValue);
            [arg reset];
            
            // 存储值
            _filterParameterDefaultDic[parameterName] = @{kFilterParameterDefaultKey: @(arg.defaultValue), kFilterParameterMaxKey: @(arg.maxFloatValue)};
            needSubmitParameter = YES;
        }
    }
    
    // 提交修改结果
    if (needSubmitParameter)
        [effect submitParameters];
    
    [self.controlMaskView.beautyPanelView reloadFilterParamters];
    
}

/**
 重置微整形参数默认值
 */
- (void)updatePlasticFaceDefaultParameters {
    
    TuSDKMediaPlasticFaceEffect *effect = [_camera mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
    NSArray<TuSDKFilterArg *> *args = effect.filterArgs;
    BOOL needSubmitParameter = NO;
    
    for (TuSDKFilterArg *arg in args) {
        NSString *parameterName = arg.key;
        
        // 是否需要更新参数值
        BOOL updateValue = NO;
        // 默认值的百分比，用于指定滤镜初始的效果（参数默认值 = 最小值 + (最大值 - 最小值) * defaultValueFactor）
        CGFloat defaultValueFactor = 1;
        // 最大值的百分比，用于限制滤镜参数变化的幅度（参数最大值 = 最小值 + (最大值 - 最小值) * maxValueFactor）
//        CGFloat maxValueFactor = 1;
        if ([parameterName isEqualToString:@"eyeSize"]) {
            // 大眼
            defaultValueFactor = 0.3;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"chinSize"]) {
            // 瘦脸
            defaultValueFactor = 0.5;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"noseSize"]) {
            // 瘦鼻
            defaultValueFactor = 0.2;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"mouthWidth"]) {
            // 嘴型
        } else if ([parameterName isEqualToString:@"lips"]) {
            // 唇厚
        } else if ([parameterName isEqualToString:@"archEyebrow"]) {
            // 细眉
        } else if ([parameterName isEqualToString:@"browPosition"]) {
            // 眉高
        }else if ([parameterName isEqualToString:@"jawSize"]) {
            // 下巴
        } else if ([parameterName isEqualToString:@"eyeAngle"]) {
            // 眼角
        } else if ([parameterName isEqualToString:@"eyeDis"]) {
            // 眼距
        }else if ([parameterName isEqualToString:@"forehead"]) {
            // 发际线
        }
        
        if (updateValue) {
            if (defaultValueFactor != 1)
                arg.defaultValue = defaultValueFactor;
//                arg.defaultValue = arg.minFloatValue + (arg.maxFloatValue - arg.minFloatValue) * defaultValueFactor * maxValueFactor;
//
//            if (maxValueFactor != 1)
//                arg.maxFloatValue = arg.minFloatValue + (arg.maxFloatValue - arg.minFloatValue) * maxValueFactor;
            // 把当前值重置为默认值
            [arg reset];
            
            needSubmitParameter = YES;
        }
    }
    
    // 提交修改结果
    if (needSubmitParameter)
        [effect submitParameters];
    
}

- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel toIndex:(NSInteger)toIndex direction:(NSInteger)direction
{
    //滚动到漫画滤镜
//    if (toIndex == self.controlMaskView.filterPanelView.filterTitles.count - 1)
//    {
//        //右侧滚动到漫画滤镜
//        if (direction == TuFilterViewScrollDirectionRight)
//        {
//            _filterCodes = @[kCameraComicsFilterCodes];
//            self.currentFilterIndex = 0;
//        }
//        //左侧滚动到漫画滤镜
//        if (direction == TuFilterViewScrollDirectionLeft)
//        {
//            _filterCodes = @[kCameraComicsFilterCodes];
//            self.currentFilterIndex = self.filterCodes.count - 1;
//        }
//        TuSDKMediaComicEffect *comicEffect = [[TuSDKMediaComicEffect alloc] initWithEffectCode:_filterCodes[self.currentFilterIndex]];
//        [_camera addMediaEffect:comicEffect];
//    }
//    else
//    {
//        //滚动到普通滤镜
//        //右侧滚动到普通滤镜
//        if (direction == TuFilterViewScrollDirectionRight)
//        {
//            _filterCodes = self.controlMaskView.filterPanelView.filtersGroups[toIndex];
//            self.currentFilterIndex = 0;
//        }
//        //左侧滚动到普通滤镜
//        if (direction == TuFilterViewScrollDirectionLeft)
//        {
//            _filterCodes = self.controlMaskView.filterPanelView.filtersGroups[toIndex];
//            self.currentFilterIndex = self.filterCodes.count - 1;
//        }
//        TuSDKMediaFilterEffect *filterEffect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:_filterCodes[self.currentFilterIndex]];
//        [_camera addMediaEffect:filterEffect];
//    }
}

#pragma mark - lazyload
- (NSMutableArray *)titleSource
{
    if (!_titleSource)
    {
        _titleSource = [NSMutableArray array];
        //获取滤镜标题数组
        NSArray *titleDataSet = [[TuCameraFilterPackage sharePackage] titleGroupsWithComics:YES];
        [_titleSource addObjectsFromArray:titleDataSet];
    }
    return _titleSource;;
}

@end
