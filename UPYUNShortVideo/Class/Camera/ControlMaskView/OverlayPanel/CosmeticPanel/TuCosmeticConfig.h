//
//  TuCosmeticConfig.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/10/21.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuCosmeticConfig : NSObject

//获取美妆数组
+ (NSArray *)cosmeticDataSet;

/**
 根据美妆code获取数组
 @param code 美妆code
 @return code名称数组
 */
+ (NSArray *)dataSetWithCosmeticCode:(NSString *)code;

/**
 根据眉毛类型 和 贴纸名称获取贴纸code
 @param browType 眉毛类型
 @param stickerName 贴纸名称
 @return 贴纸code
 */
+ (NSString *)eyeBrowCodeByBrowType:(NSInteger)browType stickerName:(NSString *)stickerName;

/**
 根据美妆code 和 贴纸名称获取贴纸code
 @param code 美妆code
 @param stickerName 贴纸名称
 @return 贴纸code
 */
+ (NSString *)effectCodeByCosmeticCode:(NSString *)code stickerName:(NSString *)stickerName;


+ (int)stickLipParamByStickerName:(NSString *)stickerName;
@end

NS_ASSUME_NONNULL_END
