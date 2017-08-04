//
//  CutVideoBottomView.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/13.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoClipView.h"

/**
 视频裁剪页面底部栏视图
 */
@interface CutVideoBottomView : UIView

// 视频总时长
@property (nonatomic, assign) CGFloat timeInterval;
// 当前时间  用来更新白条view位置
@property (nonatomic, assign) CGFloat currentTime;
// 底部滑动 View
@property (nonatomic, strong)  VideoClipView *clipView;
// 缩略图
@property (nonatomic, strong) NSArray<UIImage*> *thumbnails;
// 拖动改变的block
@property (nonatomic, strong)  void(^slipChangeTimeBlock)(CGFloat,lsqClipViewStyle);
// 拖动结束的block
@property (nonatomic, strong)  void(^slipEndBlock)(void);
// 拖动开始的block； 参数表示拖动的是起始按钮
@property (nonatomic, strong)  void(^slipBeginBlock)(void);

@end
