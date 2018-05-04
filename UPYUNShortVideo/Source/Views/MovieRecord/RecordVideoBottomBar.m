//
//  RecordVideoBottomBar.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "RecordVideoBottomBar.h"
#import "TopNavBar.h"

@interface RecordVideoBottomBar ()
{
    // 长按是否开始
    BOOL _touchBegin;
    // 手势view
    UIView *_touchView;
    // 滤镜 label
    UILabel *_filterLabel;
    // 贴纸 label
    UILabel *_stickerLabel;
    // 相册 label
    UILabel *_albumLabel;
    // 确认 label
    UILabel *_completeLabel;
    // 撤销 label
    UILabel *_cancelLabel;
}

@end

@implementation RecordVideoBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
        // 默认为正常模式
        self.recordMode = lsqRecordModeNormal;
    }
    return self;
}

- (void)setRecordMode:(lsqRecordMode)recordMode
{
    _recordMode = recordMode;
    if (self.recordMode == lsqRecordModeNormal) {
        [_recordButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        // 用来响应的touchView
        _touchView = [[UIView alloc]initWithFrame:_recordButton.frame];
        [self addSubview:_touchView];
    }
}

// 初始化视图
-(void)lsqInitView;
{
    CGRect rect = self.bounds;
    CGFloat buttonWidth = 40;
    CGFloat buttonHeight = 54;
    CGFloat labelWidth = 60;
    CGFloat labelHeight = 26;
    CGFloat sideDistance = 40;
    
    // 录制按钮
    _recordButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    [_recordButton setCenter:CGPointMake(rect.size.width/2, rect.size.height/3)];
    [_recordButton setImage:[UIImage imageNamed:@"style_default_record_btn_record_unselected"] forState:UIControlStateNormal];
    [_recordButton setImage:[UIImage imageNamed:@"style_default_record_btn_record_selected"] forState:UIControlStateSelected];
    _recordButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_recordButton];
    
    CGFloat gapDistance = rect.size.width - buttonWidth - sideDistance* 2;
    
    CGFloat stickerBtnCenterY = rect.size.height - buttonHeight/2 - 5 ;
    CGFloat titleCenterY = rect.size.height - buttonHeight/2 + 10 ;
    CGFloat albumBtnCenterY = rect.size.height/3 ;
    
    
    // 确认按钮
    _completeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_completeLabel setCenter:CGPointMake(rect.size.width - sideDistance - buttonWidth/2, titleCenterY)];
    _completeLabel.font = [UIFont systemFontOfSize:12];
    _completeLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    _completeLabel.text =  NSLocalizedString(@"lsq_complete_button_text", @"确认");
    _completeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_completeLabel];
    
    _completeButton = [[UIButton alloc]initWithFrame:CGRectMake(0 , 0, buttonWidth, buttonHeight)];
    [_completeButton setCenter:CGPointMake(_completeLabel.center.x, stickerBtnCenterY)];
    [_completeButton setImage:[UIImage imageNamed:@"style_default_btn_finish_unselected"] forState:UIControlStateDisabled];
    [_completeButton setImage:[UIImage imageNamed:@"style_default_btn_finish_selected"] forState:UIControlStateSelected];
    _completeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _completeButton.enabled = NO;
    [_completeButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _completeButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_completeButton];

    if ([UIDevice lsqDevicePlatform] == TuSDKDevicePlatform_other) return;

    // 贴纸按钮
    _stickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_stickerLabel setCenter:CGPointMake(sideDistance + buttonWidth/2, titleCenterY)];
    _stickerLabel.font = [UIFont systemFontOfSize:12];
    _stickerLabel.textColor = [UIColor colorWithRed:0.95 green:0.6 blue:0.1 alpha:1];
    _stickerLabel.text =  NSLocalizedString(@"lsq_sticker_button_text", @"动态贴纸");
    _stickerLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_stickerLabel];

    _stickerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [_stickerButton setCenter:CGPointMake(_stickerLabel.center.x, stickerBtnCenterY)];
    [_stickerButton setImage:[UIImage imageNamed:@"style_default_btn_sticker"] forState:UIControlStateNormal];
    _stickerButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_stickerButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_stickerButton];

    // 相册按钮
    _albumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_albumLabel setCenter:CGPointMake(sideDistance + buttonWidth/2, albumBtnCenterY + 15)];
    _albumLabel.font = [UIFont systemFontOfSize:12];
    _albumLabel.textColor = [UIColor colorWithRed:0.95 green:0.6 blue:0.1 alpha:1];
    _albumLabel.text =  NSLocalizedString(@"lsq_album_button_text", @"导入相册");
    _albumLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_albumLabel];
    
    _albumButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [_albumButton setCenter:CGPointMake(_albumLabel.center.x, albumBtnCenterY)];
    [_albumButton setImage:[UIImage imageNamed:@"style_default_1.7.1_btn_import"] forState:UIControlStateNormal];
    _albumButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_albumButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _albumButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_albumButton];

    // 滤镜按钮
    _filterLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_filterLabel setCenter:CGPointMake(sideDistance + buttonWidth/2 + gapDistance/3, titleCenterY)];
    _filterLabel.font = [UIFont systemFontOfSize:12];
    _filterLabel.textColor = [UIColor colorWithRed:0.95 green:0.6 blue:0.1 alpha:1];
    _filterLabel.text =  NSLocalizedString(@"lsq_filter_button_text", @"智能美化");
    _filterLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_filterLabel];

    _filterButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [_filterButton setCenter:CGPointMake(_filterLabel.center.x, stickerBtnCenterY)];
    [_filterButton setImage:[UIImage imageNamed:@"style_default_1.7.1_btn_filter_selected"] forState:UIControlStateNormal];
    _filterButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_filterButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _filterButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_filterButton];
    
    // 后退按钮
    _cancelLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_cancelLabel setCenter:CGPointMake(sideDistance + buttonWidth/2 + gapDistance*2/3, titleCenterY)];
    _cancelLabel.font = [UIFont systemFontOfSize:12];
    _cancelLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    _cancelLabel.text =  NSLocalizedString(@"lsq_cancel_button_text", @"后退");
    _cancelLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_cancelLabel];

    _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0 , 0, buttonWidth, buttonHeight)];
    [_cancelButton setCenter:CGPointMake(_cancelLabel.center.x, stickerBtnCenterY)];
    [_cancelButton setImage:[UIImage imageNamed:@"style_default_btn_back_unselected"] forState:UIControlStateDisabled];
    [_cancelButton setImage:[UIImage imageNamed:@"style_default_btn_back_selected"] forState:UIControlStateSelected];
    _cancelButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _cancelButton.enabled = NO;
    [_cancelButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_cancelButton];
    
    
}

// 录制按钮由于需要使用手势，故事件代理在touches 方法中抛出
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.recordMode == lsqRecordModeNormal) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_touchView.frame, point)) {
        // 此时被按下 开始录制
        _touchBegin = YES;
        _recordButton.selected = YES;
        if ([self.bottomBarDelegate respondsToSelector:@selector(onRecordBtnPressStart:)]) {
            [self.bottomBarDelegate onRecordBtnPressStart:_recordButton];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.recordMode == lsqRecordModeNormal) return;

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (_touchBegin) {
        // 手指移开 暂停录制
        _recordButton.selected = NO;
        if ([self.bottomBarDelegate respondsToSelector:@selector(onRecordBtnPressEnd:)]) {
            [self.bottomBarDelegate onRecordBtnPressEnd:_recordButton];
        }
    }
}

// 按钮点击事件
- (void)clickBtn:(UIButton*)sender
{
    if ([self.bottomBarDelegate respondsToSelector:@selector(onBottomBtnClicked:)]) {
        [self.bottomBarDelegate onBottomBtnClicked:sender];
    }  
}

// 设置后退是否有效(能否点击)
- (void)enabledBtnWithCancle:(BOOL)enabledCancle
{
    if (self.recordMode == lsqRecordModeNormal) return;
    
    if (enabledCancle) {
        _cancelButton.enabled = YES;
        _cancelButton.selected = YES;
        _cancelLabel.textColor = [UIColor colorWithRed:0.95 green:0.6 blue:0.1 alpha:1];
    }else{
        _cancelButton.enabled = NO;
        _cancelButton.selected = NO;
        _cancelLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    }
}

// 设置确认按钮是否有效(能否点击)
- (void)enabledBtnWithComplete:(BOOL)enabledComplete
{
    if (self.recordMode == lsqRecordModeNormal) return;
    
    if (enabledComplete) {
        _completeButton.selected = YES;
        _completeButton.enabled = YES;
        _completeLabel.textColor = [UIColor colorWithRed:0.95 green:0.6 blue:0.1 alpha:1];
    }else{
        _completeButton.selected = NO;
        _completeButton.enabled = NO;
        _completeLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    }
}

// 根据参数设置录制按钮的状态
- (void)recordBtnIsRecordingStatu:(BOOL)isRecording
{
    _recordButton.selected = isRecording;
}


@end


