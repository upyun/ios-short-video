//
//  MultiVideoPickerCell.m
//  MultiVideoPicker
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MultiVideoPickerCell.h"
#import "TuVideoModel.h"

static const CGFloat kTimeLabelHeight = 16;

@interface MultiVideoPickerCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIView *bottomMaskView;

@end

@implementation MultiVideoPickerCell

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
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_selectButton];
    [_selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [_selectButton setBackgroundImage:[UIImage imageNamed:@"edit_checkbox_sel"] forState:UIControlStateSelected];
    [_selectButton setBackgroundImage:[UIImage imageNamed:@"edit_checkbox_unsel"] forState:UIControlStateNormal];
    _selectButton.titleLabel.font = [UIFont systemFontOfSize:11];
    [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _bottomMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_bottomMaskView];
    _bottomMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textAlignment = NSTextAlignmentRight;
}

- (void)layoutSubviews {
    _imageView.frame = self.contentView.frame;
    _selectButton.frame = CGRectMake(6, 6, 20, 20);
    
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    CGFloat height = CGRectGetHeight(self.contentView.bounds);
    _bottomMaskView.frame = CGRectMake(0, height - kTimeLabelHeight, width, kTimeLabelHeight);
    _timeLabel.frame = CGRectMake(kTimeLabelHeight / 2, height - kTimeLabelHeight, width - kTimeLabelHeight, kTimeLabelHeight);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.selectButton.selected = NO;
}


#pragma mark - property

- (void)setModel:(TuVideoModel *)model{
    _model = model;
    _timeLabel.text = model.videoTime;
    if (!model.image) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            CGImageRef thumbnail = [model.asset aspectRatioThumbnail];
            
            UIImage *image = [UIImage imageWithCGImage:thumbnail scale:2.0 orientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = image;
                model.image = image;
            });
        });
    }else {
        _imageView.image = model.image;
    }

}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [_selectButton setTitle:@(_selectedIndex+1).description forState:UIControlStateSelected];
}

#pragma mark - action

- (void)selectButtonAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    sender.selected = !sender.selected;
    if (self.selectButtonActionHandler) self.selectButtonActionHandler(weakSelf, sender.selected);
}


@end
