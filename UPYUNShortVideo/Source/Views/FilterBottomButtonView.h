//
//  FilterBottomButtonView.h
//  TuSDKVideoDemo
//
//  Created by wen on 22/08/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "BottomButtonView.h"

/**
 带有底部选择按钮的滤镜栏
 */
@interface FilterBottomButtonView : UIView
// 滤镜栏
@property (nonatomic, strong) FilterView *filterView;
// 滤镜模式选择按钮
@property (nonatomic, strong) BottomButtonView *bottomButton;

@end
