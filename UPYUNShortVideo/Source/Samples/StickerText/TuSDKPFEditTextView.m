//
//  TuSDKPFEditTextView.m
//  TuSDKGeeV1
//
//  Created by wen on 20/07/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import "TuSDKPFEditTextView.h"
#import "TuSDKPFEditTextColorAdjustView.h"
#import "TuSDKPFEditTextStyleAdjustView.h"

#pragma mark - TuSDKPFEditTextBottomBar
/**
 *  底部动作栏
 */
@implementation TuSDKPFEditTextBottomBar

- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

-(void)lsqInitView;
{
    self.backgroundColor = [UIColor blackColor];
    
    // 取消按钮
    _cancelButton = [UIButton buttonWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth / 4, self.lsqGetSizeHeight)
                          imageLSQBundleNamed:@"style_default_edit_button_cancel"];
    [self addSubview:_cancelButton];
    
    // 完成按钮
    _completeButton = [UIButton buttonWithFrame:CGRectMake(_cancelButton.lsqGetSizeWidth * 3, 0, _cancelButton.lsqGetSizeWidth, self.lsqGetSizeHeight)
                            imageLSQBundleNamed:@"style_default_edit_button_completed"];
    [self addSubview:_completeButton];
}

@end


#pragma mark - TuSDKPFEditTextView
/**
 *  图片编辑文字控制器视图
 */
@interface TuSDKPFEditTextView ()<UITextViewDelegate, TuSDKPFEditTextColorAdjustDelegate, TuSDKPFEditTextStyleAdjustDelegate, TuSDKPFTextViewDelegate>{

    UIColor *_textColor;
    // 输入框
    UITextView *_textInputView;
    // 选项调节的背景View
    UIView *_optionEnterBackView;
    // 颜色调节View
    TuSDKPFEditTextColorAdjustView *_colorAdjustView;
    // 样式调节View
    TuSDKPFEditTextStyleAdjustView *_styleAdjustView;
    // 图片背景View
    UIView *_imageBackView;

    // 文字信息设置
    NSMutableParagraphStyle *_textParaStyle;
    // 当前选中的itemView 中心点
    CGPoint _itemCenter;
}

@end

@implementation TuSDKPFEditTextView

#pragma mark - init method

// 初始化视图
- (void)lsqInitView;
{
    // 底部动作栏
    _bottomBar = [TuSDKPFEditTextBottomBar initWithFrame:CGRectMake(0, self.lsqGetSizeHeight - 49, self.lsqGetSizeWidth, 49)];
    [self addSubview:_bottomBar];
    
    // 选项栏相关视图
    [self initOptionConfigView];

    // 图片内容背景view
    _imageBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, _optionBar.lsqGetOriginY)];
    [self addSubview:_imageBackView];
    
    // 图片视图
    _imageView = [UIImageView initWithFrame:_imageBackView.bounds];
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_imageBackView addSubview:_imageView];
    
    // 文字视图
    _textView = [[TuSDKPFTextView alloc]initWithFrame:_imageView.frame
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
    
    [_imageBackView addSubview:_textView];
    [self appendTextWithOption:self.textOptions];

    // 旋转和裁剪 裁剪区域视图
    _cutRegionView = [TuSDKICMaskRegionView initWithFrame:_imageView.frame];
    // 边缘覆盖区域颜色
    _cutRegionView.edgeMaskColor = [UIColor grayColor];
    [_imageBackView addSubview:_cutRegionView];
    
    _textInputView = [[UITextView alloc]initWithFrame:CGRectMake(0, self.lsqGetSizeHeight, self.lsqGetSizeWidth, 60)];
    _textInputView.backgroundColor = [UIColor blackColor];
    _textInputView.hidden = YES;
    _textInputView.delegate = self;
    [self addSubview:_textInputView];
    
    [self initOptionEnterView];
    // 其他监听信息
    [self initEventMethod];
}

- (void)initOptionConfigView;
{
    // 选项栏目
    _optionBar = [TuSDKPFEditAdjustOptionBar initWithFrame:CGRectMake(0, _bottomBar.lsqGetOriginY - 80, self.lsqGetSizeWidth, 80)];
    [self addSubview:_optionBar];
    
    _optionActionContainer = [UIView initWithFrame:_bottomBar.frame];
    _optionActionContainer.backgroundColor = [UIColor blackColor];
    
    // 参数配置视图返回按钮
    _optionBackButton = [UIButton buttonWithFrame:CGRectMake(0, 0, _optionActionContainer.lsqGetSizeWidth / 4, _optionActionContainer.lsqGetSizeHeight)
                                imageLSQBundleNamed:@"style_default_edit_button_back"];
    [_optionActionContainer addSubview:_optionBackButton];
    
    _optionActionContainer.hidden = YES;
    [self addSubview:_optionActionContainer];

}

- (void)initOptionEnterView;
{
    _optionEnterBackView = [[UIView alloc]initWithFrame:_optionBar.frame];
    _optionEnterBackView.backgroundColor = [UIColor blackColor];
    _optionEnterBackView.hidden = YES;
    [self addSubview:_optionEnterBackView];
    
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

/**
 *  设置图片
 *
 *  @param image 图片
 */
- (void)setImage:(UIImage *)image;
{
    if (!image) return;
    _imageView.image = image;
    _cutRegionView.regionRatio = image.size.width / image.size.height;
}

/**
 *  设置选项操作视图隐藏状态
 *
 *  @param isHidden 是否隐藏
 */
- (void)setOptionViewHiddenState:(BOOL)isHidden;
{
    _optionBar.hidden = !isHidden;
    _optionActionContainer.hidden = isHidden;
    _optionEnterBackView.hidden = isHidden;
    if (isHidden) {
        _colorAdjustView.hidden = YES;
        _styleAdjustView.hidden = YES;
    }
    
    CGFloat top = isHidden ? _bottomBar.lsqGetBottomY : _bottomBar.lsqGetOriginY;
    
    [UIView animateWithDuration:0.26 animations:^{
        [_optionActionContainer lsqSetOriginY:top];
    } completion:^(BOOL finished) {
        if (!finished) return;
        _optionActionContainer.hidden = isHidden;
    }];
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

#pragma mark - keyboard noti

// 键盘出现
- (void)keyboardWillShow:(NSNotification *)aNotification;
{
    [_textInputView.layer removeAllAnimations];
    [_imageBackView.layer removeAllAnimations];
    
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
        [_imageBackView lsqSetOriginY:-changeHeight];
    }];
}

// 键盘退出
- (void)keyboardWillHide:(NSNotification *)aNotification;
{
    [_textInputView.layer removeAllAnimations];
    [_imageBackView.layer removeAllAnimations];

    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        _textInputView.alpha = 0;
        [_textInputView lsqSetOriginY:_textInputView.lsqGetOriginY + keyboardHeight];
        [_imageBackView lsqSetOriginY:0];
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
