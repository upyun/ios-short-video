//
//  TuCosmeticListView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/10/20.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraFilterPanelProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class TuCosmeticPanelView;
@protocol TuCosmeticPanelViewDelegate <NSObject>

@optional
//美妆code点击回调
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view didSelectedCosmeticCode:(NSString *)code stickerCode:(NSString *)stickerCode;
//口红code点击回调
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view didSelectedLipStickType:(NSInteger)lipStickType stickerName:(NSString *)stickerName;
//关闭美妆效果
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view closeCosmetic:(NSString *)code;

//关闭透明度栏
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view closeSliderBar:(BOOL)close;

@end

@interface TuCosmeticPanelView : UIView

@property (nonatomic, weak) id<TuCosmeticPanelViewDelegate> delegate;

@property (nonatomic, assign) BOOL resetCosmetic;

@end

NS_ASSUME_NONNULL_END
