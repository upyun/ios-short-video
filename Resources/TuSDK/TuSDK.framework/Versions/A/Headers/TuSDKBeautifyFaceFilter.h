//
//  TuSDKBeautifyFace.h
//  TuSDK
//
//  Created by tusdk on 2020/11/24.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKFilterAdapter.h"
#import "TuSDKFilterParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuSDKBeautifyFaceFilter : SLGPUImageFilterGroup<TuSDKFilterParameterProtocol>
@property (nonatomic) CGFloat smooth; // 磨皮
@property (nonatomic) CGFloat whiten; // 美白
@property (nonatomic) CGFloat sharpen; // 锐化
@end

NS_ASSUME_NONNULL_END
