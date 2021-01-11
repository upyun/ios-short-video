//
//  CosmeticEyebrowFilter.h
//  TuSDK
//
//  Created by tusdk on 2020/10/13.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKFilterAdapter.h"
#import "TuSDKFilterParameter.h"
#import "TuSDKCosmeticImage.h"

@interface CosmeticEyebrowFilter : TuSDKTwoInputFilter<TuSDKFilterParameterProtocol,TuSDKFilterFacePositionProtocol>

- (void) updateSticker:(TuSDKCosmeticImage *)stickerImage;

@property(readwrite, nonatomic) float alpha;

@end

