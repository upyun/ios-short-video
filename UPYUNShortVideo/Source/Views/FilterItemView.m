//
//  FilterItemView.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/11.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "FilterItemView.h"

@interface FilterItemView (){
    // 滤镜名
    NSString *_viewName;
    
    // 按钮响应与边框显示button
    UIButton *_EventView;
    
    // 滤镜名label
    UILabel *_titleLabel;
    
    // 图片显示IV
    UIImageView *_imageView;
}

@end

@implementation FilterItemView

- (void)setViewInfoWith:(NSString *)imageName title:(NSString *)title  titleFontSize:(CGFloat)fontSize
{
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat ivWidth = viewHeight * 13/18;
    CGFloat titleHeight = 20;
    
    // 图片
    _imageView = [UIImageView new];
    _imageView.layer.cornerRadius = 3;
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:imageName ofType:@"jpg"];
    _imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_imageView];
    
    // title
    _titleLabel = [UILabel new];
    _titleLabel.text = title;
    _titleLabel.font = [UIFont systemFontOfSize:fontSize];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.adjustsFontSizeToFitWidth = true;
    _titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    _titleLabel.layer.cornerRadius = 3;
    [_imageView addSubview:_titleLabel];
    
    // 布局
    _imageView.frame = CGRectMake(0, 0, ivWidth, viewHeight);
    _titleLabel.frame = CGRectMake(0, viewHeight - titleHeight, ivWidth, titleHeight);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // 事件响应以及边框button
    _EventView = [[UIButton alloc]initWithFrame:_imageView.frame];
    [_EventView addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _EventView.layer.cornerRadius = 3;
    [self addSubview:_EventView];
}

// 按钮点击响应事件
- (void)clickBtn:(UIButton*)sender
{
    if ([self.clickDelegate respondsToSelector:@selector(clickBasicViewWith:withBasicTag:)]) {
        [self.clickDelegate clickBasicViewWith:self.viewDescription withBasicTag:self.tag];
    }
}

// 传nil为使用默认
- (void)refreshClickColor:(UIColor*)color
{
    if (_titleLabel) {
        if (color) {
            _titleLabel.backgroundColor = color;
        }else{
            _titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        }
    }

    [self refreshSelectedBoundsColor:color];
}

// 改变选中边框颜色
- (void)refreshSelectedBoundsColor:(UIColor *)color;{
    if (_EventView) {
        if (color) {
            _EventView.layer.borderWidth = 2;
            _EventView.layer.borderColor = color.CGColor;
        }else{
            _EventView.layer.borderWidth = 0;
            _EventView.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
}

@end
