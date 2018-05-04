//
//  EffectsView.h
//  TuSDKVideoDemo
//
//  Created by wen on 13/12/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectsDisplayView.h"

// 特效栏事件代理
@protocol EffectsViewEventDelegate <NSObject>
/**
选中特效
 */
- (void)effectsSelectedWithCode:(NSString *)effectCode;

/**
 结束选中的特效
 */
- (void)effectsEndWithCode:(NSString *)effectCode;

/**
 回删已添加的特效
 */
- (void)effectsBackEvent;

/**
 移动视频的播放进度条
 */
- (void)effectsMoveVideoProgress:(CGFloat)newProgress;

@end



@interface EffectsView : UIView

// 视频路径URL
@property (nonatomic, strong) NSURL *videoURL;
// 滤镜事件的代理
@property (nonatomic, assign) id<EffectsViewEventDelegate> effectEventDelegate;
// 视频处理的当前位置 0~1
@property (nonatomic, assign) CGFloat progress;
// 特效code 数组
@property (nonatomic, strong) NSArray<NSString *> * effectsCode;
// 缩略图展示view
@property (nonatomic, strong) EffectsDisplayView *displayView;


/**
 设置撤销按钮是否可点击

 @param isEnable YES:可点击
 */
- (void)backBtnEnabled:(BOOL)isEnable;

@end


