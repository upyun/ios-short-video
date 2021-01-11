//
//  PlayerView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

/**
 使用 AVPlayerLayer 呈现 AVPlayer 的视图
 */
@interface PlayerView : UIView

/**
 弱引用的 AVPlayer 对象
 */
@property (nonatomic, weak) AVPlayer *player;

@end
