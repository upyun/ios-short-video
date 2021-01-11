//
//  EditCollectionViewCell.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 视频编辑功能项单元格
 */
@interface EditCollectionViewCell : UICollectionViewCell

/**
 缩略图
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

/**
 标题标签
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@end
