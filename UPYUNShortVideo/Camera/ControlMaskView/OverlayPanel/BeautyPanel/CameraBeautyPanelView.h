//
//  CameraBeautyPanelView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewProtocol.h"
#import "CameraFilterPanelProtocol.h"
#import "CameraBeautySkinListView.h"


/**
 美化面板
 */
@interface CameraBeautyPanelView : UIView <OverlayViewProtocol, CameraFilterPanelProtocol>

/** 触发者 */
@property (nonatomic, weak) UIControl *sender;

/** 当前选中的美颜/微整形索引 */
@property (nonatomic, assign, readonly) NSInteger selectedTabIndex;

/**
 标记当前是否选择了自然美颜
 */
@property (nonatomic,readonly) BOOL useSkinNatural;

/**
 当前选择的美颜参数 （润滑，磨皮，红润）
 */
@property (nonatomic,readonly) NSString* selectedSkinKey;

/**
 事件委托
 */
@property (nonatomic, weak) id<CameraFilterPanelDelegate> delegate;

/**
 数据源委托
 */
@property (nonatomic, weak) id<CameraFilterPanelDataSource> dataSource;

/**
 清除选择的微整形特效
 */
- (void)resetPlasticFaceEffect;

@end
