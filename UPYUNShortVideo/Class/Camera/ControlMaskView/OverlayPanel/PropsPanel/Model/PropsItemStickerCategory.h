//
//  StickerPropsItemCategory.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2018/12/25.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "PropsItemCategory.h"

NS_ASSUME_NONNULL_BEGIN

/**
 贴纸道具组分类
 */
@interface PropsItemStickerCategory : PropsItemCategory

/**
 获取所有贴纸分类
 */
+ (NSArray<PropsItemCategory *> *) allCategories;

@end

NS_ASSUME_NONNULL_END
