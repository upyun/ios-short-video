//
//  EditTextViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditTextViewController.h"
#import "ScrollVideoTrimmerView.h"
#import "TextColorMenuView.h"
#import "TextEditAreaView.h"
#import "TextFontMenuView.h"
#import "TextStyleMenuView.h"
#import "MediaTextEffect.h"

/// 文字默认时长
static const CGFloat kTextItemDefaultDuration = 2.0;
/// 文字最小时长
static const CGFloat kTextItemMinDuration = 1.0;

@interface EditTextViewController ()<
ScrollVideoTrimmerViewDelegate, TextEditAreaViewDelegate,
UITextViewDelegate,
TextFontMenuViewDelegate, TextColorMenuViewDelegate, TextStyleMenuViewDelegate,
UIGestureRecognizerDelegate
>

/**
 时间修正控件
 */
@property (weak, nonatomic) IBOutlet ScrollVideoTrimmerView *trimmerView;

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;

/**
 操作面板
 */
@property (weak, nonatomic) IBOutlet UIView *actionPanel;

/**
 添加按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *addButton;

/**
 字体按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *fontButton;

/**
 颜色按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *colorButton;

/**
 文字样式按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *styleButton;

/**
 子菜单弱引用
 */
@property (nonatomic, weak) UIView *subMenuView;

/**
 文字编辑区域视图
 */
@property (nonatomic, strong) TextEditAreaView *textEditAreaView;

/**
 当前选中的文字标签
 */
@property (nonatomic, weak) AttributedLabel *currentItemLabel;

/**
 用于编辑文字的文字域
 */
@property (nonatomic, strong) UITextView *textView;

/**
 文字特效模型数组
 */
@property (nonatomic, strong) NSArray *textEffects;

/**
 标记时间轴控件最后一次跳转
 */
@property (nonatomic, assign) BOOL lastSeek;

@end


@implementation EditTextViewController

/**
 完成按钮事件

 @param sender 完成按钮
 */
- (void)doneButtonAction:(UIButton *)sender {
    [super doneButtonAction:sender];
    _textEditAreaView.hidden = YES;
    // 应用文字特效
    TuSDKVideoTrackInfo *trackInfo = self.movieEditor.inputAssetInfo.videoInfo.videoTrackInfoArray.firstObject;
    CGSize videoSize = trackInfo.presentSize;
    NSArray *textEffects = [_textEditAreaView generateTextEffectsWithVideoSize:videoSize];
    for (MediaTextEffect *textEffect in textEffects) {
        [self.movieEditor addMediaEffect:textEffect];
    }
}

/**
 取消按钮事件

 @param sender 取消按钮
 */
- (void)cancelButtonAction:(UIButton *)sender {
    [super cancelButtonAction:sender];
    _textEditAreaView.hidden = YES;
    // 恢复保存的文字特效
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerText];
    if (self.initialEffects.count) {
        for (TuSDKMediaSceneEffect *effect in self.initialEffects) {
            [self.movieEditor addMediaEffect:effect];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复到首帧
    [self.movieEditor seekToTime:kCMTimeZero];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    self.title = NSLocalizedStringFromTable(@"tu_文字", @"VideoDemo", @"文字");
    
    // 配置时间轴
    _trimmerView.thumbnailsView.thumbnails = self.thumbnails;
    _trimmerView.minIntervalProgress = kTextItemMinDuration / CMTimeGetSeconds(self.movieEditor.inputDuration);
    
    // 配置文字编辑区域
    _textEditAreaView = [[TextEditAreaView alloc] initWithFrame:CGRectZero];
    [self.view insertSubview:_textEditAreaView atIndex:0];
    _textEditAreaView.delegate = self;
    
    // 监听键盘弹出与隐藏状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 载入已加入的文字特效
    self.initialEffects = [self.movieEditor mediaEffectsWithType:TuSDKMediaEffectDataTypeStickerText];
    [_textEditAreaView setupWithTextEffects:self.initialEffects];
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerText];
    
    // 跳转到首帧
    [self.movieEditor seekToTime:kCMTimeZero];
    
    // 同步 UI 状态
    _textEditAreaView.selectedIndex = -1;
    _trimmerView.selectedMarkIndex = -1;
    self.playButton.selected = self.movieEditor.isPreviewing;
    [self updateMenuButtonState];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 获取视频在屏幕中的大小，应用到文字编辑区域的布局
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat bottomPreviewOffset = [self.class bottomPreviewOffset];
    if (@available(iOS 11.0, *)) {
        bounds = UIEdgeInsetsInsetRect(bounds, self.view.safeAreaInsets);
    }
    bounds.size.height -= bottomPreviewOffset;
    TuSDKVideoTrackInfo *trackInfo = self.movieEditor.inputAssetInfo.videoInfo.videoTrackInfoArray.firstObject;
    CGSize videoSize = trackInfo.presentSize;
    _textEditAreaView.frame = AVMakeRectWithAspectRatioInsideRect(videoSize, bounds);
    
    // 设置文字缩放
    _textEditAreaView.textScale = videoSize.width / CGRectGetWidth(_textEditAreaView.frame);
}

/**
 同步进度更新文字显示与隐藏

 @param playbackProgress 回调的进度
 */
- (void)showTextItemsWithProgress:(double)playbackProgress {
    for (NSInteger i = 0; i < _textEditAreaView.textEditItemCount; i++) {
        [_textEditAreaView showTextItemAtTime:self.movieEditor.outputTimeAtSlice index:i animated:YES];
    }
}

/**
 更新菜单按钮状态
 */
- (void)updateMenuButtonState {
    _addButton.enabled = !self.playing;
    BOOL editable = _currentItemLabel && !self.playing && _textEditAreaView.textEditItemCount > 0;
    _fontButton.enabled = _colorButton.enabled = _styleButton.enabled = editable;
    if (!editable) {
        [_subMenuView removeFromSuperview];
    }
}

/**
 seek 到给定的时间范围内

 @param timeRange 时间范围
 */
- (void)seekToTimeRange:(CMTimeRange)timeRange {
    CMTime currentTime = self.movieEditor.outputTimeAtSlice;
    if (!CMTimeRangeContainsTime(timeRange, currentTime)) {
        _lastSeek = NO;
        [self.movieEditor seekToInputTime:timeRange.start];
        _trimmerView.animatedNextUpdate = YES;
    } else {
        [self.movieEditor pausePreView];
    }
}

#pragma mark - property

- (UITextView *)textView {
    if (!_textView) {
        // text view，默认隐藏在屏幕下方，编辑文字时随键盘出现而弹出
        CGSize size = [UIScreen mainScreen].bounds.size;
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, size.height, size.width, 55)];
        [self.view addSubview:_textView];
        _textView.alpha = 0;
        _textView.delegate = self;
    }
    return _textView;
}

- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];
    
    _trimmerView.currentProgress = playbackProgress;
    
    // 跳过时间轴最后一次跳转
    if (!_trimmerView.dragging && !_lastSeek) [self showTextItemsWithProgress:playbackProgress];
}

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    self.playButton.selected = playing;
    
    // 清空 UI 状态
    if (playing) {
        _textEditAreaView.selectedIndex = -1;
        _trimmerView.selectedMarkIndex = -1;
        self.currentItemLabel = nil;
        _lastSeek = NO;
    } else {
        [self updateMenuButtonState];
    }
}

- (void)setCurrentItemLabel:(AttributedLabel *)currentItemLabel {
    _currentItemLabel = currentItemLabel;
    [self updateMenuButtonState];
}

#pragma mark - keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    // 键盘弹出时动画呈现 textView
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat endY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.origin.y = endY - textViewFrame.size.height;
    [UIView animateWithDuration:duration animations:^{
        self.textView.frame = textViewFrame;
        self.textView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    // 键盘隐藏式动画隐藏 textView
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat endY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.origin.y = endY;
    [UIView animateWithDuration:duration animations:^{
        self.textView.frame = textViewFrame;
        self.textView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    _currentItemLabel.text = textView.text;
}

#pragma mark - action

/**
 播放按钮事件

 @param sender 播放按钮
 */
- (IBAction)playButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.movieEditor startPreview];
    } else {
        [self.movieEditor pausePreView];
    }
}

/**
 添加文字按钮事件

 @param sender 添加文字按钮
 */
- (IBAction)addButtonAction:(id)sender {
    [_textEditAreaView addDefaultTextEditItem];
}

/**
 字体菜单按钮事件

 @param sender 字体按钮
 */
- (IBAction)fontButtonAction:(id)sender {
    TextFontMenuView *menu = [[TextFontMenuView alloc] initWithFrame:CGRectZero];
    menu.frame = _actionPanel.bounds;
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    _subMenuView = menu;
}

/**
 文字颜色按钮事件

 @param sender 文字颜色按钮
 */
- (IBAction)colorButtonAction:(id)sender {
    TextColorMenuView *menu = [[TextColorMenuView alloc] initWithFrame:CGRectZero];
    menu.frame = _actionPanel.bounds;
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    _subMenuView = menu;
}

/**
 文字样式按钮事件

 @param sender 文字样式按钮
 */
- (IBAction)styleButtonAction:(id)sender {
    TextStyleMenuView *menu = [[TextStyleMenuView alloc] initWithFrame:CGRectZero];
    menu.frame = _actionPanel.bounds;
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    _subMenuView = menu;
}

/**
 点击空白处

 @param sender 点击手势
 */
- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    // 结束编辑
    [self.view endEditing:YES];
    
    // 清空 UI 状态
    self.currentItemLabel = nil;
    _textEditAreaView.selectedIndex = -1;
    _trimmerView.selectedMarkIndex = -1;
}

#pragma mark - UIGestureRecognizerDelegate

/**
 处理手势响应

 @param gestureRecognizer 操作手势
 @param touch touch
 @return 是否允许手势执行
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceive = YES;
    // 响应手势的空白区域
    CGRect blankRect = self.view.bounds;
    blankRect.size.height -= [self.class bottomPreviewOffset];
    shouldReceive = CGRectContainsPoint(blankRect, [touch locationInView:self.view]);
    return shouldReceive;
}

#pragma mark - text menu delegate

#pragma mark TextStyleMenuViewDelegate

/**
 文字样式变更回调

 @param menu 文字样式菜单视图
 @param style 文字样式
 */
- (void)menu:(TextStyleMenuView *)menu didChangeStyle:(TextMenuStyle)style {
    switch (style) {
        // 中心对齐
        case TextMenuStyleAlignCenter:{
            _currentItemLabel.textAlignment = NSTextAlignmentCenter;
        } break;
        // 左对齐
        case TextMenuStyleAlignLeft:{
            _currentItemLabel.textAlignment = NSTextAlignmentLeft;
        } break;
        // 右对齐
        case TextMenuStyleAlignRight:{
            _currentItemLabel.textAlignment = NSTextAlignmentRight;
        } break;
        // 下划线
        case TextMenuStyleUnderLine:{
            _currentItemLabel.underline = !_currentItemLabel.underline;
        } break;
        // 从左到右排列
        case TextMenuStyleLeftToRight:{
            _currentItemLabel.writingDirection = @[@(2)];
        } break;
        // 从右到左排列
        case TextMenuStyleRightToLeft:{
            _currentItemLabel.writingDirection = @[@(3)];
        } break;
    }
}

#pragma mark TextFontMenuViewDelegate

/**
 文字字体变更回调

 @param menu 文字字体菜单视图
 @param font 文字字体
 */
- (void)menu:(TextFontMenuView *)menu didChangeFont:(UIFont *)font {
    CGFloat pointSize = _currentItemLabel.font.pointSize;
    NSString *fontName = font.fontName;
    
    font = [UIFont fontWithName:fontName size:pointSize];
    _currentItemLabel.font = font;
}

#pragma mark TextColorMenuViewDelegate

/**
 文字颜色变更回调

 @param menu 文字颜色菜单视图
 @param color 文字颜色
 @param type 文字样式颜色
 */
- (void)menu:(TextColorMenuView *)menu didChangeColor:(UIColor *)color forType:(TextColorType)type {
    switch (type) {
        // 文字背景颜色
        case TextColorTypeBackground:{
            _currentItemLabel.backgroundColor = color;
        } break;
        // 文字描边颜色
        case TextColorTypeStroke:{
            _currentItemLabel.textStrokeColor = color;
        } break;
        // 文字字体颜色
        case TextColorTypeText:{
            _currentItemLabel.textColor = color;
        } break;
    }
}

#pragma mark - TextEditAreaViewDelegate

/**
 文字项变更回调
 
 @param textEditAreaView 文字编辑视图
 @param itemLabel 文本 label
 @param itemIndex 元素索引
 @param added 是否添加
 @param removed 是否移除
 */
- (void)textEditAreaView:(TextEditAreaView *)textEditAreaView didUpdateItem:(AttributedLabel *)itemLabel itemIndex:(NSInteger)itemIndex added:(BOOL)added removed:(BOOL)removed {
    if (added) {
        CMTime duration = self.movieEditor.inputDuration;
        if (CMTIMERANGE_IS_INVALID(itemLabel.timeRange)) {
            // 设置默认的时间范围
            CMTime startTime = self.movieEditor.outputTimeAtSlice;
            NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
            if (durationInterval - CMTimeGetSeconds(startTime) < kTextItemDefaultDuration) {
                startTime = CMTimeMakeWithSeconds(durationInterval - kTextItemDefaultDuration, duration.timescale);
            }
            
            if (CMTimeGetSeconds(startTime) < 0) {
                startTime = kCMTimeZero;
            }
            
            itemLabel.timeRange = CMTimeRangeMake(startTime, CMTimeMakeWithSeconds(kTextItemDefaultDuration, duration.timescale));
        }
        
        // 联动更新 UI
        self.currentItemLabel = itemLabel;
        [_trimmerView addMarkWithColor:[UIColor colorWithRed:255/255.0 green:204/255.0 blue:0/255.0 alpha:0.5] timeRange:itemLabel.timeRange atDuration:duration];
        _trimmerView.selectedMarkIndex = itemIndex;
    }
    if (removed) {
        // 联动更新 UI
        self.currentItemLabel = nil;
        [_trimmerView removeMarkAtIndex:itemIndex];
        _trimmerView.trimmerMaskView.hidden = YES;
        [self.view endEditing:YES];
    }
}

/**
 选中文字项回调，在此更新 `currentItemLabel` 属性、更新 `currentTextEffect` 属性、更新 UI
 
 @param textEditAreaView 文字编辑视图
 @param selectedIndex 选中索引
 @param itemLabel 文本 label
 */
- (void)textEditAreaView:(TextEditAreaView *)textEditAreaView didSelectIndex:(NSInteger)selectedIndex itemLabel:(AttributedLabel *)itemLabel {
    // 更新 UI
    self.currentItemLabel = itemLabel;
    [_trimmerView selectMarkWithIndex:selectedIndex];
    
    // 跳转到文字的时间范围内
    [self seekToTimeRange:itemLabel.timeRange];
}

/**
 文字编辑状态回调，在此弹出 textView 进行编辑
 
 @param textEditAreaView 文字编辑区域
 @param itemLabel 文字 label
 */
- (void)textEditAreaView:(TextEditAreaView *)textEditAreaView shouldEditItem:(AttributedLabel *)itemLabel {
    self.textView.text = itemLabel.text;
    [self.textView becomeFirstResponder];
}

#pragma mark - ScrollVideoTrimmerViewDelegate

/**
 标记选中回调

 @param trimmer 时间轴
 @param markIndex 标记索引
 */
- (void)trimmer:(ScrollVideoTrimmerView *)trimmer didSelectMarkWithIndex:(NSUInteger)markIndex {
    // 更新 UI
    _textEditAreaView.selectedIndex = markIndex;
    AttributedLabel *itemLabel = [_textEditAreaView itemLabelAtIndex:markIndex];
    self.currentItemLabel = itemLabel;
    
    // 跳转到文字的时间范围内
    if (itemLabel) [self seekToTimeRange:itemLabel.timeRange];
}

#pragma mark VideoTrimmerViewDelegate

/**
 时间轴进度更新回调

 @param trimmer 时间轴
 @param progress 时间进度
 @param location 时间轴标记
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer updateProgress:(double)progress atLocation:(TrimmerTimeLocation)location {
    NSTimeInterval duration = CMTimeGetSeconds(self.movieEditor.inputDuration);
    NSTimeInterval targetTime = duration * progress;
    [self.movieEditor seekToInputTime:CMTimeMakeWithSeconds(targetTime, self.movieEditor.inputDuration.timescale)];
    
    switch (location) {
        // 左滑块修整时间
        case TrimmerTimeLocationLeft:
        // 右滑块修整时间
        case TrimmerTimeLocationRight:{
            _currentItemLabel.timeRange = [_trimmerView selectedTimeRangeAtDuration:self.movieEditor.inputDuration];
            [_textEditAreaView setTextItemAtIndex:_textEditAreaView.selectedIndex hidden:NO animated:NO];
        } break;
        // 当前游标修整时间
        case TrimmerTimeLocationCurrent:{
            [self showTextItemsWithProgress:progress];
        } break;
        default:{} break;
    }
}

/**
 时间轴开始滑动回调

 @param trimmer 时间轴
 @param location 时间轴标记
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didStartAtLocation:(TrimmerTimeLocation)location {
    [self.movieEditor pausePreView];
    _lastSeek = NO;
}

/**
 时间轴结束滑动回调

 @param trimmer 时间轴
 @param location 时间轴标记
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer didEndAtLocation:(TrimmerTimeLocation)location {
    _lastSeek = YES;
}

/**
 时间轴到达临界值回调

 @param trimmer 时间轴
 @param reachMaxIntervalProgress 时间轴最大进度
 @param reachMinIntervalProgress 时间轴最小进度
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer reachMaxIntervalProgress:(BOOL)reachMaxIntervalProgress reachMinIntervalProgress:(BOOL)reachMinIntervalProgress {
    if (reachMinIntervalProgress) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_特效时长最少%@秒", @"VideoDemo", @"特效时长最少%@秒"), @(kTextItemMinDuration)];
        [[TuSDK shared].messageHub showToast:message];
    }
}

@end
