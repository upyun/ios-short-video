//
//  StickerTextEditContainersView.m
//  TuSDK
//
//  Created by wen on 24/07/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import "StickerTextEditor.h"
#import "TuSDKFramework.h"

/**
 文字视图
 @since   v2.2.0
 */
@interface StickerTextEditorPanel()
{
    // 初始化字体
    UIFont *_textDefaultFont;
    // 初始化字体颜色
    UIColor *_textDefaultColor;
}

/**
 贴纸元件视图资源ID (需要实现 TuSDKPFStickerItemViewInterface 接口)
 @since   v2.2.0
 */
@property (nonatomic) Class textItemViewClazz;

@end

@implementation StickerTextEditorPanel

#pragma mark - setter getter

/**
 当前已添加文字数量
 @return 当前已使用贴纸总数
 @since   v2.2.0
 */
- (NSUInteger)textCount;
{
    return _allTextItemViewArray.count;
}

/**
 贴纸元件视图资源ID (需要实现 TuSDKPFTextItemViewInterface 接口)
 @since   v2.2.0
 */
- (Class)textItemViewClazz;
{
    if (!_textItemViewClazz) {
        _textItemViewClazz = [StickerTextItemView class];
    }
    return _textItemViewClazz;
}

#pragma mark - init method

/**
 初始化
 @param frame 外部设定的frame
 @return UIView
 @since   v2.2.0
 */
- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

/**
 初始化
 @param frame 外部设定的frame
 @param textFont 外部设定的字体大小
 @param textColor 外部设定的字体颜色
 @return UIView
 @since   v2.2.0
 */
- (instancetype)initWithFrame:(CGRect)frame textFont:(UIFont *)textFont textColor:(UIColor *)textColor;
{
    self = [super initWithFrame:frame];
    if (self) {
        _textDefaultColor = textColor;
        _textDefaultFont = textFont;
        [self lsqInitView];
    }
    return self;
}

/**
 初始化视图属性
 @since   v2.2.0
 */
- (void)lsqInitView;
{
    _allTextItemViewArray = [NSMutableArray array];
    _textBorderColor = [UIColor whiteColor];
    _textBorderWidth = 2.0f;
    self.clipsToBounds = YES;
}

#pragma mark - custom method

/**
 是否允许添加文字
 @return BOOL
 @since   v2.2.0
 */
- (BOOL)canAppendText;
{
    if (self.textCount >= [TuSDKAOValid shared].maxStickers) {
        NSString *msg = [NSString stringWithFormat:LSQString(@"lsq_sticker_over_limit%ld", @"OMG, 同时仅允许使用 %ld 张贴纸"),
                         [TuSDKAOValid shared].maxStickers];
        [TuSDKProgressHUD showErrorWithStatus:msg];
        return NO;
    }
    return YES;
}

/**
 添加一个贴纸
 @param sticker 贴纸元素
 @since   v2.2.0
 */
- (void)appendText;
{
    if (![self canAppendText]) return;
    
    TuSDKPFStickerText *textSticker = [TuSDKPFStickerText textWithType:lsqStickerTextDefault];
    TuSDKPFSticker *sticker = [TuSDKPFSticker stickerWithType:lsqStickerText];
    sticker.texts = @[textSticker];
    
    StickerTextItemView *stickerTextItemView = [self buildTextView:sticker];

    [self onSelectedTextItemView:stickerTextItemView];
}

/**
 修改下划线状态
 @since   v2.2.0
 */
- (void)toggleUnderline;
{
    if (_currentSelectedItem) {
        _currentSelectedItem.enableUnderline = !_currentSelectedItem.enableUnderline;
    }
}

/**
 创建贴纸视图
 @param textSticker 贴纸对象
 @return StickerTextItemView
 @since   v2.2.0
 */
- (StickerTextItemView *) buildTextView:(TuSDKPFSticker *)textSticker;
{
    StickerTextItemView *stickerTextItemView  = [self.textItemViewClazz initWithFrame:self.bounds];
    [stickerTextItemView initWithTextFont:_textDefaultFont];
    stickerTextItemView.textColor = _textDefaultColor ? _textDefaultColor : [UIColor redColor];
    stickerTextItemView.textString = self.textString;
    stickerTextItemView.textEdgeInsets = self.textEdgeInsets;
    stickerTextItemView.textMaxScale = self.textMaxScale;
    stickerTextItemView.delegate = self;
    stickerTextItemView.textBorderColor = self.textBorderColor;
    stickerTextItemView.textBorderWidth = self.textBorderWidth;

    [self addSubview:stickerTextItemView];
    [_allTextItemViewArray addObject:stickerTextItemView];
    
    // 由于初始化位置设置需要 superView 位置信息, view addSubview 调用后 才能设置textSticker
    stickerTextItemView.textSticker = textSticker;
    return stickerTextItemView;
}

/**
 改变文字内容
 @param text 文字内容
 @since   v2.2.0
 */
- (void)changeText:(NSString *)text;
{
    if (_currentSelectedItem) {
        _currentSelectedItem.textString = text;
    }
}

/**
 改变书写方向
 @param writingDirection 书写方向
 @since   v2.2.0
 */
- (void)changeWritingDirection:(NSArray<NSNumber *> *)writingDirection;
{
    if (_currentSelectedItem) {
        _currentSelectedItem.writingDirection = writingDirection;
    }
}

/**
 改变文字颜色
 @param textColor 文字颜色
 @since   v2.2.0
 */
- (void)changeTextColor:(UIColor *)textColor;
{
    if (_currentSelectedItem) {
        _currentSelectedItem.textColor = textColor;
    }
}

/**
 改变线条颜色
 @param textColor 线条颜色
 @since   v2.2.0
 */
- (void)changeStrokeColor:(UIColor *)strokeColor;
{
    if (_currentSelectedItem) {
        _currentSelectedItem.textStrokeColor = strokeColor;
    }
}

/**
 改变字体背景颜色
 @param textBackgroudColor 字体背景颜色
 @since   v2.2.0
 */
- (void)changeTextBackgroudColor:(UIColor *)textBackgroudColor;
{
    if (_currentSelectedItem) {
        _currentSelectedItem.textBackgroudColor = textBackgroudColor;
    }
}

/**
 改变文字对齐方式
 @param textAlignment 对齐方式
 @since   v2.2.0
 */
- (void)changeTextAlignment:(NSTextAlignment)textAlignment;
{
    if (_currentSelectedItem) {
        _currentSelectedItem.textAlignment = textAlignment;
    }
}

#pragma mark - result method

/**
 显示文字贴纸
 @param time 显示时间
 @since   v2.2.0
 */
- (void)disPlayTextItemViewAtTime:(CGFloat)time{
    
    [_allTextItemViewArray enumerateObjectsUsingBlock:^(StickerTextItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.timeRange.startSeconds <= time && time <= (obj.timeRange.startSeconds + obj.timeRange.durationSeconds)) {
            obj.hidden = NO;
        } else {
            obj.hidden = YES;
        }
    }];
}

/**
 是否已经选中某一个文字
 @return YES：已经选中
 @since   v2.2.0
 */
- (BOOL)hasSelectedItem;
{
    return _currentSelectedItem != nil;
}

#pragma mark - touche method

/**
 开始触摸事件
 @param touches 触摸对象
 @param event 事件对象
 @since   v2.2.0
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount > 1) return;
    
    BOOL cancel = YES;
    if ([self.delegate respondsToSelector:@selector(canCancelAllSelected)])
        cancel = [self.delegate canCancelAllSelected];
    
    if (cancel)
        [self cancelAllSelected];
}

/**
 取消所有贴纸选中状态
 @since   v2.2.0
 */
- (void)cancelAllSelected;
{
    for (StickerTextItemView *item in _allTextItemViewArray) {
        item.selected = NO;
    }
    _currentSelectedItem = nil;
}

/**
 删除所有文字贴纸View
 @since   v2.2.0
 */
- (void)deletaAllTextItemViews{
    [_allTextItemViewArray enumerateObjectsUsingBlock:^(StickerTextItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_allTextItemViewArray removeAllObjects];
    _currentSelectedItem = nil;
}

#pragma mark - TuSDKPFStickerItemViewDelegate

/**
 文字贴纸元件删除
 @param view 贴纸元件视图
 @since   v2.2.0
 */
- (void)onClosedTextItemView:(StickerTextItemView *)view;
{
    if (!view) return;
    
    [_allTextItemViewArray removeObject:view];
    [view removeFromSuperview];
    _currentSelectedItem = nil;
    
    if ([self.delegate respondsToSelector:@selector(deleteSelectedItem)])
        [self.delegate deleteSelectedItem];
}

/**
 选中贴纸元件
 @param view 贴纸元件视图
 @since   v2.2.0
 */
- (void)onSelectedTextItemView:(StickerTextItemView *)view;
{
    if (!view) return;
    
    for (StickerTextItemView *item in _allTextItemViewArray) {
        
        if ([item isEqual:view])
        {
            if (item.selected)
            {
                if ([self.delegate respondsToSelector:@selector(stickerTextEditorPanel:editingItemView:)]) {
                    
                    [self.delegate stickerTextEditorPanel:self editingItemView:item];
                }
            }else
            {
                item.selected = YES;
                _currentSelectedItem = item;
                
                if (_currentSelectedItem) {
                    
                    if ([self.delegate respondsToSelector:@selector(stickerTextEditorPanel:didSelectedItemView:)]) {
                        
                        [self.delegate stickerTextEditorPanel:self didSelectedItemView:item];
                    }
                }
            }
        }else
        {
            item.selected = NO;
        }
    }
}

@end


@interface StickerTextItemView ()<UIGestureRecognizerDelegate>{
    // 图片视图边缘距离
    UIEdgeInsets _mImageEdge;
    // 内容视图长宽
    CGSize _mCSize;
    // 内容视图边缘距离
    CGSize _mCMargin;
    // textView 边距Size
    CGSize _textViewMargin;
    // 最大缩放比例
    CGFloat _mMaxScale;
    // 默认视图长宽
    CGSize _mDefaultViewSize;
    // 内容对角线长度
    CGFloat _mCHypotenuse;
    // 初始化字号大小
    CGFloat _mDefaultFontSize;
    // 当前显示字体信息
    UIFont *_textFont;
    // 文字样式
    NSMutableDictionary *_textStyleDic;
    
    // 缩放比例
    CGFloat _mScale;
    // 旋转度数
    CGFloat _mDegree;
    // 文字视图列表
    NSMutableArray *_mTextViews;
    // 是否为旋转缩放动作
    BOOL _isRotatScaleAction;
    // 是否为宽度拉伸动作
    BOOL _isStretchAction;
    // 拖动手势
    UIPanGestureRecognizer *_panGesture;
    // 旋转手势
    UIRotationGestureRecognizer *_rotationGesture;
    // 缩放手势
    UIPinchGestureRecognizer *_pinchGesture;
    // 最后的触摸点
    CGPoint _lastPotion;
    // 是否正在操作
    BOOL _hasTouched;
    // 是否为手势动作
    BOOL _isInGesture;
}

@end

@implementation StickerTextItemView

#pragma mark - setter getter

/**
 设置文字贴纸对象
 @param textSticker TuSDKPFSticker
 @since   v2.2.0
 */
- (void)setTextSticker:(TuSDKPFSticker *)textSticker;
{
    if (!textSticker) return;
    _textSticker = textSticker;
    
    TuSDKPFStickerText *text = textSticker.texts[0];
    text.size = _mDefaultFontSize;
    
    _textSticker.size = [_textString lsqColculateTextSizeWithAttributs:_textStyleDic maxWidth:self.superview.bounds.size.width*_textMaxScale - _mCMargin.width maxHeihgt:10000];
    
    // 内容视图长宽
    _mCSize = CGSizeMake(ceil(_textSticker.size.width), ceil(_textSticker.size.height));
    
    [self initStickerPostion];
}

/**
 选中状态

 @param selected BOOL
 @since   v2.2.0
 */
- (void)setSelected:(BOOL)selected;
{
    if (!selected && _hasTouched) return;
    _selected = selected;
    [_textView lsqSetBorderWidth:self.textBorderWidth color:_selected ? self.textBorderColor : [UIColor clearColor]];
    
    _cancelButton.hidden = !selected;
    _turnButton.hidden = !selected;
    _stretchButton.hidden = !selected;
}

/**
 设置字体颜色
 @param textColor UIColor
 @since   v2.2.0
 */
- (void)setTextColor:(UIColor *)textColor;
{
    _textColor = textColor ? textColor : [UIColor clearColor];
    if (_textView) {
        [_textStyleDic setObject:textColor forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:_textString attributes:_textStyleDic];
        _textView.attributedText = attributeStr;
    }
}

/**
 文字样式信息设置
 @param textParaStyle NSMutableParagraphStyle
 @since   v2.2.0
 */
- (void)setTextParaStyle:(NSMutableParagraphStyle *)textParaStyle;
{
    _textParaStyle = textParaStyle;
    if (_textView) {
        [_textStyleDic setObject:textParaStyle forKey:NSParagraphStyleAttributeName];
        NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:_textString attributes:_textStyleDic];
        _textView.attributedText = attributeStr;
    }
}

/**
 是否设置下划线
 @param enableUnderline BOOL
 @since   v2.2.0
 */
- (void)setEnableUnderline:(BOOL)enableUnderline;
{
    _enableUnderline = enableUnderline;
    [_textStyleDic setObject:@(enableUnderline) forKey:NSUnderlineStyleAttributeName];
    NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:_textString attributes:_textStyleDic];
    _textView.attributedText = attributeStr;
}

/**
 设置文字书写方向
 @param writingDirection NSArray
 @since   v2.2.0
 */
- (void)setWritingDirection:(NSArray<NSNumber *> *)writingDirection;
{
    _writingDirection = writingDirection;
    [_textStyleDic setObject:writingDirection forKey:NSWritingDirectionAttributeName];
    NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:_textString attributes:_textStyleDic];
    _textView.attributedText = attributeStr;
}

/**
 设置对齐方式
 @param textAlignment NSTextAlignment
 @since   v2.2.0
 */
- (void)setTextAlignment:(NSTextAlignment)textAlignment;
{
    _textAlignment = textAlignment;
    _textParaStyle.alignment = _textAlignment;
    self.textParaStyle = _textParaStyle;
}

/**
 设置文字背景色
 @param textBackgroudColor UIColor
 @since   v2.2.0
 */
- (void)setTextBackgroudColor:(UIColor *)textBackgroudColor;
{
    _textBackgroudColor = textBackgroudColor;
    if (_textView) {
        _textView.backgroundColor = textBackgroudColor;
    }
}

/**
 设置文字线条颜色
 @param textStrokeColor UIColor
 @since   v2.2.0
 */
- (void)setTextStrokeColor:(UIColor *)textStrokeColor;
{
    _textStrokeColor = textStrokeColor;
    [_textStyleDic setObject:(_textStrokeColor?_textStrokeColor:[UIColor clearColor]) forKey:NSStrokeColorAttributeName];
    NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:_textString attributes:_textStyleDic];
    _textView.attributedText = attributeStr;
}

/**
 设置文字内容
 @param textString NSString
 @since   v2.2.0
 */
- (void)setTextString:(NSString *)textString;
{
    if (_textView) {
        _textString = textString ? textString : @" ";
        NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:_textString attributes:_textStyleDic];
        _textView.attributedText = attributeStr;
        
        CGFloat needHeight = [_textString lsqColculateTextSizeWithAttributs:_textStyleDic maxWidth:(_textView.bounds.size.width - _textViewMargin.width) maxHeihgt:1000].height;
        
        if (_textView.bounds.size.height != needHeight) {
            self.bounds = CGRectMake(0, 0, self.bounds.size.width, ceil(needHeight + _mCMargin.height));
            
            [self resetBasicInfo];
            [self resetViewsBounds];
        }
    }
}

/**
 设置文字边距
 @param textEdgeInsets UIEdgeInsets
 @since   v2.2.0
 */
- (void)setTextEdgeInsets:(UIEdgeInsets)textEdgeInsets;
{
    CGRect newBounds = CGRectMake(0, 0, self.bounds.size.width - _textViewMargin.width, self.bounds.size.width - _textViewMargin.height);
    _textEdgeInsets = textEdgeInsets;
    _textViewMargin = CGSizeMake(_textEdgeInsets.left + _textEdgeInsets.right, _textEdgeInsets.top + _textEdgeInsets.bottom);
    if (_textView) {
        _textView.edgeInsets = _textEdgeInsets;
        [self resetBasicInfo];
    }
    
    newBounds = CGRectMake(0, 0, newBounds.size.width + _textViewMargin.width, newBounds.size.height + _textViewMargin.height);
    self.bounds = newBounds;
    [self resetTextEdge];
}

/**
 设置最大缩放比例
 @param textMaxScale CGFloat
 @since   v2.2.0
 */
- (void)setTextMaxScale:(CGFloat)textMaxScale;
{
    _textMaxScale = textMaxScale;
}

/**
 最小缩小比例 (默认: 0.5f <= mMinScale <= 1)
 @return CGFloat
 @since   v2.2.0
 */
- (CGFloat)minScale;
{
    if (_minScale < 0.5f) {
        _minScale = 0.5f;
    }
    return _minScale;
}

#pragma mark - init method

/**
 销毁操作
 @since   v2.2.0
 */
-(void)viewWillDestory;
{
    [super viewWillDestory];
    [self removeGestureRecognizer];
}

/**
 初始化界面
 @param frame 外部设定的frame
 @return UIView
 @since   v2.2.0
 */
- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

/**
 初始化字体信息
 @param textFont UIFont
 @since   v2.2.0
 */
- (void)initWithTextFont:(UIFont *)textFont;
{
    _textFont = textFont;
    _mDefaultFontSize = _textFont.pointSize;
    [self resetTextFont:_textFont];
}

/**
 初始化视图
 @since   v2.2.0
 */
- (void)lsqInitView;
{
    [self initDefaultData];
    
    // 文字视图
    _textView = [TuSDKPFTextLabel initWithFrame:self.bounds];
    _textView.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _textView.textColor = _textColor;
    _textView.numberOfLines = 0;
    [self addSubview:_textView];
    _textViewMargin = CGSizeMake(_textView.edgeInsets.left + _textView.edgeInsets.right, _textView.edgeInsets.top + _textView.edgeInsets.bottom);
    
    // 取消按钮
    _cancelButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 36, 36)
                          imageLSQBundleNamed:@"t_ic_close"];
    [_cancelButton addTouchUpInsideTarget:self action:@selector(handleCancelButton)];
    [self addSubview:_cancelButton];

    // 旋转缩放按钮
    _turnButton = [UIButton buttonWithFrame:CGRectMake(self.lsqGetSizeWidth/2, self.lsqGetSizeHeight - 36, 36, 36)
                        imageLSQBundleNamed:@"style_default_edit_drag_rotate_scale"];
    [self addSubview:_turnButton];
    
    // 宽度拉伸按钮
    _stretchButton = [UIButton buttonWithFrame:CGRectMake(self.lsqGetSizeWidth - 36, self.lsqGetSizeHeight - 36, 36, 36)
                           imageLSQBundleNamed:@"style_default_edit_button_text_resetSize"];
    [self addSubview:_stretchButton];
    
    [self resetTextEdge];
    
    // 添加手势
    [self appendGestureRecognizer];
}

/**
 初始化数据信息
 @since   v2.2.0
 */
- (void)initDefaultData;
{
    // 默认缩放比例
    _mScale = 1.f;
    // 初始化默认字体
    _mDefaultFontSize = 15.0;
    _textFont = [UIFont systemFontOfSize:_mDefaultFontSize];
    _textString = @"";
    
    // 默认字体样式信息
    _textParaStyle = [[NSMutableParagraphStyle alloc] init];
    _textParaStyle.lineBreakMode = NSLineBreakByWordWrapping;
    _textParaStyle.alignment = NSTextAlignmentLeft;
    _textParaStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
    _textStyleDic = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName:_textFont,
                                                                    NSParagraphStyleAttributeName:_textParaStyle,
                                                                    NSForegroundColorAttributeName:[UIColor redColor],
                                                                    NSStrokeColorAttributeName:[UIColor clearColor],
                                                                    NSStrokeWidthAttributeName:@(-1)}];
    _timeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:0 endSeconds:2];
}

/**
 初始化贴纸位置
 @since   v2.2.0
 */
- (void)initStickerPostion;
{
    if (CGSizeEqualToSize(CGSizeZero, _mCSize) || !self.superview) return;
    // 内容对角线长度
    _mCHypotenuse = [TuSDKTSMath distanceOfPointX1:0 y1:0 pointX2:_mCSize.width y2:_mCSize.height];
    // 默认视图长宽
    _mDefaultViewSize = CGSizeMake(_mCSize.width + _mCMargin.width, _mCSize.height + _mCMargin.height);
    // 最大缩放比例
    CGFloat scale = _textMaxScale != 0 ? _textMaxScale : 1.2;
    _mMaxScale = (self.superview.lsqGetSizeWidth * scale - _mCMargin.width) / _mCSize.width;
    
    
    if (_mMaxScale < self.minScale) _mMaxScale = self.minScale;
    
    [self lsqSetSize:_mDefaultViewSize];
    // 重置视图大小
    [self resetViewsBounds];
    
    // 初始位置
    CGPoint origin = self.lsqGetOrigin;
    origin.x = (self.superview.lsqGetSizeWidth - _mDefaultViewSize.width) * 0.5f;
    origin.y = (self.superview.lsqGetSizeHeight - _mDefaultViewSize.height) * 0.5f;
    // 设置居中
    [self lsqSetOrigin:origin];
}

#pragma mark - reset data

/**
 重置基本信息
 @since   v2.2.0
 */
- (void)resetBasicInfo;
{
    CGSize nowSize = _textView.bounds.size;
    // 修复部分初始值
    _mCSize = CGSizeMake((_textView.bounds.size.width - _textViewMargin.width)/_mScale, (_textView.bounds.size.height - _textViewMargin.height)/_mScale);
    // 内容对角线长度
    _mCHypotenuse = [TuSDKTSMath distanceOfPointX1:0 y1:0 pointX2:nowSize.width y2:nowSize.height]/_mScale;
    // 默认视图长宽
    _mDefaultViewSize = CGSizeMake((nowSize.width + _mCMargin.width)/_mScale, (nowSize.height + _mCMargin.height)/_mScale);
    // 最大缩放比例
    CGFloat scale = _textMaxScale != 0 ? _textMaxScale : 1.2;
    _mMaxScale = (self.superview.lsqGetSizeWidth * scale - _mCMargin.width) / _mCSize.width;
    
}

/**
 重置图片视图边缘距离
 @since   v2.2.0
 */
- (void)resetTextEdge;
{
    // 图片视图边缘距离
    _mImageEdge.left = ceilf(_cancelButton.lsqGetSizeWidth * 0.5f);
    _mImageEdge.right = ceilf(_stretchButton.lsqGetSizeWidth * 0.5f);
    _mImageEdge.top = ceilf(_cancelButton.lsqGetSizeHeight * 0.5f);
    _mImageEdge.bottom = ceilf(_turnButton.lsqGetSizeHeight* 0.5f + 15);
    
    // 内容视图边缘距离
    _mCMargin.width = _mImageEdge.left + _mImageEdge.right + _textViewMargin.width;
    _mCMargin.height = _mImageEdge.top + _mImageEdge.bottom + _textViewMargin.height;
    [_textView lsqSetOrigin:CGPointMake(_mImageEdge.left, _mImageEdge.top)];
    
    [self lsqSetSize:self.lsqGetSize];
    // 重置视图大小
    [self resetViewsBounds];
}

/**
 重置视图大小
 @since   v2.2.0
 */
- (void)resetViewsBounds;
{
    CGSize size = self.bounds.size;
    [_textView lsqSetSize:CGSizeMake(size.width - _mCMargin.width + _textViewMargin.width,
                                     size.height - _mCMargin.height + _textViewMargin.height)];
    
    [_turnButton lsqSetOrigin:CGPointMake(size.width/2, size.height - _turnButton.lsqGetSizeHeight)];
    [_stretchButton lsqSetOrigin:CGPointMake(size.width - _stretchButton.lsqGetSizeWidth, _textView.lsqGetSizeHeight)];
    
}

/**
 重置字号
 @param textFont UIFont
 @since   v2.2.0
 */
- (void)resetTextFont:(UIFont *)textFont;
{
    if (!textFont) return;
    
    _textFont = textFont;
    [_textStyleDic setObject:_textFont forKey:NSFontAttributeName];
    NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithString:_textString attributes:_textStyleDic];
    _textView.attributedText = attributeStr;
    
}

#pragma mark - click method

/**
 关闭贴纸
 @since   v2.2.0
 */
- (void)handleCancelButton;
{
    if (self.delegate)
    {
        [self.delegate onClosedTextItemView:self];
    }
}


#pragma mark - gesture about

/**
 添加手势
 @since   v2.2.0
 */
- (void)appendGestureRecognizer;
{
    // 拖动手势
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    _panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_panGesture];
    // 旋转手势
    _rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotationGesture:)];
    _rotationGesture.delegate = self;
    [self addGestureRecognizer:_rotationGesture];
    
    // 缩放手势
    _pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];
    _pinchGesture.delegate = self;
    [self addGestureRecognizer:_pinchGesture];
    
}

/**
 删除手势
 @since   v2.2.0
 */
- (void)removeGestureRecognizer;
{
    [self removeGestureRecognizer:_panGesture];
    [self removeGestureRecognizer:_rotationGesture];
    [self removeGestureRecognizer:_pinchGesture];
}

#pragma mark -- UIGestureRecognizerDelegate

/**
 同时执行旋转缩放手势

 @param gestureRecognizer UIGestureRecognizer
 @param otherGestureRecognizer UIGestureRecognizer
 @return BOOL
 @since   v2.2.0
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    return YES;
}

#pragma mark - Gesture method

/**
 拖动手势
 @param recognizer UIPanGestureRecognizer
 @since   v2.2.0
 */
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
{
    _isInGesture = YES;
    CGPoint point = [recognizer locationInView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint selfPoint = [recognizer locationInView:self];
        // 是否为旋转缩放动作
        if (!_turnButton.hidden) {
            _isRotatScaleAction = CGRectContainsPoint(_turnButton.frame, selfPoint);
        }
        // 是否为宽度拉伸
        if (!_stretchButton.hidden) {
            _isStretchAction = CGRectContainsPoint(_stretchButton.frame, selfPoint);
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if(_isStretchAction){
            [self handlePanGestureStretchAction:point];
        }else if (_isRotatScaleAction) {
            [self handlePanGestureRotatScaleAction:point];
        }else {
            [self handlePanGestureTransAction:point];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        _hasTouched = NO;
    }
    _lastPotion = point;
}

/**
 旋转手势
 @param recognizer UIRotationGestureRecognizer
 @since   v2.2.0
 */
- (void)handleRotationGesture:(UIRotationGestureRecognizer *)recognizer;
{
    _isInGesture = YES;
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // 旋转度数
        _mDegree = [TuSDKTSMath numberFloat:_mDegree + 360 + [TuSDKTSMath degreesFromRadian:recognizer.rotation] modulus:360];
        
        [self rotationWithDegrees:_mDegree];
    }
    else{
        _hasTouched = (recognizer.state == UIGestureRecognizerStateBegan);
    }
    recognizer.rotation = 0;
}

/**
 缩放手势

 @param recognizer UIPinchGestureRecognizer
 @since   v2.2.0
 */
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer;
{
    _isInGesture = YES;
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self computerScaleWithScale:recognizer.scale - 1 center:self.center];
    }
    else{
        _hasTouched = (recognizer.state == UIGestureRecognizerStateBegan);
    }
    recognizer.scale = 1;
}


#pragma mark - touches

/**
 触摸开始
 @param touches 触摸对象集合
 @param event 触摸事件
 @since   v2.2.0
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    _isInGesture = NO;
    _hasTouched = YES;
}

/**
 触摸取消
 @param touches 触摸对象集合
 @param event 触摸事件
 @since   v2.2.0
 */
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [self touchesEnded:touches withEvent:event];
}

/**
 触摸结束
 @param touches 触摸对象集合
 @param event 触摸事件
 @since   v2.2.0
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if (self.delegate && !_isInGesture) {
        [self.delegate onSelectedTextItemView:self];
    }
    
    _hasTouched = _isInGesture;
    _isStretchAction = NO;
    _isRotatScaleAction = NO;
}

#pragma mark - handleTransAction

/**
 处理移动位置
 @param nowPoint CGPoint
 @since   v2.2.0
 */
- (void)handlePanGestureTransAction:(CGPoint)nowPoint;
{
    CGPoint center = self.center;
    center.x += nowPoint.x - _lastPotion.x;
    center.y += nowPoint.y - _lastPotion.y;
    // 修复移动范围
    center = [self fixedCenterPoint:center];
    self.center = center;
}

/**
 修复移动范围
 @param center 当前中心点
 @return 移动的中心坐标
 @since   v2.2.0
 */
- (CGPoint)fixedCenterPoint:(CGPoint)center;
{
    if (!self.superview) return center;
    
    if (center.x < 0) {
        center.x = 0;
    }else if (center.x > self.superview.lsqGetSizeWidth){
        center.x = self.superview.lsqGetSizeWidth;
    }
    
    if (center.y < 0) {
        center.y = 0;
    }else if (center.y > self.superview.lsqGetSizeHeight){
        center.y = self.superview.lsqGetSizeHeight;
    }
    return center;
}

#pragma mark - handleStretchAction

/**
 处理宽度调节
 @param nowPoint CGPoint
 @since   v2.2.0
 */
- (void)handlePanGestureStretchAction:(CGPoint)nowPoint;
{
    CGSize textSize = CGSizeMake(_textView.bounds.size.width - _textViewMargin.width, _textView.bounds.size.height - _textViewMargin.height);
    CGFloat changeWidth = nowPoint.x - _lastPotion.x;
    CGFloat angle = _mDegree*M_PI/180;
    CGFloat maxWidth = _mCSize.width * _mMaxScale;
    changeWidth = changeWidth * (cos(angle)/fabs(cos(angle)));
    
    if (changeWidth == 0 || textSize.width + changeWidth < _textFont.pointSize + 4)  return;
    if (textSize.width + changeWidth >= maxWidth) return;
    
    CGFloat needHeight = [_textString lsqColculateTextSizeWithAttributs:_textStyleDic maxWidth:textSize.width + changeWidth maxHeihgt:10000].height;
    CGSize newSelfSize = CGSizeMake(self.bounds.size.width + changeWidth, ceil(needHeight + _mCMargin.height));
    
    self.bounds = CGRectMake(0, 0, newSelfSize.width, newSelfSize.height);
    
    [self resetBasicInfo];
    [self resetViewsBounds];
}


#pragma mark - handleRotatScaleAction

/**
 处理旋转和缩放
 @param nowPoint CGPoint
 @since   v2.2.0
 */
- (void)handlePanGestureRotatScaleAction:(CGPoint)nowPoint;
{
    // 中心点
    CGPoint cPoint = self.center;
    
    // 计算旋转角度
    [self computerAngleWithPoint:nowPoint lastPoint:_lastPotion center:cPoint];
    
    // 计算缩放
    [self computerScaleWithPoint:nowPoint lastPoint:_lastPotion center:cPoint];
}


/**
 计算旋转角度
 @param point  当前坐标点
 @param lastPoint  最后坐标点
 @param cPoint  中心点坐标
 @since   v2.2.0
 */
- (void)computerAngleWithPoint:(CGPoint)point
                     lastPoint:(CGPoint)lastPoint
                        center:(CGPoint)cPoint;
{
    // 开始角度
    CGFloat sAngle = [TuSDKTSMath degreesWithPoint:lastPoint center:cPoint];
    // 结束角度
    CGFloat eAngle = [TuSDKTSMath degreesWithPoint:point center:cPoint];
    
    // 旋转度数
    _mDegree = [TuSDKTSMath numberFloat:_mDegree + 360 + (eAngle - sAngle) modulus:360];
    
    [self rotationWithDegrees:_mDegree];
}

/**
 计算缩放
 @param point 当前坐标点
 @param lastPoint 最后坐标点
 @param cPoint 中心点坐标
 @since   v2.2.0
 */
- (void)computerScaleWithPoint:(CGPoint)point
                     lastPoint:(CGPoint)lastPoint
                        center:(CGPoint)cPoint;
{
    // 开始距离中心点距离
    CGFloat sDistance = [TuSDKTSMath distanceOfEndPoint:cPoint startPoint:lastPoint];
    
    // 当前距离中心点距离
    CGFloat cDistance = [TuSDKTSMath distanceOfEndPoint:cPoint startPoint:point];
    // 缩放距离
    CGFloat distance = cDistance - sDistance;
    if (distance == 0) return;
    
    // 计算缩放偏移
    [self computerScaleWithScale:distance / _mCHypotenuse center:cPoint];
}

/**
 计算缩放
 @param scale  缩放倍数
 @param cPoint 中心点坐标
 @since   v2.2.0
 */
- (void)computerScaleWithScale:(CGFloat)scale center:(CGPoint)cPoint;
{
    
    // 计算缩放偏移
    CGFloat offsetScale = scale * 2;
    // 缩放比例
    _mScale += offsetScale;
    _mScale = MAX(self.minScale, MIN(_mScale, _mMaxScale));
    
    CGSize size = CGSizeMake(_mCSize.width * _mScale,
                             _mCSize.height * _mScale);
    
    [self resetTextFont:[_textFont fontWithSize:_mDefaultFontSize * _mScale]];
    
    BOOL needResetBasicInfo = NO;
    CGFloat needHeight = [_textString lsqColculateTextSizeWithAttributs:_textStyleDic maxWidth:size.width maxHeihgt:10000].height;
    if (size.height < needHeight  || size.height > needHeight + _textView.font.pointSize) {
        size.height = needHeight;
        needResetBasicInfo = YES;
    }
    size.width = ceil(size.width + _mCMargin.width);
    size.height = ceil(size.height + _mCMargin.height);
    // 修复移动范围
    CGPoint center = [self fixedCenterPoint:cPoint];
    
    self.bounds = CGRectMake(0, 0, size.width, size.height);
    self.center = center;
    [self resetViewsBounds];
    
    if (needResetBasicInfo) {
        [self resetBasicInfo];
    }
}

#pragma mark - result rect

/**
 获取贴纸处理结果
 @param regionRect 选区范围
 @return 贴纸处理结果
 @since   v2.2.0
 */
- (TuSDKPFStickerResult *)resultWithRegionRect:(CGRect)regionRect;
{
    CGRect center = [self centerOfParentRegin:regionRect];
    
    TuSDKPFStickerText *text = self.textSticker.texts[0];
    text.text = _textString;

    text.textStyleDic = _textStyleDic;
    text.color = _textColor;
    text.rectSize = _textView.bounds.size;
    text.rect = CGRectMake(0, 0, 1, 1);
    
    CGColorRef borderColor = _textView.layer.borderColor;
    _textView.layer.borderColor = [UIColor clearColor].CGColor;
    text.textImage = [self imageWithTextView:_textView];
    _textView.layer.borderColor = borderColor;
    
    TuSDKPFStickerResult *result = [TuSDKPFStickerResult initWithSticker:self.textSticker center:center degree:_mDegree];
    return result;
}

/**
 获取view的截图
 @param view
 @return UIImage
 @since   v2.2.0
 */
- (UIImage *)imageWithTextView:(UIView *)view;
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

/**
 获取相对于父亲视图选区中心百分比信息
 @param regionRect 选区范围
 @return 相对于父亲视图选区中心百分比信息
 @since   v2.2.0
 */
- (CGRect)centerOfParentRegin:(CGRect)regionRect;
{
    if (!self.superview) return regionRect;
    
    // 中心点坐标
    CGFloat distance = [TuSDKTSMath distanceOfPointX1:self.bounds.size.width/2 y1:self.bounds.size.height/2 pointX2:_textView.center.x y2:_textView.center.y];
    
    CGPoint cPoint = CGPointMake(self.center.x + distance*sin(M_PI*_mDegree/180), self.center.y - distance*cos(M_PI*_mDegree/180));
    
    if (CGRectIsEmpty(regionRect)) {
        regionRect = self.superview.bounds;
    }
    
    CGRect center = CGRectMake(cPoint.x, cPoint.y, _textView.bounds.size.width, _textView.bounds.size.height);
    
    // 减去选区外距离
    center = CGRectOffset(center, -regionRect.origin.x, -regionRect.origin.y);
    
    center.origin.x /= regionRect.size.width;
    center.origin.y /= regionRect.size.height;
    center.size.width /= regionRect.size.width;
    center.size.height /= regionRect.size.height;

    return center;
}

/**
 输出信息
 @param tag NSString
 @since   v2.2.0
 */
- (void)loginfo:(NSString *)tag;
{
    lsqLDebug(@"loginfo:%@ \rframe: %@ | \rbounds: %@ | \rcenter: %@ | \rlayer.frame:%@ |\rlayer.bounds:%@ | \rlayer.position: %@ | \rlayer.anchorPoint: %@",
              tag,
              NSStringFromCGRect(self.frame),
              NSStringFromCGRect(self.bounds),
              NSStringFromCGPoint(self.center),
              NSStringFromCGRect(self.layer.frame),
              NSStringFromCGRect(self.layer.bounds),
              NSStringFromCGPoint(self.layer.position),
              NSStringFromCGPoint(self.layer.anchorPoint));
}

- (void)dealloc
{
    [self viewWillDestory];
}

@end
