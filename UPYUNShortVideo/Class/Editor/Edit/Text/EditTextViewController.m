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
#import "TextFontMenuView.h"
#import "TextStyleMenuView.h"
#import "TextSpaceMenuView.h"
#import "TextAlphaMenuView.h"
#import "TextBorderMenuView.h"
#import "TextBgColorMenuView.h"
#import "TextAlignmentMenuView.h"
#import "TextDirectionMenuView.h"
#import "TextFontSizeMenuView.h"
#import "MediaTextEffect.h"
#import "StickerEditor.h"
#import "TextStickerEditorItem.h"
#import "ImageStickerEditorItem.h"

/// 文字默认时长
static const CGFloat kTextItemDefaultDuration = 1.0;
/// 文字最小时长
static const CGFloat kTextItemMinDuration = 1.0;

API_AVAILABLE(ios(9.0))
@interface EditTextViewController ()<
ScrollVideoTrimmerViewDelegate,
TextFontMenuViewDelegate,
TextColorMenuViewDelegate,
TextStyleMenuViewDelegate,
TextSpaceMenuViewDelegate,
TextAlphaMenuViewDelegate,
TextBorderMenuViewDelegate,
TextBgColorMenuViewDelegate,
TextAlignmentMenuViewDelegate,
TextDirectionMenuViewDelegate,
TextFontSizeMenuViewDelegate,
StickerEditorDelegate,
TextStickerEditorItemDelegate,
UIGestureRecognizerDelegate,
UITextViewDelegate
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
 底部文字菜单
 */
@property (weak, nonatomic) IBOutlet UIStackView *menuStackView;

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
 下一个文字项中点坐标
 */
@property (nonatomic, assign) CGPoint nextTextEditItemCenter;

/**
 贴纸编辑视图
 */
@property (nonatomic)  StickerEditor *stickerEditor;

/**
 当前选中的文字标签
 */
@property (nonatomic, weak) AttributedLabel *currentItemLabel;

/* desc */
@property (nonatomic, weak) TextStickerEditorItem *currentItem;

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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewContraints;

@end


@implementation EditTextViewController

/**
 完成按钮事件

 @param sender 完成按钮
 */
- (void)doneButtonAction:(UIButton *)sender {
    [super doneButtonAction:sender];
    // 应用文字特效
    CGSize videoSize = self.movieEditor.options.outputSizeOptions.outputSize;
    NSArray *textEffects = [_stickerEditor resultsWithRegionRect:CGRectMake(0, 0, videoSize.width, videoSize.height)];
    
    for (MediaTextEffect *textEffect in textEffects)
        [self.movieEditor addMediaEffect:textEffect];
    
   // 清理数据
    self.initialEffects = nil;
    _stickerEditor = nil;
}

/**
 取消按钮事件

 @param sender 取消按钮
 */
- (void)cancelButtonAction:(UIButton *)sender {
    [super cancelButtonAction:sender];
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
    
    /** 初始化 StickerEditor 用于编辑文字贴纸 */
    _stickerEditor = [[StickerEditor alloc] initWithHolderView:self.view];
    _stickerEditor.delegate = self;
    
    // 监听键盘弹出与隐藏状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 配置时间轴
    _trimmerView.thumbnailsView.thumbnails = self.thumbnails;
    _trimmerView.minIntervalProgress = kTextItemMinDuration / CMTimeGetSeconds(self.movieEditor.inputDuration);
    _trimmerView.selectedMarkIndex = -1;
    
    self.playButton.selected = self.movieEditor.isPreviewing;
    [self updateMenuButtonState];
    
    // 获取视频在屏幕中的大小，应用到文字编辑区域的布局
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat bottomPreviewOffset = [self.class bottomPreviewOffset];
//    if (@available(iOS 11.0, *)) {
//        bounds = UIEdgeInsetsInsetRect(bounds, self.view.safeAreaInsets);
//    }
    bounds.size.height -= bottomPreviewOffset;
    bounds.origin.y = 0;
    
    TuSDKVideoTrackInfo *trackInfo = self.movieEditor.inputAssetInfo.videoInfo.videoTrackInfoArray.firstObject;
    CGSize videoSize = trackInfo.presentSize;
    
    /** 计算视频绘制区域 */
    if (self.movieEditor.options.outputSizeOptions.aspectOutputRatioInSideCanvas) {
        // 根据用户设置的比例计算
        CGRect outputRect = AVMakeRectWithAspectRatioInsideRect(self.movieEditor.options.outputSizeOptions.outputSize, bounds);
        _stickerEditor.contentView.frame = outputRect;
    }else {
        _stickerEditor.contentView.frame = AVMakeRectWithAspectRatioInsideRect(videoSize, bounds);
    }
    
    /**
     由于 StickerEditor 和  MovieEditor 的特效不能同时显示，也为了保证图片贴纸和文字贴纸的编辑顺序，并在 UI 上有层级关系，这里统一将 TuSDKMediaEffectDataTypeStickerText 与 TuSDKMediaEffectDataTypeStickerImage 添加至 StickerEditor，点击保存时通过 StickerEditor 获取编辑后的特效并添加至 MovieEditor。
     */
    NSMutableArray<id<TuSDKMediaEffect>> *initialEffects = [NSMutableArray array];
    self.initialEffects = initialEffects;

    __weak typeof(self)weakSelf = self;
    [[self.movieEditor allMediaEffects] enumerateObjectsUsingBlock:^(id<TuSDKMediaEffect> _Nonnull effect, NSUInteger idx, BOOL * _Nonnull stop)
     {
        if (effect.effectType == TuSDKMediaEffectDataTypeStickerText)
        {
            /** appendStickerImageEffect 显示时 需要依赖 _stickerViewEditor 的 frame  */
            TextStickerEditorItem *item = [[TextStickerEditorItem alloc] initWithEditor:weakSelf.stickerEditor];
            item.delegate = weakSelf;
            item.effect = effect;
            item.tag  = idx;
            item.selected = NO;
            item.isChanged = NO;
            [weakSelf addItem:item];
            [initialEffects addObject:effect];
        }
    }];
    
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerText];

    [_stickerEditor showItemByTime:kCMTimeZero];
    [self.movieEditor pausePreView];
    [self.movieEditor seekToTime:kCMTimeZero];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"dealloc: %@", self);
    if (_stickerEditor) {
        _stickerEditor = nil;
    }
}

/**
 设置是否启用文字菜单

 @param enable 启用
 */
- (void)setEnableTextMenus:(BOOL)enable;{
    
    [self.menuStackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx <= 0) return;
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subView isKindOfClass:[UIControl class]]) {
                UIControl *control = subView;
                control.enabled = enable;
                subView.tintColor = enable ? [UIColor whiteColor]: [UIColor grayColor];
            }else if([subView isKindOfClass:[UILabel class]])
            {
                UILabel *title = subView;
                title.textColor = enable ? [UIColor whiteColor] : [UIColor grayColor];
            }
        }];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _bottomViewContraints.constant = self.bottomNavigationBar.frame.size.height;
    
    // 获取视频在屏幕中的大小，应用到文字编辑区域的布局
    CGRect bounds = self.movieEditor.holderView.bounds;
    TuSDKVideoTrackInfo *trackInfo = self.movieEditor.inputAssetInfo.videoInfo.videoTrackInfoArray.firstObject;
    CGSize videoSize = trackInfo.presentSize;
    bounds.origin = CGPointMake(0, self.movieEditor.holderView.superview.frame.origin.y);
    /** 计算视频绘制区域 */
    if (self.movieEditor.options.outputSizeOptions.aspectOutputRatioInSideCanvas) {
        // 根据用户设置的比例计算
        CGRect outputRect = AVMakeRectWithAspectRatioInsideRect(self.movieEditor.options.outputSizeOptions.outputSize, bounds);
        _stickerEditor.contentView.frame = outputRect;
    }else {
        _stickerEditor.contentView.frame = AVMakeRectWithAspectRatioInsideRect(videoSize, bounds);
    }
}


/**
 同步进度更新文字显示与隐藏

 @param playbackProgress 回调的进度
 */
- (void)showTextItemsWithProgress:(double)playbackProgress {
    [_stickerEditor showItemByTime:self.movieEditor.outputTimeAtSlice];
}

/**
 更新菜单按钮状态
 */
- (void)updateMenuButtonState {
    _addButton.enabled = !self.playing;
    
    __block NSUInteger count = 0;
    [[_stickerEditor items] enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull eachItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([eachItem isKindOfClass:[TextStickerEditorItem class]] && eachItem.selected)
            count ++;
    }];
    
    BOOL editable = _currentItemLabel && !self.playing && count > 0;
    [self setEnableTextMenus:editable];
    
    if (!editable)
        [_subMenuView removeFromSuperview];
    
    if ([_subMenuView respondsToSelector:@selector(updateByAttributeLabel:)])
        [_subMenuView performSelector:@selector(updateByAttributeLabel:) withObject:_currentItemLabel];

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

        [_stickerEditor cancelSelectedAllItems];
        _trimmerView.selectedMarkIndex = -1;
        self.currentItemLabel = nil;
        self.currentItem = nil;
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
    _currentItem.isChanged = YES;
}

/**
 编辑文本框内容改变处理
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;{
    
    // 换行符限制
    if ([text isEqualToString:@"\n"] && textView.text.length > 3) {
        NSString *lastChar = [textView.text substringFromIndex:textView.text.length - 3];
        if ([lastChar isEqualToString:@"\n\n\n"]){
            [[[TuSDK shared] messageHub] showError:NSLocalizedStringFromTable(@"tu_换行数量限制", @"VideoDemo", @"最多支持三个换行符")];
            return NO;
        }
    }
    return YES;
}

- (void)setSubMenuView:(UIView *)subMenuView;{
    _subMenuView = subMenuView;
    if ([_subMenuView respondsToSelector:@selector(updateByAttributeLabel:)])
        [_subMenuView performSelector:@selector(updateByAttributeLabel:) withObject:_currentItemLabel];
    
}

#pragma mark - action

/**
 播放按钮事件

 @param sender 播放按钮
 */
- (IBAction)playButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (self.trimmerView.currentProgress >= 1.0) {
            [self.movieEditor seekToTime:kCMTimeZero];
        }
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
    
    TextStickerEditorItem *item = [[TextStickerEditorItem alloc] initWithEditor:_stickerEditor];
    item.delegate = self;
    item.center = self.nextTextEditItemCenter;
    item.textLabel = [AttributedLabel defaultLabel];
    item.selected = YES;
    
    [self addItem:item];
}

/**
 多次重复添加时防止覆盖
 */
- (CGPoint)nextTextEditItemCenter;{
    if (CGPointEqualToPoint(_nextTextEditItemCenter,CGPointZero)) {
        _nextTextEditItemCenter =  CGPointMake(CGRectGetMidX(_stickerEditor.contentView.bounds), CGRectGetMidY(_stickerEditor.contentView.bounds));
    }else
    {
        _nextTextEditItemCenter = CGPointMake(_nextTextEditItemCenter.x + 7, _nextTextEditItemCenter.y + 7);
        if (_nextTextEditItemCenter.x > CGRectGetMaxX(_stickerEditor.contentView.bounds)) {
            _nextTextEditItemCenter.x = CGRectGetMaxX(_stickerEditor.contentView.bounds);
        } else if (_nextTextEditItemCenter.x < 0) {
            _nextTextEditItemCenter.x = 0;
        }
        if (_nextTextEditItemCenter.y > CGRectGetMaxY(_stickerEditor.contentView.bounds)) {
            _nextTextEditItemCenter.y = CGRectGetMaxY(_stickerEditor.contentView.bounds);
        } else if (_nextTextEditItemCenter.y < 0) {
            _nextTextEditItemCenter.y = 0;
        }
    }
    return _nextTextEditItemCenter;
}

/**
 添加一个文字贴纸项

 @param item 文字贴纸项
 */
- (void)addItem:(TextStickerEditorItem *)item {
    
    __weak typeof(item) weak_control = item;
    item.textLabel.labelUpdateHandler = ^(AttributedLabel *label) {
        [weak_control updateLayoutWithContentSize:label.intrinsicContentSize];
    };
    
    [_stickerEditor cancelSelectedAllItems];
    [_stickerEditor addItem:item];
}

/**
 字体菜单按钮事件

 @param sender 字体按钮
 */
- (IBAction)fontButtonAction:(id)sender {
    TextFontMenuView *menu = [[TextFontMenuView alloc] initWithFrame:_actionPanel.bounds];
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    self.subMenuView = menu;
}

/**
 间距菜单按钮事件
 
 @param sender 间距按钮
 */
- (IBAction)spaceButtonAction:(id)sender {
    TextSpaceMenuView *menu = [[TextSpaceMenuView alloc] initWithFrame:CGRectZero];
    menu.frame = _actionPanel.bounds;
    menu.delegate = self;
    [menu setValue:_currentItemLabel.lineSpace spaceType:TextSpaceTypeLine];
    [menu setValue:_currentItemLabel.wordSpace spaceType:TextSpaceTypeWord];
    [_actionPanel addSubview:menu];
    self.subMenuView = menu;
}

/**
 对齐菜单按钮事件
 
 @param sender 间距按钮
 */
- (IBAction)alignmentButtonAction:(id)sender {
    TextAlignmentMenuView *menu = [[TextAlignmentMenuView alloc] initWithFrame:_actionPanel.bounds];
    menu.alignment = _currentItemLabel.textAlignment;
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    self.subMenuView = menu;
}

/**
 对齐菜单按钮事件
 
 @param sender 间距按钮
 */
- (IBAction)directionButtonAction:(id)sender {
    TextDirectionMenuView *menu = [[TextDirectionMenuView alloc] initWithFrame:_actionPanel.bounds];
    
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    self.subMenuView = menu;
}

/**
 对齐菜单按钮事件
 
 @param sender 间距按钮
 */
- (IBAction)fontSizeButtonAction:(id)sender {
    TextFontSizeMenuView *menu = [[TextFontSizeMenuView alloc] initWithFrame:_actionPanel.bounds];
    menu.defaultFontSize = kDefalutFontSize;
    menu.maxFontSize = kMaxFontSize;
    menu.fontSize = _currentItemLabel.font.pointSize;
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    self.subMenuView = menu;
}

/**
 背景菜单按钮事件
 
 @param sender 间距按钮
 */
- (IBAction)bgColorButtonAction:(id)sender {
    TextBgColorMenuView *menu = [[TextBgColorMenuView alloc] initWithFrame:CGRectZero];
    menu.frame = _actionPanel.bounds;
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    self.subMenuView = menu;
}

/**
 边框菜单按钮事件
 
 @param sender 间距按钮
 */
- (IBAction)borderButtonAction:(id)sender {
    TextBorderMenuView *menu = [[TextBorderMenuView alloc] initWithFrame:CGRectZero];
    menu.frame = _actionPanel.bounds;
    menu.strokeWidth = fabs(_currentItemLabel.textStrokeWidth);
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    self.subMenuView = menu;
}

/**
 透明度菜单按钮事件
 
 @param sender 间距按钮
 */
- (IBAction)alphaButtonAction:(id)sender {
    TextAlphaMenuView *menu = [[TextAlphaMenuView alloc] initWithFrame:CGRectZero];
    menu.frame = _actionPanel.bounds;
    menu.delegate = self;
    [_actionPanel addSubview:menu];
    self.subMenuView = menu;
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
    self.subMenuView = menu;
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
    self.subMenuView = menu;
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
    self.currentItem = nil;
    [_stickerEditor cancelSelectedAllItems];
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
        // 下划线
        case TextMenuStyleUnderLine:{
            _currentItemLabel.underline = !_currentItemLabel.underline;
        } break;
        case TextMenuStyleItalics:{
            _currentItemLabel.obliqueness =  !_currentItemLabel.obliqueness;
        } break;
        case TextMenuStyleBold:{
            _currentItemLabel.bold =  !_currentItemLabel.bold;
        } break;
        default:{
            _currentItemLabel.bold = NO;
            _currentItemLabel.underline = NO;
             _currentItemLabel.obliqueness = NO;
            break;
        }
    }
    _currentItem.isChanged = YES;
    [menu updateByAttributeLabel:_currentItemLabel];
}

#pragma mark - TextDirectionMenuViewDelegate

- (void)menu:(TextDirectionMenuView *)menu didChangeDirectionType:(TextDirectionType)directionType {
    _currentItemLabel.writingDirection = @[@(directionType)];
    _currentItem.isChanged = YES;
}

#pragma mark - TextFontSizeMenuViewDelegate

-(void)menu:(TextFontSizeMenuView *)menu didChangeFontSize:(CGFloat)fontSize
{
    _currentItem.isChanged = YES;
    _currentItemLabel.font = _currentItemLabel.bold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
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
    _currentItem.isChanged = YES;
}

#pragma mark TextColorMenuViewDelegate

/**
 文字颜色变更回调

 @param menu 文字颜色菜单视图
 @param color 文字颜色
 */
- (void)menu:(TextColorMenuView *)menu didChangeTextColor:(UIColor *)color
{
    _currentItemLabel.textColor = color;
    _currentItem.isChanged = YES;
}

#pragma mark - TextSpaceMenuViewDelegate
- (void)menu:(TextSpaceMenuView *)menu didChangeSpace:(CGFloat)space forType:(TextSpaceType)type {
    switch (type) {
        case TextSpaceTypeWord:
            _currentItemLabel.wordSpace = space;
            break;
        case TextSpaceTypeLine:
            _currentItemLabel.lineSpace = space;
            break;
        default:
            break;
    }
    _currentItem.isChanged = YES;
}

#pragma mark - TextAlphaMenuViewDelegate
- (void)menu:(TextAlphaMenuView *)menu didChangeAlphavalue:(CGFloat)value {
    _currentItemLabel.textColor = [_currentItemLabel.textColor colorWithAlphaComponent:value];
    _currentItem.isChanged = YES;
}

#pragma mark - TextBorderMenuViewDelegate
- (void)menu:(TextBorderMenuView *)menu didChangeBorderSize:(CGFloat)borderSize {
    _currentItemLabel.textStrokeWidth = borderSize;
    _currentItem.isChanged = YES;
}

- (void)menu:(TextBorderMenuView *)menu didChangeBorderColor:(UIColor *)color {
    _currentItemLabel.textStrokeColor = color;
    _currentItem.isChanged = YES;
}

#pragma mark - TextBgColorMenuViewDelegate
-(void)menu:(TextBgColorMenuView *)menu didChangeBgColor:(UIColor *)color
{
    _currentItem.isChanged = YES;
    _currentItemLabel.backgroundColor = [color colorWithAlphaComponent:CGColorGetAlpha(_currentItemLabel.backgroundColor.CGColor)];
}

-(void)menu:(TextBgColorMenuView *)menu didChangeBgAlpha:(CGFloat)alpha
{
    _currentItem.isChanged = YES;
    _currentItemLabel.backgroundColor = [_currentItemLabel.backgroundColor colorWithAlphaComponent:alpha];
}

#pragma mark - TextAlignmentMenuViewDelegate
-(void)menu:(TextAlignmentMenuView *)menu didChangeAlignment:(NSTextAlignment)alignment;{
    _currentItemLabel.textAlignment = alignment;
    _currentItem.isChanged = YES;
}

#pragma mark - ScrollVideoTrimmerViewDelegate

/**
 标记选中回调

 @param trimmer 时间轴
 @param markIndex 标记索引
 */
- (void)trimmer:(ScrollVideoTrimmerView *)trimmer didSelectMarkWithIndex:(NSUInteger)markIndex {
    
    [_stickerEditor selectWithIndex:markIndex];

    if (markIndex == NSNotFound) {
        self.currentItemLabel = nil;
        self.currentItem = nil;
    }
    // 更新 UI
    TextStickerEditorItem *item = (TextStickerEditorItem *)[_stickerEditor itemByTag:markIndex];
    if (item.selected) return;
    
    self.currentItemLabel = item.textLabel;
    self.currentItem = item;
    item.selected = YES;
    // 跳转到文字的时间范围内
    if (item.textLabel) [self seekToTimeRange:item.textLabel.timeRange];
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
            _currentItem.isChanged = YES;
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

#pragma mark - StickerEditorDelegate

@implementation EditTextViewController (StickerEditorDelegate)

-(void)resetItemsTag;{
    __block NSUInteger count = 0;
    [[_stickerEditor items] enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull eachItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([eachItem isKindOfClass:[TextStickerEditorItem class]]) {
            eachItem.tag = count;
            count ++;
        }
    }];
}

/**
 Description
 
 @param item item description
 */
- (void)shouldEditItem:(TextStickerEditorItem *)item; {
    self.currentItem = item;
    self.currentItemLabel = item.textLabel;
    self.textView.text = item.textLabel.text;
    [self.textView becomeFirstResponder];
}

/**
 一个贴纸项被添加
 
 @param editor 视频编辑器
 @param item 贴纸项
 */
- (void)imageStickerEditor:(StickerEditor *)editor didAddItem:(TextStickerEditorItem *)item;{
    if (!item.editable) return;
    [self resetItemsTag];

    CMTime duration = self.movieEditor.inputDuration;
    if (CMTIMERANGE_IS_INVALID(item.textLabel.timeRange)) {
        // 设置默认的时间范围
        CMTime startTime = self.movieEditor.outputTimeAtSlice;
        NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
        if (durationInterval - CMTimeGetSeconds(startTime) < kTextItemDefaultDuration) {
            startTime = CMTimeMakeWithSeconds(durationInterval - kTextItemDefaultDuration, duration.timescale);
        }
        
        if (CMTimeGetSeconds(startTime) < 0) {
            startTime = kCMTimeZero;
        }
        
        item.textLabel.timeRange = CMTimeRangeMake(startTime, CMTimeMakeWithSeconds(kTextItemDefaultDuration, duration.timescale));
    }
    
    // 联动更新 UI
    self.currentItemLabel = item.textLabel;
    self.currentItem = item;
    [_trimmerView addMarkWithColor:[UIColor colorWithRed:255/255.0 green:204/255.0 blue:0/255.0 alpha:0.5] timeRange:item.textLabel.timeRange atDuration:duration];
    _trimmerView.selectedMarkIndex = item.selected ? item.tag : -1;
    
}

/**
 移除一个图片贴纸项
 
 @param editor 编辑器
 @param item 贴纸项
 */
-(void)imageStickerEditor:(StickerEditor *)editor didRemoveItem:(TextStickerEditorItem *)item;{
    if (!item.editable) return;
    
    // 联动更新 UI
    self.currentItemLabel = nil;
    self.currentItem = nil;
    [_trimmerView removeMarkAtIndex:item.tag];
    _trimmerView.trimmerMaskView.hidden = YES;
    [self.view endEditing:YES];
    
    [self resetItemsTag];
    if (item.effect) {
        [(NSMutableArray *)self.initialEffects removeObject:item.effect];
        [self.movieEditor removeMediaEffect:item.effect];
    }
    item = nil;
}

/**
 选中一个图片贴纸
 
 @param editor 编辑器
 @param item 贴纸项
 */
-(void)imageStickerEditor:(StickerEditor *)editor didSelectedItem:(TextStickerEditorItem *)item;{
    if (!item.editable) return;

    [_trimmerView selectMarkWithIndex:item.tag];
    
    self.currentItemLabel = item.textLabel;
    self.currentItem = item;
    // 跳转到文字的时间范围内
    [self seekToTimeRange:item.textLabel.timeRange];
}

/**
 图片贴纸视图被取消选中
 
 @param editor 编辑器
 @param item 贴纸项
 */
-(void)imageStickerEditor:(StickerEditor *)editor didCancelSelectedItem:(TextStickerEditorItem *)item;{

}


/**
 更新贴纸的特效，移除贴纸

 @param editor 特效编辑器
 @param item 贴纸
 */
- (void)imageStickerEditor:(StickerEditor *)editor updateEffectFromItem:(UIView<StickerEditorItem> *)item {
    if (item.effect) {
        [(NSMutableArray *)self.initialEffects removeObject:item.effect];
        [self.movieEditor removeMediaEffect:item.effect];
    }
}

@end
