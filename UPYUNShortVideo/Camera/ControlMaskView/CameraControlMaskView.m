//
//  CameraControlMaskView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "CameraControlMaskView.h"

// 顶部工具栏高度
static const CGFloat kTopBarHeight = 64.0;

/**
 录制相机遮罩视图
 */
@interface CameraControlMaskView () <UIGestureRecognizerDelegate, RecordButtonDelegate>

/**
 拍照模式中，确认照片视图
 */
@property (nonatomic, weak, readonly) PhotoCaptureConfirmView *photoCaptureconfirmView;

/**
 当前的底部面板
 */
@property (nonatomic, weak) UIView<OverlayViewProtocol> *currentBottomPanelView;

/**
 当前的顶部面板
 */
@property (nonatomic, weak) UIView<OverlayViewProtocol> *currentTopPanelView;

/**
 阻止 tap 手势响应的视图
 */
@property (nonatomic, strong) NSArray *blockTapViews;

/**
 底部视图
 */
@property (nonatomic, strong) NSArray *bottomViews;

/**
 录制隐藏视图
 */
@property (nonatomic, strong) NSArray *recordingHiddenViews;

/**
 上次变焦倍数，用于计算变焦增量
 */
@property (nonatomic, assign) double lastScale;

@end

@implementation CameraControlMaskView

/**
 配置界面
 */
- (void)awakeFromNib {
    [super awakeFromNib];
    _doneButton.hidden = YES;
    _undoButton.hidden = YES;
    // 速率切换按钮
    _speedSegmentButton = [[CameraSpeedSegmentButton alloc] initWithFrame:CGRectZero];
    [self addSubview:_speedSegmentButton];
    _speedSegmentButton.hidden = YES;
    _speedSegmentButton.sender = _speedButton;
    // 折叠功能菜单视图
    _moreMenuView = [[CameraMoreMenuView alloc] initWithFrame:CGRectZero];
    _moreMenuView.alpha = 0;
    _moreMenuView.sender = _moreButton;
    _moreMenuView.delegate = _moreMenuDelegate;
    // 贴纸视图
    _propsItemPanelView = [[PropsPanelView alloc] initWithFrame:CGRectZero];
    _propsItemPanelView.alpha = 0;
    _propsItemPanelView.sender = _stickerButton;
    _propsItemPanelView.delegate = _stickerPaneldelegate;
    // 滤镜视图
    _filterPanelView = [[CameraFilterPanelView alloc] initWithFrame:CGRectZero];
    _filterPanelView.alpha = 0;
    _filterPanelView.sender = _filterButton;
    _filterPanelView.delegate = _filterPanelDelegate;
    _filterPanelView.dataSource = _filterPanelDataSource;
    // 美颜视图
    _beautyPanelView = [[CameraBeautyPanelView alloc] initWithFrame:CGRectZero];
    _beautyPanelView.alpha = 0;
    _beautyPanelView.sender = _beautyButton;
    _beautyPanelView.delegate = _filterPanelDelegate;
    _beautyPanelView.dataSource = _filterPanelDataSource;
    // 相机模式
    _captureModeControl.titles = @[NSLocalizedStringFromTable(@"tu_拍照", @"VideoDemo", @"拍照"), NSLocalizedStringFromTable(@"tu_长按拍摄", @"VideoDemo", @"长按拍摄"), NSLocalizedStringFromTable(@"tu_单击拍摄", @"VideoDemo", @"单击拍摄")];
    _captureModeControl.selectedIndex = 1;
    // 录制按钮
    [_captureButton addDelegate:self];
    // 滤镜标题
    _filterNameLabel.alpha = 0;
    // 容器视图
    _blockTapViews = @[_captureModeControl, _moreMenuView, _propsItemPanelView, _filterPanelView, _beautyPanelView];
    _bottomViews = @[_leftBottomToolBar, _rightBottomToolBar, _captureButton, _captureModeControl, _undoButton];
    
    _recordingHiddenViews = @[_topToolBar, _leftBottomToolBar, _rightBottomToolBar];
    
    for (UIButton *button in _topToolBar.arrangedSubviews) {
        [button addTarget:self action:@selector(toolbarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    CGRect safeBounds = self.bounds;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, safeAreaInsets);
    }
    
    const CGFloat speedSegmentSideMargin = 37.5;
    const CGFloat speedSegmentH = 30;
    const CGFloat height_3_4 = CGRectGetWidth(safeBounds) / 3 * 4;
    const CGFloat speedSegmentOffset = 10;
    CGFloat speedSegmentY = height_3_4 - speedSegmentOffset - speedSegmentH;
    if (@available(iOS 11.0, *)) {
        CGFloat topOffset = self.safeAreaInsets.top;
        if (topOffset > 0) {
            speedSegmentY = topOffset + kTopBarHeight + height_3_4 - speedSegmentOffset - speedSegmentH;
        }
    }
    // 初始化速率变化按钮
    _speedSegmentButton.frame = CGRectMake(CGRectGetMinX(safeBounds) + speedSegmentSideMargin, speedSegmentY,
                                           CGRectGetMaxX(safeBounds) - speedSegmentSideMargin * 2, speedSegmentH);
    // 初始化折叠功能菜单视图
    const CGFloat moreMenuX = 10;
    _moreMenuView.frame = CGRectMake(CGRectGetMinX(safeBounds) + moreMenuX, CGRectGetMinY(safeBounds) + 74, CGRectGetWidth(safeBounds) - moreMenuX * 2, _moreMenuView.intrinsicContentSize.height);
    // 初始化贴纸视图
    const CGFloat stickerPanelHeight = 200 + safeAreaInsets.bottom;
    _propsItemPanelView.frame = CGRectMake(0, size.height - stickerPanelHeight, size.width, stickerPanelHeight);
    // 初始化滤镜视图
    const CGFloat filterPanelHeight = 276 + safeAreaInsets.bottom;
    _filterPanelView.frame = CGRectMake(0, size.height - filterPanelHeight, size.width, filterPanelHeight);
    // 初始化美颜视图
    _beautyPanelView.frame = CGRectMake(0, size.height - filterPanelHeight, size.width, filterPanelHeight);
    
    [_captureModeControl setNeedsDisplay];
}

#pragma mark - property

/**
 设置当前顶部视图

 @param currentTopPanelView 当前顶部显示的视图
 */
- (void)setCurrentTopPanelView:(UIView<OverlayViewProtocol> *)currentTopPanelView {
    [self setTopPanel:_currentTopPanelView hidden:YES];
    
    _currentTopPanelView = currentTopPanelView;
    if (!_currentTopPanelView) return;
    
    [self setTopPanel:currentTopPanelView hidden:NO];
}

/**
 设置当前底部视图

 @param currentBottomPanelView 当前底部显示的视图
 */
- (void)setCurrentBottomPanelView:(UIView<OverlayViewProtocol> *)currentBottomPanelView {
    [self setBottomPanel:_currentBottomPanelView hidden:YES];
    
    _currentBottomPanelView = currentBottomPanelView;
    if (!_currentBottomPanelView) return;
    
    [self setBottomPanel:currentBottomPanelView hidden:NO];
}

/**
 设置滤镜名称

 @param filterName 滤镜名称
 */
- (void)setFilterName:(NSString *)filterName {
    _filterName = filterName;
    _filterNameLabel.text = filterName;
    
    if (_filterNameLabel.alpha != 0.0) return;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.filterNameLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationDuration delay:1 options:0 animations:^{
            self.filterNameLabel.alpha = 0;
        } completion:^(BOOL finished) {}];
    }];
}

#pragma mark - 按钮事件

/**
 选中的按钮状态

 @param sender 选中的按钮
 */
- (void)toolbarButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

/**
 速率变化按钮状态

 @param sender 选中的按钮
 */
- (IBAction)speedButtonAction:(UIButton *)sender {
    _speedSegmentButton.hidden = sender.selected;
    if (!sender.selected) {
        self.currentBottomPanelView.sender.selected = NO;
        self.currentBottomPanelView = nil;
    }
}

/**
 顶部显示视图

 @param sender 按钮
 */
- (IBAction)moreButtonAction:(UIButton *)sender {
    self.currentTopPanelView = sender.selected ? nil : _moreMenuView;
}

/**
 底部显示按钮状态

 @param sender 按钮
 */
- (IBAction)stickerButtonAction:(UIButton *)sender {
    self.currentBottomPanelView = sender.selected ? nil : _propsItemPanelView;
}

/**
 底部显示按钮状态

 @param sender 按钮
 */
- (IBAction)filterButtonAction:(UIButton *)sender {
    self.currentBottomPanelView = sender.selected ? nil : _filterPanelView;
    if (_currentBottomPanelView && [self.delegate respondsToSelector:@selector(controlMask:didShowFilterPanel:)]) {
        [self.delegate controlMask:self didShowFilterPanel:(id<CameraFilterPanelProtocol>)_currentBottomPanelView];
    }
}

/**
 底部显示按钮状态

 @param sender 按钮
 */
- (IBAction)beautyButtonAction:(UIButton *)sender {
    self.currentBottomPanelView = sender.selected ? nil : _beautyPanelView;
    if (_currentBottomPanelView && [self.delegate respondsToSelector:@selector(controlMask:didShowFilterPanel:)]) {
        [self.delegate controlMask:self didShowFilterPanel:(id<CameraFilterPanelProtocol>)_currentBottomPanelView];
    }
}

/**
 点按事件

 @param sender 手势
 */
- (IBAction)tapAction:(UITapGestureRecognizer *)sender  {
    [self hideAllOverlayViews];
}

/**
 捏合手势事件
 
 @param sender 手势
 */
- (IBAction)pinchAction:(UIPinchGestureRecognizer *)sender {
    CGFloat scale = sender.scale - 1;
    if ([self.delegate respondsToSelector:@selector(controlMask:didChangeZoomDelta:)]) {
        [self.delegate controlMask:self didChangeZoomDelta:scale];
    }
    sender.scale = 1;
}

#pragma mark - private

/**
 去除所有叠层面板
 */
- (void)hideAllOverlayViews {
    _currentTopPanelView.sender.selected = NO;
    _currentBottomPanelView.sender.selected = NO;
    self.currentBottomPanelView = self.currentTopPanelView = nil;
}

/**
 在页面下部出现/隐藏给定面板

 @param panel 显示视图
 @param hidden 视图显隐状态
 */
- (void)setBottomPanel:(UIView *)panel hidden:(BOOL)hidden {
    [self setPanel:panel hidden:hidden fromTop:NO];
    
    // 页面下部出现的控件会遮挡原本的视图，因此在此需要做切换显示
    [UIView animateWithDuration:kAnimationDuration animations:^{
        for (UIView *view in self.bottomViews) {
            view.alpha = hidden ? 1 : 0;
        }
    }];
    
    if (!hidden) {
        // 下部面板显示时，取消选中速率按钮，处理速率控件
        _speedSegmentButton.sender.selected = NO;
        [self updateSpeedSegmentDisplay];
    }
}

/**
 在页面上方出现/隐藏给定面板

 @param panel 显示视图
 @param hidden 视图显隐状态
 */
- (void)setTopPanel:(UIView *)panel hidden:(BOOL)hidden {
    [self setPanel:panel hidden:hidden fromTop:YES];
}

/**
 设置视图显示位置和状态

 @param panel 显示视图
 @param hidden 视图显隐状态
 @param fromTop 距离
 */
- (void)setPanel:(UIView *)panel hidden:(BOOL)hidden fromTop:(BOOL)fromTop {
    if ((panel.alpha == 0.0) == hidden) return;
    
    CGFloat multiplier = fromTop ? 1.0 : -1.0;
    CGPoint panelCenter = panel.center;
    
    if (hidden) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            panel.alpha = 0;
            panel.center = CGPointMake(panelCenter.x, panelCenter.y + 44);
        } completion:^(BOOL finished) {
            panel.center = panelCenter;
            [panel removeFromSuperview];
        }];
    } else {
        [self addSubview:panel];
        panel.center = CGPointMake(panelCenter.x, panelCenter.y - 44 * multiplier);
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            panel.alpha = 1;
            panel.center = panelCenter;
        }];
    }
}

/**
 按钮显示状态

 @param hidden 按钮显隐状态
 */
- (void)setRecordConfrimViewsHidden:(BOOL)hidden {
    _doneButton.hidden = hidden;
    _undoButton.hidden = hidden;
}

#pragma mark - public

- (void)hideViewsWhenRecording {
    [self hideAllOverlayViews];
    
    [self updateSpeedSegmentDisplay];
    for (UIView *view in _recordingHiddenViews) {
        view.hidden = YES;
    }
    self.captureModeControl.hidden = YES;
    self.speedSegmentButton.hidden = YES;
    [self setRecordConfrimViewsHidden:YES];
}

- (void)showViewsWhenPauseRecording {
    for (UIView *view in _recordingHiddenViews) {
        view.hidden = NO;
    }
    [self updateRecordConfrimViewsDisplay];
    [self updateSpeedSegmentDisplay];
    self.speedSegmentButton.hidden = ! _speedButton.selected;

}

- (void)updateRecordConfrimViewsDisplay {
    BOOL hasRecordFragment = _markableProgressView.progress > 0;
    [self setRecordConfrimViewsHidden:!hasRecordFragment];
    _captureModeControl.hidden = hasRecordFragment;
}

- (void)updateSpeedSegmentDisplay {
    UIControl *sender = _speedSegmentButton.sender;
    BOOL speedSegmentButtonHidden = ![self isViewDisplay:sender] || !sender.selected;
    _speedSegmentButton.hidden = speedSegmentButtonHidden;
}

- (void)showPhotoCaptureConfirmViewWithConfig:(void (^)(PhotoCaptureConfirmView *confirmView))confirmViewConfigHandler {
    PhotoCaptureConfirmView *confirmView = [[PhotoCaptureConfirmView alloc] initWithFrame:self.bounds];
    _photoCaptureconfirmView = confirmView;
    if (confirmViewConfigHandler) confirmViewConfigHandler(confirmView);
    [self addSubview:confirmView];
    [confirmView show];
}

- (void)hidePhotoCaptureConfirmView {
    [_photoCaptureconfirmView hideWithCompletion:^{
        [self.photoCaptureconfirmView removeFromSuperview];
    }];
}

#pragma mark - RecordButtonDelegate

/**
 录制按钮滑动事件回调
 
 @param recordButton 录制按钮
 @param sender 滑动手势
 */
- (void)recordButton:(RecordButton *)recordButton panningWithSender:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            _lastScale = 0;
        } break;
        case UIGestureRecognizerStateChanged:{
            CGPoint captureButtonCenter = _captureButton.center;
            
            CGRect safeBounds = self.bounds;
            if (@available(iOS 11.0, *)) {
                safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
            }
            // 滑动缩放最大 Y 范围
            const CGFloat endZoomY = CGRectGetMinY(safeBounds);
            // 滑动缩放最大范围长度
            const CGFloat zoomLength = CGRectGetMaxY(safeBounds) - 119 - 20;
            // 开始滑动缩放 Y 值
            const CGFloat beginZoomY = zoomLength + endZoomY;
            // Y 差值，用于计算缩放比率
            CGFloat zoomYDiff = beginZoomY - captureButtonCenter.y;
            if (zoomYDiff < 0) {
                zoomYDiff = 0;
            } else if (captureButtonCenter.y < endZoomY) {
                // 当超出最大 Y 范围时的值处理
            }
            
            // 当前缩放比率
            double scale = 5 * zoomYDiff / zoomLength;
            // 与上一次缩放比率做差值
            double scaleDelta = scale - _lastScale;
            if ([self.delegate respondsToSelector:@selector(controlMask:didChangeZoomDelta:)]) {
                [self.delegate controlMask:self didChangeZoomDelta:scaleDelta];
            }
            _lastScale = scale;
        } break;
        default:{} break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    for (UIView *view in _blockTapViews) {
        if ([touch.view isDescendantOfView:view]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - touches

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01 || ![self pointInside:point withEvent:event]) return nil;
    UIView *hitView = [super hitTest:point withEvent:event];
    // 响应子视图
    if (hitView != self) {
        return hitView;
    }
    // 若有叠层，则由自身（tap 手势）响应
    if (_currentTopPanelView || _currentBottomPanelView || [self isViewDisplay:_speedSegmentButton]) {
        return self;
    }
    return nil;
}

#pragma mark - utils

/**
 判断视图是否显示

 @param view 视图
 @return 是否显示
 */
- (BOOL)isViewDisplay:(UIView *)view {
    if (![view isDescendantOfView:self]) {
        return NO;
    }
    if (view.hidden) {
        return NO;
    }
    if (view.alpha == .0) {
        return NO;
    }
    if (view.superview == nil) {
        return NO;
    }
    if (!CGRectContainsRect(view.superview.bounds, view.frame)) {
        return NO;
    }
    
    if (view == self) {
        return YES;
    }
    return [self isViewDisplay:view.superview];
}

@end
