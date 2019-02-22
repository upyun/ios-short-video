//
//  VideoThumbnailsView.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/22.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoThumbnailsView : UIView

/**
 每个缩略图宽度，设置 -1 为视图宽度均分缩略图数量宽度
 */
@property (nonatomic, assign) CGFloat thumbnailWidth;

/**
 缩略图数量
 */
@property (nonatomic, assign) NSInteger thumbnailCount;

/**
 完整显示总宽度
 */
@property (nonatomic, assign, readonly) CGFloat thumbnailsTotalWidth;

/**
 设置缩略图数组
 */
@property (nonatomic, strong) NSArray<UIImage *> *thumbnails;

/**
 缩略图更新回调，需要再此做 UI 更新
 */
@property (nonatomic, copy) void (^thumbnailsUpdateHandler)(VideoThumbnailsView *thumbnailsView);

/**
 渐进设置缩略图
 使用这种方式设置缩略图，需要先配置 thumbnailCount，而且其 thumbnail 不会添加到 thumbnails 数组

 @param thumbnail 缩略图
 @param index 图片索引
 */
- (void)setThumbnail:(UIImage *)thumbnail atIndex:(NSInteger)index;

@end
