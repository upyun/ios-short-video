//
//  TuSDKPFEditTextViewOptions.m
//  TuSDKGeeV1
//
//  Created by wen on 03/08/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import "TuSDKPFEditTextViewOptions.h"

@implementation TuSDKPFEditTextViewOptions
// 初始化默认option
+ (instancetype)defaultOptions;
{
    TuSDKPFEditTextViewOptions *options = [[TuSDKPFEditTextViewOptions alloc]init];
    options.textFont = [UIFont systemFontOfSize:40];
    options.textColor = [UIColor lsqClorWithHex:@"#fffc3a"];
    options.textString = LSQString(@"lsq_edit_text_input_tip", @"点击输入内容");
    
    options.enableUnderline = NO;
    options.writingDirection = @[@(NSWritingDirectionLeftToRight|NSWritingDirectionOverride)];
    options.textAlignment = NSTextAlignmentLeft;
    options.textBackgroudColor = [UIColor clearColor];
    options.textStrokeColor = [UIColor clearColor];
    options.textBorderWidth = 2;
    options.textBorderColor = [UIColor whiteColor];
    options.textEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    options.textMaxScale = 1.0;
    
    return options;
}

@end
