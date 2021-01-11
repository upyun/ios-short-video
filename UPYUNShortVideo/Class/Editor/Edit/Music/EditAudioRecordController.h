//
//  EditAudioRecordController.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/2.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseEditComponentViewController.h"

@class EditAudioRecordController;

@protocol EditAudioRecordControllerDelegate <NSObject>
@optional

/**
 录制结束回调

 @param audioRecorder 音频录制控制器
 @param recordURL 录制音频文件的 URL 地址
 */
- (void)audioRecorder:(EditAudioRecordController *)audioRecorder didFinishRecordingWithURL:(NSURL *)recordURL;

@end


/**
 录音页面
 */
@interface EditAudioRecordController : BaseEditComponentViewController

@property (nonatomic, weak) id<EditAudioRecordControllerDelegate> delegate;

@end
