//
//  MediaTextEffect.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/10/22.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TuSDKFramework.h"

/**
 文字特效子类
 */
@interface MediaTextEffect : TuSDKMediaTextEffect

/**
 内边距
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 文字内容
 */
@property (nonatomic, copy) NSString *text;

/**
 富文本样式
 */
@property (nonatomic, strong) NSDictionary *textAttributes;

/**
 背景色
 */
@property (nonatomic, strong) UIColor *backgroundColor;


/**
 保存各种颜色进度，用于回显
 */
@property (nonatomic) CGFloat textColorProgress;
@property (nonatomic) CGFloat textStrokeColorProgress;
@property (nonatomic) CGFloat bgColorProgress;

@end
