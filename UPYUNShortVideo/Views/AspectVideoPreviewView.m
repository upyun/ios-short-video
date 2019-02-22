//
//  AspectVideoPreviewView.m
//  AspectVideoPreviewView
//
//  Created by bqlin on 2018/9/26.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "AspectVideoPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@interface AspectVideoPreviewView ()

/**
 上一次视频预览尺寸
 */
@property (nonatomic, assign) CGSize lastVideoViewSize;

@end

@implementation AspectVideoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _videoView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_videoView];
    
    _videoSize = CGSizeZero;
    _lastVideoViewSize = CGSizeZero;
}

- (void)layoutSubviews {
    if (!CGSizeEqualToSize(CGSizeZero, _videoSize)) {
        CGRect bounds = self.bounds;
        if (@available(iOS 11.0, *)) {
            bounds = UIEdgeInsetsInsetRect(bounds, self.safeAreaInsets);
        }
        _videoView.frame = AVMakeRectWithAspectRatioInsideRect(_videoSize, bounds);
        CGSize videoViewSize = _videoView.frame.size;
        if (!CGSizeEqualToSize(_lastVideoViewSize, videoViewSize)) {
            if (self.resizeHandler) self.resizeHandler(self);
        }
        _lastVideoViewSize = videoViewSize;
    }
}

#pragma mark - property

- (void)setVideoView:(UIView *)videoView {
    if (_videoView) {
        [_videoView removeFromSuperview];
    }
    _videoView = videoView;
    [self addSubview:videoView];
}

- (void)setVideoSize:(CGSize)videoSize {
    _videoSize = videoSize;
    [self setNeedsLayout];
}

@end
