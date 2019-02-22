//
//  StickerDownloader.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/1/28.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKFramework.h"

NS_ASSUME_NONNULL_BEGIN

/**
 贴纸道具下载器
 */
@interface StickerDownloader : TuSDKOnlineStickerDownloader

/**
 单例对象
 */
+ (instancetype)shared;

/**
 添加下载监听

 @param delegate 监听委托
 */
- (void)addDelegate:(id<TuSDKOnlineStickerDownloaderDelegate>)delegate;

/**
 移除下载监听
 
 @param delegate 监听委托
 */
- (void)removeDelegate:(id<TuSDKOnlineStickerDownloaderDelegate>)delegate;


@end


NS_ASSUME_NONNULL_END
