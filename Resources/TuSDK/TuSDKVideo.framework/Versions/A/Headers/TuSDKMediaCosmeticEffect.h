//
//  TuSDKMediaCosmeticEffect.h
//  TuSDKVideo
//
//  Created by tusdk on 2020/10/14.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuSDKMediaEffectCore.h"
//#import "TuSDKPFSticker.h"
//#import "TuSDKCosmeticSticker.h"
//#import "CosmeticTaskQueue.h"

@interface TuSDKMediaCosmeticEffect : TuSDKMediaEffectCore

//<TuSDKCosmeticSticker *>
@property(atomic,readwrite) CosmeticTaskQueue *cosmeticStickerQueue;


/**
 根据触发时间区间初始化美妆特效
 
 @param timeRange 触发时间区间
 @return 美妆特效实例对象
 @since v3.2.0
 */
- (instancetype)initWithTimeRange:(TuSDKTimeRange * _Nullable)timeRange;

/**
 * 更新唇彩类型，颜色
 * @param type 类型
 * @param colorRGB 颜色
 */
-(void)updateLip:(CosmeticLipType) type colorRGB:(int)colorRGB;

/**
 * 关闭唇彩效果
 */
-(void)closeLip;

/**
 * 更新腮红贴纸
 * @param sticker
 * @param alpha
 */
-(void)updateBlush:(TuSDKPFSticker *)sticker;

/**
 * 关闭腮红效果
 */
-(void)closeBlush;

/**
 * 更新眉毛贴纸
 * @param sticker
 * @param alpha
 */
-(void)updateEyebrow:(TuSDKPFSticker *)sticker;
/**
 * 关闭眉毛效果
 */
-(void)closeEyebrow;

/**
 * 更新眼影贴纸
 * @param sticker
 * @param alpha
 */
-(void)updateEyeshadow:(TuSDKPFSticker *)sticker;

/**
 * 关闭眼影效果
 */
-(void)closeEyeshadow;

/**
 * 更新眼线贴纸
 * @param sticker
 * @param alpha
 */
-(void)updateEyeline:(TuSDKPFSticker *)sticker;

/**
 * 关闭眼线效果
 */
-(void)closeEyeline;

/**
 * 更新睫毛贴纸
 * @param sticker
 * @param alpha
 */
-(void)updateEyelash:(TuSDKPFSticker *)sticker;
/**
 * 关闭睫毛效果
 */
-(void)closeEyelash;


@end
