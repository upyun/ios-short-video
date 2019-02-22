//
//  StickerPropsItem.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2018/12/25.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "StickerPropsItem.h"
#import "OnlineStickerGroup.h"
#import "StickerDownloader.h"

@interface StickerPropsItem () <TuSDKOnlineStickerDownloaderDelegate>
{
   LoadHander _handler;
}
@end

@implementation StickerPropsItem


- (void)setItem:(id)item;
{
    [super setItem:item];
    _effect = nil;
}

/**
 返回特效对象
 
 @return TuSDKMediaEffect
 */
- (id<TuSDKMediaEffect>)effect;
{
    if (_effect || !self.item) return _effect;
    
    _effect = [[TuSDKMediaStickerEffect alloc] initWithStickerGroup:self.item];
    return _effect;
}

/**
 加载道具封面

 @param thumbImageView 封面视图
 @param hander 加载完成后处理事件
 */
- (void)loadThumb:(UIImageView *)thumbImageView completed:(void (^)(BOOL))hander
{
    if (!thumbImageView) return;
    
    if ([self.item isKindOfClass:[OnlineStickerGroup class]]) {
        OnlineStickerGroup *onlineSticker = (OnlineStickerGroup *)self.item;
        [thumbImageView lsq_setImageWithURL:[NSURL URLWithString:onlineSticker.previewImage]];
        
        if (hander)
            hander(YES);

    } else {
        TuSDKPFStickerGroup *sticker = (TuSDKPFStickerGroup *)self.item;
        [[TuSDKPFStickerLocalPackage package] loadThumbWithStickerGroup:sticker imageView:thumbImageView];
        if (hander)hander(YES);
    }
}


@end

#pragma mark - Download

@implementation StickerPropsItem (Download)

/**
 当前贴纸道具是否为在线贴纸，如果为 true 需下载后方可使用

 @return true/false
 */
- (BOOL)online;
{
    return [self.item isKindOfClass:[OnlineStickerGroup class]];
}

/**
 当前是否正在下载中

 @return true/falase
 */
- (BOOL)isDownLoading; {
    return ([[StickerDownloader shared] isDownloadingWithGroupId:self.item.idt]);
}

/**
 加载特效
 
 @param handler 加载完成处理器
 */
- (void)loadEffect:(LoadHander)handler;
{
    if (!self.online)
    {
        if (handler)handler(self.effect);
        return;
    }
    

    NSInteger stickerId = self.item.idt;
    if ([self isDownLoading]) return;
    
    [[StickerDownloader shared] addDelegate:self];
    _handler = handler;
    [[StickerDownloader shared] downloadWithGroupId:stickerId];
}

#pragma mark TuSDKOnlineStickerDownloaderDelegate

/**
 贴纸下载结束回调
 
 @param stickerGroupId 贴纸分组 ID
 @param progress 下载进度
 @param status 下载状态
 */
- (void)onDownloadProgressChanged:(uint64_t)stickerGroupId progress:(CGFloat)progress changedStatus:(lsqDownloadTaskStatus)status {
       
    if (self.item.idt != stickerGroupId) return;
    
    if (status == lsqDownloadTaskStatusDowned || status == lsqDownloadTaskStatusDownFailed) {
        typeof(self) weakSelf = self;

        // 加载完成后从本地再次获取贴纸数据
        NSArray<TuSDKPFStickerGroup *> *allLocalStickers = [[TuSDKPFStickerLocalPackage package] getSmartStickerGroups];
        
        // 是否找到本地贴纸
        __block BOOL found = NO;
        [allLocalStickers enumerateObjectsUsingBlock:^(TuSDKPFStickerGroup * _Nonnull stickerGroup, NSUInteger idx, BOOL * _Nonnull stop) {
            if (weakSelf.item.idt == stickerGroup.idt) {
                weakSelf.item = stickerGroup;
                *stop = YES;
                found = YES;
            }
        }];
        
        if(_handler && found)_handler(self.effect);
        _handler = nil;
        
        [[StickerDownloader shared] removeDelegate:self];

    }
    
}


@end
