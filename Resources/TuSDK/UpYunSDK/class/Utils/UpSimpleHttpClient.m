//
//  UpSimpleHttpClient.m
//
//  Created by DING FENG on 12/26/15.
//  Copyright © 2015 DING FENG. All rights reserved.
//

#import "UpSimpleHttpClient.h"

@interface UpSimpleHttpClient () <NSURLSessionDelegate>

@property (nonatomic, strong) SimpleHttpTaskCompletionHandler completionHandler;
@property (nonatomic, strong) SimpleHttpTaskDataSendProgressHandler dataSendProgressHandler;
@property (nonatomic, strong) SimpleHttpTaskDataReceiveProgressHandler dataReceiveProgressHandler;

@property (nonatomic, strong) NSURLSessionTask *nSURLSessionTask;
@property (nonatomic, strong) NSMutableData *didReceiveBody;
@property (nonatomic, strong) NSURLResponse *didReceiveResponse;

@property (nonatomic, assign) NSInteger res_content_length;//respone 头里面的 content-length
@property (nonatomic, assign) NSInteger res_content_length_did_receive;//用于记录接收数据进度

@end

@implementation UpSimpleHttpClient

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (UpSimpleHttpClient *)GET:(NSString *)URLString
        completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler {
    UpSimpleHttpClient *sHttpClient = [[UpSimpleHttpClient alloc] init];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    sessionConfiguration.HTTPShouldSetCookies = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:sHttpClient delegateQueue:nil];
    NSURL *url = [[NSURL alloc] initWithString:URLString];
    NSMutableURLRequest *request = (NSMutableURLRequest *)[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request];
    sHttpClient.nSURLSessionTask = sessionTask;
    sHttpClient.completionHandler = completionHandler;
    [sessionTask resume];
    return sHttpClient;
}

+ (UpSimpleHttpClient *)POST:(NSString *)URLString
                parameters:(NSDictionary *)parameters
         completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler {
    UpSimpleHttpClient *sHttpClient = [[UpSimpleHttpClient alloc] init];
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    sessionConfiguration.HTTPShouldSetCookies = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:sHttpClient delegateQueue:nil];
    NSURL *url = [[NSURL alloc] initWithString:URLString];
    NSMutableURLRequest *request = (NSMutableURLRequest *)[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSMutableString *postParameters = [[NSMutableString alloc] init];
    for (NSString *key in parameters.allKeys) {
        NSString *keyValue = [NSString stringWithFormat:@"&%@=%@",key, [parameters objectForKey:key]];
        [postParameters appendString:keyValue];
    }
    NSData *postData = [NSData data];
    if (postParameters.length > 1) {
        postData = [[postParameters substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
    }
    request.HTTPBody = postData;
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request];
    sHttpClient.nSURLSessionTask = sessionTask;
    sHttpClient.completionHandler = completionHandler;
    [sessionTask resume];
    
    
    return sHttpClient;
}


//POST  application/json
+ (UpSimpleHttpClient *)POST2:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
          completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler {
    
    UpSimpleHttpClient *sHttpClient = [[UpSimpleHttpClient alloc] init];
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    sessionConfiguration.HTTPShouldSetCookies = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:sHttpClient delegateQueue:nil];
    NSURL *url = [[NSURL alloc] initWithString:URLString];
    NSMutableURLRequest *request = (NSMutableURLRequest *)[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *info = @{};
    if (parameters) {
        info = parameters;
    }
    
    NSData *postData = [NSData data];
    if ([NSJSONSerialization isValidJSONObject:info]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"error  %@", error);
        }
        
        if (jsonData) {
            postData = jsonData;
        }
    }
    
    request.HTTPBody = postData;
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request];
    sHttpClient.nSURLSessionTask = sessionTask;
    sHttpClient.completionHandler = completionHandler;
    [sessionTask resume];
    return sHttpClient;
}

+ (UpSimpleHttpClient *)POST:(NSString *)URLString
                parameters:(NSDictionary *)parameters
                  formName:(NSString *)name
                  fileName:(NSString *)fileName
                  mimeType:(NSString *)mimeType
                      file:(id)filePathOrData
         sendProgressBlock:(SimpleHttpTaskDataSendProgressHandler)sendProgressBlock
         completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler {
    UpSimpleHttpClient *sHttpClient = [[UpSimpleHttpClient alloc] init];
    
    NSData *data;
    if ([filePathOrData isKindOfClass:[NSString class]]) {
        data = [[NSFileManager defaultManager] contentsAtPath:filePathOrData];
    } else if ([filePathOrData isKindOfClass:[NSData class]]) {
        data = filePathOrData;
    }
    
    NSString *boundary = @"simpleHttpClientFormBoundaryFriSep25V01|hash3ad538ea94b02b486cc9e4ab6c499f69";
    boundary = [NSString stringWithFormat:@"%@%u", boundary,  arc4random() & 0x7FFFFFFF];
    NSMutableData *body = [NSMutableData data];
    for (NSString *key in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:key]]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSURL *url = [NSURL URLWithString:URLString];
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",name, fileName]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //设置URLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    //设置Session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    sessionConfiguration.HTTPShouldSetCookies = YES;

    //iOS8.3 bug http://stackoverflow.com/questions/29528293/nsmutableurlrequest-body-malformed-after-ios-8-3-update
    
    //    sessionConfiguration.HTTPAdditionalHeaders = @{@"Accept"        : @"application/json",
    //                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]};
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:sHttpClient
                                                     delegateQueue:nil];
    //发起请求
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request];
    sHttpClient.nSURLSessionTask = sessionTask;
    sHttpClient.dataSendProgressHandler = sendProgressBlock;
    sHttpClient.completionHandler = completionHandler;
    [sessionTask resume];
    
    return sHttpClient;
}

+ (UpSimpleHttpClient *)PUT:(NSString *)URLString
                    headers:(NSDictionary *)headers
                       file:(id)filePathOrData
          sendProgressBlock:(SimpleHttpTaskDataSendProgressHandler)sendProgressBlock
          completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler {
    
    NSData *data = [[NSData alloc] init];
    if ([filePathOrData isKindOfClass:[NSString class]]) {
        data = [[NSFileManager defaultManager] contentsAtPath:filePathOrData];
    } else if ([filePathOrData isKindOfClass:[NSData class]]) {
        data = filePathOrData;
    }

    UpSimpleHttpClient *sHttpClient = [[UpSimpleHttpClient alloc] init];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    sessionConfiguration.HTTPShouldSetCookies = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:sHttpClient delegateQueue:nil];
    NSURL *url = [[NSURL alloc] initWithString:URLString];
    NSMutableURLRequest *request = (NSMutableURLRequest *)[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = data;
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    for (NSString *key in headers.allKeys) {
        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request];
    sHttpClient.nSURLSessionTask = sessionTask;
    sHttpClient.completionHandler = completionHandler;
    sHttpClient.dataSendProgressHandler = sendProgressBlock;
    [sessionTask resume];
    return sHttpClient;
}


+ (UpSimpleHttpClient *)GET:(NSString *)URLString
     receiveProgressBlock:(SimpleHttpTaskDataReceiveProgressHandler)receiveProgressBlock
        completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler {
    
    
    UpSimpleHttpClient *sHttpClient = [[UpSimpleHttpClient alloc] init];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    sessionConfiguration.HTTPShouldSetCookies = YES;
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:sHttpClient
                                                     delegateQueue:nil];
    
    NSURL *url = [[NSURL alloc] initWithString:URLString];
    NSMutableURLRequest *request = (NSMutableURLRequest *)[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    //发起请求
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request];
    sHttpClient.nSURLSessionTask = sessionTask;
    sHttpClient.dataReceiveProgressHandler = receiveProgressBlock;
    sHttpClient.completionHandler = completionHandler;
    [sessionTask resume];
    
    return sHttpClient;
}


- (void)cancel {
    [_nSURLSessionTask cancel];
}

- (void)dealloc {
//    NSLog(@"dealloc %@", self);
}

- (void)complete {
    self.dataSendProgressHandler = nil;
    self.dataReceiveProgressHandler = nil;

    self.completionHandler = nil;
    self.nSURLSessionTask = nil;
    self.didReceiveBody = nil;
    self.didReceiveResponse = nil;
    
}

#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (self.dataSendProgressHandler) {
        NSProgress *progress = [[NSProgress alloc] init];
        progress.totalUnitCount = totalBytesExpectedToSend;
        progress.completedUnitCount = totalBytesSent;
        self.dataSendProgressHandler(progress);
    }
}

- (void)URLSession:(NSURLSession *)session
             task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (self.completionHandler) {
        self.completionHandler(error, _didReceiveResponse, _didReceiveBody);
    }
    

    [self complete];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);

    _didReceiveResponse = response;
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[res allHeaderFields]
                                                              forURL:[res URL]];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies
                                                       forURL:[res URL]
                                              mainDocumentURL:nil];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    //较大文件下载
    if (self.dataReceiveProgressHandler) {
        //有 dataReceiveProgressHandler，应该是下载的较大文件，用这个接口将每片数据回调出去，自主拼接完成整个文件。
        //content-length
        if (self.res_content_length == 0) {
            NSHTTPURLResponse  *res = (NSHTTPURLResponse *)self.didReceiveResponse;
            if ([res.allHeaderFields.allKeys containsObject:@"Content-Length"]) {
                self.res_content_length = [[res.allHeaderFields objectForKey:@"Content-Length"] integerValue];
            }

        }
        //res_content_length_did_receive
        self.res_content_length_did_receive = self.res_content_length_did_receive + data.length;
        NSProgress *progress = [[NSProgress alloc] init];
        
        progress.totalUnitCount = self.res_content_length;
        progress.completedUnitCount = self.res_content_length_did_receive;
        self.dataReceiveProgressHandler(progress, data);
        return;
    }
    
    //小文件，直接收集拼接 Body 数据
    if (_didReceiveBody) {
        [_didReceiveBody appendBytes:data.bytes length:data.length];
    } else {
        _didReceiveBody = [[NSMutableData alloc] init];
        [_didReceiveBody appendBytes:data.bytes length:data.length];
    }
}

@end
