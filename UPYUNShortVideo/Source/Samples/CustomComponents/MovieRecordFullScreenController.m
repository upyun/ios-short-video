//
//  MovieRecordFullScreenController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieRecordFullScreenController.h"
/**
 *  视频录制相机示例
 */

@implementation MovieRecordFullScreenController

#pragma mark - TuSDK Camera

-(void)viewDidLoad;
{
    [super viewDidLoad];
    self.bottomBar.backgroundColor = [UIColor clearColor];
    self.bottomBackView.backgroundColor =  [UIColor colorWithWhite:0 alpha:0.5];
    self.topBar.backgroundColor = [UIColor clearColor];
}

// 初始化camera
- (void)startCamera
{
    if (!self.cameraView) {
        // 将 cameraView 的 frame 设置为全屏展示
        self.cameraView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, self.view.lsqGetSizeHeight)];
        [self.view insertSubview:self.cameraView atIndex:0];
        
        // 使用tapView 做中间的手势响应范围，为了防止和录制按钮的手势时间冲突(偶发)
        UIView *tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 74, self.view.lsqGetSizeWidth, self.view.lsqGetSizeWidth)];
        [self.view addSubview:tapView];
        // 添加手势方法
        UITapGestureRecognizer *cameraTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cameraTapEvent)];
        [tapView addGestureRecognizer:cameraTap];
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
    // 相机预览画面区域显示算法，如需全屏显示需要注释 self.camera.regionHandler 的相关代码
    // self.camera.regionHandler = [[CustomTuSDKCPRegionDefaultHandler alloc]init];

    // 输出 1:1 画幅视频，如需全屏显示需要注释 self.camera.cameraViewRatio 的相关代码
    // self.camera.cameraViewRatio = 1.0;
    
    // 指定比例后，如不指定尺寸，SDK 会根据设备情况自动输出适应比例的尺寸，采集如有设置尺寸 AVCaptureSessionPreset640x480，self.camera.outputSize需要保持一致
     self.camera.outputSize = CGSizeMake(720, 1280);
    
    // 输出视频的画质，主要包含码率、分辨率等参数 (默认为空，采用系统设置)
    self.camera.videoQuality =  [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Low1];
    // 是否禁用持续自动对焦
    self.camera.disableContinueFoucs = NO;
    // 视频覆盖区域颜色 (默认：[UIColor blackColor])
    self.camera.regionViewColor = [UIColor blackColor];
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
     self.camera.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
    // 设置水印图片的位置
     self.camera.waterMarkPosition = lsqWaterMarkTopLeft;
    // 最大录制时长 8s
    self.camera.maxRecordingTime = 8;
    // 最小录制时长 2s
    self.camera.minRecordingTime = 1;
    // 正常模式/续拍模式  - 注：该录制模式需和 self.bottomBar 中的一致, 若不使用这套UI逻辑，可进行自定义交互操作
    self.camera.recordMode = self.inputRecordMode;
    // 启动相机
    [self.camera tryStartCameraCapture];
    
    // 默认为前置摄像头 此时应关闭闪光灯
    self.flashModeIndex = 0;
    [self resetFlashBtnStatusWithBtnEnabled:NO];
}

#pragma mark - BottomBarDelegate

/**
 按钮点击的代理方法
 
 @param btn 按钮
 */
- (void)onBottomBtnClicked:(UIButton*)btn;
{
    [super onBottomBtnClicked:btn];
    if (self.stickerView)
    {
        self.stickerView.backgroundColor = [UIColor clearColor];
    }
    
    if (self.filterBottomView)
    {
    self.filterBottomView.backgroundColor = [UIColor clearColor];
    }
}

// 初始化贴纸栏
- (void)createStikerView;
{
    [super createStikerView];
    self.stickerView.cameraStickerType = lsqCameraStickersTypeFullScreen;
}
@end
