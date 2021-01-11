//
//  TuSDKCosmeticImage.h
//  TuSDK
//
//  Created by tusdk on 2020/10/23.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKPFSticker.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuSDKCosmeticImage : NSObject

@property (nonatomic, readonly) GLuint textureId;
@property (nonatomic, readonly) GLubyte *imageData;
@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, readonly) GLenum imageFormat;

+ (instancetype)initWithImage:(UIImage *)image;

-(void) updateStickerSync:(TuSDKPFSticker *)sticker;

-(void) updateStickerSyncImage:(UIImage *)image;

-(void) reset;

@end

NS_ASSUME_NONNULL_END
