//
//  MultipleCameraFullScreenController.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/23.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MultipleCameraFullScreenController.h"
#import "MoviePreviewAndCutRatioAdaptedController.h"
/**
 多功能相机示例，点击拍照，长按录制
 */
@implementation MultipleCameraFullScreenController

// 保存照片或录制的视频
- (void)savePictureOrVideo
{
    if (!self.takePictureIV.hidden) {
        // 保存照片
        [TuSDKTSAssetsManager saveWithImage:self.takePictureIV.image compress:0 metadata:nil toAblum:nil completionBlock:^(id<TuSDKTSAssetInterface> asset, NSError *error) {
            if (!error) {
                self.takePictureIV.image = nil;
                self.takePictureIV.hidden = YES;
                [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
            }
        } ablumCompletionBlock:nil];
        
    }
    
    if (self.videoPlayer && self.videoPath) {
        // 保存视频，同时删除临时文件
        [TuSDKTSAssetsManager saveWithVideo:[NSURL fileURLWithPath:self.videoPath] toAblum:nil completionBlock:^(id<TuSDKTSAssetInterface> asset, NSError *error) {
            if (!error) {
//                 [TuSDKTSFileManager deletePath:self.videoPath];
                // self.videoPath = nil;
                [self destroyVideoPlayer];
                // [[TuSDK shared].messageHub showSuccess:NSLocalizedString(@"lsq_save_saveToAlbum_succeed", @"保存成功")];
            }
        } ablumCompletionBlock:nil];
    
        // 开启时间裁剪
        MoviePreviewAndCutRatioAdaptedController *vc = [MoviePreviewAndCutRatioAdaptedController new];
        vc.inputURL = [NSURL fileURLWithPath:self.videoPath];
        [self.navigationController pushViewController:vc animated:YES];
    }
    self.preView.hidden = YES;
}


@end
