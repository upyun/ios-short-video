//
//  TuCameraFilterCell.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/9/9.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuCameraFilterCell : UICollectionViewCell

@property (nonatomic, strong) NSArray *codeArray;

@end

NS_ASSUME_NONNULL_END

@interface CameraFilterCell : UICollectionViewCell

/**
 缩略图视图
 */
@property (nonatomic, strong, nullable) UIImageView *thumbnailView;

/**
 标题标签
 */
@property (nonatomic, strong, nullable) UILabel *titleLabel;

@property (nonatomic, copy, nullable) NSString *codeName;

@end
