//
//  APIImageVideoComposer.h
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/5/29.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "TuSDKFramework.h"

NS_ASSUME_NONNULL_BEGIN


/**
 资源合成
 @since v3.4.1
 */
@interface APIImageVideoComposer : NSObject

/**
 输入的合成项列表
 @since v3.4.1
 */
@property (nonatomic)NSArray<PHAsset *> *inputPHAssets;

/**
 完成回调
 @since v3.4.1
 */
@property (nonatomic, copy) void (^composerCompleted)(__kindof AVURLAsset *result);


/**
 图片合成时，每张图片的时长，默认2s
 @since v3.4.1
 */
@property (nonatomic, assign) NSTimeInterval singleImageDuration;

/**
 开始合成
 @since v3.4.1
 */
- (void)startCompose;


/**
 取消合成
 @since v3.4.1
 */
- (void)cancelCompose;

@end

NS_ASSUME_NONNULL_END
