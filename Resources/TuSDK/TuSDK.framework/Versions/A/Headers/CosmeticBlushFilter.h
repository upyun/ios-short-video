//
//  CosmeticBlushFilter.h
//  TuSDK
//
//  Created by tusdk on 2020/10/12.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKFilterAdapter.h"
#import "TuSDKFilterParameter.h"
#import "TuSDKCosmeticImage.h"

@interface CosmeticBlushFilter : TuSDKTwoInputFilter<TuSDKFilterParameterProtocol,TuSDKFilterFacePositionProtocol>

- (void) updateSticker:(TuSDKCosmeticImage *)stickerImage;

@property(readwrite, nonatomic) float alpha;

@end
