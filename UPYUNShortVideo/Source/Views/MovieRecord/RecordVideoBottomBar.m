//
//  RecordVideoBottomBar.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/10.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "RecordVideoBottomBar.h"
#import "TuSDKFramework.h"
#import "TopNavBar.h"

@interface RecordVideoBottomBar ()
{
    UIView *_touchView;
    
    // 滤镜 label
    UILabel *_filterLabel;
    
    // 贴纸 label
    UILabel *_stickerLabel;
    
    // 贴纸 label
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
    CGFloat buttonWidth = 30;
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
    
    // 贴纸按钮
    _stickerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonWidth)];
    [_stickerButton setCenter:CGPointMake(sideDistance + buttonWidth/2, rect.size.height*3/4)];
    [_stickerButton setImage:[UIImage imageNamed:@"style_default_btn_sticker"] forState:UIControlStateNormal];
    [_stickerButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_stickerButton];
    
    CGFloat stickerBtnCenterY = rect.size.height*3/4 ;
    CGFloat stickerLabCenterY = _stickerButton.frame.origin.y +  buttonWidth + labelHeight/2 ;

    _stickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_stickerLabel setCenter:CGPointMake(_stickerButton.center.x, stickerLabCenterY)];
    _stickerLabel.font = [UIFont systemFontOfSize:12];
    _stickerLabel.textColor = HEXCOLOR(0x22bbf4);
    _stickerLabel.text =  NSLocalizedString(@"lsq_sticker_button_text", @"动态贴纸");
    _stickerLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_stickerLabel];
    
    CGFloat albumBtnCenterY = rect.size.height/3 ;
    
    // 相册按钮
    _albumButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonWidth)];
    [_albumButton setCenter:CGPointMake(sideDistance + buttonWidth/2, albumBtnCenterY)];
    [_albumButton setImage:[UIImage imageNamed:@"style_default_1.6.0_homepage_import_icon"] forState:UIControlStateNormal];
    [_albumButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _albumButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_albumButton];

    CGFloat albumLabCenterY = _albumButton.frame.origin.y +  buttonWidth + labelHeight/2 ;

    _albumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_albumLabel setCenter:CGPointMake(_albumButton.center.x, albumLabCenterY)];
    _albumLabel.font = [UIFont systemFontOfSize:12];
    _albumLabel.textColor = HEXCOLOR(0x22bbf4);
    _albumLabel.text =  NSLocalizedString(@"lsq_album_button_text", @"导入相册");
    _albumLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_albumLabel];
    
    // 滤镜按钮
    _filterButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonWidth)];
    [_filterButton setCenter:CGPointMake(sideDistance + buttonWidth/2 + gapDistance/3, stickerBtnCenterY)];
    [_filterButton setImage:[UIImage imageNamed:@"style_default_btn_filter"] forState:UIControlStateNormal];
    [_filterButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _filterButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_filterButton];
    
    _filterLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_filterLabel setCenter:CGPointMake(_filterButton.center.x, stickerLabCenterY)];
    _filterLabel.font = [UIFont systemFontOfSize:12];
    _filterLabel.textColor = HEXCOLOR(0x22bbf4);
    _filterLabel.text =  NSLocalizedString(@"lsq_filter_button_text", @"智能美化");
    _filterLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_filterLabel];

    // 后退按钮
    _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0 , 0, buttonWidth, buttonWidth)];
    [_cancelButton setCenter:CGPointMake(sideDistance + buttonWidth/2 + gapDistance*2/3, stickerBtnCenterY)];
    [_cancelButton setImage:[UIImage imageNamed:@"style_default_btn_back_unselected"] forState:UIControlStateDisabled];
    [_cancelButton setImage:[UIImage imageNamed:@"style_default_btn_back_selected"] forState:UIControlStateSelected];
    _cancelButton.enabled = NO;
    [_cancelButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_cancelButton];
    
    _cancelLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_cancelLabel setCenter:CGPointMake(_cancelButton.center.x, stickerLabCenterY)];
    _cancelLabel.font = [UIFont systemFontOfSize:12];
    _cancelLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    _cancelLabel.text =  NSLocalizedString(@"lsq_cancel_button_text", @"后退");
    _cancelLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_cancelLabel];

    // 确认按钮
    _completeButton = [[UIButton alloc]initWithFrame:CGRectMake(0 , 0, buttonWidth, buttonWidth)];
    [_completeButton setCenter:CGPointMake(rect.size.width - sideDistance - buttonWidth/2, stickerBtnCenterY)];
    [_completeButton setImage:[UIImage imageNamed:@"style_default_btn_finish_unselected"] forState:UIControlStateDisabled];
    [_completeButton setImage:[UIImage imageNamed:@"style_default_btn_finish_selected"] forState:UIControlStateSelected];
    _completeButton.enabled = NO;
    [_completeButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _completeButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:_completeButton];
    
    
    _completeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    [_completeLabel setCenter:CGPointMake(_completeButton.center.x, stickerLabCenterY)];
    _completeLabel.font = [UIFont systemFontOfSize:12];
    _completeLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    _completeLabel.text =  NSLocalizedString(@"lsq_complete_button_text", @"确认");
    _completeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_completeLabel];
}

// 录制按钮由于需要使用手势，故事件代理在touches 方法中抛出
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.recordMode == lsqRecordModeNormal) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_touchView.frame, point)) {
        // 此时被按下；开始录制
        _recordButton.selected = YES;
        if ([self.bottomBarDelegate respondsToSelector:@selector(onRecordBtnPressStart:)]) {
            [self.bottomBarDelegate onRecordBtnPressStart:_recordButton];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.recordMode == lsqRecordModeNormal) return;

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(_touchView.frame, point)) {
        // 此时手指滑动移开按钮范围； 暂停录制
        if (_recordButton.selected) {
            _recordButton.selected = NO;
            if ([self.bottomBarDelegate respondsToSelector:@selector(onRecordBtnPressEnd:)]) {
                [self.bottomBarDelegate onRecordBtnPressEnd:_recordButton];
            }
        }
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.recordMode == lsqRecordModeNormal) return;

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_touchView.frame, point)) {
        // 手指移开； 暂停录制
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
        _cancelLabel.textColor = HEXCOLOR(0x22bbf4);
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
        _completeLabel.textColor = HEXCOLOR(0x22bbf4);
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


