//
//  TuCameraFilterPackage.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/8/28.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuCameraFilterPackage.h"
#import "TuSDKFramework.h"

@implementation TuCameraFilterPackage

/**
 *  相机滤镜配置
 *
 *  @return 相机滤镜配置
 */
+ (instancetype)sharePackage;
{
    static dispatch_once_t pred = 0;
    static TuCameraFilterPackage *object = nil;
    dispatch_once(&pred, ^{
        object = [[self alloc]init];
    });
    return object;
}

/**
 *  滤镜标题数组
 *
 *  @return 滤镜标题数组
 */
- (NSArray *)titleGroupsWithComics:(BOOL)isComics;
{
    NSMutableArray *titles = [NSMutableArray array];

    NSArray *filterGroups = [[TuCameraFilterPackage sharePackage] filterGroups];
    
    for (TuSDKFilterGroup *filterGroup in filterGroups)
    {
        NSString *filterName = NSLocalizedStringFromTable(filterGroup.name, @"TuSDKConstants", @"无需国际化");
        NSLog(@"filterName====%@", filterName);
        [titles addObject:filterName];
    }
    //是否包含漫画
    if (isComics)
    {
        [titles addObject:NSLocalizedStringFromTable(@"tu_漫画", @"VideoDemo", @"漫画")];
    }
    
    return titles;
}
/**
 *  获取短视频滤镜组
 *
 *  @return 短视频滤镜组
 */
- (NSArray *)filterGroups;
{
    NSMutableArray *list = [NSMutableArray array];

    NSArray *filterGroups = [TuSDKFilterLocalPackage package].groups;
    
    for (TuSDKFilterGroup *filterGroup in filterGroups)
    {
        if (filterGroup.groupFilterType == 0)
        {
            [list addObject:filterGroup];
        }
    }
    return [[list reverseObjectEnumerator] allObjects];
}

/**
 *  获取滤镜组
 *
 *  @return group 滤镜列表
 */
- (NSArray *)filterOptionsGroups;
{
    NSMutableArray *list = [NSMutableArray array];
    
    NSArray *filterGroups = [[TuCameraFilterPackage sharePackage] filterGroups];
    
    for (TuSDKFilterGroup *groups in filterGroups)
    {
        NSArray *filters = [[TuSDKFilterLocalPackage package] optionsWithGroup:groups];
        [list addObject:filters];
    }
    return [[list reverseObjectEnumerator] allObjects];
}

/**
 *  获取滤镜codes组
 *
 *  @return group 滤镜codes列表
 */
- (NSArray *)filterCodesGroups;
{
    NSMutableArray *list = [NSMutableArray array];
    
    NSArray *filterGroups = [[TuCameraFilterPackage sharePackage] filterGroups];
    
    for (TuSDKFilterGroup *groups in filterGroups)
    {
        NSMutableArray *codesArray = [NSMutableArray array];
        NSArray *filters = [[TuSDKFilterLocalPackage package] optionsWithGroup:groups];

        for (TuSDKFilterOption *options in filters)
        {
            [codesArray addObject:options.code];
        }
        [list addObject:codesArray];
    }
    return list;
}


@end
