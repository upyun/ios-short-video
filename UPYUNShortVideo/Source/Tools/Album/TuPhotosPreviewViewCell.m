//
//  TuPhotosPreviewViewCell.m
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import "TuPhotosPreviewViewCell.h"
#import "TuVideoModel.h"

@interface TuPhotosPreviewViewCell ()

@property (weak, nonatomic) UIImageView *imgeView;
@property (weak, nonatomic) UIButton *bgBtn;
@property (weak, nonatomic) UIImageView *videoIcon;
@property (weak, nonatomic) UILabel *videoTime;
@property (weak, nonatomic) UIView *videoBgView;

@end

@implementation TuPhotosPreviewViewCell

#pragma mark - setter getter

- (void)setModel:(TuVideoModel *)model
{
    _model = model;
    
    _videoBgView.hidden = NO;
    _videoTime.text = model.videoTime;
    
    if (!model.image) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            CGImageRef thumbnail = [model.asset aspectRatioThumbnail];
            
            UIImage *image = [UIImage imageWithCGImage:thumbnail scale:2.0 orientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imgeView.image = image;
                model.image = image;
            });
        });
    }else {
        _imgeView.image = model.image;
    }
    
    [_bgBtn setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
}

#pragma mark - init method

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    _imgeView = imageView;
    _imgeView.frame = CGRectMake(0, 0, width, height);
    
    UIView *videoBgView = [[UIView alloc] init];
    videoBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    videoBgView.frame = CGRectMake(0, height - 20, width, 20);
    [self.contentView addSubview:videoBgView];
    _videoBgView = videoBgView;
    
    UIImageView *videoIcon = [[UIImageView alloc] init];
    videoIcon.image = [UIImage imageNamed:@"video_style_album_videoSend@2x.png"];
    videoIcon.frame = CGRectMake(5, 0, videoIcon.image.size.width, videoIcon.image.size.width);
    videoIcon.center = CGPointMake(videoIcon.center.x, 10);
    [videoBgView addSubview:videoIcon];
    _videoIcon = videoIcon;
    
    UILabel *videoTime = [[UILabel alloc] init];
    videoTime.textAlignment = NSTextAlignmentRight;
    videoTime.font = [UIFont systemFontOfSize:12];
    videoTime.textColor = [UIColor whiteColor];
    
    CGFloat videoIconMaxX = CGRectGetMaxX(videoIcon.frame);
    videoTime.frame = CGRectMake(videoIconMaxX, 0, width - videoIconMaxX - 5, 20);
    
    [videoBgView addSubview:videoTime];
    _videoTime = videoTime;
    
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bgBtn addTarget:self action:@selector(didPHClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:bgBtn];
    bgBtn.frame = CGRectMake(0, 0, width, height);
    _bgBtn = bgBtn;
    
}

- (void)didPHClick
{
    if (self.didPHBlock) {
        self.didPHBlock(self);
    }
}

@end

