//
//  MultiAssetPickerCell.h
//  MultiVideoPicker
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


/**
 多视频选择器单元格
 */
@interface MultiAssetPickerCell : UICollectionViewCell

/**
 缩略图视图
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

/**
 选中按钮
 */
@property (nonatomic, strong, readonly) UIButton *selectButton;

/**
 时间标签
 */
@property (nonatomic, strong, readonly) UILabel *timeLabel;

/**
 选中按钮事件回调
 */
@property (nonatomic, copy) void (^selectButtonActionHandler)(MultiAssetPickerCell *cell, UIButton *sender);

/**
 视频时长
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 选中序号
 */
@property (nonatomic, assign) NSInteger selectedIndex;


/**
 设置视频资产
 */
@property (nonatomic,assign)PHAsset *asset;

@end

/**
 多视频选取器页脚视图
 */
@interface MultiVideoPickerFooterView : UICollectionReusableView

/**
 视频个数
 */
@property (nonatomic, assign) NSInteger videoCount;

@end
