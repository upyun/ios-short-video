//
//  TuSDKMediaEffectData.h
//  TuSDKVideo
//
//  Created by wen on 06/07/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKTimeRange.h"
#import "TuSDKVideoImport.h"
#import "TuSDKMediaEffectData.h"

// 特效类型
typedef NS_ENUM(NSUInteger,TuSDKMediaEffectDataType) {
    TuSDKMediaEffectDataTypeFilter = 0,
    TuSDKMediaEffectDataTypeAudio ,
    TuSDKMediaEffectDataTypeSticker,
    TuSDKMediaEffectDataTypeStickerAudio,
    TuSDKMediaEffectDataTypeScene,
    TuSDKMediaEffectDataTypeParticle,
    TuSDKMediaEffectDataTypeStickerText
};

/**
 特效数据模型继承类
 */
@interface TuSDKMediaEffectData : NSObject <NSCopying>
{
    @protected
    /** 特效类型 */
    TuSDKMediaEffectDataType _effectType;
    /** 特效wrap 可能为空 */
    TuSDKFilterWrap *_filterWrap;
}

/**
 * 时间范围
 */
@property (nonatomic,strong) TuSDKTimeRange *atTimeRange;

/**
 特效类型
 */
@property (nonatomic,readonly) TuSDKMediaEffectDataType effectType;

/**
 特效 TuSDKFilterWrap
 */
@property (nonatomic,readonly) TuSDKFilterWrap *filterWrap;

/**
 特效设置是否有效
 */
@property (nonatomic, assign, readonly) BOOL isValid;

/**
 * 标记当前特效是否正在应用中
 * 开发者不应修改该标识
 */
@property (nonatomic) BOOL isApplyed;

/**
 当前特效是否正在编辑中
 */
@property (nonatomic) BOOL isEditing;

/**
 初始化方法
 */
- (instancetype)initWithTimeRange:(TuSDKTimeRange *)timeRange effectType:(TuSDKMediaEffectDataType)type;

/**
 销毁特效数据
 */
- (void)destory;

@end
