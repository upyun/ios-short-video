//
//  ScrollListItemCell.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/8/2.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 滚动列表项单元格
 */
@interface ScrollListItemCell : UICollectionViewCell

/// 标题
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/// 缩略图
@property (nonatomic, strong, readonly) UIImageView *thumbnailView;

/**
 配置无效果样式
 */
- (void)setupDisableStyle;

/**
 配置普通样式

 @param thumbnail 缩略图
 @param title 标题
 */
- (void)setupWithThumbnail:(UIImage *)thumbnail title:(NSString *)title;

@end
