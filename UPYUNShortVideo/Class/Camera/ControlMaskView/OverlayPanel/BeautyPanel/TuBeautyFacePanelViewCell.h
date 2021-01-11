//
//  TuBeautyPanelViewCell.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/12/4.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

NS_ASSUME_NONNULL_BEGIN

//是否选中
typedef NS_ENUM(NSInteger, TuBeautyFaceSelectType)
{
    TuBeautyFaceSelectTypeUnselected = 0,
    TuBeautyFaceSelectTypeSelected
};

@interface TuBeautyFaceData : NSObject

@property (nonatomic, copy) NSString *beautyFaceCode;
@property (nonatomic, assign) TuBeautyFaceSelectType beautyFaceSelectType;


@end

@interface TuBeautyFacePanelViewCell : UICollectionViewCell

@property (nonatomic, strong) TuBeautyFaceData *beautyFaceData;

@end

NS_ASSUME_NONNULL_END
