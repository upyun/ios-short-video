//
//  StickerDownloader.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/1/28.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "StickerDownloader.h"

@interface StickerDownloader () <TuSDKOnlineStickerDownloaderDelegate> {
    
    /** 委托事件 */
    NSMutableArray<id<TuSDKOnlineStickerDownloaderDelegate>> *_delegateArray;
    
}
@end

@implementation StickerDownloader

- (instancetype)init; {
    if (self = [super init]) {
        
        [super setDelegate:self];
        _delegateArray = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

/**
 下载器
 
 @return 贴纸下载器
 */
+ (instancetype)shared {
    
    static StickerDownloader *_stickerDownloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_stickerDownloader == nil) {
            _stickerDownloader = [[StickerDownloader alloc] init];
        }
    });
    
    return _stickerDownloader;
}

/**
 设置委托事件
 
 @param delegate 委托事件
 */
- (void)setDelegate:(id<TuSDKOnlineStickerDownloaderDelegate>)delegate; {
    [_delegateArray removeAllObjects];
    [self addDelegate:delegate];
}

/**
 添加新的委托事件

 @param delegate 委托事件
 */
- (void)addDelegate:(id<TuSDKOnlineStickerDownloaderDelegate>)delegate; {
    if (!delegate) return;
    [_delegateArray addObject:delegate];
}

/**
 移除下载监听
 
 @param delegate 监听委托
 */
- (void)removeDelegate:(id<TuSDKOnlineStickerDownloaderDelegate>)delegate; {
    if (!delegate) return;
    [_delegateArray removeObject:delegate];
}


- (void)dealloc; {
    [super setDelegate:nil];
    [_delegateArray removeAllObjects];
}

#pragma mark TuSDKOnlineStickerDownloaderDelegate

/**
 贴纸下载结束回调
 
 @param stickerGroupId 贴纸分组 ID
 @param progress 下载进度
 @param status 下载状态
 */
- (void)onDownloadProgressChanged:(uint64_t)stickerGroupId progress:(CGFloat)progress changedStatus:(lsqDownloadTaskStatus)status {
    
    [_delegateArray enumerateObjectsUsingBlock:^(id<TuSDKOnlineStickerDownloaderDelegate>  _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate onDownloadProgressChanged:stickerGroupId progress:progress changedStatus:status];
    }];
}

@end
