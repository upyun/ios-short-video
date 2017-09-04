//
//  RecordCameraViewController.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

/**
 *  视频录制示例：支持断点续拍，正常模式(模式的切换需要更改相关代码)
 */
@interface RecordCameraViewController : UIViewController

// 事件处理队列
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

/**
 *  录制模式 默认:lsqRecordModeNormal (lsqRecordModeNormal: 正常模式, lsqRecordModeKeep: 续拍模式,支持断点续拍）
 */
@property (nonatomic, assign) lsqRecordMode inputRecordMode;

@end
