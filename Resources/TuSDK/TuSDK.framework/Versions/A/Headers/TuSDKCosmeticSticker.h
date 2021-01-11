//
//  TuSDKCosmeticSticker.h
//  TuSDK
//
//  Created by tusdk on 2020/10/16.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKLiveStickerImage.h"
#import "CosmeticLipFilter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 美妆贴纸状态枚举
 */
typedef NS_ENUM(NSInteger,CosmeticStickerState)  {
    CosmeticStickerStateNoChange,
    CosmeticStickerStateUpdate,
    CosmeticStickerStateClose
};

@interface TuSDKCosmeticSticker : NSObject

@property(nonatomic,readwrite) CosmeticStickerState state; // 美妆贴纸状态

@property(nonatomic,readwrite) lsqStickerPositionType type; // 美妆类型

@property(nonatomic,readwrite) TuSDKPFSticker *data; // 美妆贴纸数据

@property(nonatomic,readwrite) CosmeticLipType lipType; // 唇彩类型，唇彩特有属性

@property(nonatomic,readwrite) int lipColor; // 唇彩颜色rgb，唇彩特有属性


@end

NS_ASSUME_NONNULL_END
