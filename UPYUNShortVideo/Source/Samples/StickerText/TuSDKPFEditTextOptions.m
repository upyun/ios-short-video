//
//  TuSDKPFEditTextOptions.m
//  TuSDKGeeV1
//
//  Created by wen on 25/07/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import "TuSDKPFEditTextOptions.h"

@implementation TuSDKPFEditTextOptions
- (void)initOptions;
{
    [super initOptions];
}

/**
 *  默认控制器类
 *
 *  @return 默认控制器类
 */
-(Class)defaultComponentClazz;
{
    return [TuSDKPFEditTextController class];
}

/**
 *  创建图片编辑文字控制器对象
 *
 *  @return 图片编辑滤镜控制器对象
 */
- (TuSDKPFEditTextController *)viewController;
{
    TuSDKPFEditTextController *controller = self.componentInstance;
    controller.textOptions = self.textOptions;
    // 视图类 (默认:TuSDKPFEditTextView, 需要继承 TuSDKPFEditTextView)
    controller.viewClazz = self.viewClazz;
    return controller;
}

@end
