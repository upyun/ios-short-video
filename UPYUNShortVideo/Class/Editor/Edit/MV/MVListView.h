//
//  MVListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"

@class MVListView, TuSDKMediaStickerAudioEffect;

@protocol MVListViewDelegate <NSObject>
@optional

/**
 MV 特效选中回调

 @param listView MV 列表视图
 @param mvEffect MV 效果
 @param tapCount 点击次数
 */
- (void)mvlist:(MVListView *)listView didSelectEffect:(TuSDKMediaStickerAudioEffect *)mvEffect tapCount:(NSInteger)tapCount;

@end

/**
 MV 列表视图
 */
@interface MVListView : HorizontalListView

@property (nonatomic, weak) IBOutlet id<MVListViewDelegate> delegate;

/**
 设置给定的 MV 特效对应的列表项为选中状态。边缘情况：传入 nil，则无选中；传入非列表的音乐则选中录音项

 @param mvEffect MV 效果
 */
- (void)selectMVWithEffect:(TuSDKMediaStickerAudioEffect *)mvEffect;

@end
