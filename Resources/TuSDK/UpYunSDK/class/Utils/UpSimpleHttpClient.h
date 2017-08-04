//
//  UpSimpleHttpClient.h
//
//  Created by DING FENG on 12/26/15.
//  Copyright © 2015 DING FENG. All rights reserved.
//

#import <Foundation/Foundation.h>


/* 简单的 http 请求结束回调 block。
 error：请求发生错误，没有正常完成；（如 DNS 解析失败，请求超时，请求取消，网络断开）。
 response：一个 NSHTTPURLResponse 对象，可以查看 http response headers 信息。
 data： http response body。
 */
typedef void (^SimpleHttpTaskCompletionHandler)(NSError *error, id response, NSData *body);

//用于获取数据发送进度
typedef void(^SimpleHttpTaskDataSendProgressHandler)(NSProgress *progress);

//用于获取数据接收进度及数据
typedef void(^SimpleHttpTaskDataReceiveProgressHandler)(NSProgress *progress, NSData *buffer);



@interface UpSimpleHttpClient : NSObject


#pragma mark 简单接口。用于 GET/POST json，xml 等小文件和数据，无需获取进度信息。
//GET   可用于获取 json 等数据接口。
+ (UpSimpleHttpClient *)GET:(NSString *)URLString
          completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler;


//POST  发送 body 的 content-type：application/x-www-form-urlencoded
+ (UpSimpleHttpClient *)POST:(NSString *)URLString
                  parameters:(NSDictionary *)parameters
           completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler;


//POST  发送 body 的 content-type：application/json
+ (UpSimpleHttpClient *)POST2:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
            completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler;



#pragma mark 高级接口。用于发送和接收稍大的文件，关心数据传输进度。

/*
 POST 上传 body 的 content-type：multipart/form-data。
 一般用来发送文件图片等，所以可以用 progressBlock 获取数据发送进度。
 
 parameters: 一般参数键值对
 name： 文件参数－表单名
 fileName： 文件参数－文件名
 mimeType： 文件参数－文件类型
 filePathOrData：文件参数－文件数据或者位置
 */

+ (UpSimpleHttpClient *)POST:(NSString *)URLString
                  parameters:(NSDictionary *)parameters
                    formName:(NSString *)name
                    fileName:(NSString *)fileName
                    mimeType:(NSString *)mimeType
                        file:(id)filePathOrData
           sendProgressBlock:(SimpleHttpTaskDataSendProgressHandler)sendProgressBlock
           completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler;




/*
 PUT 上传 body 的 content-type：application/octet-stream。
 一般用来发送文件图片等，所以可以用 progressBlock 获取数据发送进度。
 
 headers: http 头部参数
 filePathOrData：文件参数－文件数据或者位置
 */

+ (UpSimpleHttpClient *)PUT:(NSString *)URLString
                    headers:(NSDictionary *)headers
                       file:(id)filePathOrData
          sendProgressBlock:(SimpleHttpTaskDataSendProgressHandler)sendProgressBlock
          completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler;


/*
 GET  下载大文件或者图片。
 一般用来下载文件图片等，所以可以用 progressBlock 获取数据接收进度。
 注意：基于普遍性和内存占用考虑，receiveProgressBlock 是下载分片数据的接收处。completionHandler 结束回掉里面的 data 将是 nil。
 所以数据的是在内存里面直接拼接，还是一点一点直接写到一个硬盘文件里，可以自由决定。
 
 */
+ (UpSimpleHttpClient *)GET:(NSString *)URLString
       receiveProgressBlock:(SimpleHttpTaskDataReceiveProgressHandler)receiveProgressBlock
          completionHandler:(SimpleHttpTaskCompletionHandler)completionHandler;


//取消请求任务
- (void)cancel;
@end
