//
//  TuCosmeticConfig.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/10/21.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuCosmeticConfig.h"
#import "Constants.h"

//眉毛
#define KCosmeticEyeBrow @"标准黑", @"标准灰", @"标准棕", @"柳弯黑", @"柳弯灰", @"柳弯棕", @"叶细黑", @"叶细灰", @"叶细棕", @"峰眉黑", @"峰眉灰", @"峰眉棕", @"粗平黑", @"粗平灰", @"粗平棕", @"弯线黑", @"弯线灰", @"弯线棕", @"芭比黑", @"芭比灰", @"芭比棕", @"小桃黑", @"小桃灰", @"小桃棕", @"新月黑", @"新月灰", @"新月棕", @"断眉黑", @"断眉灰", @"断眉棕", @"野生黑", @"野生灰", @"野生棕", @"欧线黑", @"欧线灰", @"欧线棕", @"圆眉黑", @"圆眉灰", @"圆眉棕", @"延禧黑", @"延禧灰", @"延禧棕"

@implementation TuCosmeticConfig

//获取美妆数组
+ (NSArray *)cosmeticDataSet
{
    // 美妆
    //@"CosLipGloss", @"CosBlush", @"CosBrows", @"CosEyeShadow", @"CosEyeLine", @"CosEyeLash", @"CosIris"
    return @[@"reset", @"point", @"lipstick", @"blush", @"eyebrow", @"eyeshadow", @"eyeliner", @"eyelash"];
}

/**
 根据美妆code获取数组
 @param code 美妆code
 @return code名称数组
 */
+ (NSArray *)dataSetWithCosmeticCode:(NSString *)code;
{
    if ([code isEqualToString:@"reset"])
    {
        return @[@"reset"];
    }
    else if ([code isEqualToString:@"point"])
    {
        return @[@"point"];
    }
    else if ([code isEqualToString:@"lipstick"])
    {
        //口红
        NSArray *stickArray = [TuCosmeticConfig codeNameDataSetByCosmeticCode:code];
        return stickArray;
    }
    else if ([code isEqualToString:@"blush"])
    {
        //腮红
        NSArray *blushArray = [TuCosmeticConfig codeNameDataSetByCosmeticCode:code];
        return blushArray;
    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        //眉毛
        return @[@"point", @"back", @"eyebrowType", @"reset", KCosmeticEyeBrow, @"point"];
    }
    else if ([code isEqualToString:@"eyeshadow"])
    {
        //眼影
        NSArray *eyeShadowArray = [TuCosmeticConfig codeNameDataSetByCosmeticCode:code];
        return eyeShadowArray;
    }
    else if ([code isEqualToString:@"eyeliner"])
    {
        //睫毛
        NSArray *eyeLinerArray = [TuCosmeticConfig codeNameDataSetByCosmeticCode:code];
        return eyeLinerArray;
    }
    else
    {
        NSArray *eyeLashArray = [TuCosmeticConfig codeNameDataSetByCosmeticCode:code];
        return eyeLashArray;
    }
}

/**
 根据美妆code获取名称数组
 @param code 美妆code
 @return 相对应code下包含的贴纸名称数组
 */
+ (NSMutableArray *)codeNameDataSetByCosmeticCode:(NSString *)code
{
    //获取对应的code数组
    NSDictionary *cosmeticParam = [TuCosmeticConfig localCosmeticSticekerJSON];
    
    NSMutableArray *titleDataSet = [NSMutableArray array];
    
    //添加 返回 和 重置 字段
    if (![code isEqualToString:@"lipstick"])
    {
        [titleDataSet addObject:@"point"];
    }
    
    [titleDataSet addObject:@"back"];
    
    if ([code isEqualToString:@"lipstick"])
    {
        [titleDataSet addObject:@"lipstickType"];
    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        [titleDataSet addObject:@"eyebrowType"];
    }
    
    [titleDataSet addObject:@"reset"];
    
    //未正确读取到json文件，只返回"back" 和 "reset"
    if (cosmeticParam == nil)
    {
        NSLog(@"cosmeticCategories.json is not found");
        return titleDataSet;
    }
    NSDictionary *codeParams = [cosmeticParam objectForKey:code];
    
    NSArray *blushStickerArray = codeParams[@"stickers"];
    
    for (NSDictionary *stickerParam in blushStickerArray)
    {
        NSString *codeName = stickerParam[@"name"];
        [titleDataSet addObject:codeName];
    }
    if (![code isEqualToString:@"eyelash"])
    {
        [titleDataSet addObject:@"point"];
    }
    
    return titleDataSet;
}

/**
 根据眉毛类型 和 贴纸名称获取贴纸code
 @param browType 眉毛类型
 @param stickerName 贴纸名称
 @return 贴纸code
 */
+ (NSString *)eyeBrowCodeByBrowType:(NSInteger)browType stickerName:(NSString *)stickerName
{
    NSDictionary *cosmeticParam = [TuCosmeticConfig localCosmeticSticekerJSON];
    //未正确读取到json文件，返回空
    if (cosmeticParam == nil)
    {
        NSLog(@"cosmeticCategories.json is not found");
        return @"";
    }
    //获取对应的code数组
    NSString *code = @"eyebrow-Fog";
    //0 -> 雾根眉  1 -> 雾眉
    if (browType == 0)
    {
        code = @"eyebrow-Fogen";
        stickerName = [stickerName stringByAppendingString:@"b"];
    }
    else
    {
        stickerName = [stickerName stringByAppendingString:@"a"];
    }
    NSDictionary *codeParams = [[TuCosmeticConfig localCosmeticSticekerJSON] objectForKey:code];
    NSArray *blushStickerArray = codeParams[@"stickers"];
    
    for (NSDictionary *stickerParam in blushStickerArray)
    {
        if ([stickerParam[@"name"] isEqualToString:stickerName])
        {
            return stickerParam[@"id"];
        }
    }
    return @"";
}


/**
 根据美妆code 和 贴纸名称获取贴纸code
 @param code 美妆code
 @param stickerName 贴纸名称
 @return 贴纸code
 */
+ (NSString *)effectCodeByCosmeticCode:(NSString *)code stickerName:(NSString *)stickerName
{
    NSDictionary *cosmeticParam = [TuCosmeticConfig localCosmeticSticekerJSON];
    //未正确读取到json文件，返回空
    if (cosmeticParam == nil)
    {
        NSLog(@"cosmeticCategories.json is not found");
        return @"";
    }
    //获取对应的code数组
    NSDictionary *codeParams = [[TuCosmeticConfig localCosmeticSticekerJSON] objectForKey:code];
    NSArray *blushStickerArray = codeParams[@"stickers"];
    
    for (NSDictionary *stickerParam in blushStickerArray)
    {
        if ([stickerParam[@"name"] isEqualToString:stickerName])
        {
            return stickerParam[@"id"];
        }
    }
    return @"";
}

/**
 本地配置的美妆数据

 @return NSDictionary<NSString *,NSDictionary*> *
 */
+ (NSDictionary<NSString *,NSDictionary*> *)localCosmeticSticekerJSON
{
   
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"cosmeticCategories" ofType:@"json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:0 error:&error];
    if (error) {
        NSLog(@"cosmetic sticker categories error: %@", error);
        return nil;
    }
    
    return jsonDic;
}


/**
 本地配置的口红参数
 */
+ (int)stickLipParamByStickerName:(NSString *)stickerName
{
    if ([stickerName isEqualToString:@"lipStick_1"])
    {
        //枫叶红
        return 0xB23029;
    }
    else if ([stickerName isEqualToString:@"lipStick_2"])
    {
        //正红色
        return 0xC2030D;
    }
    else if ([stickerName isEqualToString:@"lipStick_3"])
    {
        //牛血红
        return 0x6A0500;
    }
    else if ([stickerName isEqualToString:@"lipStick_4"])
    {
        //番茄橘
        return 0xA02112;
    }
    else if ([stickerName isEqualToString:@"lipStick_5"])
    {
        //暖柿红
        return 0xEF5D47;
    }
    else if ([stickerName isEqualToString:@"lipStick_6"])
    {
        //正橘色
        return 0xBF1B1C;
    }
    else if ([stickerName isEqualToString:@"lipStick_7"])
    {
        //珊瑚粉
        return 0xF27A7A;
    }
    else if ([stickerName isEqualToString:@"lipStick_8"])
    {
        //玫红色
        return 0xD00A39;
    }
    else if ([stickerName isEqualToString:@"lipStick_9"])
    {
        //梅子色
        return 0x6A122D;
    }
    else if ([stickerName isEqualToString:@"lipStick_10"])
    {
        //覆盆子
        return 0x842852;
    }
    else if ([stickerName isEqualToString:@"lipStick_11"])
    {
        //肉桂色
        return 0xE58C7A;
    }
    else if ([stickerName isEqualToString:@"lipStick_12"])
    {
        //奶茶色
        return 0xFFBEB5;
    }
    else
    {
        //豆沙色
        return 0xB78073;
    }
}

@end
