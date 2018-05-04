//
//  TuPhotosPreviewViewCell.h
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TuVideoModel;

/**
 相册内容预览cell
 */
@interface TuPhotosPreviewViewCell : UICollectionViewCell
// model对象
@property (strong, nonatomic) TuVideoModel *model;
// 展示图
@property (strong, nonatomic) UIImage *image;
// 点击回调block
@property (copy, nonatomic) void(^didPHBlock)(UICollectionViewCell *cell);

@end

