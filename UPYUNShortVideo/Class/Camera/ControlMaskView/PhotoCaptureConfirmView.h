//
//  PhotoCaptureConfirmView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/25.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 拍照结果确认视图
 */
@interface PhotoCaptureConfirmView : UIView

/**
 背景容器视图
 */
@property (nonatomic, strong, readonly) UIView *backgroundView;

/**
 拍照结果展示视图
 */
@property (nonatomic, strong, readonly) UIImageView *photoView;

/**
 返回按钮
 */
@property (nonatomic, strong, readonly) UIButton *backButton;

/**
 确认按钮
 */
@property (nonatomic, strong, readonly) UIButton *doneButton;

/**
 图片宽高比
 */
@property (nonatomic, assign) CGFloat photoRatio;

/**
 视图显示状态
 */
- (void)show;

/**
 完成后回调操作
 
 @param completion 完成后的操作
 */
- (void)hideWithCompletion:(void (^)(void))completion;

@end
