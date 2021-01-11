//
//  TuBeautySkinPanelView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/12/9.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

NS_ASSUME_NONNULL_BEGIN

@class TuBeautySkinPanelView;

@protocol TuBeautySkinPanelViewDelegate <NSObject>

/**重置美肤效果*/
- (void)tuBeautySkinPanelViewResetParamters;

/**点击美肤效果*/
- (void)tuBeautySkinPanelView:(TuBeautySkinPanelView *)view didSelectSkinIndex:(NSInteger)skinIndex;

@end

@interface TuBeautySkinPanelView : UIView

@property (nonatomic, weak) id<TuBeautySkinPanelViewDelegate> delegate;

/*美肤类型*/
@property (nonatomic, readonly) TuSkinFaceType faceType;

/**
 当前选择的美颜参数 （润滑，磨皮，红润）
 */
@property (nonatomic,readonly) NSString* selectedSkinKey;

@end

NS_ASSUME_NONNULL_END
