//
//  CameraFilterPanelProtocol.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CameraFilterPanelProtocol;

/**
 滤镜面板回调代理
 */
@protocol CameraFilterPanelDelegate <NSObject>
@optional

/**
 滤镜面板切换标签回调

 @param filterPanel 滤镜面板
 @param tabIndex 标签索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSwitchTabIndex:(NSInteger)tabIndex;

/**
 滤镜面板选中回调
 
 @param filterPanel 滤镜面板
 @param code 滤镜码
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedFilterCode:(NSString *)code;

/**
 美妆面板选中回调
 
 @param filterPanel 美妆面板
 @param code 美妆类型码
 @param stickerCode 美妆效果code
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedCosmeticCode:(NSString *)code stickerCode:(nonnull NSString *)stickerCode;

/**
 美妆面板值变更回调
 
 @param filterPanel 美妆面板
 @param percent 美妆参数变更数值
 @param stickerCode 美妆贴纸code
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>_Nullable)filterPanel didChangeValue:(double)percent cosmeticIndex:(NSInteger)cosmeticIndex;

/**
 美妆口红面板选中回调
 
 @param filterPanel 美妆面板
 @param lipStickType 口红类型
 @param stickerName 口红贴纸名称
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedLipStickType:(NSInteger)lipStickType stickerName:(NSString *)stickerName;

/**
 美妆面板重置回调
 
 @param filterPanel 美妆面板
 @param code 美妆类型码
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel closeCosmetic:(NSString *)code;

/**
 滤镜面板值变更回调
 
 @param filterPanel 滤镜面板
 @param percent 滤镜参数变更数值
 @param index 滤镜参数索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didChangeValue:(double)percent paramterIndex:(NSUInteger)index;

/**
 重置滤镜参数回调
 
 @param filterPanel 滤镜面板
 @param paramterKeys 滤镜参数
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel resetParamterKeys:(NSArray *)paramterKeys;

/**
 滚动视图回调
 @param filterPanel 滤镜面板
 @param toIndex 目标标签下标
 @param direction 滚动方向
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel toIndex:(NSInteger)toIndex direction:(NSInteger)direction;

@end


/**
 滤镜面板数据源
 */
@protocol CameraFilterPanelDataSource <NSObject>

/**
 滤镜参数个数

 @return 参数数量
 */
- (NSInteger)numberOfParamter:(id<CameraFilterPanelProtocol>)filterPanel;

/**
 对应索引的参数名称

 @param index 滤镜参数的索引
 @return 滤镜参数的名称
 */
- (NSString *)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel  paramterNameAtIndex:(NSUInteger)index;

/**
 滤镜参数对应索引的参数值

 @param index 滤镜参数的索引
 @return 对应参数的数值
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel  percentValueAtIndex:(NSUInteger)index;
/**
 滤镜参数对应索引的参数值

 @param index 滤镜参数的索引
 @return 对应参数的数值
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel  defaultPercentValueAtIndex:(NSUInteger)index;

/**
 美妆参数对应索引的参数值

 @param index 滤镜参数的索引
 @return 对应参数的数值
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel  cosmeticPercentValueAtIndex:(NSUInteger)index cosmeticIndex:(NSInteger)cosmeticIndex;
/**
 美妆参数对应索引的默认参数值

 @param index 滤镜参数的索引
 @return 对应参数的数值
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel  cosmeticDefaultValueAtIndex:(NSUInteger)index cosmeticIndex:(NSInteger)cosmeticIndex;

@end


/**
 滤镜面板通用接口
 */
@protocol CameraFilterPanelProtocol <NSObject>

@property (nonatomic, weak) id<CameraFilterPanelDelegate> delegate;
@property (nonatomic, weak) id<CameraFilterPanelDataSource> dataSource;

/**
 是否展示
 */
@property (nonatomic, assign, readonly) BOOL display;

/**
 重载参数列表，会触发数据源代理方法
 */
- (void)reloadFilterParamters;

@end
