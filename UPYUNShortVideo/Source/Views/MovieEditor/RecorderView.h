//
//  RecorderView.h
//  TuSDKVideoDemo
//
//  Created by wen on 06/07/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"


/**
 录音 view
 */
@interface RecorderView : UIView

// 录音文件路径
@property (nonatomic, copy) NSString *resultAudioPath;
// 最大录制时长
@property (nonatomic, assign) CGFloat recorderDuration;
// 录制完成的回调
@property (nonatomic, copy) void(^recorderCompletedHandler)(NSString *resultPath);

@end
