//
//  MovieEditorClipView.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/26.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoClipView.h"

@interface MovieEditorClipView : UIView

// 总时间，用来后续计算
@property (nonatomic, assign) CGFloat timeInterval;
// 当前时间，用来设置白色时间条位置
@property (nonatomic, assign) CGFloat currentTime;
// 最小剪切时间，用来控制两端的间隔
@property (nonatomic, assign) CGFloat minCutTime;
// 事件代理
@property (nonatomic, assign) id<VideoClipViewDelegate> clipDelegate;
// 视频路径URL
@property (nonatomic, strong) NSURL *videoURL;


@end
