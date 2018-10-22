//
//  ScrollListItemCell.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/8/2.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "ScrollListItemCell.h"
#import "TuSDKFramework.h"

@interface ScrollListItemCell ()

/// 普通状态图片
@property (nonatomic, strong) UIImage *normalImage;

/// 选中图片
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation ScrollListItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}


/**
 初始化 UI 元素
 */
- (void)commonInit
{
    _thumbnailView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_thumbnailView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:11];
    
    self.contentView.layer.borderWidth = 0;
    self.contentView.layer.borderColor = lsqRGB(244, 161, 24).CGColor;
    self.contentView.layer.cornerRadius = 3;
    self.contentView.clipsToBounds = YES;
}

/**
 布局 UI 元素
 */
- (void)layoutSubviews
{
    CGSize size = self.contentView.bounds.size;
    _thumbnailView.frame = self.contentView.bounds;
    const CGFloat titleHeight = 20;
    _titleLabel.frame = CGRectMake(0, size.height - titleHeight, size.width, titleHeight);
}

/**
 选中状态切换
 */
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.contentView.layer.borderWidth = selected ? 2 : 0;
    if (_titleLabel.backgroundColor != [UIColor clearColor]) {
        _titleLabel.backgroundColor = selected ? lsqRGB(244, 161, 24) : [UIColor colorWithWhite:0 alpha:0.7];
    }
    if (_selectedImage) {
        _thumbnailView.image = selected ? _selectedImage : _normalImage;
    }
}

#pragma mark - public

/**
 配置无效果样式
 */
- (void)setupDisableStyle
{
    _normalImage = [UIImage imageNamed:@"style_default_1.11_btn_effect_unselect"];
    _selectedImage = [UIImage imageNamed:@"style_default_1.11_btn_effect_select"];
    _thumbnailView.image = _normalImage;
    _thumbnailView.contentMode = UIViewContentModeCenter;
    
    //_titleLabel.text = NSLocalizedString(@"lsq_deleteBtn_title", @"无效果");
    //_titleLabel.textColor = lsqRGB(244, 161, 24);
    _titleLabel.backgroundColor = [UIColor clearColor];
}

/**
 配置普通样式
 
 @param thumbnail 缩略图
 @param title 标题
 */
- (void)setupWithThumbnail:(UIImage *)thumbnail title:(NSString *)title
{
    _normalImage = thumbnail;
    _thumbnailView.image = thumbnail;
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    
    _titleLabel.text = title;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
}

@end
