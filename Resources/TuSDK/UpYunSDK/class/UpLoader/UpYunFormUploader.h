//
//  UpYunFormUploader.h
//  UpYunSDKDemo
//
//  Created by DING FENG on 2/13/17.
//  Copyright © 2017 upyun. All rights reserved.
//



/*实现的存储接口及文档
 表单API。文档地址：http://docs.upyun.com/api/form_api/
 认证鉴权－在 Body 中包含签名。 文档地址：http://docs.upyun.com/api/authorization/#body
 */

#import <Foundation/Foundation.h>
#import "UpYunUploader.h"

@interface UpYunFormUploader : NSObject


/**表单上传接口
 参数  bucketName:           服务名
 参数  operator:             操作员
 参数  password:             操作员密码
 
 服务名、操作员、操作员密码, 可以在 upyun 控制台获取：https://console.upyun.com/dashboard/ 导航栏>云产品>云存储>创建服务


 参数  fileData:             上传文件数据
 参数  fileName:             上传文件名
 参数  saveKey:              上传文件的保存路径, 例如：“/2015/0901/file1.jpg”。可用占位符，参考：http://docs.upyun.com/api/form_api/#save-key
 参数  otherParameters:      可选的其它参数可以为nil. 参考文档：表单-API-参数http://docs.upyun.com/api/form_api/#_2
 参数  successBlock:         上传成功回调
 参数  failureBlock:         上传失败回调
 参数  progressBlock:        上传进度回调
 */

- (void)uploadWithBucketName:(NSString *)bucketName
                    operator:(NSString *)operatorName
                    password:(NSString *)operatorPassword
                    fileData:(NSData *)fileData
                    fileName:(NSString *)fileName
                     saveKey:(NSString *)saveKey
             otherParameters:(NSDictionary *)otherParameters
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock;



/**表单上传接口，上传策略和签名可以是从服务器获取
 参数  operator:        操作员
 参数  policy:          上传策略
 参数  signature:       上传策略签名
 参数  fileData:        上传的数据
 参数  fileName:        上传文件名
 参数  success:         上传成功回调
 参数  failure:         上传失败回调
 参数  progress:        上传进度回调
 */
- (void)uploadWithOperator:(NSString *)operatorName
                    policy:(NSString *)policy
                 signature:(NSString *)signature
                  fileData:(NSData *)fileData
                  fileName:(NSString *)fileName
                   success:(UpLoaderSuccessBlock)successBlock
                   failure:(UpLoaderFailureBlock)failureBlock
                  progress:(UpLoaderProgressBlock)progressBlock;

//取消上传
- (void)cancel;

@end
