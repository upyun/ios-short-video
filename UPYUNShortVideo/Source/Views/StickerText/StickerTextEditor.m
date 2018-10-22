//
//  StickerTextEditTextView.m
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "StickerTextEditor.h"
#import "TuSDKFramework.h"

/**
 * 文字贴纸视图类
 * @since   v2.2.0
 */

@interface StickerTextEditor()<UITextViewDelegate,TopNavBarDelegate,StickerTextEditorPanelDelegate,StickerTextColorAdjustDelegate,StickerTextStyleAdjustDelegate,VideoClipViewDelegate>
{
    // 底部视图
    CGRect _originFrame;
    // 编辑视图
    CGRect _editFrame;
    // 内容View (不包含缩略图)
    UIView *_contentBackView;
    // touchView
    UIView *_touchView;
    // 返回按钮
    UIButton *_backBtn;
    // 当前选中的itemView 中心点
    CGPoint _itemCenter;
    
    // 视频编辑类
    MovieEditorFullScreenController * _movieEditorFullScreen;

    // 文字特效开始时间
    CGFloat _textEffectStartTime;
    // 文字特效结束时间
    CGFloat _textEffectEndTime;
}

/**
 预览界面位置信息
 @since     v2.2.0
 */
@property (nonatomic, assign) CGRect  preViewFrame;

@end

@implementation StickerTextEditor

#pragma mark - initView

/**
 设置编辑状态
 @param isEditTextStatus BOOL
 @since     v2.2.0
 */
-(void)setIsEditTextStatus:(BOOL)isEditTextStatus
{
    _isEditTextStatus = isEditTextStatus;
    [self refreshContentView];
}

/**
 初始化 StickerTextEditTextView
 @param  frame       self.frame
 @param  movieEditor TuSDKMovieEditor
 @return StickerTextEditTextView
 @since              v2.2.0
 */
-(instancetype)initWithFrame:(CGRect)frame WithMovieEditor:(MovieEditorFullScreenController *)movieEditorFull
{
    if (self = [super initWithFrame:frame]) {
        _movieEditorFullScreen = movieEditorFull;
        [self initContentView];
    }
    return self;
}

/**
 初始化视图
 @since     v2.2.0
 */
-(void)initContentView
{
    // 设置默认的文字效果覆盖范围，此处应与UI保持一致
    //默认设置2s时间
    _textEffectStartTime = 0.f;
    _textEffectEndTime = 2.f;

    _originFrame = self.frame;
    _editFrame = [UIScreen mainScreen].bounds;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    // 创建整体内容View （不包含缩略图）
    _contentBackView = [[UIView alloc]initWithFrame:_editFrame];
    [self addSubview:_contentBackView];
    
    // 文字编辑面板
    CGRect frame = [self getEditPanelFrame];
    _editorPanel = [[StickerTextEditorPanel alloc] initWithFrame:frame
                                              textFont:self.textOptions.textFont ? self.textOptions.textFont : [UIFont systemFontOfSize:15]
                                             textColor:self.textOptions.textColor ? self.textOptions.textColor : [UIColor redColor]];
    _editorPanel.delegate = self;
    if (self.textOptions) {
        _editorPanel.textString = self.textOptions.textString;
        _editorPanel.textBorderWidth = self.textOptions.textBorderWidth;
        _editorPanel.textBorderColor = self.textOptions.textBorderColor;
        _editorPanel.textEdgeInsets = self.textOptions.textEdgeInsets;
        _editorPanel.textMaxScale = self.textOptions.textMaxScale;
    }
    _editorPanel.userInteractionEnabled = YES;
    [_contentBackView addSubview:_editorPanel];
    
    // contentBackView 上面添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTapGesture)];
    [_editorPanel addGestureRecognizer:tap];
    
    // 文字缩略图栏
    CGFloat height = 52;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        height = 78;
    }
    _bottomThumbnailView = [[MovieEditorClipView alloc]initWithFrame:CGRectMake(0,_contentBackView.lsqGetSizeHeight-height, _contentBackView.lsqGetSizeWidth, 36)];
    _bottomThumbnailView.clipDelegate = self;
    _bottomThumbnailView.duration = _movieEditorFullScreen.movieEditor.duration;
    _bottomThumbnailView.clipsToBounds = YES;
    if (_bottomThumbnailView.duration < 2) {
        _textEffectEndTime = _bottomThumbnailView.duration;
    }
    
    CMTime rangeStart = CMTimeMakeWithSeconds(_textEffectStartTime, USEC_PER_SEC);
    CMTime rangeEnd = CMTimeMakeWithSeconds(_textEffectEndTime, USEC_PER_SEC);
//    _bottomThumbnailView.clipTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_textEffectStartTime endSeconds:_textEffectEndTime];
    _bottomThumbnailView.clipTimeRange = CMTimeRangeFromTimeToTime(rangeStart, rangeEnd);
    [_contentBackView addSubview:_bottomThumbnailView];
    
    // 旋转和裁剪 裁剪区域视图，可获取视图部分区域贴纸
    _cutRegionView = [TuSDKICMaskRegionView initWithFrame:frame];
    _cutRegionView.edgeMaskColor = [UIColor grayColor];
    [_contentBackView addSubview:_cutRegionView];
    
    // 输入弹窗
    _textInputView = [[UITextView alloc]initWithFrame:CGRectMake(0, self.lsqGetSizeHeight, self.lsqGetSizeWidth, 60)];
    _textInputView.backgroundColor = [UIColor blackColor];
    _textInputView.hidden = YES;
    _textInputView.delegate = self;
    [_contentBackView addSubview:_textInputView];
    
    // 顶部视图
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    UIView * topTextViwe = [[UIView alloc] initWithFrame:CGRectMake(0, topY, screenSize.width, 44)];
    [topTextViwe setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [_contentBackView addSubview:topTextViwe];
    
    // 返回按钮
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_backBtn setStateNormalImage:[UIImage imageNamed:@"lsq_edit_text_style_icon_nav_ic_close"]];
    
    [_backBtn addTarget:self action:@selector(clickBackBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [topTextViwe addSubview:_backBtn];
    
    // 文字标题
    UILabel * topTextViewTitle = [[UILabel alloc] initWithFrame:CGRectMake((_contentBackView.lsqGetSizeWidth-44)/2,0, 44, 44)];
    topTextViewTitle.textColor = [UIColor whiteColor];
    topTextViewTitle.text      = NSLocalizedString(@"lsq_movieEditor_text", @"文字");
    [topTextViwe addSubview:topTextViewTitle];
    
    // 文字编辑完成
    UIButton * textComplteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_contentBackView.lsqGetSizeWidth-49,0,44,44)];
    [textComplteBtn setStateNormalImage:[UIImage imageNamed:@"lsq_edit_text_style_icon_nav_ic_save"]];
    [textComplteBtn addTouchUpInsideTarget:self action:@selector(textComplteEvent:)];
    [topTextViwe addSubview:textComplteBtn];
    
    // 选项栏相关视图
    [self initOptionConfigView];
    // 颜色、样式视图
    [self initOptionEnterView];
    
    _contentBackView.hidden = YES;
    // 默认不播放视频
    self.isVideoPlay = NO;
    // 监听键盘
    [self initEventMethod];
}

- (void)setTotalDuration:(CGFloat)totalDuration;
{
    _totalDuration = totalDuration;
    _bottomThumbnailView.duration = totalDuration;
}

/**
 获取文字编辑区域位置
 @return CGRect
 @since     v2.2.0
 */
- (CGRect)getEditPanelFrame{
    CGSize size = [self getOrignVideoSize];
    CGRect frame, preViewFrame;
    
    if (size.width < size.height) {
        CGRect rect = [UIScreen mainScreen].bounds;
        CGFloat width = (rect.size.height - 220)*rect.size.width/rect.size.height;
        preViewFrame = CGRectMake((rect.size.width - width)/2, _movieEditorFullScreen.topBar.lsqGetOriginY+_movieEditorFullScreen.topBar.lsqGetSizeHeight, width, rect.size.height - 220);
        frame = AVMakeRectWithAspectRatioInsideRect(size, preViewFrame);
    } else {
        
        CGRect rect = [UIScreen mainScreen].bounds;
        frame = AVMakeRectWithAspectRatioInsideRect(size, rect);
        CGFloat y = frame.origin.y;
        frame = CGRectMake(frame.origin.x, frame.origin.y - y/3, frame.size.width, frame.size.height);
        preViewFrame = CGRectMake(rect.origin.x, rect.origin.y - y/3, rect.size.width, rect.size.height);
    }
    _preViewFrame = preViewFrame;
    return frame;
}


/**
 获取视频尺寸
 @return CGSize
 @since     v2.2.0
 */
- (CGSize)getOrignVideoSize;
{
    AVAsset *asset = [AVAsset assetWithURL:_movieEditorFullScreen.movieEditor.inputURL];
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    CGSize videoSize = videoTrack.naturalSize;
    // 根据朝向判断是否需要交换宽高
    CGAffineTransform transform = videoTrack.preferredTransform;
    BOOL isNeedSwopWH = NO;
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
        // Right
        isNeedSwopWH = YES;
    }else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0){
        // Left
        isNeedSwopWH = YES;
    }else if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0){
        // Down
        isNeedSwopWH = NO;
    }else{
        // Up
        isNeedSwopWH = NO;
    }
    
    if (isNeedSwopWH) {
        // 交换宽高
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    return videoSize;
}

/**
 预览界面位置
 @return CGRect
 @since     v2.2.0
 */
- (CGRect)preViewFrame{
    if (!CGRectIsEmpty(_preViewFrame)) {
        [self getEditPanelFrame];
    }
    return _preViewFrame;
}

/**
 文字贴纸配置
 @return StickerTextEditTextViewOptions
 @since     v2.2.0
 */
- (StickerTextEditTextViewOptions *)textOptions;
{
    if (!_textOptions)
        _textOptions = [StickerTextEditTextViewOptions defaultOptions];
    
    return _textOptions;
}

/**
 文字添加调节选项栏
 @since     v2.2.0
 */
- (void)initOptionConfigView;
{
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 34;
    }
    // 选项栏目
    NSArray *btnStrs = @[@"text_addText", @"text_color", @"text_style"];
    _optionBar = [StickerTextEditAdjustOptionBar initWithFrame:CGRectMake(0, _contentBackView.lsqGetSizeHeight - 80-49-topY, _contentBackView.lsqGetSizeWidth, 60)];
    [_optionBar bindModules:btnStrs target:self action:@selector(onOptionSelectedAction:)];
    [_contentBackView addSubview:_optionBar];
    
    _optionActionContainer = [UIView initWithFrame:CGRectMake(0, _contentBackView.lsqGetSizeHeight - 49-80-49-topY, _contentBackView.lsqGetSizeWidth, 49)];
    _optionActionContainer.backgroundColor = [UIColor blackColor];

     //参数配置视图返回按钮
    _optionBackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (_optionActionContainer.lsqGetSizeHeight - 49)/2, 80, 49)];
    [_optionBackButton setStateNormalImage:[UIImage imageNamed:@"t_ic_back"]];
    
    [_optionBackButton addTouchUpInsideTarget:self action:@selector(onOptionBackAction)];
    [_optionActionContainer addSubview:_optionBackButton];

    _optionActionContainer.hidden = YES;
    [_contentBackView addSubview:_optionActionContainer];

}

/**
 颜色调节栏
 @since     v2.2.0
 */
- (void)initOptionEnterView;
{
    _optionEnterBackView = [[UIView alloc]initWithFrame:_optionBar.frame];
    _optionEnterBackView.backgroundColor = [UIColor blackColor];
    _optionEnterBackView.hidden = YES;
    [_contentBackView addSubview:_optionEnterBackView];
    
    // 颜色调节View
    _colorAdjustView = [[StickerTextColorAdjustView alloc]initWithFrame:_optionEnterBackView.bounds];
    _colorAdjustView.edgeInsets = UIEdgeInsetsMake(10, 15, 10, 15);
    _colorAdjustView.hidden = YES;
    _colorAdjustView.colorDelegate = self;
    _colorAdjustView.styleSelectedColor = lsqRGB(250, 154, 112);
    _colorAdjustView.styleNormalColor = [UIColor whiteColor];
    _colorAdjustView.defaultClearColor = YES;
    _colorAdjustView.styleArr = @[@(TuSDKPFEditTextColorType_TextColor),
                                  @(TuSDKPFEditTextColorType_BackgroudColor),
                                  @(TuSDKPFEditTextColorType_StrokeColor)];
    _colorAdjustView.hexColors = @[@"#ffffff", @"#cccccc", @"#808080", @"#404040", @"#362f2d", @"#000000",
                                   @"#be8145", @"#800000", @"#cc0000", @"#ff0000", @"#ff5500", @"#ff8000",
                                   @"#fffc3a", @"#a8e000", @"#6cbf00", @"#008c00", @"#80d4ff", @"#0095ff",
                                   @"#0066cc", @"#001a66", @"#3c0066", @"#75008c", @"#ff338f", @"#ffbfd4"];
    [_optionEnterBackView addSubview:_colorAdjustView];
    
    // 样式调节View
    _styleAdjustView = [[StickerTextStyleAdjustView alloc]initWithFrame:_optionEnterBackView.bounds];
    _styleAdjustView.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _styleAdjustView.styleImageNames = @[@(TuSDKPFEditTextStyleType_LeftToRight),
                                         @(TuSDKPFEditTextStyleType_RightToLeft),
                                         @(TuSDKPFEditTextStyleType_Underline),
                                         @(TuSDKPFEditTextStyleType_AlignmentLeft),
                                         @(TuSDKPFEditTextStyleType_AlignmentRight),
                                         @(TuSDKPFEditTextStyleType_AlignmentCenter)];
    _styleAdjustView.hidden = YES;
    _styleAdjustView.styleDelegate = self;
    [_optionEnterBackView addSubview:_styleAdjustView];
    
}

#pragma  mark - 选项配置

/**
 设置选项操作视图隐藏状态
 @param isHidden 是否隐藏
 @since   v2.2.0
 */
- (void)onOptionBackAction;
{
    [self setOptionViewHiddenState:YES];
}

/**
 选中某一个选项
 @param index 选项下标
 @since   v2.2.0
 */
- (void)onOptionSelectedAction:(UIView *)btn;
{
    [self selectedIndexWith:btn.tag];
}

#pragma mark - VideoClipViewDelegate

/**
 文字缩略图 拖动到某位置处
 
 @param time 拖动的当前位置所代表的时间节点
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 @since    v2.2.0
 */
- (void)chooseTimeWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus;
{
    if (isStartStatus == lsqClipViewStyleLeft)
    {
        // 调整开始时间
        _textEffectStartTime = time;
    }else if (isStartStatus == lsqClipViewStyleRight)
    {
        // 调整结束时间
        _textEffectEndTime = time;
    }else if (isStartStatus == lsqClipViewStyleCurrent){
        
        [_editorPanel disPlayTextItemViewAtTime:time];
    }
    
    // 设置贴纸出现的时间范围
    TuSDKTimeRange *mediaEffectTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_textEffectStartTime endSeconds:_textEffectEndTime];
    if (_editorPanel.currentSelectedItem) {
        _editorPanel.currentSelectedItem.timeRange = mediaEffectTimeRange;
    }
    
    [_movieEditorFullScreen.movieEditor seekToPreviewWithTime:CMTimeMakeWithSeconds(time, 1*NSEC_PER_SEC)];
}

/**
 文字缩略图 拖动开始的事件方法
 @since   v2.2.0
 */
- (void)slipBeginEvent;
{
    if ([_movieEditorFullScreen.movieEditor isPreviewing]) {
        [_movieEditorFullScreen.movieEditor pausePreView];
    }
}

/**
 文字缩略图 拖动结束的事件方法
 @since   v2.2.0
 */
- (void)slipEndEvent;
{
    // 设置贴纸出现的时间范围
    TuSDKTimeRange *mediaEffectTimeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_textEffectStartTime endSeconds:_textEffectEndTime];
    if (_editorPanel.currentSelectedItem) {
        _editorPanel.currentSelectedItem.timeRange = mediaEffectTimeRange;
    }
}


/**
 键盘监听事件
 @since    v2.2.0
 */
- (void)initEventMethod;
{
    // 键盘出现
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // 键盘退出
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - keyboard notification

/**
 键盘弹出
 @param aNotification NSNotification
 @since    v2.2.0
 */
- (void)keyboardWillShow:(NSNotification *)aNotification;
{
    [_textInputView.layer removeAllAnimations];
    
    _textInputView.hidden = NO;
    [_textInputView lsqSetOrigin:CGPointMake(_textInputView.lsqGetOriginX, self.lsqGetSizeHeight - _textInputView.lsqGetSizeHeight)];
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat changeHeight = 0;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    
    if (_itemCenter.y > screenHeight - keyboardHeight - _textInputView.lsqGetSizeHeight) {
        CGFloat maxChange = keyboardHeight + _textInputView.lsqGetSizeHeight - (screenHeight - _editorPanel.lsqGetSizeHeight);
        changeHeight = _itemCenter.y - (screenHeight - keyboardHeight - _textInputView.lsqGetSizeHeight)/2;
        changeHeight = MIN(changeHeight, maxChange);
    }
    
    CGFloat textViewChangeOriginY = _textInputView.lsqGetOriginY - keyboardHeight;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        textViewChangeOriginY += 34;
    }
    
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        _textInputView.alpha = 1;
        [_textInputView lsqSetOriginY:textViewChangeOriginY];
    }];
}

/**
 键盘退出
 @param aNotification NSNotification
 @since    v2.2.0
 */
- (void)keyboardWillHide:(NSNotification *)aNotification;
{
    [_textInputView.layer removeAllAnimations];
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        _textInputView.alpha = 0;
        [_textInputView lsqSetOriginY:_textInputView.lsqGetOriginY + keyboardHeight];
    } completion:^(BOOL finished) {
        if (finished) {
            _textInputView.hidden = YES;
            _textInputView.text = @"";
            [_textInputView lsqSetOrigin:CGPointMake(_textInputView.lsqGetOriginX, self.lsqGetSizeHeight)];
        }
    }];
}

#pragma mark - TuSDKPFTextViewDelegate

/**
 选中文字贴纸View
 @param editorPanel 文字编辑界面
 @param itemView 选中的文字贴纸View
 @since    v2.2.0
 */
- (void)stickerTextEditorPanel:(StickerTextEditorPanel *)editorPanel didSelectedItemView:(StickerTextItemView *)itemView;
{
    [_movieEditorFullScreen.movieEditor pausePreView];
    
    // 更新缩略栏时间范围
    dispatch_async(dispatch_get_main_queue(), ^{
//        _bottomThumbnailView.clipTimeRange = itemView.timeRange;
        _bottomThumbnailView.clipTimeRange = CMTimeRangeMake(itemView.timeRange.start, itemView.timeRange.duration);
        [_bottomThumbnailView hideLeftRightTouchView:NO];
    });
}

/**
 文字贴纸进行编辑

 @param editorPanel 文字编辑界面
 @param itemView 进行编辑的文字贴纸View
 @since    v2.2.0
 */
- (void)stickerTextEditorPanel:(StickerTextEditorPanel *)editorPanel editingItemView:(StickerTextItemView *)itemView;
{
    [_movieEditorFullScreen.movieEditor pausePreView];
    
    _textInputView.text = itemView.textString;
    if ([itemView.textString isEqualToString:_textOptions.textString]) {
        _textInputView.text = @"";
    }
    
    _itemCenter = itemView.center;
    _textInputView.hidden = NO;
    [_textInputView becomeFirstResponder];
}

#pragma mark - StickerTextEditorPanelDelegate

/**
 取消选中文字贴纸文字编辑界面操作
 @return BOOL
 @since    v2.2.0
 */
- (BOOL)canCancelAllSelected;
{
    if ([_textInputView isFirstResponder]) {
        [_textInputView resignFirstResponder];
        return NO;
    }
    [_bottomThumbnailView hideLeftRightTouchView:YES];
    return YES;
}

/**
 删除文字贴纸文字编辑界面操作
 @since    v2.2.0
 */
- (void)deleteSelectedItem;
{
    if ([_textInputView isFirstResponder]) {
        [_textInputView resignFirstResponder];
    }
    [_bottomThumbnailView hideLeftRightTouchView:YES];
}

/**
 选中某一个选项
 @param index 选项下标
 @since   v2.2.0
 */
- (void)selectedIndexWith:(NSInteger)index;
{
    switch (index) {
        case 0:
        {
            // 添加文字
            if (_editorPanel) {
                [self appendTextWithOption:self.textOptions];
                [_movieEditorFullScreen.movieEditor pausePreView];
            }
        }
            break;
            
        case 1:
        {
            // 颜色选择
            _colorAdjustView.hidden = NO;
            [self setOptionViewHiddenState:NO];
        }
            break;
            
        case 2:
        {
            // 样式选择
            _styleAdjustView.hidden = NO;
            [self setOptionViewHiddenState:NO];
        }
            break;
            
        default:
            break;
    }
}

/**
 设置选项操作视图隐藏状态
 @param isHidden 是否隐藏
 @since   v2.2.0
 */
- (void)setOptionViewHiddenState:(BOOL)isHidden;
{
    _optionBar.hidden = !isHidden;
    _optionEnterBackView.hidden = isHidden;
    if (isHidden) {
        _colorAdjustView.hidden = YES;
        _styleAdjustView.hidden = YES;
    }
    
    _optionActionContainer.hidden = isHidden;
}

#pragma mark - TuSDKPFEditTextColorAdjustDelegate

/**
 改变贴纸颜色
 @param color 颜色
 @param styleType TuSDKPFEditTextColorType
 @since   v2.2.0
 */
- (void)onSelectColorWith:(UIColor *)color styleType:(TuSDKPFEditTextColorType)styleType;
{
    if (!_editorPanel) return;
    
    switch (styleType) {
        case TuSDKPFEditTextColorType_TextColor:
        {
            [_editorPanel changeTextColor:color];
        }
            break;
            
        case TuSDKPFEditTextColorType_BackgroudColor:
        {
            [_editorPanel changeTextBackgroudColor:color];
        }
            break;
            
        case TuSDKPFEditTextColorType_StrokeColor:
        {
            [_editorPanel changeStrokeColor:color];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - TuSDKPFEditTextStyleAdjustDelegate

/**
 改变贴纸样式
 @param styleType TuSDKPFEditTextStyleType
 @since   v2.2.0
 */
- (void)onSelectStyle:(TuSDKPFEditTextStyleType)styleType;
{
    if (!_editorPanel)  return;
    
    switch (styleType) {
        case TuSDKPFEditTextStyleType_LeftToRight:{  // 方向从左向右
            NSArray *writingDirection = @[@(NSWritingDirectionLeftToRight|NSWritingDirectionOverride)];
            [_editorPanel changeWritingDirection:writingDirection];
        }break;
            
        case TuSDKPFEditTextStyleType_RightToLeft:{  // 方向从右向左
            NSArray *writingDirection = @[@(NSWritingDirectionRightToLeft|NSWritingDirectionOverride)];
            [_editorPanel changeWritingDirection:writingDirection];
        }break;
            
        case TuSDKPFEditTextStyleType_Underline:{  // 下划线
            [_editorPanel toggleUnderline];
        }break;
            
        case TuSDKPFEditTextStyleType_AlignmentLeft:{  // 左对齐
            [_editorPanel changeTextAlignment:NSTextAlignmentLeft];
        }break;
            
        case TuSDKPFEditTextStyleType_AlignmentRight:{  // 左对齐对齐
            [_editorPanel changeTextAlignment:NSTextAlignmentRight];
        }break;
            
        case TuSDKPFEditTextStyleType_AlignmentCenter:{  // 居中
            [_editorPanel changeTextAlignment:NSTextAlignmentCenter];
        }break;
            
        default:
            break;
    }
}

#pragma mark - custom method

/**
 添加文字贴纸
 @param options StickerTextEditTextViewOptions
 @since   v2.2.0
 */
- (void)appendTextWithOption:(StickerTextEditTextViewOptions *)options;
{
    [_editorPanel appendText];
    [_editorPanel changeTextColor:options.textColor];
    [_editorPanel changeTextBackgroudColor:options.textBackgroudColor];
    [_editorPanel changeStrokeColor:options.textStrokeColor];
    
    if (options.writingDirection)
        [_editorPanel changeWritingDirection:options.writingDirection];
    
    if (options.enableUnderline)
        [_editorPanel toggleUnderline];
    
    // 根据当前帧时间重设时间范围
    StickerTextItemView *stickerTextItemView = _editorPanel.allTextItemViewArray.lastObject;
    stickerTextItemView.timeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_bottomThumbnailView.currentTime durationSeconds:2];
    
    // 新添加的itemView初始时间范围校正,不能超过视频时长
    if (_bottomThumbnailView.currentTime + 2 > _bottomThumbnailView.duration) {
        stickerTextItemView.timeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:_bottomThumbnailView.currentTime endSeconds:_bottomThumbnailView.duration];
    }
    
    // 更新缩略栏时间范围
    dispatch_async(dispatch_get_main_queue(), ^{
        //_bottomThumbnailView.clipTimeRange = stickerTextItemView.timeRange;
        _bottomThumbnailView.clipTimeRange = CMTimeRangeMake(stickerTextItemView.timeRange.start, stickerTextItemView.timeRange.duration);
    });
}

#pragma mark - 文字贴纸特效事件

/**
 文字贴纸特效手势
 @since   v2.2.0
 */
- (void)clickTapGesture
{
    self.isVideoPlay = !self.isVideoPlay;
    [self clickPlayBtnEvent:self.isVideoPlay];
}

/**
 视频播放事件
 @param  isVidePlay 是否播放
 @since   v2.2.0
 */
- (void)clickPlayBtnEvent:(BOOL)isVidePlay;
{
    if (isVidePlay) {
        [_movieEditorFullScreen startPreview];
    }else{
        [_movieEditorFullScreen pausePreview];
    }
}

/**
 编辑文字特效 返回
 @param btn 按钮对象
 @param navBar 导航条
 @since   v2.2.0
 */
- (void)clickBackBtnEvent:(UIButton *)sender;
{
    [_textInputView resignFirstResponder];
    if (_editorPanel) {
        [_editorPanel deletaAllTextItemViews];
    }
    [self setIsEditTextStatus:NO];
    _movieEditorFullScreen.bottomBar.hidden = NO;
    _movieEditorFullScreen.topBar.hidden = NO;
    
    // 恢复到预览时的frame
    CGRect rect = [UIScreen mainScreen].bounds;
    [_movieEditorFullScreen.movieEditor updatePreViewFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
}

/**
 编辑文字特效 完成
 @param btn 按钮对象
 @since   v2.2.0
 */
-(void)textComplteEvent:(UIButton *)sender
{
    [_textInputView resignFirstResponder];
    [self onImageCompleteAtion];
}

/**
 *  编辑文字特效 结果
 *  @since   v2.2.0
 */
- (void)onImageCompleteAtion;
{
    if (!self.editorPanel)    return;
    
   NSMutableArray<StickerTextItemView *> *stickerItemViewArray = _editorPanel.allTextItemViewArray;
    
    [stickerItemViewArray enumerateObjectsUsingBlock:^(StickerTextItemView * _Nonnull stickerTextItemView, NSUInteger idx, BOOL * _Nonnull stop) {
       
        [self addTextEffectData:stickerTextItemView];
        
    }];
    
    [self setIsEditTextStatus:NO];
    _movieEditorFullScreen.bottomBar.hidden = NO;
    _movieEditorFullScreen.topBar.hidden = NO;

    // 恢复到预览时的frame
    CGRect rect = [UIScreen mainScreen].bounds;
    [_movieEditorFullScreen.movieEditor updatePreViewFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    [_movieEditorFullScreen.movieEditor seekToPreviewWithTime:CMTimeMakeWithSeconds(0.1, USEC_PER_SEC)];

}


/**
 添加文字效果数据到编辑器
 @param stickerTextItemView 文字贴纸view
 @since   v2.2.0
 */
- (void)addTextEffectData:(StickerTextItemView *)stickerTextItemView{
    
    TuSDKPFStickerResult *result = [stickerTextItemView resultWithRegionRect:_cutRegionView.regionRect];
    
    // 添加文字贴纸
    TuSDKMediaTextEffectData *textEffectData = [[TuSDKMediaTextEffectData alloc] initWithStickerImage:[result.sticker.texts[0] textImage] center:result.center degree:result.degree designSize:CGSizeMake(self.editorPanel.lsqGetSizeWidth, self.editorPanel.lsqGetSizeHeight)];
    
    TuSDKTimeRange *timeRange = stickerTextItemView.timeRange;
    textEffectData.atTimeRange = timeRange;
    
    [_movieEditorFullScreen.movieEditor addMediaEffect:textEffectData];
}

/**
 修改视图的frame 用来隐藏和显示编辑视图
 @since   v2.2.0
 */
- (void)refreshContentView;
{
    if (_isEditTextStatus && !CGRectEqualToRect(self.frame, _editFrame)) {
        _contentBackView.hidden = NO;
        self.frame = _editFrame;
        if (!_editorPanel.allTextItemViewArray.count) {
            [self appendTextWithOption:self.textOptions];
        }
    }else if (!_isEditTextStatus && !CGRectEqualToRect(self.frame, _originFrame)){
        _contentBackView.hidden = YES;
        self.frame = _originFrame;
    }
}

#pragma mark - UITextViewDelegate

/**
 文字改变

 @param textView UITextView
 @since   v2.2.0
 */
- (void)textViewDidChange:(UITextView *)textView;
{
    if (_editorPanel && [_editorPanel hasSelectedItem]) {
        [_editorPanel changeText:textView.text];
    }
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
