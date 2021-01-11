//
//  TuBeautyPanelViewCell.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/12/4.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuBeautyFacePanelViewCell.h"

@implementation TuBeautyFaceData
- (instancetype)init
{
    if (self = [super init])
    {
        _beautyFaceCode = @"reset";
    }
    return self;
}

- (void)setBeautyFaceCode:(NSString *)beautyFaceCode
{
    _beautyFaceCode = beautyFaceCode;
}


@end

@interface TuBeautyFacePanelViewCell()
{
    UILabel *_titleLabel;
    UIImageView *_thumbnailView;
    UIImageView *_selectImageView;
    UIView *_pointView;
    UIColor *_normalColor;
    UIColor *_selectColor;
}

@end

@implementation TuBeautyFacePanelViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initWithSubViews];
    }
    return self;
}

- (void)initWithSubViews
{
    _normalColor = [UIColor colorWithWhite:1 alpha:0.35];
    _selectColor = [UIColor lsqClorWithHex:@"#FFDE00"];
    
    _thumbnailView = [[UIImageView alloc] init];
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    _thumbnailView.backgroundColor = [UIColor clearColor];
    _thumbnailView.layer.masksToBounds = YES;
    [self addSubview:_thumbnailView];
    
    _selectImageView = [[UIImageView alloc] init];
    _selectImageView.layer.masksToBounds = YES;
    [self addSubview:_selectImageView];
    _selectImageView.hidden = YES;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:10];
    _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.35];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _pointView = [[UIView alloc] init];
    _pointView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    _pointView.layer.cornerRadius = 3;
    _pointView.hidden = YES;
    [self addSubview:_pointView];
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    const CGFloat labelHeight = 22;
    const CGFloat imageWidth = 40;
    
    CGFloat margin = 0;
    CGFloat labelWidth = size.width;
    CGFloat titleMinX = 0;

    _thumbnailView.frame = CGRectMake(size.width / 2 - imageWidth / 2 + margin, 12, imageWidth, imageWidth);
    _titleLabel.frame = CGRectMake(titleMinX, CGRectGetHeight(_thumbnailView.frame) + CGRectGetMinY(_thumbnailView.frame), labelWidth, labelHeight);
    
    _selectImageView.frame = _thumbnailView.frame;
    
    _pointView.frame = CGRectMake(0, 0, 6, 6);
    _pointView.center = _thumbnailView.center;
}

- (void)setBeautyFaceData:(TuBeautyFaceData *)beautyFaceData
{
    _beautyFaceData = beautyFaceData;
    
    _pointView.hidden = _selectImageView.hidden = YES;
    _thumbnailView.hidden = NO;
    
    if ([beautyFaceData.beautyFaceCode isEqualToString:@"reset"])
    {
        _titleLabel.text = NSLocalizedStringFromTable(@"tu_重置", @"VideoDemo", @"重置");
        // 缩略图
        NSString *imageName = [NSString stringWithFormat:@"plastic_%@", beautyFaceData.beautyFaceCode];
        _thumbnailView.image = [UIImage imageNamed:imageName];
        
        NSString *selectImageName = [NSString stringWithFormat:@"plastic_%@_sel", beautyFaceData.beautyFaceCode];
        _selectImageView.image = [UIImage imageNamed:selectImageName];
    }
    else if ([beautyFaceData.beautyFaceCode isEqualToString:@"point"])
    {
        _titleLabel.text = @"";
        _thumbnailView.hidden = _selectImageView.hidden = YES;
        _pointView.hidden = NO;
        
    }
    else
    {
        // 标题
        NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", beautyFaceData.beautyFaceCode];
        _titleLabel.text = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
        // 缩略图
        NSString *imageName = [NSString stringWithFormat:@"plastic_%@", beautyFaceData.beautyFaceCode];
        _thumbnailView.image = [UIImage imageNamed:imageName];
        
        NSString *selectImageName = [NSString stringWithFormat:@"plastic_%@_sel", beautyFaceData.beautyFaceCode];
        _selectImageView.image = [UIImage imageNamed:selectImageName];
    }
    
    if (_beautyFaceData.beautyFaceSelectType == TuBeautyFaceSelectTypeSelected)
    {
        if (![beautyFaceData.beautyFaceCode isEqualToString:@"reset"])
        {
            _selectImageView.hidden = NO;
            _titleLabel.textColor = _selectColor;
        }
    }
    else
    {
        _selectImageView.hidden = YES;
        _titleLabel.textColor = _normalColor;
    }
}


@end
