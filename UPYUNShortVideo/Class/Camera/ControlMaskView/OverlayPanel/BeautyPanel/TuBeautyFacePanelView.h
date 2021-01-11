//
//  TuBeautyPanelView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/12/4.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TuBeautyFacePanelView;

@protocol TuBeautyFacePanelViewDelegate <NSObject>
/**重置微整形效果*/
- (void)tuBeautyFacePanelViewResetParamters;
/**点击微整形效果*/
- (void)tuBeautyFacePanelView:(TuBeautyFacePanelView *)view didSelectFaceCode:(NSString *)faceCode;

@end

@interface TuBeautyFacePanelView : UIView

@property (nonatomic, weak) id<TuBeautyFacePanelViewDelegate> delegate;

/**
 选中的微整形配置项
 */
@property (nonatomic, copy) NSString *selectedFaceFeature;

@end

NS_ASSUME_NONNULL_END
