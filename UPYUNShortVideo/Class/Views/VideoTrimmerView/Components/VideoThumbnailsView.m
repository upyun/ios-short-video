//
//  VideoThumbnailsView.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/22.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "VideoThumbnailsView.h"

@interface VideoThumbnailsView ()

/**
 缩略图视图组
 */
@property (nonatomic, strong) NSArray<UIImageView *> *thumbnailViews;

@end

@implementation VideoThumbnailsView

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.clipsToBounds = YES;
    _thumbnailWidth = -1;
}

- (void)layoutSubviews {
    CGFloat height = CGRectGetHeight(self.bounds);
    
    for (int i = 0; i < self.thumbnailViews.count; i++) {
        UIImageView *thumbnailView = _thumbnailViews[i];
        thumbnailView.frame = CGRectMake(self.thumbnailWidth * i, 0, self.thumbnailWidth, height);
    }
}

#pragma mark - property

- (CGFloat)thumbnailsTotalWidth {
    return self.thumbnailCount * self.thumbnailWidth;
}

- (NSArray<UIImageView *> *)thumbnailViews {
    if (!_thumbnailViews) {
        if (_thumbnailCount <= 0) return nil;
        NSMutableArray *thumbnailViews = [NSMutableArray array];
        for (int i = 0; i < _thumbnailCount; i ++) {
            UIImageView *thumbnailView = [self.class commonThumbnailView];
            [self addSubview:thumbnailView];
            [thumbnailViews addObject:thumbnailView];
        }
        _thumbnailViews = thumbnailViews.copy;
    }
    return _thumbnailViews;
}

- (void)setThumbnails:(NSArray<UIImage *> *)thumbnails {
    _thumbnails = thumbnails;
    _thumbnailCount = thumbnails.count;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < MIN(thumbnails.count, self.thumbnailViews.count); i++) {
            self.thumbnailViews[i].image = thumbnails[i];
        }
    });
    if (self.thumbnailsUpdateHandler) self.thumbnailsUpdateHandler(self);
}

- (CGFloat)thumbnailWidth {
    if (_thumbnailWidth <= 0) {
        return CGRectGetWidth(self.bounds) / _thumbnailCount;
    }
    return _thumbnailWidth;
}

#pragma mark - public

- (void)setThumbnail:(UIImage *)thumbnail atIndex:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [self.thumbnailViews objectAtIndex:index];
        imageView.image = thumbnail;
    });
}

#pragma mark - private

/**
 生成统一的 UIImageView 对象
 */
+ (UIImageView *)commonThumbnailView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    return imageView;
}

@end
