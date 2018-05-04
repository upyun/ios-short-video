//
//  ClickPressBottomBar.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/23.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordVideoBottomBar.h"

@interface ClickPressBottomBar : UIView

// 代理对象
@property (nonatomic, assign) id<BottomBarDelegate> bottomBarDelegate;

// 录制按钮
@property (nonatomic, readonly) UIButton *recordButton;
// 滤镜按钮
@property (nonatomic, readonly) UIButton *filterButton;
// 贴纸按钮
@property (nonatomic, readonly) UIButton *stickerButton;
// 删除按钮
@property (nonatomic, readonly) UIButton *deleteButton;
// 保存按钮
@property (nonatomic, readonly) UIButton *saveButton;

// 录制按钮 Label
@property (nonatomic, readonly) UILabel *recordLabel;
// 滤镜按钮 Label
@property (nonatomic, readonly) UILabel *filterLabel;
// 贴纸按钮 Label
@property (nonatomic, readonly) UILabel *stickerLabel;



// 设置当前的录制进度
@property (nonatomic, assign) CGFloat recordProgress;

// 是否显示删除保存的 bottom 视图
- (void)deleteAndSaveVisible:(BOOL)isVisible;
@end
