//
//  TuBeautySkinPanelViewCell.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/12/9.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
NS_ASSUME_NONNULL_BEGIN

//是否选中
typedef NS_ENUM(NSInteger, TuBeautySkinSelectType)
{
    TuBeautySkinSelectTypeUnselected = 0,
    TuBeautySkinSelectTypeSelected
};

@interface TuBeautySkinData : NSObject

@property (nonatomic, copy) NSString *beautySkinCode;
@property (nonatomic, assign) TuBeautySkinSelectType beautySkinSelectType;

@end

@interface TuBeautySkinPanelViewCell : UICollectionViewCell

@property (nonatomic, strong) TuBeautySkinData *beautySkinData;

@end

NS_ASSUME_NONNULL_END
