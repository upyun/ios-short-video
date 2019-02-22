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

@end


#import "TextEditAreaView.h"

@interface TextEditAreaView (MediaTextEffect)

/**
 生成文字特效

 @param videoSize 视频尺寸
 @return 文字特效
 */
- (NSArray<MediaTextEffect *> *)generateTextEffectsWithVideoSize:(CGSize)videoSize;

/**
 通过文字特效配置显示的文字项

 @param textEffects 文字特效
 */
- (void)setupWithTextEffects:(NSArray<MediaTextEffect *> *)textEffects;

@end
