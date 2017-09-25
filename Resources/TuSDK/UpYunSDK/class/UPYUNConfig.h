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
#import "UpYunFileDealManger.h"


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
 *	@brief 默认进行表单上传, 超过 20 M 大小后走分块上传
 */
@property (nonatomic, assign) NSInteger DEFAULT_MUTUPLOAD_SIZE;



/**上传接口
 参数  bucketName:           服务名
 参数  operator:             操作员
 参数  password:             操作员密码
 
 服务名、操作员、操作员密码, 可以在 upyun 控制台获取：https://console.upyun.com/dashboard/ 导航栏>云产品>云存储>创建服务
 
 
 参数  fileData:             上传文件数据
 参数  fileName:             上传文件名
 参数  saveKey:              上传文件的保存路径, 例如：“/2015/0901/file1.jpg”。可用占位符，参考：http://docs.upyun.com/api/form_api/#save-key
 参数  otherParameters:      可选的其它参数可以为nil. 表单上传--参考文档：表单-API-参数http://docs.upyun.com/api/form_api/#_2         分块上传 任务信息, 详见 https://docs.upyun.com/cloud/av/#tasks
 
 参数  successBlock:         上传成功回调
 参数  failureBlock:         上传失败回调
 参数  progressBlock:        上传进度回调
 */

- (void)uploadFilePath:(NSString *)filePath saveKey:(NSString *)saveKey success:(UpLoaderSuccessBlock)successBlock failure:(UpLoaderFailureBlock)failureBlock progress:(UpLoaderProgressBlock)progressBlock;


/**截图接口
 参数  task:                 截图任务的相关接口 可参考 https://docs.upyun.com/cloud/sync_video/#m3u8_2
 参数  successBlock:         成功回调
 参数  failureBlock:         失败回调

 
 task: 相对地址前需要加上'/'表示根目录   source 需截图的视频相对地址,   save_as 保存截图的相对地址, point 截图时间点 hh:mm:ss 格式
 
 
 后两个参数可不添加  size 截图尺寸，格式为 宽x高，默认是视频尺寸  format  截图格式，可选值为 jpg，png, webp, 默认根据 savekey 的后缀生成
 */
- (void)fileTask:(NSDictionary *)task success:(UpLoaderSuccessBlock)successBlock failure:(UpLoaderFailureBlock)failureBlock;



@end
