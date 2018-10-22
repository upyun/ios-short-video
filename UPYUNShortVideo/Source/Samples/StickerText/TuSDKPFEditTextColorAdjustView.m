//
//  TuSDKPFEditTextColorAdjustView.m
//  TuSDKGeeV1
//
//  Created by wen on 27/07/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import "TuSDKPFEditTextColorAdjustView.h"

@interface TuSDKPFEditTextColorAdjustView (){
    CGFloat _itemWidth;
    CGFloat _itemHeight;
    CGFloat _originY;
    NSInteger _currentColorIndex;
    NSUInteger _currentStyeIndex;
    UIView *_displayView;
    
}

@end

@implementation TuSDKPFEditTextColorAdjustView

#pragma mark - setter getter

- (void)setHexColors:(NSArray<NSString *> *)hexColors;
{
    _hexColors = hexColors;
    _currentColorIndex = -1;
    [self resetColorView];
}

- (void)setStyleArr:(NSArray<NSNumber *> *)styleArr;
{
    _styleArr = styleArr;
    NSNumber *styleType = styleArr[0];
    _currentStyeIndex = [styleType unsignedIntegerValue];
    [self resetStyleView];
}

#pragma mark - init method 

- (instancetype)init;
{
    if (self = [super init]) {
        _edgeInsets = UIEdgeInsetsMake(10, 20, 10, 10);
    }
    return self;
}

- (void)resetColorView;
{
    NSInteger allCount = _defaultClearColor ? _hexColors.count + 1 : _hexColors.count;
    
    _itemWidth = (self.lsqGetSizeWidth - _edgeInsets.left - _edgeInsets.right)/allCount;
    _originY = (self.lsqGetSizeHeight - _edgeInsets.top - _edgeInsets.bottom)*3/5 + _edgeInsets.top;
    _itemHeight = self.lsqGetSizeHeight - _originY - _edgeInsets.bottom;
    
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
        CGFloat displayViewWidth = _originY - _edgeInsets.top - 5;
        _displayView = [[UIView alloc]initWithFrame:CGRectMake(0, _edgeInsets.top, displayViewWidth, displayViewWidth)];
        _displayView.hidden = YES;
        _displayView.layer.borderColor = [UIColor whiteColor].CGColor;
        _displayView.layer.borderWidth = 1;
        [self addSubview:_displayView];
    }
}

- (void)resetStyleView;
{
    CGFloat btnInterval = 10;
    CGFloat btnWidth = (self.lsqGetSizeWidth - _edgeInsets.left - _edgeInsets.right - btnInterval)/(_styleArr.count) - btnInterval;
    CGFloat btnHeight = 16;
    CGFloat btnCenterX = _edgeInsets.left + btnInterval + btnWidth/2;
    CGFloat btnCenterY = 5 + btnHeight/2;
    
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y >= _originY && point.y <= (_originY + _itemHeight)) {
        [self getColorAtPointX:point.x];
        [self resetDisplayViewCenterWith:point isHidden:NO];
    }
}

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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self resetDisplayViewCenterWith:CGPointZero isHidden:YES];
}

#pragma mark - custom method

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

- (void)resetDisplayViewCenterWith:(CGPoint)point isHidden:(BOOL)isHidden;
{
    _displayView.hidden = isHidden;
    if (!isHidden) {
        _displayView.center = CGPointMake(point.x, _displayView.center.y);
    }
}

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
