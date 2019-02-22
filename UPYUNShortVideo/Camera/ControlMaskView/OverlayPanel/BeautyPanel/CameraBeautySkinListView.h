//
//  CameraBeautySkinListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/9/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"


/**
 美颜滤镜列表
 */
@interface CameraBeautySkinListView : HorizontalListView

/**
 点击回调
 */
@property (nonatomic, copy) void (^itemViewTapActionHandler)(CameraBeautySkinListView *listView, HorizontalListItemView *selectedItemView);

/**
 标记当前是否选择了自然美颜
 */
@property (nonatomic,readonly) BOOL useSkinNatural;

/**
 当前选择的美颜参数 （润滑，磨皮，红润）
 */
@property (nonatomic,readonly) NSString* selectedSkinKey;

@end
