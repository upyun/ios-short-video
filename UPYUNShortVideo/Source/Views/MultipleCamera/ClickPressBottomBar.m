//
//  ClickPressBottomBar.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/23.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "ClickPressBottomBar.h"
#import "TopNavBar.h"

@interface ClickPressBottomBar ()<UIGestureRecognizerDelegate>
{
    // 滤镜按钮背景view
    UIView *_filterBackView;
    // 贴纸按钮背景view
    UIView *_stickerBackView;
    // 删除按钮背景view
    UIView *_deleteBackView;
    // 保存按钮背景view
    UIView *_saveBackView;
    // 录制按钮的背景view 包括圆环
    UIView *_recorderBack;
    // 进度的背景圆环
    CAShapeLayer *_borderBackLayer;
    // 进度的显示圆环
    CAShapeLayer *_borderProgressLayer;
    
    // 长按手势
    UILongPressGestureRecognizer *_pressGesture;
    // 是否开始长按手势
    BOOL _startPressRecorCenter;
}

@end

@implementation ClickPressBottomBar

- (void)setRecordProgress:(CGFloat)recordProgress
{
    _recordProgress = recordProgress;
    _borderProgressLayer.strokeEnd = _recordProgress;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

// 初始化视图
-(void)lsqInitView;
{
    CGFloat buttonWidth = 36;
    CGFloat buttonHeight = 36;
    CGFloat edgeLeft1 = 0.097*self.lsqGetSizeWidth;
    CGFloat edgeLeft2 = 0.18*self.lsqGetSizeWidth;
    
    _recorderBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 90)];
    [_recorderBack setCenter:CGPointMake(self.lsqGetSizeWidth/2, 38+35)];
    [self addSubview:_recorderBack];
    // 录制按钮
    _recordButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    [_recordButton setCenter:CGPointMake(_recorderBack.lsqGetSizeWidth/2, _recorderBack.lsqGetSizeHeight/2)];
    _recordButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    _recordButton.layer.cornerRadius = 35;
    [_recorderBack addSubview:_recordButton];
    [self addGestures];
    
    // 外侧的圆环
    CGFloat radius = 44;
    _borderBackLayer = [CAShapeLayer new];
    _borderBackLayer.lineWidth = 6;
    _borderBackLayer.strokeColor = [UIColor whiteColor].CGColor;
    _borderBackLayer.fillColor = [UIColor clearColor].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:_recordButton.center radius:radius startAngle:0 endAngle:2*M_PI clockwise:true];
    _borderBackLayer.path = path.CGPath;
    [_recorderBack.layer addSublayer:_borderBackLayer];
    // 进度条的圆环
    _borderProgressLayer = [CAShapeLayer new];
    _borderProgressLayer.lineWidth = _borderBackLayer.lineWidth;
    _borderProgressLayer.strokeColor = [UIColor lsqClorWithHex:@"#F6A623"].CGColor;
    _borderProgressLayer.fillColor = [UIColor clearColor].CGColor;
    UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:_recordButton.center radius:44 startAngle:0 endAngle:2*M_PI clockwise:true];
    _borderProgressLayer.path = path2.CGPath;
    _borderProgressLayer.strokeEnd = 0;
    [_recorderBack.layer addSublayer:_borderProgressLayer];

    _recorderBack.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    
    // 删除按钮
    _deleteBackView = [[UIView alloc]initWithFrame:CGRectMake(edgeLeft2, 44, 65, 88)];
    _deleteBackView.hidden = YES;
    [self addSubview:_deleteBackView];
    
    _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 65, 65)];
    [_deleteButton setImage:[UIImage imageNamed:@"style_default_1.6.0_del_btn_default"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.adjustsImageWhenHighlighted = NO;
    [_deleteBackView addSubview:_deleteButton];
    
    UILabel *deleteTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, _deleteBackView.lsqGetSizeHeight - 15, _deleteBackView.lsqGetSizeWidth, 15)];
    deleteTitle.text = NSLocalizedString(@"lsq_delete_video", @"删除");
    deleteTitle.textAlignment = NSTextAlignmentCenter;
    deleteTitle.textColor = [UIColor whiteColor];
    deleteTitle.font = [UIFont systemFontOfSize:12];
    deleteTitle.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_deleteBackView addSubview:deleteTitle];

    // 保存按钮
    _saveBackView = [[UIView alloc]initWithFrame:CGRectMake(self.lsqGetSizeWidth - edgeLeft2 - 65, 44, 65, 88)];
    _saveBackView.hidden = YES;
    [self addSubview:_saveBackView];

    _saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 65, 65)];
    [_saveButton setImage:[UIImage imageNamed:@"style_default_1.6.0_save_btn_default"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.adjustsImageWhenHighlighted = NO;
    [_saveBackView addSubview:_saveButton];
    
    UILabel *saveTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, _saveBackView.lsqGetSizeHeight - 15, _saveBackView.lsqGetSizeWidth, 15)];
    saveTitle.text = NSLocalizedString(@"lsq_save_video", @"保存");
    saveTitle.textAlignment = NSTextAlignmentCenter;
    saveTitle.textColor = [UIColor whiteColor];
    saveTitle.font = [UIFont systemFontOfSize:12];
    saveTitle.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_saveBackView addSubview:saveTitle];
    
    
    if ([UIDevice lsqDevicePlatform] == TuSDKDevicePlatform_other) return;
    
    // 贴纸按钮
    _stickerBackView = [[UIView alloc]initWithFrame:CGRectMake(edgeLeft1, 52, 60, 58)];
    [self addSubview:_stickerBackView];
    
    _stickerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    _stickerButton.center = CGPointMake(_stickerBackView.lsqGetSizeWidth/2, buttonHeight/2);
    [_stickerButton setImage:[UIImage imageNamed:@"style_default_1.6.0_sticker_btn_default"] forState:UIControlStateNormal];
    [_stickerButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _stickerButton.adjustsImageWhenHighlighted = NO;
    [_stickerBackView addSubview:_stickerButton];
    
    _stickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _stickerBackView.lsqGetSizeWidth, 18)];
    _stickerLabel.center = CGPointMake(_stickerBackView.lsqGetSizeWidth/2, _stickerBackView.lsqGetSizeHeight-_stickerLabel.lsqGetSizeHeight/2);
    _stickerLabel.text = NSLocalizedString(@"lsq_sticker_button_text", @"动态贴纸");
    _stickerLabel.textAlignment = NSTextAlignmentCenter;
    _stickerLabel.textColor = [UIColor whiteColor];
    _stickerLabel.font = [UIFont systemFontOfSize:12];
    _stickerLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_stickerBackView addSubview:_stickerLabel];
    
    // 滤镜按钮
    _filterBackView = [[UIView alloc]initWithFrame:CGRectMake(self.lsqGetSizeWidth - 60 - edgeLeft1, 52, 60, 58)];
    [self addSubview:_filterBackView];

    _filterButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    _filterButton.center = CGPointMake(_filterBackView.lsqGetSizeWidth/2, buttonHeight/2);
    [_filterButton setImage:[UIImage imageNamed:@"style_default_1.6.0_filter_btn_default"] forState:UIControlStateNormal];
    [_filterButton addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    _filterButton.adjustsImageWhenHighlighted = NO;
    [_filterBackView addSubview:_filterButton];
    
    _filterLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _filterBackView.lsqGetSizeWidth, 18)];
    _filterLabel.center = CGPointMake(_filterBackView.lsqGetSizeWidth/2, _filterBackView.lsqGetSizeHeight-_filterLabel.lsqGetSizeHeight/2);
    _filterLabel.text = NSLocalizedString(@"lsq_filter_button_text", @"智能美化");
    _filterLabel.textAlignment = NSTextAlignmentCenter;
    _filterLabel.textColor = [UIColor whiteColor];
    _filterLabel.font = [UIFont systemFontOfSize:12];
    _filterLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_filterBackView addSubview:_filterLabel];
    

}

- (void)addGestures
{
    // 点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickRecordCenter)];
    tapGesture.numberOfTapsRequired = 1;
    [_recordButton addGestureRecognizer:tapGesture];
    // 长按手势
    _pressGesture = [[UILongPressGestureRecognizer alloc]init];
    _pressGesture.delegate = self;
    [_recordButton addGestureRecognizer:_pressGesture];
    [_pressGesture addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

// YES：表示bottom显示只有删除、保存按钮的界面  NO：表示bottom复原为原始状态
- (void)deleteAndSaveVisible:(BOOL)isVisible
{
    _borderProgressLayer.strokeEnd = 0;
    _recorderBack.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _recorderBack.hidden = isVisible;
    _filterBackView.hidden = isVisible;
    _stickerBackView.hidden = isVisible;
    _saveBackView.hidden = !isVisible;
    _deleteBackView.hidden = !isVisible;
}

// 按钮点击事件
- (void)clickRecordCenter
{
    // 点击
    [self deleteAndSaveVisible:YES];
    _startPressRecorCenter = NO;
    if ([self.bottomBarDelegate respondsToSelector:@selector(onBottomBtnClicked:)]) {
        [self.bottomBarDelegate onBottomBtnClicked:_recordButton];
    }
}

- (void)clickBtn:(UIButton*)sender
{
    if ([self.bottomBarDelegate respondsToSelector:@selector(onBottomBtnClicked:)]) {
        [self.bottomBarDelegate onBottomBtnClicked:sender];
    }
}

- (void)endPressRecordCenter
{
    // 结束长按
    _recordButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    if ([self.bottomBarDelegate respondsToSelector:@selector(onRecordBtnPressEnd:)]) {
        [self.bottomBarDelegate onRecordBtnPressEnd:_recordButton];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // press begin 
    _startPressRecorCenter = YES;
    _stickerBackView.hidden = true;
    _filterBackView.hidden = true;
    _recordButton.backgroundColor = [UIColor lsqClorWithHex:@"#F6A623"];
    [UIView animateWithDuration:0.2 animations:^{
        _recorderBack.transform = CGAffineTransformScale(_recorderBack.transform, 1.2, 1.2);
    }];

    if ([self.bottomBarDelegate respondsToSelector:@selector(onRecordBtnPressStart:)]) {
        [self.bottomBarDelegate onRecordBtnPressStart:_recordButton];
    }

    return YES;
}

#pragma mark - KVO 检测长按手势结束
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    UILongPressGestureRecognizer *pressGesture = (UILongPressGestureRecognizer *)object;
    if ([keyPath isEqualToString:@"state"]) {
        if (pressGesture.state == UIGestureRecognizerStateEnded ) {
            if (_startPressRecorCenter) {
                [self endPressRecordCenter];
            }
        }
        if (pressGesture.state == UIGestureRecognizerStateCancelled || pressGesture.state == UIGestureRecognizerStateFailed) {
            _recordButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
            [self deleteAndSaveVisible:NO];
        }
    }
}

- (void)dealloc
{
    [_pressGesture removeObserver:self forKeyPath:@"state" context:nil];
}

@end
