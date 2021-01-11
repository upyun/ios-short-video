//
//  TuSDKCosmeticStickerManager.h
//  TuSDK
//
//  Created by tusdk on 2020/10/16.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKCosmeticImage.h"
#import "TuSDKCosmeticSticker.h"


NS_ASSUME_NONNULL_BEGIN

@interface TuSDKCosmeticStickerManager : NSObject


@property(atomic,readonly) NSMutableDictionary<NSNumber *,TuSDKCosmeticImage *> *cosmeticStickerDict;


+ (dispatch_queue_t)sharedLoadQueue;

/**
 * 加载美妆贴纸
 * @param type
 */
-(void)runTask:(TuSDKCosmeticSticker *)cosmeticSticker;

@end

NS_ASSUME_NONNULL_END
