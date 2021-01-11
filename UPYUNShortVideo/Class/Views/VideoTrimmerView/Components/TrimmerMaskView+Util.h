//
//  TrimmerMaskView+Util.h
//  VideoTrimmerExp
//
//  Created by bqlin on 2018/9/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TrimmerMaskView.h"
#import "VideoTrimmerViewProtocol.h"

@interface TrimmerMaskView (Util)

/**
 通过触摸的控件获取其位置

 @param touchControl 触摸的控件
 @return 所在的位置
 */
- (TrimmerTimeLocation)locationWithTouchControl:(UIView *)touchControl;

@end
