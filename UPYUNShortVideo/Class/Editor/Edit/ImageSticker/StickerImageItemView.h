//
//  EditTileStickerListItemView.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/5.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"
#import "TuSDKFramework.h"

@class EditTileStickerModel;

NS_ASSUME_NONNULL_BEGIN

@interface StickerImageItemView : HorizontalListItemBaseView

/**
 当前自定义贴纸数据
 */
@property (nonatomic,strong)UIImage *stickerimage;

@end

NS_ASSUME_NONNULL_END
