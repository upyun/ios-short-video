//
//  PropsItemCategory.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKFramework.h"

typedef void(^LoadHander)(id<TuSDKMediaEffect>);

@class PropsItem;

/**
 道具自定义分类模型
 */
@interface PropsItemCategory : NSObject

/**
 分类类型
 */
@property (nonatomic) TuSDKMediaEffectDataType categoryType;

/**
 分类名称
 */
@property (nonatomic, copy) NSString *name;

/**
 分类道具
 */
@property (nonatomic, strong) NSArray<PropsItem *> *propsItems;

/**
 是否可以删除道具物品

 @return true 可以被删除
 */
- (BOOL)canRemovePropsItem:(PropsItem *)propsItem;

/**
 删除指定道具物品

 @param propsItem 道具物品
 */ 
- (BOOL)removePropsItem:(PropsItem *)propsItem;

@end


/**
 道具项
 */
@interface PropsItem <Item> : NSObject
{
    id<TuSDKMediaEffect> _effect;
}

/**
 道具项数据
 */
@property (nonatomic) Item item;

/**
 当前贴纸道具是否为在线贴纸，如果为 true 需下载后方可使用
 
 @return true/false
 */
@property (nonatomic,readonly) BOOL online;

/**
 是否正在下载中
 */
@property (nonatomic,readonly) BOOL isDownLoading;

/**
 道具特效对象
 */
@property (nonatomic,readonly) id<TuSDKMediaEffect> effect;

/**
 加载道具封面

 @param thumbImageView 封面视图
 @param hander 加载完成处理器
 */
- (void)loadThumb:(UIImageView *)thumbImageView completed:(void(^)(BOOL))hander;

/**
 加载特效

 @param hander 加载完成处理器
 */
- (void)loadEffect:(LoadHander)hander;

@end

#pragma mark - 支持的 json 配置格式

// 示例配置
// {
//     "categories":
//     [
//         {
//             "categoryName": "分类名称0", // 分类名称
//             "stickers": // 道具数组，支持本地道具和在线道具
//             [
//                 { // 在线道具示例，需配置 `name`、`id`、`previewImage`
//                     // 道具名称
//                     "name": "道具0",
//                     // 道具唯一 ID
//                     "id": "1024",
//                     "previewImage": "https://img.tusdk.com/api/stickerGroup/img?id=stickerID" // 道具预览图 URL
//                 },
//                 { // 本地道具配置示例，只需配置 `id`
//                     "id": "1048576" // 本地道具对应的 ID
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
