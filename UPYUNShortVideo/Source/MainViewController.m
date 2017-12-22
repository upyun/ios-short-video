//
//  MainViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/9.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MainViewController.h"
#import "TuSDKFramework.h"
#import "RecordCameraViewController.h"
#import "ComponentListViewController.h"

#import "UPLivePlayerVC.h"
#import "MoviePreviewAndCutViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


#import "UPRecordSettingVC.h"
#import "UPEditorSettingVC.h"




@interface MainViewController ()<TuSDKFilterManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>




@end

@implementation MainViewController
#pragma mark - 基础配置方法
// 针对 单个VC 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    return YES;
}

// 是否允许旋转 IOS5
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

// 是否允许旋转 IOS6
-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [self setNavigationBarHidden:YES animated:NO];
//    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


#pragma mark - 视图布局方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];   
    // 异步方式初始化滤镜管理器
    // 需要等待滤镜管理器初始化完成，才能使用所有功能
    [TuSDK checkManagerWithDelegate:self];
}


- (void)setupView {

    

    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat mainWith = CGRectGetWidth(rect);
    CGFloat mainHeigth = CGRectGetHeight(rect);
    
    // 背景图
    UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mainWith, 1334.0/750.0*mainWith)];
    backgroundImage.center = self.view.center;
    backgroundImage.image = [UIImage imageNamed:@"homepage@2x"];
    backgroundImage.userInteractionEnabled = YES;
    [self.view addSubview:backgroundImage];
    
    

    
    
    
    NSArray *imageNames = @[@"homepage_video", @"homepage_inport", @"homepage_play"];
    NSArray *buttonNames = @[@"拍摄视频", @"编辑视频", @"播放视频"];
    
    CGFloat btnW = 80;
    
    CGFloat space = (mainWith - 80 * imageNames.count)/4;
    
    CGPoint btnCenter = CGPointMake(btnW/2, btnW/2);
    for (int i = 0; i < imageNames.count; i++) {
        UIButton *itmButton = [[UIButton alloc]initWithFrame:CGRectMake(space + (btnW+space) * i, mainHeigth - btnW - 60, btnW, btnW)];
        

        
        itmButton.backgroundColor = [UIColor whiteColor];
        
        itmButton.layer.masksToBounds = YES;
        itmButton.layer.cornerRadius = 5;
        
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
        imgV.frame = CGRectMake(0, 0, btnW/2, btnW/2);
        imgV.center = CGPointMake(btnCenter.x, btnCenter.y - 10);
        
        [itmButton addSubview:imgV];
        
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnW, 30)];
        title.text = [buttonNames objectAtIndex:i];
        title.textColor = [UIColor colorWithRed:48/255.0 green:188/255.0 blue:241/255.0 alpha:1];
        title.font = [UIFont systemFontOfSize:16];
        title.textAlignment = NSTextAlignmentCenter;
        
        
        title.center = CGPointMake(btnCenter.x, btnCenter.y + btnW/4 );
        [itmButton addSubview:title];
        
        itmButton.tag = i + 100;
        [itmButton addTarget:self action:@selector(enterAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:itmButton];
        
    }

}

- (void)enterAction:(UIButton *)button {
    
    if (button.tag == 100) {
//        RecordCameraViewController *vc = [RecordCameraViewController new];
//        vc.inputRecordMode = lsqRecordModeKeep;
//        [self.navigationController pushViewController:vc animated:YES];
//
        
        UPRecordSettingVC *settingVC = [[UPRecordSettingVC alloc] init];
        settingVC.view.backgroundColor = HEXCOLOR(0xe7e7e7);
        [self.navigationController pushViewController:settingVC animated:YES];
        
        

    } else if (button.tag == 101) {
        
        UPEditorSettingVC *settingVC = [[UPEditorSettingVC alloc] init];
        settingVC.view.backgroundColor = HEXCOLOR(0xe7e7e7);
        [self.navigationController pushViewController:settingVC animated:YES];
        
//        ComponentListViewController *vc = [ComponentListViewController new];
//        [self.navigationController pushViewController:vc animated:YES];
//        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
//
//        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
//            ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
//            ipc.mediaTypes = @[(NSString *)kUTTypeMovie];
//        }
//        ipc.allowsEditing = NO;
//        ipc.delegate = self;
//
//        [self presentViewController:ipc animated:YES completion:nil];
    } else {
        UPLivePlayerVC *vc = [[UPLivePlayerVC alloc] init];
        vc.url = @"http://uprocess.b0.upaiyun.com/demo/short_video/UPYUN_0.mp4";
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
{
    MainViewController *wSelf = self;
    [picker dismissViewControllerAnimated:NO completion:^{
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];

        /// 从相册中上传视频,图片等
        
//        NSString *saveKey = [NSString stringWithFormat:@"short_video_lib_test_%d.mp4", arc4random() % 10];
//        [[UPYUNConfig sharedInstance] uploadFilePath:url.path saveKey:saveKey success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
//            [[TuSDK shared].messageHub showSuccess:@"上传成功"];
//            NSLog(@"file url：http://%@.b0.upaiyun.com/%@",[UPYUNConfig sharedInstance].DEFAULT_BUCKET, saveKey);
//        } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
//            [[TuSDK shared].messageHub showSuccess:@"上传失败"];
//            NSLog(@"上传失败 error：%@", error);
//            NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
//            NSLog(@"上传失败 message：%@", responseBody);
//        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
//        }];


        
        UPEditorSettingVC *settingVC = [[UPEditorSettingVC alloc] init];
        settingVC.videoUrl = url;
        settingVC.view.backgroundColor = HEXCOLOR(0xe7e7e7);
        [self.navigationController pushViewController:settingVC animated:YES];
        
//        // 开启视频编辑导入视频
//        MoviePreviewAndCutViewController *vc = [MoviePreviewAndCutViewController new];
//        vc.inputURL = url;
//        [wSelf.navigationController pushViewController:vc animated:YES];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [picker dismissModalViewControllerAnimated];
}



#pragma mark - TuSDKFilterManagerDelegate
/**
 * 滤镜管理器初始化完成
 *
 * @param manager
 *            滤镜管理器
 */
- (void)onTuSDKFilterManagerInited:(TuSDKFilterManager *)manager;
{
    // 初始化完成
    NSLog(@"TuSDK inited");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
