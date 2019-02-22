//
//  PropsItemMonsterCategory.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2018/12/25.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "PropsItemMonsterCategory.h"
#import "FaceMonsterPropsItem.h"
#import "TuSDKFramework.h"

@implementation PropsItemMonsterCategory

-(instancetype)init;
{
    if (self = [super init]) {
        self.categoryType = TuSDKMediaEffectDataTypeMonsterFace;
    }
    return self;
}

/**
 是否可以删除道具物品
 
 @return true 可以被删除
 */
- (BOOL)canRemovePropsItem:(PropsItem *)propsItem; {
    return NO;
}

/**
 获取所有哈哈镜分类
 */
+ (NSArray *)allCategories {
    
    static NSArray<PropsItemCategory *> *categories;
    if (categories) return categories;
    
    NSMutableArray<PropsItemCategory *> *allCagegories = [NSMutableArray array];
    PropsItemMonsterCategory *monsterCategory = [[PropsItemMonsterCategory alloc] init];
    monsterCategory.name = NSLocalizedStringFromTable(@"tu_哈哈镜", @"VideoDemo", @"哈哈镜");
    [allCagegories addObject:monsterCategory];
    
    NSMutableArray<PropsItem *> *monsterPropItems = [NSMutableArray array];
    
    NSDictionary<NSNumber*,NSString*> *monsterFaceTypeDic =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    /** 图片缩略图 ： 哈哈镜类型  */
                    // 哈哈镜 - 大鼻子
                    @"bignose",@(TuSDKMonsterFaceTypeBigNose),
                    // 哈哈镜 - 木瓜脸
                    @"papaya",@(TuSDKMonsterFaceTypePapayaFace),
                    // 哈哈镜 - 大饼脸
                    @"pie",@(TuSDKMonsterFaceTypePieFace),
                    // 哈哈镜 - 眯眯眼
                    @"smalleyes",@(TuSDKMonsterFaceTypeSmallEyes),
                    // 哈哈镜 - 蛇精脸
                    @"snake",@(TuSDKMonsterFaceTypeSnakeFace),
                    // 哈哈镜 - 国字脸
                    @"square",@(TuSDKMonsterFaceTypeSquareFace),
                    // 哈哈镜 - 厚嘴唇
                    @"thicklips",@(TuSDKMonsterFaceTypeThickLips),
     nil];

    [monsterFaceTypeDic.allKeys enumerateObjectsUsingBlock:^(NSNumber* _Nonnull monsterFaceType, NSUInteger idx, BOOL * _Nonnull stop) {
 
        FaceMonsterPropsItem *propsItem = [[FaceMonsterPropsItem alloc] init];
        propsItem.item = monsterFaceType;
        propsItem.thumbImageName = [NSString stringWithFormat:@"face_monster_ic_%@",[monsterFaceTypeDic objectForKey:monsterFaceType]];
        [monsterPropItems addObject:propsItem];
        
    }];
    
    monsterCategory.propsItems = monsterPropItems;
    return categories = allCagegories;
}
@end
