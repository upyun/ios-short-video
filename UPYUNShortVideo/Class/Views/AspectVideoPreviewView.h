//
//  AspectVideoPreviewView.h
//  AspectVideoPreviewView
//
//  Created by bqlin on 2018/9/26.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 自适应视频预览视图
 */
@interface AspectVideoPreviewView : UIView

/**
 视频视图
 */
@property (nonatomic, strong, readonly) UIView *videoView;

/**
 视频尺寸
 */
@property (nonatomic, assign) CGSize videoSize;

/**
 布局变更回调
 */
@property (nonatomic, copy) void (^resizeHandler)(AspectVideoPreviewView *previewView);

@end

NS_ASSUME_NONNULL_END
