//
//  MVScrollView.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/26.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerScrollView.h"

/**
  MV 相关代理方法
 @param stickGroup 贴纸组对象
 */
@protocol MVViewClickDelegate <NSObject>

/**
 点击新的MV组代理方法

 @param mvData MV贴纸的数据
 */
- (void)clickMVListViewWith:(TuSDKMediaStickerAudioEffectData *)mvData;
@end


#pragma mark - MVScrollView

@interface MVScrollView : UIView

// MV 事件代理
@property (nonatomic, assign) id<MVViewClickDelegate> mvDelegate;
// collectionView 对象
@property (nonatomic, strong) UICollectionView *collectionView;

// 选中某一个cell
- (void)selectItemWithIndex:(NSIndexPath *)indexPath;
@end
