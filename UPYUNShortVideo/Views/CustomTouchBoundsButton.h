//
//  CustomTouchBoundsButton.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/9/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自定义触摸范围按钮
 */
@interface CustomTouchBoundsButton : UIButton

/**
 可接收触摸时间的尺寸
 */
@property (nonatomic, assign) CGSize targetTouchSize;

@end
