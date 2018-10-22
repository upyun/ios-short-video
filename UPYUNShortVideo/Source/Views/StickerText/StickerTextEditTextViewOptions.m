//
//  StickerTextEditTextViewOptions.m
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright © 2018 tusdk.com. All rights reserved.
//

#import "StickerTextEditTextViewOptions.h"

/**
 文字贴纸初始化配置类
 @since     v2.2.0
 */
@implementation StickerTextEditTextViewOptions

/**
 初始化默认option
 @return 实例化
 @since  v2.2.0
 */
+ (instancetype)defaultOptions;
{
    StickerTextEditTextViewOptions *options = [[StickerTextEditTextViewOptions alloc] init];
    options.textFont = [UIFont systemFontOfSize:15];
    options.textColor = [UIColor lsqClorWithHex:@"#ffffff"];
    options.textString = LSQString(@"lsq_edit_text_input_tip", @"点击输入内容");
    
    options.enableUnderline = NO;
    options.writingDirection = @[@(NSWritingDirectionLeftToRight|NSWritingDirectionOverride)];
    options.textAlignment = NSTextAlignmentLeft;
    options.textBackgroudColor = [UIColor clearColor];
    options.textStrokeColor = [UIColor clearColor];
    options.textBorderWidth = 2;
    options.textBorderColor = [UIColor whiteColor];
    options.textEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    options.textMaxScale = 2.0;
    
    return options;
}

@end
