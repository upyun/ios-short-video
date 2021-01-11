//
//  EditCollectionViewCell.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditCollectionViewCell.h"
#import "DemoAppearance.h"

// 缩略图宽度
const CGFloat kThumbnailWidth = 36;

@interface EditCollectionViewCell ()

@end

@implementation EditCollectionViewCell

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
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_imageView];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize:11];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [DemoAppearance setupDefaultShadowOnLayer:_titleLabel.layer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.contentView.bounds.size;
    _imageView.frame = CGRectMake(0, 0, kThumbnailWidth, kThumbnailWidth);
    _imageView.center = CGPointMake(size.width / 2, size.height / 2);
    
    CGSize titleSize = _titleLabel.intrinsicContentSize;
    _titleLabel.frame = CGRectMake(0, size.height - titleSize.height - 6, size.width, titleSize.height);
}

@end
