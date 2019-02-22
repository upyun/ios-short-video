//
//  MusicListView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/2.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"

@class MusicListView;

@protocol MusicListViewDelegate <NSObject>
@optional

/**
 音乐列表选中回调

 @param listView 音乐列表视图
 @param musicURL 音乐文件的 URL 地址
 @param tapCount 点击次数
 */
- (void)musicList:(MusicListView *)listView didSelectMusic:(NSURL *)musicURL tapCount:(NSInteger)tapCount;

/**
 录音选中回调

 @param listView 音乐列表视图
 */
- (void)musicListDidNeedRecord:(MusicListView *)listView;

@end

/**
 配乐列表视图
 */
@interface MusicListView : HorizontalListView

@property (nonatomic, weak) IBOutlet id<MusicListViewDelegate> delegate;

/**
 列表中的所有配乐
 */
@property (nonatomic, strong, readonly) NSArray *musicURLs;

/**
 设置给定的 URL 对应的列表项为选中状态。边缘情况：传入 nil，则无选中；传入非列表的音乐则选中录音项

 @param musicURL 音乐文件的 URL 地址
 */
- (void)selectMusicURL:(NSURL *)musicURL;

@end
