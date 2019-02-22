//
//  StickerPropsItemCategory.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2018/12/25.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "PropsItemStickerCategory.h"
#import "OnlineStickerGroup.h"
#import "StickerPropsItem.h"
#import "TuSDKFramework.h"


static NSString * const kStickerIdKey = @"id";
static NSString * const kStickerNameKey = @"name";
static NSString * const kStickerPreviewImageKey = @"previewImage";
static NSString * const kStickerCategoryNameKey = @"categoryName";
static NSString * const kStickerCategoryStickersKey = @"stickers";
static NSString * const kStickerCategoryCategoriesKey = @"categories";

@implementation PropsItemStickerCategory

-(instancetype)init;
{
    if (self = [super init]) {
        self.categoryType = TuSDKMediaEffectDataTypeSticker;
    }
    return self;
}

/**
 删除指定道具物品
 
 @param propsItem 道具物品
 */
- (BOOL)removePropsItem:(StickerPropsItem *)propsItem;
{
    if (![self canRemovePropsItem:propsItem]) return NO;
    
    NSUInteger index = [self.propsItems indexOfObject:propsItem];
    
    if (index >= 0 && !propsItem.online) {
        // 删除本地存在的贴纸
        [[TuSDKPFStickerLocalPackage package] removeDownloadWithIdt:propsItem.item.idt];
     
        /** 本地配置的在线贴纸数据，需要下载后才可以使用 */
        NSDictionary *onlineStickerJSONDic = [PropsItemStickerCategory localOnlineSticekerJSON];
        // 遍历 categories 字段的数组，其每个元素是字典
        NSArray *onlineStickerJSONCategories = onlineStickerJSONDic[kStickerCategoryCategoriesKey];
        
        for (NSDictionary *onlineCategory in onlineStickerJSONCategories) {
            
            for (NSDictionary *stickerDic in onlineCategory[kStickerCategoryStickersKey]) {
                NSInteger idt = [stickerDic[kStickerIdKey] integerValue];
                if (idt == propsItem.item.idt) {
                    OnlineStickerGroup *onlineSticker = [[OnlineStickerGroup alloc] init];
                    onlineSticker.idt = idt;
                    onlineSticker.previewImage = stickerDic[kStickerPreviewImageKey];
                    onlineSticker.name = stickerDic[kStickerNameKey];
                    propsItem.item = onlineSticker;
                    
                }
            }
        }
        
        return YES;
    }
    
    return NO;
}

/**
 本地配置的在线贴纸数据

 @return NSDictionary<NSString *,NSDictionary*> *
 */
+ (NSDictionary<NSString *,NSDictionary*> *)localOnlineSticekerJSON {
   
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"customStickerCategories" ofType:@"json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:0 error:&error];
    if (error) {
        NSLog(@"sticker categories error: %@", error);
        return nil;
    }
    
    return jsonDic;
}

/**
 加载 json 数据中的贴纸
 
 @return 贴纸
 */
+ (NSArray *)allCategories {

    static NSArray<PropsItemCategory *> *categories;
    if (categories) return categories;
    
    /** 本地配置的在线贴纸数据，需要下载后才可以使用 */
    NSDictionary *onlineStickerJSONDic = [self localOnlineSticekerJSON];
    // 遍历 categories 字段的数组，其每个元素是字典
    NSArray *onlineStickerJSONCategories = onlineStickerJSONDic[kStickerCategoryCategoriesKey];
    
    
    // 获取本地打包及在线下载后的所有贴纸，并创建索引字典
    NSArray<TuSDKPFStickerGroup *> *allLocalStickers = [[TuSDKPFStickerLocalPackage package] getSmartStickerGroups];
    NSMutableDictionary *localStickerDic = [NSMutableDictionary dictionary];
    for (TuSDKPFStickerGroup *sticker in allLocalStickers) {
        localStickerDic[@(sticker.idt)] = sticker;
    }
    
    /** 本地贴纸 + 在线贴纸分类 */
    NSMutableArray *allStickerCategories = [NSMutableArray array];
    

    for (NSDictionary *onlineCategory in onlineStickerJSONCategories) {
        
        PropsItemStickerCategory *stickerCategory = [[PropsItemStickerCategory alloc] init];
        stickerCategory.name = onlineCategory[kStickerCategoryNameKey];

        // 通过 idt 进行筛选，若本地存在该贴纸，则使用本地的贴纸对象；否则为在线贴纸
        NSMutableArray<StickerPropsItem *> *propsItems = [NSMutableArray array];
        
        for (NSDictionary *stickerDic in onlineCategory[kStickerCategoryStickersKey]) {
          
            NSInteger idt = [stickerDic[kStickerIdKey] integerValue];
            TuSDKPFStickerGroup *sticker = localStickerDic[@(idt)];
            StickerPropsItem *propsItem = [[StickerPropsItem alloc] init];
           
            // 如果本地包含该贴纸 无效下载
            if (sticker)
            {
                propsItem.item = sticker;
                [propsItems addObject:propsItem];
                
            } else
            {
                // 本地不包含该贴纸 需要标记为在线贴纸
                OnlineStickerGroup *onlineSticker = [[OnlineStickerGroup alloc] init];
                sticker = onlineSticker;
                onlineSticker.idt = idt;
                onlineSticker.previewImage = stickerDic[kStickerPreviewImageKey];
                onlineSticker.name = stickerDic[kStickerNameKey];
                propsItem.item = sticker;
                [propsItems addObject:propsItem];
            }
        }
        
        stickerCategory.propsItems = propsItems;
        [allStickerCategories addObject:stickerCategory];
    }
    
    return categories = [allStickerCategories copy];
}

#pragma mark - 支持的 json 配置格式示例

// 示例配置
// {
//     "categories":
//     [
//         {
//             "categoryName": "分类名称0", // 分类名称
//             "stickers": // 贴纸数组，支持本地贴纸和在线贴纸
//             [
//                 { // 在线贴纸示例，需配置 `name`、`id`、`previewImage`
//                     // 贴纸名称
//                     "name": "贴纸0",
//                     // 贴纸唯一 ID
//                     "id": "1024",
//                     "previewImage": "https://img.tusdk.com/api/stickerGroup/img?id=stickerID" // 贴纸预览图 URL
//                 },
//                 { // 本地贴纸配置示例，只需配置 `id`
//                     "id": "1048576" // 本地贴纸对应的 ID
//                 }
//             ]
//         },
//         { // 其他分类配置以此类推
//             "categoryName": "分类名称1",
//             "stickers":
//             [
//                 {
//                     "id": "2048"
//                 },
//                 {
//                     "id": "512"
//                 }
//             ]
//         }
//     ]
// }

@end
