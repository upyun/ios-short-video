//
//  TuSDKMediaStickerAudioEffectData+Equal.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/16.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TuSDKMediaStickerAudioEffect+Equal.h"

@implementation TuSDKMediaStickerAudioEffect (Equal)

- (BOOL)isEqualToMvEffect:(TuSDKMediaStickerAudioEffect *)mvEffect {
    return [self mvHash] == [mvEffect mvHash];
}

/**
 计算 TuSDKMediaStickerAudioEffect 对象哈希值

 @return TuSDKMediaStickerAudioEffect 对象哈希值
 */
- (NSUInteger)mvHash {
    NSUInteger stickerHash = self.stickerEffect.stickerGroup.idt ^ self.stickerEffect.stickerGroup.categoryId;
    NSUInteger audioHash = self.audioEffect.audioURL.hash;
    return stickerHash ^ audioHash;
}

@end
