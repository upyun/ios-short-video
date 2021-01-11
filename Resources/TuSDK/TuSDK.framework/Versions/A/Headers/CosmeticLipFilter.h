//
//  CosmeticLipFilter.h
//  TuSDK
//
//  Created by tusdk on 2020/10/13.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKFilterAdapter.h"
#import "TuSDKFilterParameter.h"

typedef NS_ENUM(NSInteger ,CosmeticLipType){
    COSMETIC_WUMIAN_TYPE,   // 雾面
    COSMETIC_ZIRUN_TYPE,    // 滋润
    COSMETIC_SHUIRUN_TYPE   // 水润
};

@interface CosmeticLipFilter : TuSDKTwoInputFilter<TuSDKFilterParameterProtocol,TuSDKFilterFacePositionProtocol>

@property(readwrite, nonatomic) float alpha;            // 透明度
@property(readwrite, nonatomic) CosmeticLipType type;   // 唇彩类型

// 唇彩颜色
- (void)setColorRGB:(int)colorRGB;

@end


