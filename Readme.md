# 又拍云短视频 


1.提供短视频的拍摄、编辑、合成、上传等基础功能。

2.提供播放器支持。

_注:该 SDK 不支持模拟器运行,请使用真机_

## 目录
1 [短视频](#1)

2 [上传](#2)

3 [播放器](#3)



<h2 id="1">短视频</h2>

### 1.配置环境

#### 1.1 基本介绍

* 短视频拍摄、编辑、合成部分，包含断点录制、分段回删、美颜、滤镜、贴纸、视频剪辑、视频压缩、本地转码在内的 30 多种功能，支持自定义界面和二次开发。


#### 1.2 运行环境

* 支持 iOS `8.0` 以上版本。

#### 1.3 密钥 和 资源

* 短视频 SDK 提供一个免费版和两个收费版，任何版本使用都需要授权（key），收费版可以免费试用一个月。

* 获取授权，请提供应用名称、申请使用的 SDK 版本、使用的平台（iOS）、Bundle Id、给您的商务经理，或者[联系我们](https://www.upyun.com/contact)。

#### 1.4 环境配置

1、将示例工程源码中 `Resources` 文件夹内的文件拖入到 Xcode 项目中中。`TuSDK` 包含项目运行所需要的 framework 文件。 `Resources` 包含项目运行所需要的资源文件。

* TuSDK 文件夹
* `UPLiveSDK.framework`  注: __播放器,不需要可不添加__ 
* `UpYunSDK 文件夹` 注: __上传视频必需__ 
* `GPUImage.framework`
* `libyuv.framework` 
* `TuSDK.framework`
* `TuSDKVideo.framework`
* `TuSDKFace.framework`
* Resources 文件夹
* ` TuSDK.strings` 为 SDK 中使用的语言文件。
* ` Localizable.strings` 为 demo 展示项目的语言文件。
* `TuSDK.bundle` 为项目资源文件，包含滤镜，动态贴纸等文件。

2、勾选 **Copy items if needed**，点击 **Finish**。

3、打开项目 app target，查看 **Build Settings** 中 **Linking** - **Other Linker Flags** 选项，确保含有 `-ObjC`，若没有则添加。用户使用 Cocoapod 进行第三方依赖库管理，需要在 `-ObjC` 前添加 `$(inherited)`。目前短视频 SDK 暂不支持 Cocoapod。

4、在项目的 app target 中，查看 **Build Phases** 中的 **Linking** - **Link Binary With Libraries** 选项中，手动添加 `Photos.framework`，并将 Photos.framework 的 Status 设置成 `Optional`。

5、在项目的 app target 中，查看 **Build Phases** 中的 **Linking** - **Link Binary With Libraries** 选项中，手动添加 `Accelerate.framework`。

6、用户联系 `UPYUN` 服务支持, 需要的滤镜资源。资源文件中包含 `others` ， `textures`和`stickers` 需要将这些文件夹替换到 TuSDK.bundle 中对应位置。

7、用户可以在 `TuSDKVideoDemo/Resources` 文件中找到 TuSDK.bundle 文件。文件中包含 `others` ，`textures`，`stickers`和`ui_default` 这些文件夹。用户需要替换 `others/lsq_tusdk_configs.json` 文件 `textures`和`stickers`整个文件夹。


#### 1.5 TuSDK 的初始化

1、在需要使用 TuSDK 的类的文件中引入头文件 `#import "TuSDKFramework.h"`。

2、在 `AppDelegate.m` 的 `didFinishLaunchingWithOptions` 方法中添加初始化代码，用户如果需求同一应用不同版本发布，请 [联系我们](https://www.upyun.com/contact)

3、为便于开发，可打开 TuSDK 的调试日志，在初始化方法的同一位置添加以下代码：`[TuSDK setLogLevel:lsqLogLevelDEBUG];`发布应用时请关闭日志。

  
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // 初始化SDK (请前往 联系UPYUN 获取您的 APP 开发密钥)
        [TuSDK initSdkWithAppKey:@"828d700d182dd469-04-ewdjn1"];
        // 多 masterkey 方式启动方法
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.XXXXXXXX.XXXX"]) {
            [TuSDK initSdkWithAppKey:@"714f0a1265b39708-02-xie0p1" devType:@"release"];
        }
        // 开发时请打开调试日志输出
        [TuSDK setLogLevel:lsqLogLevelDEBUG];
    }
  
4、添加位置权限，在 `viewDidLoad` 协议方法中添加以下代码，并在项目的 `Info.plist` 文件中加入获取位置信息字段。例如：

  
    - (void)viewDidLoad {
        // 启动GPS
        // 不需要定位功能，可注释该代码,即不再申请定位权限
        [[TuSDKTKLocation shared] requireAuthorWithController:self];
    }

  
5、检查滤镜管理器的初始化，在使用滤镜前的某个界面的 `viewDidLoad` 协议方法中添加以下代码，即可检查滤镜管理器的初始化是否完成。

  
    - (void)viewDidLoad {
        // 异步方式初始化滤镜管理器 
        // 需要等待滤镜管理器初始化完成，才能使用所有功能
        [TuSDK checkManagerWithDelegate:self];
        // 库文件的版本号
        NSLog(@"TuSDK.framework 的版本号 : %@",lsqSDKVersion);
        NSLog(@"TuSDKVideo.framework 的版本号 : %@",lsqVideoVersion);
    }
    
    
        #pragma mark - TuSDKFilterManagerDelegate
        /**
         * 滤镜管理器初始化完成（代理方法）
         *
         * @param manager
         * 滤镜管理器
         */
        - (void)onTuSDKFilterManagerInited:(TuSDKFilterManager *)manager;
        {
            
        }
  
6、需要在 info.plist 中添加的权限字段

    <!-- 相册 --> 
    <key>NSPhotoLibraryUsageDescription</key> 
    <string>Recording requires to use your photo library</string> 
    <!-- 相机 --> 
    <key>NSCameraUsageDescription</key> 
    <string>Recording requires to use your camera</string> 
    <!-- 麦克风 --> 
    <key>NSMicrophoneUsageDescription</key> 
    <string>Recording requires to use your microphone</string> 
    <!-- 在使用期间访问位置 --> 
    <key>NSLocationWhenInUseUsageDescription</key> 
    <string>Recording requires your location</string> 

7、前期库文件的安装和 TuSDK 初始化已完成，后期功能代码调用见 `TuSDKVideoDemo` 。


### 2.相机采集

#### 2.1 创建相机对象
 
        // 录制相机对象
        TuSDKRecordVideoCamera  *_camera;

* 遵守代理 `TuSDKRecordVideoCameraDelegate`

#### 2.2 请求相机权限

  
        // 开启访问相机权限
        [TuSDKTSDeviceSettings checkAllowWithController:self
                                                   type:lsqDeviceSettingsCamera
                                              completed:^(lsqDeviceSettingsType type, BOOL openSetting)
         {
             if (openSetting) {
                 lsqLError(@"Can not open camera");
                 return;
             }
             // 启动相机的方法
             // ...
         }];
  

#### 2.3 配置滤镜列表,创建事件处理队列，请求相册权限

  
        // 滤镜列表，获取滤镜前往 TuSDK.bundle/others/lsq_tusdk_configs.json  
        // TuSDK 滤镜信息介绍 @see-https://tusdk.com/docs/ios/self-customize-filter
        _videoFilters = @[@"Normal", @"SkinSugar", @"DeepWhitening"];
              
        // 事件处理队列
        _sessionQueue = dispatch_queue_create("org.lasque.tusdkvideo", DISPATCH_QUEUE_SERIAL);
              
        // 测试相册访问权限
        [TuSDKTSAssetsManager testLibraryAuthor:^(NSError *error)
        {
            if (error) {
                [TuSDKTSAssetsManager showAlertWithController:self loadFailure:error];
            }else{
                NSLog(@"已经获得了相册的权限");
            }
        }];
  

#### 2.4 配置录制相机


* 创建相机预览画面的视图

        if (!_cameraView) {
            _cameraView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.getSizeWidth, self.view.getSizeHeight)];
            [self.view addSubview:_cameraView];
            [self.view insertSubview:_cameraView atIndex:0];
        }
        
        
* 启动相机对象 
        
        // SessionPreset :采集画面的清晰度，建议 AVCaptureSessionPresetHigh 
        // 设置参考：AVFoundation/AVCaptureSession.h
        // cameraPosition：默认前置摄像头，[AVCaptureDevice lsqFirstFrontCameraPosition]
        _camera = [TuSDKRecordVideoCamera initWithSessionPreset:AVCaptureSessionPresetMedium
           cameraPosition:[AVCaptureDevice lsqFirstFrontCameraPosition]
               cameraView:_cameraView];
               
* 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)，可输出 MP4       
         
        _camera.fileType = lsqFileTypeMPEG4;
* 输出视频的画质，影响保存视频文件的体积 (默认采用系统设置,自定义设置请参考「自定义使用5」)
 
        _camera.videoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Medium2];        
* 设置委托

        _camera.videoDelegate = self;
* 相机预览画面区域显示算法

        _camera.regionHandler = [[CustomTuSDKCPRegionDefaultHandler alloc]init];
* 预览画面画幅设置，_cameraView 设置为全屏尺寸后，调节比例可以输出 1:1 画幅视频
  
        _camera.cameraViewRatio = 1.0;
* 指定比例后，建议输出画面尺寸和设定 cameraViewRatio 保持一致，SDK 会根据设备情况自动输出最合适的尺寸
  
        _camera.outputSize = CGSizeMake(640, 640);
* 禁用持续自动对焦
  
        _camera.disableContinueFoucs = NO;
* 视频覆盖区域颜色 (默认：[UIColor blackColor])
  
        _camera.regionViewColor = [UIColor blackColor];
* 禁用前置摄像头自动水平镜像 (默认: NO，前置摄像头拍摄结果自动进行水平镜像)
  
        _camera.disableMirrorFrontFacing = NO;
* 闪光灯模式（默认是关闭:AVCaptureFlashModeOff）
        
        [_camera flashWithMode:AVCaptureFlashModeOff];
* 相机采集帧率，默认20帧; 开启智能贴纸时，帧率建议范围：12 ~ 20;  关闭智能贴纸时，帧率建议范围：12 ~ 30
  
        _camera.frameRate = 30;
* 不保存到相册，可在代理方法中获取 result.videoPath（默认：YES，录制完成自动保存到相册）
        
        _camera.saveToAlbum = NO;
        
* 保存到指定相册（需要将 saveToAlbum 置为 YES 后生效）

        _camera.saveToAlbumName = @"TuSDK";

* 启用智能贴纸
        
        _camera.enableFaceAutoBeauty = YES;
* 设置图片水印，默认为空
  
        _camera.waterMarkImage = [UIImage imageNamed:@"sample.png"];
* 设置水印图片的位置
  
        _camera.waterMarkPosition = lsqWaterMarkBottomRight;
* 最大录制时长 8s
  
        _camera.maxRecordingTime = 8;
* 最小录制时长 2s
  
        _camera.minRecordingTime = 2;
* 续拍模式（若沿用 demo 示例 UI 相机和底部栏的 recordMode 配置，需要保持一致）
  
        _camera.recordMode = lsqRecordModeKeep;
* 设置默认滤镜（若沿用 demo 示例 UI，filterView 初始化设置 currentFilterTag 需要对应，可参考「自定义使用7」）
  
        [_camera switchFilterWithCode:_videoFilters[1]];
* 设置使用录制相机最小空间限制,开发者可根据需要自行设置（单位：字节 默认：50M）
  
        _camera.minAvailableSpaceBytes  = 1024.f*1024.f*50.f;        
* 启动相机
       
        [_camera tryStartCameraCapture];

* 初始化相机时，以下几点需要注意
* _camera.outputSize 和 _camera.videoQuality，影响保存视频的文件大小。
* Demo 默认设置 outputSize 尺寸 CGSizeMake(640, 640)，需要设置为 16 的倍数。

#### 2.5 预览画面位置位置调整

* _camera.regionHandler 是用来调整预览画面距离顶端距离
* 如果采用全屏录制需要将相机配置参数中的代码注释掉，代码如下

  
        _camera.regionHandler = [[CustomTuSDKCPRegionDefaultHandler alloc]init];
  
* 需要设置预览画面距离顶端的距离， SDK 会自动调整预览画面位置

        /**
         *  选区范围百分比
         */
        - (CGRect)rectPercent;
        {
            // 设置距离屏幕顶部的距离
            NSUInteger topBarHeight = 74;
            CGRect rect = [UIScreen mainScreen].bounds;
            return CGRectMake(0, topBarHeight/rect.size.height, 1.0, (rect.size.width)/rect.size.height);
        }
  

#### 2.6 滤镜的使用

* 直播相机初始化前需要配置滤镜列表
* 引入头文件 #import "FilterView.h"
* Demo 提供使用范例，用户可根据接口自定义修改相关使用。

  
        // 滤镜列表，获取滤镜前往 TuSDK.bundle/others/lsq_tusdk_configs.json  
        // TuSDK 滤镜信息介绍 @see-https://tusdk.com/docs/ios/self-customize-filter
        _videoFilters = @[@"Normal",@"VideoFair", @"VideoWhiteSkin"];
  

* 初始化滤镜栏

        _filterView = [[FilterView alloc]initWithFrame:CGRectMake(0, (_bottomBackView.lsqGetSizeHeight - filterViewHeight)/2, self.view.lsqGetSizeWidth, filterViewHeight)];
        _filterView.canAdjustParameter = true;
        _filterView.filterEventDelegate = self;
        // 应与 相机初始化加载的默认滤镜所 对应的下标保持一致
        _filterView.currentFilterTag = 201;
        _filterView.backgroundColor = [UIColor whiteColor];
        [_filterView createFilterWith:_videoFilters];
        [_filterView refreshAdjustParameterViewWith:_currentFilter.code filterArgs:_currentFilter.filterParameter.args];
        
        [_bottomBackView addSubview:_filterView];

* 遵守代理 FilterViewEventDelegate，实现代理方法。

        #pragma mark -- 滤镜栏点击代理方法 FilterEventDelegate
        - (void)filterViewParamChangedWith:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress{
            //根据tag获得当前滤镜的对应参数，修改precent;
            NSInteger index = seekbar.tag;
            TuSDKFilterArg *arg = _currentFilter.filterParameter.args[index];
            arg.precent = progress;
            //设置滤镜参数；
            [_currentFilter submitParameter];
        }
        // 启动后默认选择滤镜，请参考「自定义使用7」
  
* 切换滤镜

        - (void)filterViewSwitchFilterWithCode:(NSString *)filterCode{
            //切换滤镜
            [_camera switchFilterWithCode:filterCode];
        }

        // 相机调用 switchFilterWithCode 之后的回调方法
        /**
         *  相机滤镜改变 (如需操作UI线程， 请检查当前线程是否为主线程)
         *
         *  @param camera    相机对象
         *  @param newFilter 新的滤镜对象
         */
        - (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera filterChanged:(TuSDKFilterWrap *)newFilter;
        {
            //赋值新滤镜 同事刷新新滤镜的参数配置；
            _currentFilter = newFilter;
            [_filterView refreshAdjustParameterViewWith:newFilter.code filterArgs:newFilter.filterParameter.args];
        }

#### 2.7 动态贴纸的使用

* 引入头文件 #import "StickerScrollView.h"
* Demo 提供使用范例，用户可根据接口自定义修改相关使用。
* 使用非标准版直播服务，请跳过该部分介绍
* 初始化贴纸栏

        CGFloat stickerViewHeight = _bottomBackView.lsqGetSizeHeight - 10;
        _stickerView = [[StickerScrollView alloc]initWithFrame:CGRectMake(0, (_bottomBackView.lsqGetSizeHeight - stickerViewHeight), self.view.lsqGetSizeWidth, stickerViewHeight)];
        _stickerView.stickerDelegate = self;
        _stickerView.backgroundColor = [UIColor whiteColor];
        [_bottomBackView addSubview:_stickerView];
  

* 遵守代理 StickerViewClickDelegate，实现代理方法。

        #pragma mark -- 贴纸栏点击代理方法 StickerViewClickDelegate
        - (void)clickStickerViewWith:(TuSDKPFStickerGroup *)stickGroup{
            if (!stickGroup) {
                //为nil时 移除已有贴纸组；
                [_camera removeAllLiveSticker];
                return;
            }
            //展示对应贴纸组；
            [_camera showGroupSticker:stickGroup];
        }
  

#### 2.8 录制完成

    #pragma mark -- 录制相关代理方法 TuSDKVideoCameraDelegate
    /**
     *  视频录制完成
     *
     *  @param camerea 相机
     *  @param result  TuSDKVideoResult 对象
     */
    - (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea result:(TuSDKVideoResult *)result;
    {
        // 通过相机初始化设置  _camera.saveToAlbum = NO;  result.videoPath 拿到视频的临时文件路径
        NSLog(@"TuSDK complete %@",result.videoPath);
        if (result.videoPath) {
            // 进行自定义操作，例如保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
            [[TuSDK shared].messageHub showSuccess:LSQString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
        }else{
            // _camera.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
            [[TuSDK shared].messageHub showSuccess:LSQString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
        }
        
        // 引入头文件 #import "MoivePreviewAndCutController.h"
        // result.videoPath 转换格式
        // NSURL *inputURL = [NSURL fileURLWithPath:result.videoPath];
        // MoivePreviewAndCutController *vc = [MoivePreviewAndCutController new];
        // vc.inputURL = inputURL;
        // [self pushViewController:vc animated:YES];
    }
  

* `saveToAlbum`置为 YES，在录制达到最大时长或中途保存后，会自动保存到相册中。
* `saveToAlbum`置为 NO，在录制达到最大时长或中途保存后，会通过 result.videoPath 获取到对应视频的临时文件，可进行自定义操作。

#### 2.9 录制出现错误
* 录制出现错误

        /**
         *  视频录制出错
         *
         *  @param camerea 相机
         *  @param error   错误对象
         */
        - (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea failedWithError:(NSError*)error;
        {
            if (error.code == lsqRecordVideoErrorUnknow) {
                NSLog(@"录制失败：未知原因失败");
            }else if (error.code == lsqRecordVideoErrorSaveFailed){
                // 取消录制 同时 重置UI
                [self resetRecordUI];
                [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_failed", @"录制失败")];
                NSLog(@"录制失败：保存视频失败");
            }else if (error.code == lsqRecordVideoErrorLessMinDuration){
                NSLog(@"录制失败：小于最小时长");
            }else if (error.code == lsqRecordVideoErrorMoreMaxDuration){
                NSLog(@"录制失败：大于最大时长 请保存视频后继续录制");
                [[TuSDK shared].messageHub showError:NSLocalizedString(@"lsq_record_moreMaxDuration", @"大于最大时长，请保存视频后继续录制")];
            }else if (error.code == lsqRecordVideoErrorNotEnoughSpace){
                NSLog(@"手机可用空间不足，请清理手机");
            }
        }


### 2.10 录制状态

* 录制操作过程中的状态改变

        /**
         录制状态
        
         @param camerea camerea TuSDKRecordVideoCamera
         @param state state lsqRecordState
         */
        - (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea recordStateChanged:(lsqRecordState)state;
        {
            
            if (state == lsqRecordStateRecordingCompleted) {
            [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_record_complete", @"录制完成")];                       
           }else if (state == lsqRecordStateRecording){
            }else if (state == lsqRecordStatePaused){
                // 暂停录制
            }else if (state == lsqRecordStateMerging){
                // 正在合成视频
            }else if (state == lsqRecordStateCanceled){
                // 取消录制 
            }else if (state == lsqRecordStateSaveing){
                // 正在保存
            }
        }
        
### 3.视频编辑

#### 3.1 导入视频
* SDK 目前采用了系统的图片选择器 `UIImagePickerController`
* 并在对应的代理方法中将选择好的视频地址传给`裁剪编辑器`

  
        #pragma mark - UIImagePickerControllerDelegate
        - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
        {
            [picker dismissViewControllerAnimated:NO completion:^{
                NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
                
                [self openMovieEditor:url];
            }];
        }
  
#### 3.2 视频裁剪功能

* 裁剪功能控制器 `MoivePreviewAndCutController`
* 开启控制器需要传入一个视频的相册地址

  
        // 视频URL
        @property (nonatomic) NSURL *inputURL;
 
* 用户可以选择在完成录制之后，直接开启视频裁剪的控制器
* 录制完成后可以获取到 `result.videoPath`,经过转换后传输给裁剪控制器

        NSURL *inputURL = [NSURL fileURLWithPath:result.videoPath];
   
* 获取视频裁剪栏缩略图，用于裁剪栏的展示

        // 获取视频缩略图
        __weak MoivePreviewAndCutController * wSelf = self;
        TuSDKVideoImageExtractor *imageExtractor = [TuSDKVideoImageExtractor createExtractor];
        imageExtractor.videoPath = wSelf.inputURL;
        // 设置返回展示缩略图的数量，默认设置为 10，否则缩略图过少无法铺满整个裁剪栏
        imageExtractor.extractFrameCount = 10;
        [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
            NSLog(@"get images = %@",images);
            wSelf.cutVideoView.thumbnails = images;
        }];
        
* 裁剪控制器并未对视频本身进行裁剪，而是获取到需要裁剪的时间，以待后续处理。 
* TuSDKVideoImageExtractor 可用于获取视频的缩略图，例如返回视频首帧画面作为展示封面。

#### 3.3 视频编辑功能

* 视频裁剪完成后，获取到对应的裁剪的时间段后会开启 `MovieEditorViewController`
* 开启后，会将裁剪的时间范围和视频的地址，传输到视频编辑的控制器

        MovieEditorViewController *vc = [MovieEditorViewController new];
        vc.inputURL = _inputURL;
        vc.startTime = _startTime;
        vc.endTime = _endTime;
        [self pushViewController:vc animated:true];
            
#### 3.4 视频编辑控制器配置项

* 遵守代理 `TuSDKMovieEditorDelegate`
* 初始化视频编辑的参数设置
    
        TuSDKMovieEditorOptions *options = [TuSDKMovieEditorOptions defaultOptions];
* 设置视频的 inoutURL 地址
    
        options.inputURL = self.inputURL;
* 设置视频截取范围
    
        options.cutTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_startTime endSeconds:_endTime];
* 是否按照正常速度播放
    
        options.playAtActualSpeed = YES;
* 设置裁剪范围 注：该参数对应的值均为比例值，即：若视频展示View总高度800，此时截取时y从200开始，则cropRect的 originY = 偏移位置/总高度， 应为 0.25, 其余三个值同理
    
        options.cropRect = _cropRect;
* 设置编码视频的画质
    
        options.encodeVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_High1];
* 是否保留视频原音（置为 NO，视频中的原因就被去除）
    
        options.enableVideoSound = YES;

* 初始化视频编辑器

        _movieEditor = [[TuSDKMovieEditor alloc]initWithPreview:_videoView options:options];
* 遵守代理
    
        _movieEditor.delegate = self;
    
* 贴纸出现的默认时间范围（1.7.0 之后已不再使用）
 
        /*设置贴纸出现的默认时间范围 （开始时间~结束时间，注：基于裁剪范围，如原视频8秒，裁剪第2~第7秒的内容，此时贴纸时间范围为1~2，即原视频的第3~第4秒展示贴纸）
         */
        // _movieEditor.mvItemTimeRange = [[TuSDKMVEffectData alloc]initEffectInfoWithStart:_mvStartTime end:_mvEndTime type:lsqMVEffectDataTypeStickerAudio];
    
* 保存到系统相册 默认为YES
  
        _movieEditor.saveToAlbum = NO;
        
* 保存到指定相册（需要将 saveToAlbum 置为 YES后生效）

        _movieEditor.saveToAlbumName = @"TuSDK";
        
* 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
  
        _movieEditor.fileType = lsqFileTypeMPEG4;

* 是否开启美颜
  
        _movieEditor.enableBeauty = YES;
* 设置水印，默认为空
  
        _movieEditor.waterMarkImage = [UIImage imageNamed:@"sample_watermark.png"];
* 设置水印图片的位置
  
        _movieEditor.waterMarkPosition = lsqWaterMarkTopRight;
* 视频播放音量设置，0 ~ 1.0 仅在 enableVideoSound 为 YES 时有效
  
        _movieEditor.videoSoundVolume = 0.8;
* 设置默认镜
  
        [_movieEditor switchFilterWithCode:_videoFilters[1]];
* 加载视频，显示第一帧
  
        [_movieEditor loadVideo];
       


#### 3.5 视频编辑完成

    #pragma mark - 视频播放的代理方法 TuSDKMovieEditorDelegate
    // 视频保存完成
    - (void)onMovieEditor:(TuSDKMovieEditor *)editor result:(TuSDKVideoResult *)result
    {
        //保存成功后取消提示框 同时返回到root
        // 通过相机初始化设置  _movieEditor.saveToAlbum = NO;  result.videoPath 拿到视频的临时文件路径
        NSLog(@"视频保存的临时文件路径：%@",result.videoPath);
        if (result.videoPath) {
            // 进行自定义操作，例如保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
            [[TuSDK shared].messageHub showSuccess:LSQString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
        }else{
            // _movieEditor.saveToAlbum = YES;（默认为 ：YES）将自动保存到相册
            [[TuSDK shared].messageHub showSuccess:LSQString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
        }
    }

#### 3.6 录制状态改变

    #pragma mark - 视频播放的代理方法 TuSDKMovieEditorDelegate
    // 视频处理状态改变
    - (void)onMovieEditor:(TuSDKMovieEditor *)editor statusChanged:(lsqMovieEditorStatus)status
    {
        if (status == lsqMovieEditorStatusLoadFailed) {
            lsqLDebug(@"加载失败");
        }else if (status == lsqMovieEditorStatusPreviewingCompleted){
        }
    }
    
#### 3.7 视频编辑滤镜使用

* 直播相机初始化前需要配置滤镜列表
* 引入头文件 #import "FilterView.h"
* Demo 提供使用范例，用户可根据接口自定义修改相关使用。

        // 滤镜列表，获取滤镜前往 TuSDK.bundle/others/lsq_tusdk_configs.json  
        // TuSDK 滤镜信息介绍 @see-https://tusdk.com/docs/ios/self-customize-filter
        _videoFilters = @[@"Normal", @"DeepWhitening",@"WarmSunshine", @"Leica", @"Newborn", @"Morning",@"VideoYoungGirl", @"VideoJelly", @"AmericaPast", @"SkinSugar"];
  

* 初始化滤镜栏

        // 底部滤镜控制栏
        _filterView = [[FilterView alloc]initWithFrame:CGRectMake(0, rect.size.width + 61, rect.size.width , rect.size.height - rect.size.width - 61)];
        _filterView.canAdjustParameter = true;
        _filterView.filterEventDelegate = self;
        [_filterView setBackgroundColor:[UIColor whiteColor]];
        [_filterView createFilterWith:_videoFilters];
        [self.view addSubview:_filterView];

* 遵守代理 `FilterViewEventDelegate`，实现代理方法。

        #pragma mark - 滤镜View代理方法 FilterViewEventDelegate
        // 改变滤镜参数
        - (void)filterViewParamChangedWith:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress
        {
            // 调整滤镜参数 根据tag判断是当前滤镜的哪一个参数
            NSInteger index = seekbar.tag;
            TuSDKFilterArg *arg = _currentFilter.filterParameter.args[index];
            arg.precent = progress;
            [_currentFilter submitParameter];
        }

* 切换滤镜

        - (void)filterViewSwitchFilterWithCode:(NSString *)filterCode
        {
            // 更换滤镜
            [_movieEditor switchFilterWithCode:filterCode];
        }
        // 视频编辑器 switchFilterWithCode 调用之后的回调方法
        // 滤镜改变方法
        - (void)onMovieEditor:(TuSDKMovieEditor *)editor filterChanged:(TuSDKFilterWrap *)newFilter
        {
            _currentFilter = newFilter;
            [_filterView refreshAdjustParameterViewWith:newFilter.code filterArgs:newFilter.filterParameter.args];
        }


### 4. UI 自定义

* 用户可根据自身需求修改 UI 和交互，demo/source/view 中包含了 UI 部分的代码。
* Demo 提供了 UI 设计和界面交互，用户可以直接启动对应控制器调用相关功能。 


### 5.自定义使用

* 1.如果用户需求调整滤镜效果，效果确认完毕后，用户需要在控制台重新打包下载资源文件，然后替换到对应位置。`参考 framework 安装 第 5 步`。
* 2.如果用户工程已使用 `GPUImage` 的部分功能，建议用户使用 Github 提供的 [完整版GPUImage](https://github.com/BradLarson/GPUImage/archive/master.zip) 。如果在使用完整版 GPUImage 的过程中有什么问题，可以参考文档[GPUImage 的相关错误](http://tusdk.com/docs/ios-faq/gpuimage-use)。
* 3.用户可以在 TuSDK.bundle/others/config.json 文件中查看自己的滤镜资源 `"name":"lsq_filter_VideoFair"`，`VideoFair ` 就是该滤镜的filterCode ，在`_videoFilters = @[@"VideoFair"];` 可以进行选择使用滤镜的设置。
* 4.录制相机进行全屏录制需要进行以下设置

        // 不启动相机预览画面区域显示算法，注释掉该行代码
        // _camera.regionHandler = [[CustomTuSDKCPRegionDefaultHandler alloc]init];
        // 比例设置为 1.0 ，预览画面为 1:1 方形画幅。
        // 比例设置为 0，预览画面为全屏画幅
        _camera.cameraViewRatio = 0;
        // 最终输出的视频尺寸由 outputSize 控制
        // 需要将输出尺寸修改为均为 16 的倍数
        // _camera.outputSize = CGSizeMake(640, 640);
        
* 5.录制相机控制输出的文件大小

        // 输出视频的画质，主要包含码率、分辨率等参数 (默认为空，采用系统设置)
        _camera.videoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_Low1];
        // 可以进行输出视频文件的码率自定义，配置参数请参考 TuSDKVideo/TuSDKVideoQuality.h
        TuSDKVideoQuality *customVideoQuality = [[TuSDKVideoQuality alloc]init];
        customVideoQuality.lsqVideoBitRate = 1200 * 1000;
        _camera.videoQuality = customVideoQuality;
        
* 6.录制相机的模式切换

        // 需要配置相机的录制模式，如果沿用 demo 提供的示例 UI，需要同时配置底部栏的 recordMode
        /**
            录制模式
         */
        typedef NS_ENUM(NSInteger,lsqRecordMode)
        {
            /** 正常模式 */
            lsqRecordModeNormal,
            /** 续拍模式 */
            lsqRecordModeKeep,
        };
        _camera.recordMode = _inputRecordMode;
        _bottomBar.recordMode = _inputRecordMode;
        // 拍照录制相机的录制模式为正常模式
        
* 7.录制相机初始化，默认选择一款滤镜

        // 需要配置相机的默认选择滤镜，如果沿用 demo 提供的示例 UI ，需要同时配置滤镜栏的默认滤镜
        // 设置默认滤镜  对应filterView创建时默认的 currentFilterTag 和相机保持一致
        [_camera switchFilterWithCode:_videoFilters[1]];
        // 注： currentFilterTag 基于200 即：200 + 滤镜列表中某滤镜的对应下标
        _filterView.currentFilterTag = 201;

* 8.MoviePreviewAndCutViewController 全屏/视频比例自适应展示设置

        // 可以设置全屏/视频比例自适应展示，如果沿用 demo 提供的示例 UI ，需要进行以下更改
        // 需要将控制器内 - (void)initPlayerView 方法中的部分代码注释
        // _videoScroll 和 _videoView 默认是 frame 为屏幕宽度的 1：1 区域
        // 设置全屏展示时，需要将两者的 frame 设置为屏幕宽高，如不设置将视频按照比例自适应展示。
        // 调整其他控件的背景色的 alpha 值，以防止遮挡视觉效果
        // 需要注释代码如下
           /*
            AVAssetTrack *videoTrack = [_item.asset tracksWithMediaType:AVMediaTypeVideo][0];
            CGSize videoSize = videoTrack.naturalSize;
            // 根据朝向判断是否需要交换宽高
            CGAffineTransform transform = videoTrack.preferredTransform;
            BOOL isNeedSwopWH = NO;
            if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
                // Right
                isNeedSwopWH = YES;
            }else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0){
                // Left
                isNeedSwopWH = YES;
            }else if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0){
                // Down
                isNeedSwopWH = NO;
            }else{
                // Up
                isNeedSwopWH = NO;
            }
            if (isNeedSwopWH) {
                // 交换宽高
                videoSize = CGSizeMake(videoSize.height, videoSize.width);
            }
            // 如需比例自适应，需要注释下方代码块
            // 此处的宽高计算仅适用于 1：1 情况下，若有其他的适配，请重新修改计算方案
            if (videoSize.width > videoSize.height) {
                // 定高适配宽
                CGSize newSize = CGSizeMake(_videoView.lsqGetSizeHeight*videoSize.width/videoSize.height, _videoView.lsqGetSizeHeight);
                CGFloat offset = (newSize.width - _videoView.lsqGetSizeWidth)/2;
                [_videoView lsqSetSize:newSize];
                _videoScroll.contentSize = newSize;
                _videoScroll.contentOffset = CGPointMake(offset, 0);
            }else{
                // 定宽适配高
                CGSize newSize = CGSizeMake(_videoView.lsqGetSizeWidth, _videoView.lsqGetSizeWidth*videoSize.height/videoSize.width);
                CGFloat offset = (newSize.height - _videoView.lsqGetSizeHeight)/2;
                [_videoView lsqSetSize:newSize];
                _videoScroll.contentSize = newSize;
                _videoScroll.contentOffset = CGPointMake(0, offset);
            }
            */

* 9.MovieEditorViewController 全屏/视频比例自适应展示设置

        // 可以设置全屏/视频比例自适应展示，如果沿用 demo 提供的示例 UI ，需要进行以下更改
        // 启动时候需要设置参数如下
        MovieEditorFullScreenController *vc = [MovieEditorFullScreenController new];
        vc.inputURL = _inputURL;
        vc.startTime = _startTime;
        vc.endTime = _endTime;
        vc.cropRect = CGRectMake(0, 0, 0, 0);
        // 同时将控制器内 - (void)lsqInitView 中视频展示 _previewView 的 frame 设置为屏幕宽高，画面即为全屏展示
        // 如不设置 _previewView 的 frame 将进行视频比例的自适应的展示
        // 调整其他控件的背景色的 alpha 值，以防止遮挡视觉效果
        
* 10.拍照录制相机/断点续拍相机，连接其他控制器使用

        // 拍照录制相机连接视频编辑功能，需要进行一些调整
        -(void)viewWillDisappear:(BOOL)animated
        {
            [super viewWillDisappear:animated];
            // 进行页面跳转需要注释销毁相机的代码
            // 相机页面销毁的时候,不要忘记销毁相机
            // [self destroyCamera];
            [self destroyVideoPlayer];
        }
        
        // 在保存照片或录制的视频的方法中，进行相关控制器的开启
        - (void)savePictureOrVideo
        {
            if (!_takePictureIV.hidden) {
                // 保存照片
                [TuSDKTSAssetsManager saveWithImage:_takePictureIV.image compress:0 metadata:nil toAblum:nil completionBlock:^(id<TuSDKTSAssetInterface> asset, NSError *error) {
                    if (!error) {
                        _takePictureIV.image = nil;
                        _takePictureIV.hidden = YES;
                        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
                    }
                } ablumCompletionBlock:nil];
                
            }
            if (_videoPlayer && _videoPath) {
                // 保存视频，同时删除临时文件
                [TuSDKTSAssetsManager saveWithVideo:[NSURL fileURLWithPath:_videoPath] toAblum:nil completionBlock:^(id<TuSDKTSAssetInterface> asset, NSError *error) {
                    if (!error) {
                        // 需要注释销毁临时文件的方法
                        // 相机最终销毁的时候，不要忘记将临时文件删除
                        // [TuSDKTSFileManager deletePath:_videoPath];
                        // _videoPath = nil;
                        [self destroyVideoPlayer];
                        // [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
                    }
                } ablumCompletionBlock:nil];
                // 开启时间裁剪
                MoviePreviewAndCutRatioAdaptedController *vc = [MoviePreviewAndCutRatioAdaptedController new];
                vc.inputURL = [NSURL fileURLWithPath:_videoPath];
                [self.navigationController pushViewController:vc animated:YES];
            }
            _preView.hidden = YES;
        }

* 11.断点续拍相机，连接其他控制器使用

        // 断点续拍相机连接视频编辑功能，需要进行一些调整
        -(void)viewWillDisappear:(BOOL)animated
        {
            [super viewWillDisappear:animated];
            // 进行页面跳转的时候，需要注释下方销毁相机的方法。
            // 相机页面销毁，不要忘记销毁相机
            // [self destroyCamera];
        }
        // 在视频录制完成的代理方法中，进行相关控制器的开启
        - (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea result:(TuSDKVideoResult *)result;
        {
            // 通过相机初始化设置  _camera.saveToAlbum = NO;  result.videoPath 拿到视频的临时文件路径
            if (result.videoPath) {
                // 进行自定义操作，例如保存到相册
                // UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
                // [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
                // 开启视频编辑添加滤镜
                MovieEditorFullScreenController *vc = [MovieEditorFullScreenController new];
                vc.inputURL = [NSURL fileURLWithPath:result.videoPath];
                // 视频编辑如需全屏展示，参数需要设置 vc.cropRect = CGRectMake(0, 0, 0, 0); 画面展示会进行比例自适应
                vc.cropRect = CGRectMake(0, 0, 0, 0);
                vc.startTime = 0;
                vc.endTime = result.duration;
                [self.navigationController pushViewController:vc animated:true];
            }else{
                // _camera.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
                [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
            }
            
            if (_camera && _camera.recordMode == lsqRecordModeNormal) {
                [_bottomBar recordBtnIsRecordingStatu:NO];
            }
            // 自动保存后设置为 恢复进度条状态
            [self changeNodeViewWithLocation:0];
        }

* 12.获取到视频的临时文件后，需要保存到指定的相册

        // 录制完成后，拿到临时文件地址可通过以下方法，保存到指定位置
            if (_videoPlayer && _videoPath) {
                // 保存视频，同时删除临时文件
                [TuSDKTSAssetsManager saveWithVideo:[NSURL fileURLWithPath:_videoPath] toAblum:@"自定义相册" completionBlock:^(id<TuSDKTSAssetInterface> asset, NSError *error) {
                    if (!error) {
                        // 删除临时文件地址
                        [TuSDKTSFileManager deletePath:_videoPath];
                        _videoPath = nil;
                    }
                } ablumCompletionBlock:nil];
            } 

### API 使用示例
* API 使用示例具体使用，参考「VideoDemo」- 「API」文件夹内组件范例

#### 多音轨混合

* 遵守代理 *TuSDKTSAudioMixerDelegate*
* 获取音频文件地址

        NSURL *mainAudioURL = [self filePathName:@"sound_cat.mp3"];
* 创建音频数据对象

        mainAudio = [[TuSDKTSAudio alloc]initWithAudioURL:mainAudioURL];
* 设置音频对象的混合输出的音量大小（demo 为了展示将初始化设置为 0，最终输出是在 seekBar 代理方法中重新赋值）

        mainAudio.audioVolume = 0;
* 设置需要裁剪的时间范围

        mainAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:6];
    
* 音乐素材1   

        NSURL *firstMixAudioURL = [self filePathName:@"sound_children.mp3"];
        firstMixAudio = [[TuSDKTSAudio alloc]initWithAudioURL:firstMixAudioURL];
        firstMixAudio.audioVolume = 0;
        firstMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:3];
    
* 音乐素材2
    
        NSURL *secondMixAudioURL = [self filePathName:@"sound_tangyuan.mp3"];
        secondMixAudio = [[TuSDKTSAudio alloc]initWithAudioURL:secondMixAudioURL];
        secondMixAudio.audioVolume = 0;
        secondMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:3];
    
* 初始化音乐混合器对象，并设置相关参数

        _audiomixer = [[TuSDKTSAudioMixer alloc]init];
* 遵守代理
    
        _audiomixer.mixDelegate = self;
* 设置主音轨
  
        _audiomixer.mainAudio = mainAudio;
* 是否允许素材循环添加 (默认 NO，即主音轨时长 9 秒，音乐素材时长 3 秒，音乐素材将会循环添加三次)
  
        _audiomixer.enableCycleAdd = YES;
* 音频混合的点击事件
    
        _audiomixer.mixAudios = [NSArray arrayWithObjects:firstMixAudio, secondMixAudio,nil];
        [_audiomixer startMixingAudioWithCompletion:^(NSURL *fileURL, lsqAudioMixStatus status) {
            _resultURL = fileURL;
        }];


#### 音视频混合
* 遵守代理 *TuSDKTSMovieMixerDelegate*
* 获取背景音乐素材地址

        NSURL *firstAudioURL = [self filePathName:@"sound_cat.mp3"];
* 转换为 *AVURLAsset* 对象
 
        AVURLAsset *firstMixAudioAsset = [AVURLAsset URLAssetWithURL:firstAudioURL options:nil];
* 构建音频数据对象
    
        firstMixAudio = [[TuSDKTSAudio alloc]initWithAsset:firstMixAudioAsset];
* 设置添加音乐素材的时间范围
    
        firstMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:1 endSeconds:6];

* 获取另一段背景音乐素材地址
   
        NSURL *secondAudioURL = [self filePathName:@"sound_children.mp3"];
        // 同样可以使用 URL 地址进行初始化
        secondMixAudio = [[TuSDKTSAudio alloc]initWithAudioURL:secondAudioURL];
        secondMixAudio.atTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:1 endSeconds:6];
    
* 获取视频素材地址

        NSURL *videoURL = [self filePathName:@"tusdk_sample_video.mov"];
* 初始化音视频混合器的对象

        movieMixer = [[TuSDKTSMovieMixer alloc]initWithMoviePath:videoURL.path];
* 遵守代理    
    
        movieMixer.mixDelegate = self;
* 是否允许音频循环（ 默认 NO，即视频素材时长 9 秒，音频素材 3 秒，将音频素材循环添加三次）
    
        movieMixer.enableCycleAdd = YES;
* 混合时视频的选中时间
  
        movieMixer.videoTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:1 endSeconds:20];       

* 是否保留视频原音
    
        movieMixer.enableVideoSound = NO;
* 将背景音乐素材赋值给音视频混合器

        movieMixer.mixAudios = [NSArray arrayWithObjects:firstMixAudio, secondMixAudio, nil];
* 进行混合
   
        [movieMixer startMovieMixWithCompletionHandler:^(NSString *filePath, lsqMovieMixStatus status) {
            if (status == lsqMovieMixStatusCompleted) {
                // 操作成功 保存到相册
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
            }else{
                // 提示失败
                NSLog(@"保存失败");
            }
        }];

#### 获取视频缩略视图
* 获取视频的地址

        NSURL *videoURL  = [self filePathName:@"tusdk_sample_video.mov"];
* 初始化视频画面提取的工具类
    
        imageExtractor = [TuSDKVideoImageExtractor createExtractor];
* 将视频地址赋值给对象
    
        imageExtractor.videoPath = videoURL;
* 设置需要返回的缩略图的数量
    
        imageExtractor.extractFrameCount = 15;
* 需要输出缩略图的最大尺寸,(默认设置 ： 80 * 80 )
    
        imageExtractor.outputMaxImageSize = CGSizeMake(100, 100);
* 返回 NSArray<UIImage *>，数组中即为视频的缩略图   
    
        [imageExtractor asyncExtractImageList:^(NSArray<UIImage *> * images) {
        // 获取到返回的视频的缩率图
        thumbnailsArr =  images;
        }];
    
#### 多视频拼接
* 遵守代理 *TuSDKMovieSplicerDelegate*
* 初始化视频合成器

        _movieSplicer = [TuSDKTSMovieSplicer createSplicer];

* 遵守代理
        _movieSplicer.splicerDelegate = self;

* 获取视频素材的地址
    
        NSURL *sampleOneURL = [self filePathName:@"tusdk_sample_splice_video.mov"];
        NSURL *sampleTwoURL = [self filePathName:@"tusdk_sample_video.mov"];
    
* 将视频素材的地址赋值给 TuSDKMoiveFragment，并设置拼接部分的时间范围
    
        NSString *moviePath1 = sampleOneURL.path;
        TuSDKTimeRange *timeRange1 = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:8];
        TuSDKMoiveFragment *fragment1 = [[TuSDKMoiveFragment alloc]initWithMoviePath:moviePath1 atTimeRange:timeRange1];
        
        NSString *moviePath2 = sampleTwoURL.path;
        TuSDKTimeRange *timeRange2 = [TuSDKTimeRange makeTimeRangeWithStartSeconds:10 endSeconds:14];
        TuSDKMoiveFragment *fragment2 = [[TuSDKMoiveFragment alloc]initWithMoviePath:moviePath2 atTimeRange:timeRange2];

* 将赋值过得拼接片段添加到对应的数组中    
    
        _movieSplicer.movies = [NSArray arrayWithObjects:fragment1, fragment2, nil];
    
* 将多段视频片段合并为一个视频
    
        [_movieSplicer startSplicingWithCompletionHandler:^(NSString *filePath, lsqMovieSplicerSessionStatus status) {
        if (status == lsqMovieSplicerSessionStatusCompleted){
            // 操作成功 保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
        }else if(status == lsqMovieSplicerSessionStatusFailed || status == lsqMovieSplicerSessionStatusCancelled || status == lsqMovieSplicerSessionStatusUnknown){
            // 其他操作
        }
        }];

#### 视频时间范围裁剪
* 遵守代理 *TuSDKMovieClipperDelegate*
* 创建「开始时间」和「结束时间」

        NSMutableArray *dropArr = [[NSMutableArray alloc]init];
        if (_startTime >= 0) {
            TuSDKTimeRange *cutTimeRange1 = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:_startTime];
            [dropArr addObject:cutTimeRange1];
        }
        if (_endTime < CMTimeGetSeconds(_item.duration)) {
            TuSDKTimeRange *cutTimeRange2 = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_endTime endSeconds:CMTimeGetSeconds(_item.duration)];
            [dropArr addObject:cutTimeRange2];
        }

* 初始化视频裁剪工具，并赋值 inputURL

        _movieClipper =  [[TuSDKMovieClipper alloc] initWithMoviePath:_inputURL.path];
* 是否保留视频原音

        _movieClipper.enableVideoSound = YES;
* 遵守代理
        
        _movieClipper.clipDelegate = self;
* 输出视频的文件格式，可输出 MP4
       
        _movieClipper.outputFileType = lsqFileTypeQuickTimeMovie;
   
* 将时间范围的数组赋值给视频裁剪工具

        _movieClipper.dropTimeRangeArr = dropArr;

* 进行视频裁剪

        [_movieClipper startClippingWithCompletionHandler:^(NSString *outputFilePath, lsqMovieClipperSessionStatus status) {
        if (status == lsqMovieClipperSessionStatusCompleted){
            // 操作成功 保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(outputFilePath, nil, nil, nil);
        }else if(status == lsqMovieClipperSessionStatusFailed || status == lsqMovieClipperSessionStatusCancelled || status == lsqMovieClipperSessionStatusUnknown){
            
        }
        }];

#### 音频录制

* 遵守代理 *TuSDKTSAudioRecoderDelegate*
* 初始化录音机

        _audioRecorder = [[TuSDKTSAudioRecorder alloc]init];
* 设置可以录制的最大时长

        _audioRecorder.maxRecordingTime = 30;
* 遵守代理

        _audioRecorder.recordDelegate = self;
* 开始录音
        
        [_audioRecorder startRecording];
* 暂停录音（暂停后，再次调用 startRecording，会从暂停处继续录制）

        [_audioRecorder pauseRecording];
        
* 结束录音 （停止录音，并保存输出音频的临时文件地址）

        [_audioRecorder finishRecording];
* 取消录音 （停止录音，删除已录制的音频临时文件）
    
        [_audioRecorder cancelRecording];
* 获取保存文件的地址

        /**
         结果通知代理
        
         @param recoder recoder TuSDKTSAudioRecorder
         @param result result TuSDKAudioResult
         */
        - (void)onAudioRecoder:(TuSDKTSAudioRecorder *)recoder result:(TuSDKAudioResult *)result;
        {
            NSLog(@"result   path: %@   duration : %f",result.audioPath,result.duration);
        }

* 录音过程被打断的状态判断

        // 中断开始
        - (void)onAudioRecoderBeginInterruption:(TuSDKTSAudioRecorder *)recoder;
        {
            // 有中断时会取消录制内容 可在此做一些其他操作 如来电中断
        }
        // 中断已结束
        - (void)onAudioRecoderEndInterruption:(TuSDKTSAudioRecorder *)recoder;
        {
            // 中断结束后，可进行恢复操作
        }

<h2 id="2">又拍云短视频上传</h2>

### 使用说明
1. 拖入`UpYunSDK ` 文件夹 
2. 在需要使用的地方 `#import "UPYUNConfig.h"`
3. 在 `AppDelegate.m` 的 `didFinishLaunchingWithOptions` 方法中添加上传的配置 

```
    // 上传 服务名 即 空间  bucket
    [UPYUNConfig sharedInstance].DEFAULT_BUCKET = @"";
    // 上传 操作员的名字
    [UPYUNConfig sharedInstance].OPERATOR_NAME = @"";
    // 上传 操作员的密码
    [UPYUNConfig sharedInstance].OPERATOR_PWD = @"";

```

### 示例代码
* 上传相册中的视频

```

	[picker dismissViewControllerAnimated:NO completion:^{
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];

 		 /// 从相册中上传视频,图片等
 		 /// saveKey 就是文件的保存路径
        NSString *saveKey = [NSString stringWithFormat:@"short_video_lib_test_%d.mp4", arc4random() % 10];
        [[UPYUNConfig sharedInstance] uploadFilePath:url.path saveKey:saveKey success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
            [[TuSDK shared].messageHub showSuccess:@"上传成功"];
            NSLog(@"保存地址。%@", saveKey);
        } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
            
            NSLog(@"上传失败 error：%@", error);
            NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
            NSLog(@"上传失败 message：%@", responseBody);
        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
        }];
        
    }];


```

* 上传编辑完的视频

```
    if (result.videoPath) {

        /// 上传到UPYUN 存储空间
        NSString *saveKey = [NSString stringWithFormat:@"short_video_test_%d.mp4", arc4random() % 10];
        /// 上传操作
        [[UPYUNConfig sharedInstance] uploadFilePath:result.videoPath saveKey:saveKey success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
			/// 注意 bucketname 应该是实际的 bucket 名
            NSLog(@"file url：https://%@.b0.upaiyun.com/%@", @"bucketname", saveKey);
        } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {

            NSLog(@"上传失败 error：%@", error);
            NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
            NSLog(@"上传失败 message：%@", responseBody);
        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
        }];

    }

```




<h2 id="3">又拍云播放器</h2>

#### 功能说明 

* 支持播放网络视频，支持播放本地视频文件。

* 支持视频格式：`FLV`，`mp4` 等视频格式 
	
* 播放器支持单音频流播放，支持 speex 解码，可以配合浏览器 Flex 推流的播放 

* 支持自定义窗口大小和全屏设置

* 支持音量调节，静音设置

* 支持亮度调整

* 支持缓冲大小设置，缓冲进度回调

* 支持自动音画同步调整

### 1.配置环境

#### 1.1 基本介绍

`又拍云` 播放器 `SDK`。功能完备接口简练，可以快速安装使用, 灵活性强可以满足复杂定制需求。

### 2.SDK使用说明

#### 2.1 运行环境和兼容性

`UPLiveSDK.framework` 支持 `iOS 8` 及以上系统版本；     
支持 `ARMv7`，`ARM64` 架构。请使用真机进行开发和测试。     


### 2.2 安装使用说明

	
#### 手动安装：

直接将示例工程源码中 `UPLiveSDK.framework`文件夹拖拽到目标工程目录。

#### 工程设置：     
打开项目 app target，查看 **Build Settings** 中 **Enable bitcode** ,  设置为 `NO`  			

***注: 如果需要 app 退出后台仍然不间断推流直播，需要设置 ```TARGET -> Capabilities -> Backgroud Modes:ON    √ Audio, AirPlay,and Picture in Picture```***	



#### 需要添加工程依赖：

在项目的 app target 中，查看 **Build Phases** 中的 **Linking** - **Link Binary With Libraries** 选项中，手动添加 

`VideoToolbox.framework`

`libbz2.1.0.tbd`

`libiconv.tbd`

`libz.tbd`

`libc++.tbd`



***注: 此 `SDK` 已经包含 `FFMPEG 3.0` , 不建议自行再添加 `FFMPEG` 库 , 如有特殊需求, 请联系我们***   



### 3.播放器使用
#### 3.1 播放器简单调用

使用 ```UPAVPlayer``` 需要引入头文件 ```#import <UPLiveSDKDll/UPAVPlayer.h>```

`UPAVPlayer` 使用接口类似 `AVFoundation` 的 `AVPlayer` 。

```
    //1. 初始化播放器
    _player = [[UPAVPlayer alloc] initWithURL:@"http://uprocess.b0.upaiyun.com/demo/short_video/UPYUN_0.mp4"];
    
    //2. 设置代理，接收状态回调信息
    _player.delegate = self;
    
    //3. 设置播放器 playView Frame
    [_player setFrame:self.view.bounds];
    
    //4. 添加播放器 playView
    [self.view insertSubview:_player.playView atIndex:0];
    
    //5. 开始播放
    [_player play];

    //6. 停止播放
    [_player stop];

```

#### 3.2 播放器配置

* 设置播放缓冲区大小, 单位 秒, 设置为 0 的话, 会缓冲完整视频。

```
	_player.bufferingTime = 5; 

```

* 播放器画面的View

```
	_player.playView;

```

* 缓冲区大小 (0.1s -- 10s) 设置为 0 的话, 会缓冲完整视频
```
	_player.bufferingTime = 5; 
```

* 音量大小 0.0f - 1.0f

```
	_player.volume = 0.5; 
	
```

* 屏幕明亮度 0.0f - 1.0f

```
	_player. bright = 0.5; 

``` 

* 静音控制 默认为 NO

```
	// 静音
	_player.mute = YES; 

``` 

* 视频缓冲超时，单位 秒,  默认 60, 一段时间内未能缓冲到可播放的数据

```
	_player.timeoutForBuffering = 60; 

``` 

* 连接超时，默认 10s  一段时间内无数据传输

```
	_player.timeoutForOpenFile = 10; 

``` 

* 打开视频失败后的重试次数限制，默认 1 次，最大 10 次

```
	_player.maxNumForReopenFile = 1; 

``` 

* 播放器的 delegate
```
	_player.delegate = self; 
```
* 音画同步，默认值 YES

```
	_player.lipSynchOn = YES; 
``` 
* 音视频同步方式, 0:音频向视频同步,视频向标准时间轴同步；1:视频向音频同步，音频按照原采样率连续播放。默认值 为 1。

```
	_player.lipSynchMode = 1; 
``` 

#### 3.3 播放器方法

* 设置画面的frame

	- (void)setFrame:(CGRect)frame;

* 连接方法
	- (void)connect;
* 开始播放
	- (void)play;
* 暂停
	- (void)pause;
* 停止, 会清除播放信息
	- (void)stop;
* 拖拽功能 秒为单位
	- (void)seekToTime:(CGFloat)position;
