//
//  TuSDKICMessageHubInterface.h
//  TuSDK
//
//  Created by Clear Hu on 15/9/6.
//  Copyright (c) 2015年 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  进度信息提示接口
 */
@protocol TuSDKICMessageHubInterface <NSObject>
/**
 * 显示信息
 *
 * @param status
 *            信息
 */
-(void)setStatus:(NSString *)status;

/**
 * 修改背景颜色
 *
 * @param backGroudColor
 *            背景颜色
 */
- (void)setBackGroudColor:(UIColor *)backGroudColor;

/**
 * 修改背景颜色
 *
 * @param textColor
 *            背景颜色
 */
- (void)setTextColor:(UIColor *)textColor;
/**
 * 修改文字字体
 *
 * @param font
 *            文字字体
 */
- (void)setTextFont:(UIFont *)font;

/**
 * 显示信息 并自动关闭
 *
 * @param message
 *            信息
 */
-(void)showToast:(NSString *)message;

/**
 * 显示进度信息
 *
 * @param progress
 *            进度
 * @param status
 *            信息
 */
-(void)showProgress:(float)progress status:(NSString *)status;

/**
 * 显示成功信息 并自动关闭
 *
 * @param status
 *            信息
 */
-(void)showSuccess:(NSString *)status;

/**
 * 显示错误信息 并自动关闭
 *
 * @param status
 *            信息
 */
-(void)showError:(NSString *)status;


/**
 * 使用动画关闭
 */
-(void)dismiss;
@end
