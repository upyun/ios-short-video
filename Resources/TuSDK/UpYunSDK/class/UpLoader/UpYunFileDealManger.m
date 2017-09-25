//
//  UpYunFileDealManger.m
//  UpYunSDKDemo
//
//  Created by lingang on 2017/8/8.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import "UpYunFileDealManger.h"

#import "UpSimpleHttpClient.h"


#define UpYunFileURI  @"/pretreatment/"

#define  NSErrorDomain_UpYunFileDeal   @"NSErrorDomain_UpYunFileDeal"


@interface UpYunFileDealManger () {
    UpSimpleHttpClient *_httpClient;    
}

@end


@implementation UpYunFileDealManger


- (void)dealTaskWithBucketName:(NSString *)bucketName
                      operator:(NSString *)operatorName
                      password:(NSString *)operatorPassword
                    notify_url:(NSString *)notify_url
                        source:(NSString *)source
                         tasks:(NSArray *)tasks
                       success:(UpLoaderSuccessBlock)successBlock
                       failure:(UpLoaderFailureBlock)failureBlock {
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"EEE, dd MMM y HH:mm:ss zzz"];
    
    NSString *date = [dateFormatter stringFromDate:now];

    
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tasks options:NSJSONWritingPrettyPrinted error:&jsonError];
    
    if (jsonError) {
        NSLog(@"请检查 task 格式");
        if (failureBlock) {
            failureBlock(jsonError, nil, nil);
        }
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    /// base64 转码
    NSString *tasksString = [UpApiUtils base64EncodeFromString:jsonString];
    NSDictionary *parameters = @{@"accept":@"json", @"service":bucketName, @"notify_url":notify_url, @"source":source, @"tasks":tasksString};


    
    NSString *bodyString = [UpApiUtils queryStringFrom:parameters];
    NSData *postData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *content_md5 = [UpApiUtils getMD5HashFromData:postData];
    
    /// 处理任务的 URI 是写死的
    NSString *uri = UpYunFileURI;
    NSString *signature = [UpApiUtils getSignatureWithPassword:operatorPassword
                                                    parameters:@[@"POST", uri, date, content_md5]];
    
   
    NSString *authorization = [NSString stringWithFormat:@"UPYUN %@:%@", operatorName, signature];
    

    NSDictionary *headers = @{@"Authorization": authorization,
                              @"Date": date,
                              @"Content-MD5": content_md5};
    _httpClient = [UpSimpleHttpClient POSTURL:UpYunFileDealServer headers:headers parameters:parameters completionHandler:^(NSError *error, id response, NSData *body) {
            
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
                    error  = [[NSError alloc] initWithDomain:NSErrorDomain_UpYunFileDeal
                                                        code:res.statusCode
                                                    userInfo:NULL];
                }
                
                failureBlock(error, res, retObj);
                return ;
            }
            successBlock(res, retObj);
        } ];

}


- (void)dealSyncTaskWithBucketName:(NSString *)bucketName
                          operator:(NSString *)operatorName
                          password:(NSString *)operatorPassword
                             tasks:(NSDictionary *)task
                           success:(UpLoaderSuccessBlock)successBlock
                           failure:(UpLoaderFailureBlock)failureBlock {
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"EEE, dd MMM y HH:mm:ss zzz"];
    
    NSString *date = [dateFormatter stringFromDate:now];
    
    
    NSError *jsonError = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:task options:NSJSONWritingPrettyPrinted error:&jsonError];
    
    if (jsonError) {
        NSLog(@"请检查 task 格式");
        if (failureBlock) {
            failureBlock(jsonError, nil, nil);
        }
        return;
    }
    
    /// 处理任务的 URI 是写死的
//    NSString *uri = UpYunFileURI;
    NSString *uri = [NSString stringWithFormat:@"/%@/snapshot/", bucketName];
    NSString *url = [NSString stringWithFormat:@"%@%@/snapshot/", UpYunFileSyncDealServer, bucketName];
    NSString *signature = [UpApiUtils getSignatureWithPassword:operatorPassword
                                                    parameters:@[@"POST", uri, date]];
    
    
    NSString *authorization = [NSString stringWithFormat:@"UPYUN %@:%@", operatorName, signature];
    
    
    NSDictionary *headers = @{@"Authorization": authorization,
                              @"Date": date,
                              @"Content-Type": @"application/json"};
    _httpClient = [UpSimpleHttpClient POST2:url headers:headers parameters:task completionHandler:^(NSError *error, id response, NSData *body) {
        
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
                NSLog(@"NSErrorDomain_UpYunFormUploader snapshot json parse failed %@", error_json);
                NSLog(@"NSErrorDomain_UpYunFormUploader snapshot res.body content %@", [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
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
                error  = [[NSError alloc] initWithDomain:NSErrorDomain_UpYunFileDeal
                                                    code:res.statusCode
                                                userInfo:NULL];
            }
            
            failureBlock(error, res, retObj);
            return ;
        }
        successBlock(res, retObj);
    } ];
    
}



- (void)cancel {
    
    
}

@end
