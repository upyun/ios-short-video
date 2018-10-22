//
//  StickerTextColorAdjustView.m
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright © 2018 tusdk.com. All rights reserved.
//

#import "StickerTextColorAdjustView.h"

/**
 颜色选择视图类
 @since   v2.2.0
 */
@interface StickerTextColorAdjustView (){
    // 颜色小视图宽度
    CGFloat _itemWidth;
    // 颜色小视图高度
    CGFloat _itemHeight;
    // 颜色小视图起点Y
    CGFloat _originY;
    // 当前颜色选择索引
    NSInteger _currentColorIndex;
    // 当前样式选择索引
    NSUInteger _currentStyeIndex;
    // 显示视图
    UIView *_displayView;
}

@end

@implementation StickerTextColorAdjustView

#pragma mark - setter getter

/**
 设置颜色视图
 @param hexColors NSArray
 @since   v2.2.0
 */
- (void)setHexColors:(NSArray<NSString *> *)hexColors;
{
    _hexColors = hexColors;
    _currentColorIndex = -1;
    [self resetColorView];
}

/**
 设置样式视图
 @param styleArr NSArray
 @since   v2.2.0
 */
- (void)setStyleArr:(NSArray<NSNumber *> *)styleArr;
{
    _styleArr = styleArr;
    NSNumber *styleType = styleArr[0];
    _currentStyeIndex = [styleType unsignedIntegerValue];
    [self resetStyleView];
}

#pragma mark - init method 

/**
 初始化
 @return UIView
 @since   v2.2.0
 */
- (instancetype)init;
{
    if (self = [super init]) {
        _edgeInsets = UIEdgeInsetsMake(10, 20, 10, 10);
    }
    return self;
}

/**
 重新创建颜色视图
 @since   v2.2.0
 */
- (void)resetColorView;
{
    NSInteger allCount = _defaultClearColor ? _hexColors.count + 1 : _hexColors.count;
    
    _itemWidth = (self.lsqGetSizeWidth - _edgeInsets.left - _edgeInsets.right)/allCount;
    
    CGFloat height = (self.lsqGetSizeHeight - _edgeInsets.top - _edgeInsets.bottom)*3/5 + _edgeInsets.top;
    _originY =  height - _edgeInsets.top - 5;
    _itemHeight = self.lsqGetSizeHeight - height - _edgeInsets.bottom;
    
    for (UIView *view in self.subviews) {
        if (view.tag == 201) {
            [view removeFromSuperview];
        }
    }
    
    CGFloat originX = _edgeInsets.left;
    
    if (_defaultClearColor) {
        UIImageView *item = [UIImageView initWithFrame:CGRectMake(originX, _originY, _itemWidth, _itemHeight) imageLSQBundleNamed:@"style_default_edit_button_text_clearColor"];
        item.tag = 201;
        [self addSubview:item];
        originX += _itemWidth;
    }
    
    for (NSString *hexColor in _hexColors) {
        UIView *item = [[UIView alloc]initWithFrame:CGRectMake(originX, _originY, _itemWidth, _itemHeight)];
        item.tag = 201;
        item.backgroundColor = [UIColor lsqClorWithHex:hexColor];
        [self addSubview:item];
        originX += _itemWidth;
    }
    
    if (!_displayView) {
        CGFloat displayViewWidth = height - _edgeInsets.top - 5;
        _displayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, displayViewWidth, displayViewWidth)];
        _displayView.hidden = YES;
        _displayView.layer.borderColor = [UIColor whiteColor].CGColor;
        _displayView.layer.borderWidth = 1;
        [self addSubview:_displayView];
    }
}

/**
 重新创建样式视图
 @since   v2.2.0
 */
- (void)resetStyleView;
{
    CGFloat btnInterval = 10;
    CGFloat btnWidth = (self.lsqGetSizeWidth - _edgeInsets.left - _edgeInsets.right - btnInterval)/(_styleArr.count) - btnInterval;
    CGFloat btnHeight = 16;
    CGFloat btnCenterX = _edgeInsets.left + btnInterval + btnWidth/2;
    CGFloat btnCenterY = (self.lsqGetSizeHeight - _edgeInsets.top - _edgeInsets.bottom) + _edgeInsets.top;
    
    NSInteger index = 0;
    
    for (UIView *view in self.subviews) {
        if (view.tag >= 100) {
            [view removeAllSubviews];
        }
    }
    
    for (NSNumber *styleNum in _styleArr) {
        NSString *styleStr = [self getStyleNameWith:styleNum.integerValue];
        CGFloat needWidth = [styleStr lsqColculateTextSizeWithFont:[UIFont systemFontOfSize:14] maxWidth:btnWidth maxHeihgt:btnHeight].width + 15;
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, (needWidth > btnWidth ? btnWidth : needWidth), btnHeight)];
        btn.center = CGPointMake(btnCenterX, btnCenterY);
        btn.tag = styleNum.integerValue;
        if (index == 0) {
            [btn setTitleColor:_styleSelectedColor ? _styleSelectedColor : [UIColor redColor] forState:UIControlStateNormal];
        }else{
            btn.titleLabel.textColor = _styleNormalColor ? _styleNormalColor : [UIColor whiteColor];
        }
        
        [btn setTitle:styleStr forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(clickStyleBtnWith:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        btnCenterX = btnCenterX + btnWidth + btnInterval;
        index ++;
    }
}

#pragma mark - touch method

/**
 触摸开始
 @param touches 触摸对象集合
 @param event 触摸事件
 @since   v2.2.0
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y >= _originY && point.y <= (_originY + _itemHeight)) {
        [self getColorAtPointX:point.x];
        [self resetDisplayViewCenterWith:point isHidden:NO];
    }
}

/**
 触摸移动
 @param touches 触摸对象集合
 @param event 触摸事件
 @since   v2.2.0
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y >= _originY && point.y <= (_originY + _itemHeight)) {
        [self getColorAtPointX:point.x];
        [self resetDisplayViewCenterWith:point isHidden:NO];
    }else{
        [self resetDisplayViewCenterWith:CGPointZero isHidden:YES];
    }
}

/**
 触摸结束
 @param touches 触摸对象集合
 @param event 触摸事件
 @since   v2.2.0
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self resetDisplayViewCenterWith:CGPointZero isHidden:YES];
}

#pragma mark - custom method

/**
 获取颜色类型
 @param colorType
 @return NSString
 @since   v2.2.0
 */
- (NSString *)getStyleNameWith:(NSUInteger)colorType;
{
    NSString *type = @"color";
    switch (colorType) {
        case TuSDKPFEditTextColorType_TextColor:
            type = LSQString(@"lsq_edit_text_color_text", @"字体颜色");
            break;
        case TuSDKPFEditTextColorType_BackgroudColor:
            type = LSQString(@"lsq_edit_text_color_backgroud", @"背景颜色");
            break;
        case TuSDKPFEditTextColorType_StrokeColor:
            type = LSQString(@"lsq_edit_text_color_stroke", @"线条颜色");
            break;

        default:
            break;
    }
    return type;
}

/**
 获取对应颜色
 @param x 所在位置
 @return UIColor
 @since   v2.2.0
 */
- (UIColor *)getColorAtPointX:(CGFloat)x;
{
    CGFloat newX = x - _edgeInsets.left;
    UIColor *resultColor = nil;
    NSInteger index = newX/_itemWidth;
    NSInteger allCount = _defaultClearColor ? _hexColors.count + 1 : _hexColors.count;

    if (index >= 0 && index < allCount && _currentColorIndex != index) {
        if (_defaultClearColor) {
            resultColor = (index == 0) ? [UIColor clearColor] : [UIColor lsqClorWithHex:_hexColors[index - 1]];
        }else{
            resultColor = [UIColor lsqClorWithHex:_hexColors[index]];
        }
        _displayView.backgroundColor = resultColor;
        _currentColorIndex = index;
        // 回调选中的颜色
        if ([self.colorDelegate respondsToSelector:@selector(onSelectColorWith: styleType:)]) {
            [self.colorDelegate onSelectColorWith:resultColor styleType:_currentStyeIndex];
        }
    }
    return resultColor;
}

/**
 重置显示视图位置
 @param point CGPoint
 @param isHidden BOOL
 @since   v2.2.0
 */
- (void)resetDisplayViewCenterWith:(CGPoint)point isHidden:(BOOL)isHidden;
{
    _displayView.hidden = isHidden;
    if (!isHidden) {
        _displayView.center = CGPointMake(point.x, _displayView.center.y);
    }
}

/**
 选中按钮后的显示
 @param btn UIButton
 */
- (void)clickStyleBtnWith:(UIButton *)btn;
{
    _currentStyeIndex = btn.tag;

    for (UIButton *theBtn in self.subviews) {
        if (theBtn.tag >= 100 && theBtn.tag < 200) {
            if (theBtn == btn) {
                [theBtn setTitleColor:_styleSelectedColor ? _styleSelectedColor : [UIColor redColor] forState:UIControlStateNormal];
            }else{
                [theBtn setTitleColor:_styleNormalColor ? _styleNormalColor : [UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
}

@end
