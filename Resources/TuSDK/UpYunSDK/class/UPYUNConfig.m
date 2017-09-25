//
//  UPYUNConfig.m
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/2.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import "UPYUNConfig.h"

@implementation UPYUNConfig
+ (UPYUNConfig *)sharedInstance
{
    static dispatch_once_t once;
    static UPYUNConfig *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[UPYUNConfig alloc] init];
        sharedInstance.DEFAULT_BUCKET = @"";
        sharedInstance.OPERATOR_PWD = @"";
        sharedInstance.OPERATOR_NAME = @"";
        sharedInstance.DEFAULT_MUTUPLOAD_SIZE = 20*1024*1024;

    });
    return sharedInstance;
}

- (void)uploadFilePath:(NSString *)filePath saveKey:(NSString *)saveKey success:(UpLoaderSuccessBlock)successBlock failure:(UpLoaderFailureBlock)failureBlock progress:(UpLoaderProgressBlock)progressBlock {
    
    
    
    if (_DEFAULT_BUCKET.length == 0
        || _OPERATOR_NAME.length == 0
        || _OPERATOR_PWD.length == 0) {
        
        
        NSError *error = [NSError errorWithDomain:@"UPYUN ShortVideo" code:-101 userInfo:@{@"message":@"空间名, 操作员, 操作员密码 未配置完整"}];
        
        if (failureBlock) {
            failureBlock(error, nil, nil);
        }
        return;
    }
    
    NSString *fileLength =  [UpApiUtils lengthOfFileAtPath:filePath];

    if (fileLength.longLongValue > _DEFAULT_MUTUPLOAD_SIZE) {
        /// 断点续传
        UpYunBlockUpLoader *up = [[UpYunBlockUpLoader alloc] init];
        [up uploadWithBucketName:_DEFAULT_BUCKET operator:_OPERATOR_NAME password:_OPERATOR_PWD filePath:filePath savePath:saveKey   success:successBlock failure:failureBlock progress:progressBlock];
    } else {
        // 表单上传
        NSData *fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
        UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
        [up uploadWithBucketName:_DEFAULT_BUCKET operator:_OPERATOR_NAME password:_OPERATOR_PWD fileData:fileData fileName:nil saveKey:saveKey otherParameters:nil success:successBlock failure:failureBlock progress:progressBlock];
    }
}

- (void)fileTask:(NSDictionary *)task success:(UpLoaderSuccessBlock)successBlock failure:(UpLoaderFailureBlock)failureBlock {
    
    UpYunFileDealManger *upDeal = [[UpYunFileDealManger alloc] init];
    
    [upDeal dealSyncTaskWithBucketName:[UPYUNConfig sharedInstance].DEFAULT_BUCKET operator:[UPYUNConfig sharedInstance].OPERATOR_NAME password:[UPYUNConfig sharedInstance].OPERATOR_PWD tasks:task success:successBlock failure:failureBlock];
}


@end
