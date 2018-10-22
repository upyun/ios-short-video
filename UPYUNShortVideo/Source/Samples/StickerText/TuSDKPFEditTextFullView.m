//
//  TuSDKPFEditTextFullView.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2018/6/25.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TuSDKPFEditTextFullView.h"
#import "TuSDKTSScreen+Extend.h"
#import "TuSDKTSDevice+Extend.h"
#import "TuSDKICView+Extend.h"
#import "TuSDKPFStickerFactory.h"



@interface TuSDKPFEditTextFullView()<UITextViewDelegate,TopNavBarDelegate,TuSDKPFTextViewDelegate,TuSDKPFEditTextColorAdjustDelegate,TuSDKPFEditTextStyleAdjustDelegate,VideoClipViewDelegate>
{
    //底部视图
    CGRect _originFrame;
    //编辑视图
    CGRect _editFrame;
    // 内容View (不包含缩略图)
    UIView *_contentBackView;
    // touchView
    UIView *_touchView;
    // 返回按钮
    UIButton *_backBtn;
    
    // 当前选中的itemView 中心点
    CGPoint _itemCenter;
    
    BOOL _enableShowHub;
    
    
}
@end

@implementation TuSDKPFEditTextFullView

#pragma mark initView

-(void)setIsEditTextStatus:(BOOL)isEditTextStatus
{
    _isEditTextStatus = isEditTextStatus;
    [self refreshContentView];
    
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initContentView];
        _enableShowHub = YES;
    }
    return self;
}

-(void)initContentView
{
    _originFrame = self.frame;
    _editFrame = [UIScreen mainScreen].bounds;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    // 创建整体内容View （不包含缩略图）
    _contentBackView = [[UIView alloc]initWithFrame:_editFrame];
    [self addSubview:_contentBackView];
    
    // contentBackView 上面添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTapGesture)];
    [_contentBackView addGestureRecognizer:tap];
    
    // 文字视图
    
    _textView = [[TuSDKPFTextView alloc] initWithFrame:_contentBackView.frame
                                              textFont:self.textOptions.textFont ? self.textOptions.textFont : [UIFont systemFontOfSize:30]
                                             textColor:self.textOptions.textColor ? self.textOptions.textColor : [UIColor redColor]];
    _textView.textDelegate = self;
    if (self.textOptions) {
        _textView.textString = self.textOptions.textString;
        _textView.textBorderWidth = self.textOptions.textBorderWidth;
        _textView.textBorderColor = self.textOptions.textBorderColor;
        _textView.textEdgeInsets = self.textOptions.textEdgeInsets;
        _textView.textMaxScale = self.textOptions.textMaxScale;
    }
    _textView.userInteractionEnabled = YES;
    [_contentBackView addSubview:_textView];
    [self appendTextWithOption:self.textOptions];
    
    
    // 文字 缩略图栏
    _bottomThumbnailView = [[MovieEditorClipView alloc]initWithFrame:CGRectMake(0,_contentBackView.lsqGetSizeHeight-44, _contentBackView.lsqGetSizeWidth, 44)];
    _bottomThumbnailView.center = CGPointMake(_contentBackView.lsqGetSizeWidth/2, _contentBackView.lsqGetSizeHeight-44/2);
    _bottomThumbnailView.clipDelegate = self;
    _bottomThumbnailView.minCutTime = 0.0;
    _bottomThumbnailView.clipsToBounds = YES;
    [_contentBackView addSubview:_bottomThumbnailView];
    
    // 旋转和裁剪 裁剪区域视图
    _cutRegionView = [TuSDKICMaskRegionView initWithFrame:_contentBackView.frame];
    // 边缘覆盖区域颜色
    _cutRegionView.edgeMaskColor = [UIColor grayColor];
    [_contentBackView addSubview:_cutRegionView];
    
    _textInputView = [[UITextView alloc]initWithFrame:CGRectMake(0, self.lsqGetSizeHeight, self.lsqGetSizeWidth, 60)];
    _textInputView.backgroundColor = [UIColor blackColor];
    _textInputView.hidden = YES;
    _textInputView.delegate = self;
    [_contentBackView addSubview:_textInputView];
    
    
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        topY = 44;
    }
    //顶部视图
    UIView * topTextViwe = [[UIView alloc] initWithFrame:CGRectMake(0, topY, screenSize.width, 44)];
    [topTextViwe setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [_contentBackView addSubview:topTextViwe];
    
    //返回按钮
    _backBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) imageLSQBundleNamed:@"lsq_edit_text_style_icon_nav_ic_close"];
    [_backBtn addTarget:self action:@selector(clickBackBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [topTextViwe addSubview:_backBtn];
    
    //title
    UILabel * topTextViewTitle = [[UILabel alloc] initWithFrame:CGRectMake((_contentBackView.lsqGetSizeWidth-44)/2,0, 44, 44)];
    topTextViewTitle.textColor = [UIColor whiteColor];
    topTextViewTitle.text      = NSLocalizedString(@"lsq_movieEditor_text", @"文字");
    [topTextViwe addSubview:topTextViewTitle];
    
    //文字编辑完成
    UIButton * textComplteBtn = [UIButton buttonWithFrame:CGRectMake(_contentBackView.lsqGetSizeWidth-49, 0, 44,44 ) imageLSQBundleNamed:@"lsq_edit_text_style_icon_nav_ic_save"];
    [textComplteBtn addTouchUpInsideTarget:self action:@selector(textComplteEvent:)];
    [topTextViwe addSubview:textComplteBtn];
    
    
     //选项栏相关视图
    [self initOptionConfigView];
    
    [self initOptionEnterView];
    
    _contentBackView.hidden = YES;
    self.isVideoPlay = NO;//默认不播放视频
    //监听键盘
    [self initEventMethod];
}

- (TuSDKPFEditTextViewOptions *)textOptions;
{
    if (!_textOptions)
        _textOptions = [TuSDKPFEditTextViewOptions defaultOptions];
    
    return _textOptions;
}

- (void)initOptionConfigView;
{
    // 选项栏目
    NSArray *btnStrs = @[@"text_addText", @"text_color", @"text_style"];
    _optionBar = [TuSDKPFEditAdjustOptionBar initWithFrame:CGRectMake(0, _contentBackView.lsqGetSizeHeight - 80-49, _contentBackView.lsqGetSizeWidth, 80)];
    [_optionBar bindModules:btnStrs target:self action:@selector(onOptionSelectedAction:)];
    [_contentBackView addSubview:_optionBar];
    
    
    
    _optionActionContainer = [UIView initWithFrame:CGRectMake(0, _contentBackView.lsqGetSizeHeight - 49, _contentBackView.lsqGetSizeWidth, 49)];
    _optionActionContainer.backgroundColor = [UIColor blackColor];

     //参数配置视图返回按钮
    _optionBackButton = [UIButton buttonWithFrame:CGRectMake(0, 0, _optionActionContainer.lsqGetSizeWidth / 4, _optionActionContainer.lsqGetSizeHeight)
                              imageLSQBundleNamed:@"style_default_edit_button_back"];
    [_optionBackButton addTouchUpInsideTarget:self action:@selector(onOptionBackAction)];
    [_optionActionContainer addSubview:_optionBackButton];

    _optionActionContainer.hidden = YES;
    [_contentBackView addSubview:_optionActionContainer];

}

- (void)initOptionEnterView;
{
    _optionEnterBackView = [[UIView alloc]initWithFrame:_optionBar.frame];
    _optionEnterBackView.backgroundColor = [UIColor blackColor];
    _optionEnterBackView.hidden = YES;
    [_contentBackView addSubview:_optionEnterBackView];
    
    // 颜色调节View
    _colorAdjustView = [[TuSDKPFEditTextColorAdjustView alloc]initWithFrame:_optionEnterBackView.bounds];
    _colorAdjustView.edgeInsets = UIEdgeInsetsMake(20, 25, 10, 25);
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
    _styleAdjustView = [[TuSDKPFEditTextStyleAdjustView alloc]initWithFrame:_optionEnterBackView.bounds];
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

- (void)onOptionBackAction;
{
    [self setOptionViewHiddenState:YES];
}

- (void)onOptionSelectedAction:(UIView *)btn;
{
    [self selectedIndexWith:btn.tag];
}

#pragma mark - VideoClipViewDelegate
/**
 文字缩略图 拖动到某位置处
 
 @param time 拖动的当前位置所代表的时间节点
 @param isStartStatus 当前拖动的是否为开始按钮 true:开始按钮  false:拖动结束按钮
 */
- (void)chooseTimeWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus;
{
    if ([self.textEditDelegate respondsToSelector:@selector(movieEditor_textSlipThumbnailViewWith:withState:)]) {
        [self.textEditDelegate movieEditor_textSlipThumbnailViewWith:time withState:isStartStatus];
    }
 //   lsqLDebug(@"拖动到%@位置和状态%@",time,isStartStatus);
}

/**
 文字缩略图 拖动结束的事件方法
 */
- (void)slipEndEvent;
{
    if ([self.textEditDelegate respondsToSelector:@selector(movieEditor_textSlipThumbnailViewSlipEndEvent)]) {
        [self.textEditDelegate movieEditor_textSlipThumbnailViewSlipEndEvent];
    }
    lsqLDebug(@"拖动缩略图结束");
}

/**
 文字缩略图 拖动开始的事件方法
 */
- (void)slipBeginEvent;
{
    if ([self.textEditDelegate respondsToSelector:@selector(movieEditor_textSlipThumbnailViewSlipBeginEvent)]) {
        [self.textEditDelegate movieEditor_textSlipThumbnailViewSlipBeginEvent];
    }
    lsqLDebug(@"拖动缩略图结束");
    
}

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
#pragma mark - keyboard noti

// 键盘出现
- (void)keyboardWillShow:(NSNotification *)aNotification;
{
    [_textInputView.layer removeAllAnimations];
//    [_imageBackView.layer removeAllAnimations];
    
    _textInputView.hidden = NO;
    [_textInputView lsqSetOrigin:CGPointMake(_textInputView.lsqGetOriginX, self.lsqGetSizeHeight - _textInputView.lsqGetSizeHeight)];
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat changeHeight = 0;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    
    if (_itemCenter.y > screenHeight - keyboardHeight - _textInputView.lsqGetSizeHeight) {
        CGFloat maxChange = keyboardHeight + _textInputView.lsqGetSizeHeight - (screenHeight - _textView.lsqGetSizeHeight);
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
        //[_imageBackView lsqSetOriginY:-changeHeight];
    }];
}

// 键盘退出
- (void)keyboardWillHide:(NSNotification *)aNotification;
{
    [_textInputView.layer removeAllAnimations];
    //[_imageBackView.layer removeAllAnimations];
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        _textInputView.alpha = 0;
        [_textInputView lsqSetOriginY:_textInputView.lsqGetOriginY + keyboardHeight];
        //[_imageBackView lsqSetOriginY:0];
    } completion:^(BOOL finished) {
        if (finished) {
            _textInputView.hidden = YES;
            _textInputView.text = @"";
            [_textInputView lsqSetOrigin:CGPointMake(_textInputView.lsqGetOriginX, self.lsqGetSizeHeight)];
        }
    }];
}

#pragma mark - TuSDKPFTextViewDelegate

- (void)clickToEnterEvent:(NSString *)originText itemCenter:(CGPoint)center;
{
    _textInputView.text = originText;
    if ([originText isEqualToString:_textOptions.textString]) {
        _textInputView.text = @"";
    }
    _itemCenter = center;
    _textInputView.hidden = NO;
    [_textInputView becomeFirstResponder];
}

- (void)switchSelectedItem:(NSString *)originText itemCenter:(CGPoint)center;
{
    if ([_textInputView isFirstResponder]) {
        [_textInputView resignFirstResponder];
    }
}

- (BOOL)canCancelAllSelected;
{
    if ([_textInputView isFirstResponder]) {
        [_textInputView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)deleteSelectedItem;
{
    if ([_textInputView isFirstResponder]) {
        [_textInputView resignFirstResponder];
    }
}

/**
 选中某一个选项
 
 @param index 选项下标
 */
- (void)selectedIndexWith:(NSInteger)index;
{
    switch (index) {
        case 0:{
            // 添加文字
            if (_textView) {
                [self appendTextWithOption:self.textOptions];
            }
        }break;
            
        case 1:{
            // 颜色选择
            _colorAdjustView.hidden = NO;
            [self setOptionViewHiddenState:NO];
        }break;
            
        case 2:{
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
 *  设置选项操作视图隐藏状态
 *
 *  @param isHidden 是否隐藏
 */
- (void)setOptionViewHiddenState:(BOOL)isHidden;
{
    _optionBar.hidden = !isHidden;
    _optionEnterBackView.hidden = isHidden;
    if (isHidden) {
        _colorAdjustView.hidden = YES;
        _styleAdjustView.hidden = YES;
    }
    
    CGFloat top = isHidden ? _optionActionContainer.lsqGetBottomY : _optionActionContainer.lsqGetOriginY;

    [UIView animateWithDuration:0.26 animations:^{
        [_optionActionContainer lsqSetOriginY:top];
    } completion:^(BOOL finished) {
        if (!finished) return;
        _optionActionContainer.hidden = isHidden;
    }];
}

#pragma mark - TuSDKPFEditTextColorAdjustDelegate

- (void)onSelectColorWith:(UIColor *)color styleType:(TuSDKPFEditTextColorType)styleType;
{
    if (!_textView) return;
    
    switch (styleType) {
        case TuSDKPFEditTextColorType_TextColor:{
            [_textView changeTextColor:color];
        }break;
            
        case TuSDKPFEditTextColorType_BackgroudColor:{
            [_textView changeTextBackgroudColor:color];
        }break;
            
        case TuSDKPFEditTextColorType_StrokeColor:{
            [_textView changeStrokeColor:color];
        }break;
            
        default:
            break;
    }
}

#pragma mark - TuSDKPFEditTextStyleAdjustDelegate

- (void)onSelectStyle:(TuSDKPFEditTextStyleType)styleType;
{
    if (!_textView)  return;
    
    switch (styleType) {
        case TuSDKPFEditTextStyleType_LeftToRight:{  // 方向从左向右
            NSArray *writingDirection = @[@(NSWritingDirectionLeftToRight|NSWritingDirectionOverride)];
            [_textView changeWritingDirection:writingDirection];
        }break;
            
        case TuSDKPFEditTextStyleType_RightToLeft:{  // 方向从右向左
            NSArray *writingDirection = @[@(NSWritingDirectionRightToLeft|NSWritingDirectionOverride)];
            [_textView changeWritingDirection:writingDirection];
        }break;
            
        case TuSDKPFEditTextStyleType_Underline:{  // 下划线
            [_textView toggleUnderline];
        }break;
            
        case TuSDKPFEditTextStyleType_AlignmentLeft:{  // 左对齐
            [_textView changeTextAlignment:NSTextAlignmentLeft];
        }break;
            
        case TuSDKPFEditTextStyleType_AlignmentRight:{  // 左对齐对齐
            [_textView changeTextAlignment:NSTextAlignmentRight];
        }break;
            
        case TuSDKPFEditTextStyleType_AlignmentCenter:{  // 居中
            [_textView changeTextAlignment:NSTextAlignmentCenter];
        }break;
            
        default:
            break;
    }
}


#pragma mark - custom method

- (void)appendTextWithOption:(TuSDKPFEditTextViewOptions *)options;
{
    
    [_textView appendText];
    [_textView changeTextColor:options.textColor];
    [_textView changeTextBackgroudColor:options.textBackgroudColor];
    [_textView changeStrokeColor:options.textStrokeColor];
    
    if (options.writingDirection)
        [_textView changeWritingDirection:options.writingDirection];
    
    if (options.enableUnderline)
        [_textView toggleUnderline];
    
}

#pragma mark - click event

// 点击手势的事件
- (void)clickTapGesture
{
    self.isVideoPlay = !self.isVideoPlay;
    [self clickPlayBtnEvent:self.isVideoPlay];
}

//play Event
- (void)clickPlayBtnEvent:(BOOL)isVidePlay;
{
    NSLog(@"文字编辑手势触发");
    // 注：selected 为YES 表示为播放状态    NO：暂停状态
    
    if ([self.textEditDelegate respondsToSelector:@selector(textEditFullEditView_playVideoEvent:)]) {
        [self.textEditDelegate textEditFullEditView_playVideoEvent:isVidePlay];
    }
}

/**
 左侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)clickBackBtnEvent:(UIButton *)sender;
{
    NSLog(@"左侧返回按钮");
    if ([self.textEditDelegate respondsToSelector:@selector(textEditFullEditView_backViewEvent)]) {
        [self.textEditDelegate textEditFullEditView_backViewEvent];
    }
}

#pragma mark - complete

/**
 右侧按钮点击事件 编辑完成按钮动作
 
 @param btn 按钮对象
 
 */
-(void)textComplteEvent:(UIButton *)sender
{
    NSLog(@"文字编辑完成");
    if ([self.textEditDelegate respondsToSelector:@selector(textEditFullEditView_completeEvent)]) {
        [self.textEditDelegate textEditFullEditView_completeEvent];
    }
    
    [self onImageCompleteAtion];
    
}

/**
 *  编辑图片完成按钮动作
 */
- (void)onImageCompleteAtion;
{
//    if (!self.textView)
//    {
//        //[self backActionHadAnimated];
//        return;
//    }
    
    TuSDKResult *result = [TuSDKResult result];
    
    CGRect region = _cutRegionView.regionRect;
    result.stickers = [_textView resultsWithRegionRect:region];
    TuSDKPFStickerResult * stickerResult = [result.stickers objectAtIndex:0];
    
    lsqLDebug(@"asyncEditWithResult: %@", NSStringFromCGRect(stickerResult.center));
//    // 不处理没有贴纸状态
//    if (!result.stickers || result.stickers.count == 0) {
//        [self backActionHadAnimated];
//        return;
//    }
    
    //[self showHubWithStatus:LSQString(@"lsq_edit_processing", @"正在处理...")];
    [NSThread detachNewThreadSelector:@selector(asyncEditWithResult:) toTarget:self withObject:result];
}

// 异步处理图片
- (void)asyncEditWithResult:(TuSDKResult *)result;
{
    //result.image = [self loadOrginImage];
    
    // 使用了文字贴纸
    if (result.stickers) {
        result.image = [TuSDKPFStickerFactory megerStickers:result.stickers image:result.image];
        result.stickers = nil;
    }
    
    lsqLDebug(@"asyncEditWithResult: %@", NSStringFromCGSize(result.image.size));
    
    // 异步处理如果需要保存文件
    //[self asyncProcessingIfNeedSave:result];
}




/**
 修改视图的frame 用来隐藏和显示编辑视图
 */
- (void)refreshContentView;
{
    if (_isEditTextStatus && !CGRectEqualToRect(self.frame, _editFrame)) {
        _contentBackView.hidden = NO;
        self.frame = _editFrame;
    }else if (!_isEditTextStatus && !CGRectEqualToRect(self.frame, _originFrame)){
        _contentBackView.hidden = YES;
        self.frame = _originFrame;
    }
    
}
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView;
{
    if (_textView && [_textView hasSelectedItem]) {
        [_textView changeText:textView.text];
    }
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
