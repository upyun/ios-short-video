//
//  TuCosmeticCategoryCell.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/10/21.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//是否选中
typedef NS_ENUM(NSInteger, TuCosmeticSelectType)
{
    TuCosmeticSelectTypeUnselected = 0,
    TuCosmeticSelectTypeSelected
};

//是否存在美妆特效
typedef NS_ENUM(NSInteger, TuCosmeticType)
{
    TuCosmeticTypeNone = 0,
    TuCosmeticTypeExist
};


typedef NS_ENUM(NSInteger, TuCosmeticLipSticktType)
{
    TuCosmeticLipSticktWaterWet = 0, //水润
    TuCosmeticLipSticktMoist,        //滋润
    TuCosmeticLipSticktMatte         //雾面
};

typedef NS_ENUM(NSInteger, TuCosmeticEyeBrowType)
{
    TuCosmeticEyeBrowFogen = 0,      //雾根眉
    TuCosmeticEyeBrowFog             //雾眉
};

@interface TuCosmeticHeaderData : NSObject

@property (nonatomic, copy) NSString *cosmeticCode;
@property (nonatomic, assign) TuCosmeticSelectType cosmeticSelectType;
@property (nonatomic, assign) TuCosmeticType cosmeticExistType;

@end

@interface TuCosmeticItemData : NSObject

@property (nonatomic, copy) NSString *stickerName;
@property (nonatomic, copy) NSString *cosmeticCode;
@property (nonatomic, assign) TuCosmeticSelectType cosmeticSelectType;

@end

//口红
@interface TuCosmeticLipStickData : NSObject

@property (nonatomic, copy) NSString *itemCode;
@property (nonatomic, copy) NSString *cosmeticCode;
@property (nonatomic, assign) TuCosmeticLipSticktType lipStickType;
@end

//眉毛
@interface TuCosmeticEyeBrowData : NSObject

@property (nonatomic, copy) NSString *itemCode;
@property (nonatomic, copy) NSString *cosmeticCode;
@property (nonatomic, assign) TuCosmeticEyeBrowType eyeBrowType;
@end

@interface TuCosmeticCategoryCell : UICollectionViewCell

//口红等大分类数据
@property (nonatomic, strong) TuCosmeticHeaderData *data;
//大分类下细分的效果数据
@property (nonatomic, strong) TuCosmeticItemData *itemData;
//口红类型数据
@property (nonatomic, strong) TuCosmeticLipStickData *lipStickData;
//眉毛类型数据
@property (nonatomic, strong) TuCosmeticEyeBrowData *eyeBrowData;


@end

NS_ASSUME_NONNULL_END
