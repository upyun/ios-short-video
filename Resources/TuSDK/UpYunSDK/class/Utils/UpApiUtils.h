//
//  UpApiUtils.h
//  UpYunSDKDemo
//
//  Created by DING FENG on 2/13/17.
//  Copyright © 2017 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpApiUtils : NSObject


//文档：http://docs.upyun.com/api/authorization/

///生成上传策略和上传签名
+ (NSString *)getPolicyWithParameters:(NSDictionary *)parameter;
+ (NSString *)getSignatureWithPassword:(NSString *)password
                            parameters:(NSArray *)parameter;



+ (NSDictionary *)getDictFromPolicyString:(NSString *)policy;



///hash 方法
+ (NSString *)getMD5HashFromData:(NSData *)data;
+ (NSString *)getMD5HashOfFileAtPath:(NSString *)path;
+ (NSString *)base64EncodeFromString:(NSString *)string;
+ (NSString *)base64DecodeFromString:(NSString *)base64String;
+ (NSString *)getHmacSha1HashWithKey:(NSString *)key
                              string:(NSString *)string;

+ (NSString*)mimeTypeOfFileAtPath:(NSString *) path;
+ (NSString*)lengthOfFileAtPath:(NSString *) path;

///  dic to query tring
+ (NSString*)queryStringFrom:(NSDictionary *)parameters;

@end

