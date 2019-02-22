//
//  StickerCategory.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "PropsItemCategory.h"

@implementation PropsItemCategory

/**
 是否可以删除道具物品
 
 @return true 可以被删除
 */
- (BOOL)canRemovePropsItem:(PropsItem *)propsItem {
    return (propsItem && !propsItem.online);
}

/**
 删除指定道具物品
 
 @param propsItem 道具物品
 */
- (BOOL)removePropsItem:(PropsItem *)propsItem;
{
    if (!self.propsItems || self.propsItems.count == 0 ||propsItem.online || ![self canRemovePropsItem:propsItem]) return NO;
    
    NSMutableArray<PropsItem *> *newPropsItemArray = [NSMutableArray arrayWithArray:self.propsItems];
    [newPropsItemArray removeObject:propsItem];
    
    return YES;
}

@end

@implementation PropsItem
@end
