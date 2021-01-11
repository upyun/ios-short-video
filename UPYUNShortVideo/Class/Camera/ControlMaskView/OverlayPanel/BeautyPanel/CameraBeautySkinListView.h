//
//  CameraBeautySkinListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/9/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"
#import "HorizontalListItemView.h"
#import "TuSDKFramework.h"

/**
 美颜滤镜列表
 */
@interface CameraBeautySkinListView : HorizontalListView

/**
 点击回调
 */
@property (nonatomic, copy) void (^itemViewTapActionHandler)(CameraBeautySkinListView *listView, HorizontalListItemView *selectedItemView);


/*美肤类型*/
@property (nonatomic,readonly) TuSkinFaceType faceType;

/**
 当前选择的美颜参数 （润滑，磨皮，红润）
 */
@property (nonatomic,readonly) NSString* selectedSkinKey;

@end
