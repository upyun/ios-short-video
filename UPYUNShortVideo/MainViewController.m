//
//  MainViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/9.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MainViewController.h"
#import "TuSDKFramework.h"
#import "MultiVideoPickerViewController.h"
#import "MovieCutViewController.h"
#import "MovieEditViewController.h"
#import "CameraViewController.h"
#import "MoviePreviewViewController.h"
#import "UPLivePlayerVC.h"



@interface MainViewController ()<TuSDKFilterManagerDelegate>

@end

@implementation MainViewController
#pragma mark - 基础配置方法

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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

        CameraViewController *record = [CameraViewController recordController];
        [self.navigationController pushViewController:record animated:YES];
    } else if (button.tag == 101) {
        MultiVideoPickerViewController *picker = [[MultiVideoPickerViewController alloc] initWithNibName:nil bundle:nil];
        picker.maxSelectedCount = 9;
        picker.rightButtonActionHandler = ^(MultiVideoPickerViewController *picker, UIButton *sender) {
            NSArray *assets = [picker allSelectedAssets];
            if (assets.count) [self actionAfterPickVideos:assets];
        };
        [self.navigationController pushViewController:picker animated:YES];

    } else {

        UPLivePlayerVC *vc = [[UPLivePlayerVC alloc] init];
        vc.url = @"http://uprocess.b0.upaiyun.com/demo/short_video/UPYUN_0.mp4";


        [self presentViewController:vc animated:YES completion:nil];
    }
    
}

/**
 相册返回数据，进入视频时间裁剪

 @param assets 相册返回数据
 */
- (void)actionAfterPickVideos:(NSArray<AVURLAsset *> *)assets {
    MovieCutViewController *cutter = [[MovieCutViewController alloc] initWithNibName:nil bundle:nil];
    cutter.inputAssets = assets;
    cutter.rightButtonActionHandler = ^(MovieCutViewController *cutter, UIButton *sender) {
        [self actionAfterMovieCutWithURL:cutter.outputURL];
    };
    [self.navigationController pushViewController:cutter animated:YES];
}

/**
 相册进入视频编辑器

 @param inputURL 视频文件 URL 地址
 */
- (void)actionAfterMovieCutWithURL:(NSURL *)inputURL {
    MovieEditViewController *edit = [[MovieEditViewController alloc] initWithNibName:nil bundle:nil];
    edit.inputURL = inputURL;
    [self.navigationController pushViewController:edit animated:YES];
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
    NSLog(@"SDK 初始化完成- 可以进行 SDK 操作");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
