//
//  AttributedLabel.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/3.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

static const CGFloat kTextEdgeInset = 14;

/** 默认字体大小 */
static const CGFloat kDefalutFontSize = 24.0;

/** 默认字体大小 */
static const CGFloat kMaxFontSize = kDefalutFontSize * 4;

/**
 可动态更改所有文字、段落样式的 UILabel 子类
 */
@interface AttributedLabel : UILabel

/**
 显示时间范围
 */
@property (nonatomic, assign) CMTimeRange timeRange;

/**
 内边距
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 文字内容更回调
 */
@property (nonatomic, copy) void (^labelUpdateHandler)(AttributedLabel *label);

/**
 文字
 */
@property (nonatomic, copy) NSString *text;

/**
 富文本样式
 */
@property (nonatomic, strong) NSDictionary *textAttributes;

/**
 文字颜色
 */
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) CGFloat textColorProgress;

/**
 文字描边颜色
 */
@property (nonatomic, strong) UIColor *textStrokeColor;
@property (nonatomic) CGFloat textStrokeColorProgress;

@property (nonatomic) CGFloat bgColorProgress;


/**
 文字描边宽度
 */
@property (nonatomic) CGFloat textStrokeWidth;

/**
 字间距
 */
@property (nonatomic) CGFloat wordSpace;

/**
 行间距
 */
@property (nonatomic) CGFloat lineSpace;

/**
 文字字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 斜体
 */
@property (nonatomic)BOOL obliqueness;

/**
 粗体
 */
@property (nonatomic)BOOL bold;


/**
 段落样式
 */
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

/**
 下划线
 */
@property (nonatomic, assign) BOOL underline;

/**
 书写方向
 */
@property (nonatomic, strong) NSArray<NSNumber *> *writingDirection;

/**
 文字对齐
 */
@property(nonatomic, assign) NSTextAlignment textAlignment;

/**
 初始百分比值中点
 */
@property (nonatomic, assign) CGPoint initialPercentCenter;

/**
 默认自定义标签

 @return 默认标签
 */
+ (instancetype)defaultLabel;

@end
