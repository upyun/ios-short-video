//
//  EditCollectionViewDataSource.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 编辑子页面索引
 */
typedef NS_ENUM(NSInteger, EditComponentIndex) {
    // 滤镜页面
    EditComponentIndexFilter = 0,
    // MV 页面
    EditComponentIndexMV,
    // 配乐页面
    EditComponentIndexMusic,
    // 文字页面
    EditComponentIndexText,
    // 特效页面
    EditComponentIndexEffect,
    // 图片贴纸
    EditComponentIndexTileSticker,
    // 比例裁剪
    EditComponentIndexRatio,
    // 转场特效
    EditComponentIndexTransitionEffects
};

/**
 视频编辑底部标签栏数据源
 */
@interface EditCollectionViewDataSource : NSObject<UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end
