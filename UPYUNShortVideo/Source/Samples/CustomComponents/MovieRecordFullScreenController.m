//
//  MovieRecordFullScreenController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieRecordFullScreenController.h"
#import "MovieEditorFullScreenController.h"
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
    // self.camera.waterMarkImage = [UIImage imageNamed:@"sampleself.watermark.png"];
    // 设置水印图片的位置
    // self.camera.waterMarkPosition = lsqWaterMarkTopLeft;
    // 最大录制时长 8s
    self.camera.maxRecordingTime = 8;
    // 最小录制时长 2s
    self.camera.minRecordingTime = 1;
    // 正常模式/续拍模式  - 注：该录制模式需和 self.bottomBar 中的一致, 若不使用这套UI逻辑，可进行自定义交互操作
    self.camera.recordMode = self.inputRecordMode;
    // 是否开启美颜
    self.camera.enableBeauty = YES;
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
    
    if (self.filterView)
    {
    self.filterView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - TuSDKRecordVideoCameraDelegate
/**
 *  视频录制完成
 *
 *  @param camerea 相机
 *  @param result  TuSDKVideoResult 对象
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea result:(TuSDKVideoResult *)result;
{
    // 通过相机初始化设置  self.camera.saveToAlbum = NO;  result.videoPath 拿到视频的临时文件路径
    if (result.videoPath) {
        // 进行自定义操作，例如保存到相册
        // UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
        // [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsqself.saveself.saveToAlbumself.succeed", @"保存成功")];
        // 开启视频编辑添加滤镜
        MovieEditorFullScreenController *vc = [MovieEditorFullScreenController new];
        vc.inputURL = [NSURL fileURLWithPath:result.videoPath];
        // 视频编辑如需全屏展示，参数需要设置 vc.cropRect = CGRectMake(0, 0, 0, 0); 画面展示会进行比例自适应
        vc.cropRect = CGRectMake(0, 0, 0, 0);
        vc.startTime = 0;
        vc.endTime = result.duration;
        [self.navigationController pushViewController:vc animated:true];
    }else{
        // self.camera.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsqself.saveself.saveToAlbumself.succeed", @"保存成功")];
    }
    
    if (self.camera && self.camera.recordMode == lsqRecordModeNormal) {
        [self.bottomBar recordBtnIsRecordingStatu:NO];
    }

    // 自动保存后设置为 恢复进度条状态
    [self changeNodeViewWithLocation:0];
}

@end
