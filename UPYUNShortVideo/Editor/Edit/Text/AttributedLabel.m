//
//  AttributedLabel.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/3.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "AttributedLabel.h"

/** 默认字体大小 */
static const CGFloat kDefalutFontSize = 24.0;

@interface AttributedLabel ()

/**
 富文本样式
 */
@property (nonatomic, strong) NSMutableDictionary *attributes;

@end

@implementation AttributedLabel{
    NSString *_text;
}
@synthesize text = _text;
@dynamic textColor;
@dynamic textAlignment;
@dynamic font;

#pragma mark - edgeInsets

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets) limitedToNumberOfLines:numberOfLines];
    rect.origin.x -= self.edgeInsets.left;
    rect.origin.y -= self.edgeInsets.top;
    rect.size.width += (self.edgeInsets.left + self.edgeInsets.right);
    rect.size.height += (self.edgeInsets.top + self.edgeInsets.bottom);
    
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

#pragma mark - public

+ (instancetype)defaultLabel {
    AttributedLabel *textLabel = [[AttributedLabel alloc] initWithFrame:CGRectZero];
    textLabel.edgeInsets = UIEdgeInsetsMake(kTextEdgeInset, kTextEdgeInset, kTextEdgeInset, kTextEdgeInset);
    textLabel.text = NSLocalizedStringFromTable(@"tu_点击输入内容", @"VideoDemo", @"点击输入内容");
    textLabel.numberOfLines = -1;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:kDefalutFontSize];
    return textLabel;
}

#pragma mark - attributes

- (void)updateTextAttributes {
    if (!_text.length) return;
    self.attributedText = [[NSAttributedString alloc] initWithString:_text attributes:_attributes];;
}

- (NSMutableDictionary *)attributes {
    if (!_attributes) {
        _attributes = [NSMutableDictionary dictionary];
    }
    return _attributes;
}

- (void)setTextAttributes:(NSDictionary *)textAttributes {
    _attributes = textAttributes.mutableCopy;
    self.attributedText = [[NSAttributedString alloc] initWithString:_text attributes:_attributes];
}
- (NSDictionary *)textAttributes {
    return _attributes.copy;
}

#pragma mark - rewrite

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    if (self.labelUpdateHandler) self.labelUpdateHandler(self);
}

- (void)setText:(NSString *)text {
    _text = text;
    self.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.attributes];
}
- (NSString *)text {
    return _text;
}

- (void)setTextColor:(UIColor *)textColor {
    self.attributes[NSForegroundColorAttributeName] = textColor;
    [self updateTextAttributes];
}
- (UIColor *)textColor {
    return _attributes[NSForegroundColorAttributeName];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    self.paragraphStyle.alignment = textAlignment;
    [self updateTextAttributes];
}
- (NSTextAlignment)textAlignment {
    return self.paragraphStyle.alignment;
}

- (void)setFont:(UIFont *)font {
    self.attributes[NSFontAttributeName] = font;
    [self updateTextAttributes];
}
- (UIFont *)font {
    return _attributes[NSFontAttributeName];
}

#pragma mark - custom

- (void)setTextStrokeColor:(UIColor *)textStrokeColor {
    self.attributes[NSStrokeColorAttributeName] = textStrokeColor;
    self.attributes[NSStrokeWidthAttributeName] = @(-1);
    [self updateTextAttributes];
}
- (UIColor *)textStrokeColor {
    return _attributes[NSStrokeColorAttributeName];
}

- (void)setParagraphStyle:(NSMutableParagraphStyle *)paragraphStyle {
    self.attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    [self updateTextAttributes];
}
- (NSMutableParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *style = _attributes[NSParagraphStyleAttributeName];
    if (!style) {
        style = [[NSMutableParagraphStyle alloc] init];
        _attributes[NSParagraphStyleAttributeName] = style;
    }
    return style;
}

- (void)setUnderline:(BOOL)underline {
    self.attributes[NSUnderlineStyleAttributeName] = @(underline);
    [self updateTextAttributes];
}
- (BOOL)underline {
    return [_attributes[NSUnderlineStyleAttributeName] boolValue];
}

- (void)setWritingDirection:(NSArray<NSNumber *> *)writingDirection {
    self.attributes[NSWritingDirectionAttributeName] = writingDirection;
    [self updateTextAttributes];
}
- (NSArray<NSNumber *> *)writingDirection {
    return _attributes[NSWritingDirectionAttributeName];
}

@end
