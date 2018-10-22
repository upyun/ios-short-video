//
//  EffectsItemView.m
//  TuSDKVideoDemo
//
//  Created by wen on 13/12/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "EffectsItemView.h"
#import "TuSDKFramework.h"

@interface EffectsItemView (){
    // 滤镜名
    NSString *_viewName;
    
    // 事件响应与阴影显示button
    UIView *_EventView;
    
    // 滤镜名label
    UILabel *_titleLabel;
    
    // 图片显示IV
    UIImageView *_imageView;
}
@end


@implementation EffectsItemView

- (void)setViewInfoWith:(NSString *)imageName title:(NSString *)title  titleFontSize:(CGFloat)fontSize
{
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat titleHeight = 20;
    CGFloat ivWidth = MIN(self.lsqGetSizeWidth, viewHeight - titleHeight);
    
    // 图片
    _imageView = [UIImageView new];
    _imageView.layer.cornerRadius = 3;
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:imageName ofType:@"jpg"];
    _imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    // title
    _titleLabel = [UILabel new];
    _titleLabel.text = title;
    _titleLabel.font = [UIFont systemFontOfSize:fontSize];
    _titleLabel.textColor = lsqRGB(153, 153, 153);
    _titleLabel.adjustsFontSizeToFitWidth = true;
    [self addSubview:_titleLabel];
    
    // 布局
    _imageView.frame = CGRectMake(0, 0, ivWidth, ivWidth);
    _imageView.center = CGPointMake(self.lsqGetSizeWidth/2, ivWidth/2);
    _titleLabel.frame = CGRectMake(0, viewHeight - titleHeight, self.lsqGetSizeWidth, titleHeight);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // 事件响应以及边框button
    _EventView = [[UIView alloc]initWithFrame:_imageView.frame];
    _EventView.layer.cornerRadius = ivWidth/2;
    [self addSubview:_EventView];
}

// 改变选中阴影色
- (void)refreshShadowColor:(UIColor *)color;{
    if (_EventView) {
        if (color) {
            _EventView.backgroundColor = color;
            _titleLabel.textColor = color;
        }else{
            _EventView.backgroundColor = [UIColor clearColor];
            _titleLabel.textColor = lsqRGB(153, 153, 153);
        }
    }
}

- (void)touchBeginEvent;
{
    if ([self.eventDelegate respondsToSelector:@selector(touchBeginWithSelectCode:)]) {
        [self.eventDelegate touchBeginWithSelectCode:_effectCode];
        [self refreshShadowColor:(_selectColor?_selectColor:lsqRGBA(60, 60, 60, 0.6))];
    }
}

- (void)touchEndEvent;
{
    if ([self.eventDelegate respondsToSelector:@selector(touchEndWithSelectCode:)]) {
        [self.eventDelegate touchEndWithSelectCode:_effectCode];
        [self refreshShadowColor:nil];
    }
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self touchBeginEvent];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self touchEndEvent];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
//    [self touchEndEvent];
}

@end
