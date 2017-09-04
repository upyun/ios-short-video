//
//  MovieEditorRatioAdaptedController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/15.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditorRatioAdaptedController.h"

@implementation MovieEditorRatioAdaptedController

#pragma mark - 初始化 movieEditor 

- (void)initSettingsAndPreview
{
    TuSDKMovieEditorOptions *options = [TuSDKMovieEditorOptions defaultOptions];
    // 设置视频地址
    options.inputURL = self.inputURL;
    // 设置视频截取范围
    options.cutTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:self.startTime endSeconds:self.endTime];
    // 是否按照时间播放
    options.playAtActualSpeed = YES;
    // 设置裁剪范围 注：该参数对应的值均为比例值，即：若视频展示View总高度800，此时截取时y从200开始，则cropRect的 originY = 偏移位置/总高度， 应为 0.25, 其余三个值同理
    options.cropRect = self.cropRect;
    // 设置编码视频的画质
    options.encodeVideoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_High1];
    // 是否保留原音
    options.enableVideoSound = YES;

   self.movieEditor = [[TuSDKMovieEditor alloc]initWithPreview:self.videoView options:options];
   self.movieEditor.delegate = self;
    
//    /*设置贴纸出现的默认时间范围 （开始时间~结束时间，注：基于裁剪范围，如原视频8秒，裁剪2~7秒的内容，此时贴纸时间范围为1~2，即原视频的3~4秒）
//     * 注： 应与顶部的缩略图滑动栏的默认范围一致
//     */
//   self.movieEditor.mvItemTimeRange = [[TuSDKMVEffectData alloc]initEffectInfoWithStart:_mvStartTime end:_mvEndTime type:lsqMVEffectDataTypeStickerAudio];
    // 保存到系统相册 默认为YES
   self.movieEditor.saveToAlbum = YES;
    // 设置录制文件格式(默认：lsqFileTypeQuickTimeMovie)
   self.movieEditor.fileType = lsqFileTypeMPEG4;
//    // 设置水印，默认为空
//   self.movieEditor.waterMarkImage = [UIImage imageNamed:@"upyun_wartermark.png"];
//    // 设置水印图片的位置
//   self.movieEditor.waterMarkPosition = lsqWaterMarkTopLeft;
    // 视频播放音量设置，0 ~ 1.0 仅在 enableVideoSound 为 YES 时有效
   self.movieEditor.videoSoundVolume = 0.5;

    // 设置默认镜
    [self.movieEditor switchFilterWithCode:self.videoFilters[0]];
    // 加载视频，显示第一帧
    [self.movieEditor loadVideo];
}

@end
