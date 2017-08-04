//
//  MovieRecordCameraViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieRecordCameraViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MoviePreviewAndCutViewController.h"

/**
 *  视频录制相机示例
 */

@implementation MovieRecordCameraViewController

#pragma mark - TuSDKRecordVideoCameraDelegate
/**
 *  视频录制完成
 *
 *  @param camerea 相机
 *  @param result  TuSDKVideoResult 对象
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea result:(TuSDKVideoResult *)result;
{
    // 通过相机初始化设置  _camera.saveToAlbum = NO;  result.videoPath 拿到视频的临时文件路径
    if (result.videoPath) {
        /*
        // 进行自定义操作，例如保存到相册
        UISaveVideoAtPathToSavedPhotosAlbum(result.videoPath, nil, nil, nil);
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
        */        
        // 开启裁剪
        
        MoviePreviewAndCutViewController *vc = [MoviePreviewAndCutViewController new];
        vc.inputURL = [NSURL fileURLWithPath:result.videoPath];
        [self.navigationController pushViewController:vc animated:true];
        
    }else{
        // _camera.saveToAlbum = YES; （默认为 ：YES）将自动保存到相册
        [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
    }
    
    if (self.camera && self.camera.recordMode == lsqRecordModeNormal) {
        [self.bottomBar recordBtnIsRecordingStatu:NO];
    }

    // 自动保存后设置为 恢复进度条状态
    [self changeNodeViewWithLocation:0];
}


@end
