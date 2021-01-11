//
//  TuSDKBoxBlurAlphaFilter.h
//  TuSDK
//
//  Created by tusdk on 2020/11/24.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "TuSDKFilterAdapter.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,BoxBlurAlphaOrientation)
{
    BoxBlurAlphaOrientationHorizontal = 0,
    BoxBlurAlphaOrientationVertical
};

@interface TuSDKBoxBlurAlphaFilter : TuSDKFilter

-(id)initWithOrientaion:(BoxBlurAlphaOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
