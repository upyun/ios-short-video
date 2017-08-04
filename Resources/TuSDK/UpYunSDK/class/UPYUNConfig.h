//
//  UPYUNConfig.h
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/2.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UpYunUploader.h"
#import "UpYunFormUploader.h"
#import "UpYunBlockUpLoader.h"


@interface UPYUNConfig : NSObject
+ (UPYUNConfig *)sharedInstance;
/**
 *	@brief 默认空间名(必填项), 默认为 *****
 */
@property (nonatomic, copy) NSString *DEFAULT_BUCKET;
/**
 *	@brief	操作员
 */
@property (nonatomic, copy) NSString *OPERATOR_NAME;
/**
 *	@brief	操作员密码
 */
@property (nonatomic, copy) NSString *OPERATOR_PWD;
/**
 *	@brief 上传文件的命名规则前缀, 没有的话. 将使用默认命名方式
 */
@property (nonatomic, copy) NSString *SAVE_KEY_HEADER;
/**
 *	@brief 默认超过 20 M 大小后走分块上传
 */
@property (nonatomic, assign) NSInteger DEFAULT_MUTUPLOAD_SIZE;


- (void)uploadFilePath:(NSString *)filePath saveKey:(NSString *)saveKey success:(UpLoaderSuccessBlock)successBlock failure:(UpLoaderFailureBlock)failureBlock progress:(UpLoaderProgressBlock)progressBlock;


@end
