//
//  FilterParamItemView.m
//  TuSDKVideoDemo
//
//  Created by wen on 22/08/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import "FilterParamItemView.h"
#import "TuSDKFramework.h"

@interface FilterParamItemView ()<TuSDKICSeekBarDelegate>{
    // 参数名
    UILabel *_nameLabel;
    // 滑动条
    TuSDKICSeekBar *_seekBar;
    // 数值label
    UILabel *_argValueLabel;
}

@end

@implementation FilterParamItemView


#pragma mark - setter getter

- (void)setMainColor:(UIColor *)mainColor;
{
    if (_nameLabel) {
        _mainColor = mainColor;
        _nameLabel.textColor = _mainColor;
        _seekBar.aboveView.backgroundColor = _mainColor;
        _seekBar.dragView.backgroundColor = _mainColor;
        _argValueLabel.textColor = _mainColor;
    }
}

- (void)setProgress:(CGFloat)progress;
{
    _progress = progress;
    _seekBar.progress = progress;
    _argValueLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];
}

#pragma mark - init method

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        _mainColor = lsqRGB(244, 161, 24);
    }
    return self;
}

- (void)initParamViewWith:(NSString *)title originProgress:(CGFloat)progress;
{
    CGFloat itemHeigth = self.lsqGetSizeHeight;
    
    // 参数名
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(4, 0, 40, itemHeigth)];
    _nameLabel.textColor = _mainColor;
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.text = title;
    _nameLabel.textAlignment = NSTextAlignmentRight;
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_nameLabel];
    
    // 数值label
    _argValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.lsqGetSizeWidth - 40, 0, 40, itemHeigth)];
    _argValueLabel.textColor = _mainColor;
    _argValueLabel.font = [UIFont systemFontOfSize:13];
    _argValueLabel.textAlignment = NSTextAlignmentCenter;
    _argValueLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];
    [self addSubview:_argValueLabel];
    
    // 滑动条
    CGFloat seekBarX = _nameLabel.lsqGetOriginX + _nameLabel.lsqGetSizeWidth + 15;
    _seekBar = [TuSDKICSeekBar initWithFrame:CGRectMake(seekBarX, 0, self.lsqGetSizeWidth - seekBarX - 10 - _argValueLabel.lsqGetSizeWidth , itemHeigth)];
    _seekBar.delegate = self;
    _seekBar.progress = progress;
    _seekBar.aboveView.backgroundColor = _mainColor;
    _seekBar.belowView.backgroundColor = lsqRGB(217, 217, 217);
    _seekBar.dragView.backgroundColor = _mainColor;
    [self addSubview: _seekBar];
}

#pragma mark - TuSDKICSeekBarDelegate

// 滑动条调整的响应方法
- (void)onTuSDKICSeekBar:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress
{
    if (_progress != progress) {
        _progress = progress;
        _argValueLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];
        if ([self.itemDelegate respondsToSelector:@selector(filterParamItemView:changedProgress:)]) {
            [self.itemDelegate filterParamItemView:self changedProgress:_progress];
        }
    }
}
@end
