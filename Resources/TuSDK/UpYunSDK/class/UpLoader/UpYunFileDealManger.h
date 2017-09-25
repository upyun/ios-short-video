//
//  UpYunFileDealManger.h
//  UpYunSDKDemo
//
//  Created by lingang on 2017/8/8.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpYunUploader.h"

@interface UpYunFileDealManger : NSObject



/** 文件处理接口
 参数  bucketName:           上传空间名
 参数  operator:             空间操作员
 参数  password:             空间操作员密码
 参数  notify_url:           回调通知地址, 详见 https://docs.upyun.com/cloud/av/#notify_url
 参数  source:               原始音/视频文件路径
 参数  tasks:                任务信息, 详见 https://docs.upyun.com/cloud/av/#tasks
 参数  accept:               回调信息的格式, 值为json
 参数  successBlock:         处理请求成功回调
 参数  failureBlock:         处理请求失败回调
 */

- (void)dealTaskWithBucketName:(NSString *)bucketName
                      operator:(NSString *)operatorName
                      password:(NSString *)operatorPassword
                    notify_url:(NSString *)notify_url
                        source:(NSString *)source
                         tasks:(NSArray *)tasks
                       success:(UpLoaderSuccessBlock)successBlock
                       failure:(UpLoaderFailureBlock)failureBlock;



/** 同步截图接口
 参数  bucketName:           服务名
 参数  operator:             操作员
 参数  password:             操作员密码
 参数  tasks:                任务信息, 详见 https://docs.upyun.com/cloud/sync_video/#m3u8_2
 参数  successBlock:         处理请求成功回调
 参数  failureBlock:         处理请求失败回调
 */

- (void)dealSyncTaskWithBucketName:(NSString *)bucketName
                      operator:(NSString *)operatorName
                      password:(NSString *)operatorPassword
                         tasks:(NSDictionary *)task
                       success:(UpLoaderSuccessBlock)successBlock
                       failure:(UpLoaderFailureBlock)failureBlock;

- (void)cancel;

@end
