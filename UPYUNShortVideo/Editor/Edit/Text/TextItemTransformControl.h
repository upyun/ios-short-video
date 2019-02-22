//
//  TextItemTransformControl.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/6.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributedLabel.h"

/**
 文字项变形控件
 */
@interface TextItemTransformControl : UIControl

/**
 显示的文字标签
 */
@property (nonatomic, strong) AttributedLabel *textLabel;

/**
 关闭按钮事件回调
 */
@property (nonatomic, copy) void (^closeButtonActionHandler)(TextItemTransformControl *control, UIButton *sender);

/**
 通过内容大小更新布局

 @param contentSize 布局尺寸
 */
- (void)updateLayoutWithContentSize:(CGSize)contentSize;

@end
