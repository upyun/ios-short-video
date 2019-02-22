//
//  PlayerView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerView ()

@end

@implementation PlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)self.layer player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [(AVPlayerLayer *)self.layer setPlayer:player];
}

@end
