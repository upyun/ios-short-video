//
//  StickerPropsItem.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2018/12/25.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "PropsItemCategory.h"

@class TuSDKPFStickerGroup;

NS_ASSUME_NONNULL_BEGIN

/**
 贴纸道具
 */
@interface StickerPropsItem : PropsItem <TuSDKPFStickerGroup *>



@end

@interface StickerPropsItem (Download)


@end

NS_ASSUME_NONNULL_END
