//
//  MultiAssetPickerCell.m
//  MultiAssetPickerCell
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MultiAssetPickerCell.h"
#import "CustomTouchBoundsButton.h"

static const CGFloat kTimeLabelHeight = 16;

@interface MultiAssetPickerCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) CustomTouchBoundsButton *selectButton;

@property (nonatomic, strong) UILabel *timeLabel;

/**
 底部背景视图
 */
@property (nonatomic, strong) UIView *bottomMaskView;

@end

@implementation MultiAssetPickerCell

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
    
    _selectButton = [CustomTouchBoundsButton buttonWithType:UIButtonTypeCustom];
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

-(void)setAsset:(PHAsset *)asset;{
    _asset = asset;
    __weak typeof(self) weak_cell = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(weak_cell.contentView.bounds), CGRectGetHeight(weak_cell.contentView.bounds));
    
    switch (asset.mediaType) {
        case PHAssetMediaTypeVideo:
        case PHAssetMediaTypeAudio:
            weak_cell.duration = asset.duration;
            break;
        default:
            weak_cell.duration = -1;
            break;
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weak_cell.imageView.image = result;
    }];
}

/**
 根据给定的时间创建时间字符串
 
 @param timeInterval 秒
 @return 时间字符串
 */
+ (NSString *)textWithTimeInterval:(NSTimeInterval)timeInterval {
    if (isnan(timeInterval) || timeInterval < 0) return nil;
    NSInteger time = (NSInteger)(timeInterval + .5);
    NSInteger hours = time / 60 / 60;
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    NSString *text = @"";
    if (hours > 0) {
        text = [text stringByAppendingFormat:@"%02zd", hours];
    }
    text = [text stringByAppendingFormat:@"%02zd:%02zd", minutes, seconds];
    return text;
}

#pragma mark - property

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    _timeLabel.text = [self.class textWithTimeInterval:duration];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [_selectButton setTitle:@(_selectedIndex+1).description forState:UIControlStateSelected];
}

#pragma mark - action

/**
 选中按钮事件

 @param sender 点击的按钮
 */
- (void)selectButtonAction:(UIButton *)sender {
    if (self.selectButtonActionHandler) self.selectButtonActionHandler(self, sender);
}

@end


@interface MultiVideoPickerFooterView ()

/**
 视频数量标签
 */
@property (nonatomic, strong) UILabel *videoCountLabel;

@end


@implementation MultiVideoPickerFooterView

- (UILabel *)videoCountLabel {
    if (!_videoCountLabel) {
        _videoCountLabel = [[UILabel alloc] init];
        [self addSubview:_videoCountLabel];
        _videoCountLabel.textColor = [UIColor colorWithWhite:1 alpha:0.3];
        _videoCountLabel.font = [UIFont systemFontOfSize:14];
        _videoCountLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _videoCountLabel;
}

- (void)setVideoCount:(NSInteger)videoCount {
    _videoCount = videoCount;
    self.videoCountLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_共%@个视频", @"VideoDemo", @"共%@个视频"), @(videoCount)];
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.bounds);
    
    [self.videoCountLabel sizeToFit];
    CGFloat labelHeight = CGRectGetHeight(self.videoCountLabel.bounds);
    self.videoCountLabel.frame = CGRectMake(0, 64, width, labelHeight);
}

@end
