//
//  TuSDKVideoFocusTouchView.h
//  TuSDKVideo
//
//  Created by Yanlin on 4/18/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKVideoImport.h"
#import "TuSDKFilterConfigProtocol.h"
#import "TuSDKVideoSourceProtocol.h"


#pragma mark  - TuSDKVideoFocusTouchView
/**
 *  相机聚焦触摸视图
 */
@interface TuSDKVideoFocusTouchView : TuSDKCPFocusTouchViewBase <TuSDKVideoCameraExtendViewInterface>
{
    @protected
    // 聚焦视图 (如果不设定，将使用 TuSDKICFocusRangeView)
    UIView<TuSDKICFocusRangeViewProtocol> *_rangeView;
}


@property (nonatomic, readonly) UIView<TuSDKICFocusRangeViewProtocol> *rangeView; // 聚焦视图 (如果不设定，将使用 TuSDKICFocusRangeView)
@property (nonatomic, weak) id<TuSDKCPFocusTouchViewDelegate> focusViewDelegate; // 聚焦中心点击回调
@property (nonatomic) NSInteger topSpace; // 顶部边距
@property (nonatomic) BOOL disableTapFocus; // 是否禁止触摸聚焦 (默认: YES)


- (void) updateFaceFeatures:(NSArray<TuSDKFaceAligment *> *)aligments;

@end

