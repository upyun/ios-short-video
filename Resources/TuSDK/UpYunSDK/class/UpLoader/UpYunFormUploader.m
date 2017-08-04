//
//  UpYunFormUploader.m
//  UpYunSDKDemo
//
//  Created by DING FENG on 2/13/17.
//  Copyright © 2017 upyun. All rights reserved.
//

#import "UpYunFormUploader.h"
#import "UpSimpleHttpClient.h"


#define  NSErrorDomain_UpYunFormUploader   @"NSErrorDomain_UpYunFormUploader"

@interface UpYunFormUploader()
{
    UpSimpleHttpClient *_httpClient;
    int64_t _totalUnitCountToSend;
}
@end



@implementation UpYunFormUploader



- (void)uploadWithBucketName:(NSString *)bucketName
                    operator:(NSString *)operatorName
                    password:(NSString *)operatorPassword
                    fileData:(NSData *)fileData
                    fileName:(NSString *)fileName
                     saveKey:(NSString *)saveKey
             otherParameters:(NSDictionary *)otherParameters
                     success:(UpLoaderSuccessBlock)successBlock
                     failure:(UpLoaderFailureBlock)failureBlock
                    progress:(UpLoaderProgressBlock)progressBlock {
    
    NSDate *now = [NSDate date];
    NSString *expiration = [NSString stringWithFormat:@"%.0f",[now timeIntervalSince1970] + 1800];//本地自签名30分钟后过期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"EEE, dd MMM y HH:mm:ss zzz"];
    
    NSString *date = [dateFormatter stringFromDate:now];
    NSString *content_md5 = [UpApiUtils getMD5HashFromData:fileData];

    
    NSMutableDictionary *policyDict = [NSMutableDictionary new];
    NSDictionary *policyDict_part1 = @{@"bucket": bucketName,
                                       @"save-key": saveKey,
                                       @"expiration": expiration,
                                       @"date": date,
                                       @"content-md5": content_md5,
                                       @"content-length":[NSString stringWithFormat:@"%ld", fileData.length]};
    
    NSDictionary *policyDict_part2 = [NSDictionary new];
    if (otherParameters) {
        policyDict_part2 = otherParameters;
    }
    
    //所有上传参数都是放到上传策略 policy 中
    [policyDict addEntriesFromDictionary:policyDict_part1];
    [policyDict addEntriesFromDictionary:policyDict_part2];
    

    NSString *policy = [UpApiUtils getPolicyWithParameters:policyDict];
    
    
    NSString *uri = [NSString stringWithFormat:@"/%@", bucketName];
    NSString *signature = [UpApiUtils getSignatureWithPassword:operatorPassword
                                                    parameters:@[@"POST", uri, date, policy, content_md5]];

    [self uploadWithOperator:operatorName
                      policy:policy
                   signature:signature
                    fileData:fileData
                    fileName:fileName
                     success:successBlock
                     failure:failureBlock
                    progress:progressBlock];
}


- (void)uploadWithOperator:(NSString *)operatorName
                    policy:(NSString *)policy
                 signature:(NSString *)signature
                  fileData:(NSData *)fileData
                  fileName:(NSString *)fileName
                   success:(UpLoaderSuccessBlock)successBlock
                   failure:(UpLoaderFailureBlock)failureBlock
                  progress:(UpLoaderProgressBlock)progressBlock {
    
    
    NSString *authorization = [NSString stringWithFormat:@"UPYUN %@:%@", operatorName, signature];
    NSDictionary *parameters = @{@"policy": policy, @"authorization": authorization};
    
    if (fileName.length <= 0) {
        fileName = @"fileName";
    }
    NSDictionary *polcyDictDecoded = [UpApiUtils getDictFromPolicyString:policy];
    
    NSString *bucketName_new = [polcyDictDecoded objectForKey:@"bucket"];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", UpYunStorageServer, bucketName_new];
    _httpClient = [UpSimpleHttpClient POST:urlString
                                parameters:parameters
                                  formName:@"file"
                                  fileName:fileName
                                  mimeType:@""
                                      file:fileData
                         sendProgressBlock:^(NSProgress *progress) {
                             _totalUnitCountToSend = progress.totalUnitCount;
                             progressBlock(progress.completedUnitCount, progress.totalUnitCount);
                         }
                         completionHandler:^(NSError *error,
                                             id response,
                                             NSData *body) {
                             
                             NSHTTPURLResponse *res = response;
                             NSDictionary *retObj  = NULL;// 期待返回的数据结构
                             NSError *error_json; //接口期望的是 json 数据
                             
                             // http 请求错误，网络错误。取消，超时，断开等
                             if (error) {
                                 failureBlock(error, res, retObj);
                                 return ;
                             }
                             
                             if (body) {
                                 //有返回 body ：尝试按照 json 解析。
                                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:&error_json];
                                 retObj = json;
                                 if (error_json) {
                                     NSLog(@"NSErrorDomain_UpYunFormUploader json parse failed %@", error_json);
                                     NSLog(@"NSErrorDomain_UpYunFormUploader res.body content %@", [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
                                 }
                             }

                             // http 请求 res body 格式错误，无法进行 json 序列化
                             if (error_json) {
                                 failureBlock(error_json, res, nil);
                                 return ;
                             }
                             
                             // api 接口错误。参数错误，权限错误
                             if (res.statusCode >= 400) {
                                 if (!error) {
                                     error  = [[NSError alloc] initWithDomain:NSErrorDomain_UpYunFormUploader
                                                                         code:res.statusCode
                                                                     userInfo:NULL];
                                 }
                                 
                                 failureBlock(error, res, retObj);
                                 return ;
                             }
                             
                             // 上传成功
                             progressBlock(_totalUnitCountToSend, _totalUnitCountToSend);//使发送进度为 100%
                             successBlock(res, retObj);
                         }];
}

- (void)cancel {
    [_httpClient cancel];
}

- (void)dealloc {
}

@end
