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


#import "MovieRecordFullScreenController.h"
#import "TuAssetManager.h"
#import "TuAlbumViewController.h"
#import "MoviePreviewAndCutFullScreenController.h"



@interface MainViewController ()<TuSDKFilterManagerDelegate,TuVideoSelectedDelegate>

@end

@implementation MainViewController
#pragma mark - 基础配置方法
// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNavigationBarHidden:YES animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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

        MovieRecordFullScreenController *vc = [MovieRecordFullScreenController new];
        vc.inputRecordMode = lsqRecordModeNormal;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (button.tag == 101) {
        [TuAssetManager sharedManager].ifRefresh = YES;
        TuAlbumViewController *videoSelector = [[TuAlbumViewController alloc] init];
        videoSelector.selectedDelegate = self;
        // 若需要选择视频后进行预览 设置为YES，默认为NO
        videoSelector.isPreviewVideo = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:videoSelector];
        [self presentViewController:nav animated:YES completion:nil];

    } else {
        UPLivePlayerVC *vc = [[UPLivePlayerVC alloc] init];
//        vc.url = @"http://upyun-xiuxiuquan-ios.test.upcdn.net/MGLBBOITWNMXVPBS.mp4";
        vc.url = @"http://aicdn.baozibaozi.cn/video/20180807/78ce51a44cea4433ec2f084f0a32aadc.mp4";


        [self presentViewController:vc animated:YES completion:nil];
    }
    
}

#pragma mark - TuVideoSelectedDelegate

- (void)selectedModel:(TuVideoModel *)model;
{
    NSURL *url = model.url;
    MoviePreviewAndCutFullScreenController *vc = [MoviePreviewAndCutFullScreenController new];
    vc.inputURL = url;
    [self.navigationController pushViewController:vc animated:YES];
    
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
