//
//  UpYunUploader.h
//  UpYunSDKDemo
//
//  Created by DING FENG on 2/16/17.
//  Copyright © 2017 upyun. All rights reserved.
//

#define UpYunSDKVersion @"2.0.1"

/*** UpYunStorageServer list  http://docs.upyun.com/api/rest_api/
 智能选路（推荐）：v0.api.upyun.com
 电信线路：v1.api.upyun.com
 联通（网通）线路：v2.api.upyun.com
 移动（铁通）线路：v3.api.upyun.com
 */

#import "UpApiUtils.h"
#define UpYunStorageServer  @"https://v0.api.upyun.com"
#define UpYunFileBlcokSize (1024 * 1024)//分块上传，文件块大小。固定大小，不可改变。

typedef void (^UpLoaderSuccessBlock)(NSHTTPURLResponse *response, NSDictionary *responseBody);
typedef void (^UpLoaderFailureBlock)(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody);
typedef void (^UpLoaderProgressBlock)(int64_t completedBytesCount, int64_t totalBytesCount);


