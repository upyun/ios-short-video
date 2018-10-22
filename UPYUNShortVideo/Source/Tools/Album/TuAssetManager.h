//
//  TuAssetManager.h
//  VideoAlbumDemo
//
//  Created by wen on 23/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TuVideoModel.h"

/**
 相册管理类
 */
@interface TuAssetManager : NSObject

// 是否需要刷新读取数据
@property (assign, nonatomic) BOOL ifRefresh;

// 初始化方法
+ (instancetype)sharedManager;
// 获取所有相册信息
- (void)getAllAlbumWithStart:(void(^)(void))start WithEnd:(void(^)(NSArray *allAlbum,NSArray *photosAy))album WithFailure:(void(^)(NSError *error))failure;

@end

