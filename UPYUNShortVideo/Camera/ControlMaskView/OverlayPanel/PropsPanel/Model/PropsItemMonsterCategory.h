//
//  PropsItemMonsterCategory.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2018/12/25.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "PropsItemCategory.h"
#import "FaceMonsterPropsItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 哈哈镜道具分类
 */
@interface PropsItemMonsterCategory : PropsItemCategory

/**
 获取所有哈哈镜分类
 */
+ (NSArray<PropsItemCategory *> *) allCategories;

@end

NS_ASSUME_NONNULL_END
