//
//  EditRationListItemView.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/1.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalListView.h"

@class EditRationModel;

NS_ASSUME_NONNULL_BEGIN

@interface EditRatioListItemView : HorizontalListItemBaseView

@property (nonatomic)EditRationModel *model;

@end


@interface EditRationModel : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *iconName;
@property (nonatomic,copy) NSString *selectedIconName;

@property (nonatomic)CGFloat ratio;

@end

NS_ASSUME_NONNULL_END
