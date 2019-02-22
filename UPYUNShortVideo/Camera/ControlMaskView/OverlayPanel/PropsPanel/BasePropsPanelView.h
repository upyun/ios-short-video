//
//  BaseStickerPanelView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageTabbar.h"
#import "ViewSlider.h"

@class PropsItemCategory;

/**
 道具面板基类
 */
@interface BasePropsPanelView : UIView <PageTabbarDelegate, ViewSliderDataSource, ViewSliderDelegate>

/**
 重置安桥
 */
@property (nonatomic, strong, readonly) UIButton *unsetButton;

/**
 道具分类
 */
@property (nonatomic, strong, readonly) PageTabbar *categoryTabbar;

/**
 分类的滑动栏
 */
@property (nonatomic, strong, readonly) ViewSlider *categoryPageSlider;

- (void)commonInit;

@end
