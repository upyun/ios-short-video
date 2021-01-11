//
//  CosmeticEyepartFilter.h
//  TuSDK
//
//  Created by tusdk on 2020/10/13.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKFilterAdapter.h"
#import "TuSDKFilterParameter.h"
#import "TuSDKCosmeticImage.h"

typedef NS_ENUM(NSInteger,CosmeticEyePartType) {
    COSMETIC_EYESHADOW_TYPE,    // 眼影
    COSMETIC_EYELINE_TYPE,      // 眼线
    COSMETIC_EYELASH_TYPE       // 睫毛
};

@interface CosmeticEyepartFilter : TuSDKTwoInputFilter<TuSDKFilterParameterProtocol,TuSDKFilterFacePositionProtocol>

-(void) updateStickers:(CosmeticEyePartType) type stickerImage:(TuSDKCosmeticImage*)stickerImage;

-(void) close:(CosmeticEyePartType)type;

-(BOOL) enable;

@end

