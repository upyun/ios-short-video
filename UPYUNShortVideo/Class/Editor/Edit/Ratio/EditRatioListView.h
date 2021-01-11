//
//  EditRationListView.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/1.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"
#import "EditRatioListItemView.h"
@protocol EditRationListViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface EditRatioListView : HorizontalListView

@property (nonatomic,weak) IBOutlet id<EditRationListViewDelegate> delegate;

@end

@protocol EditRationListViewDelegate <NSObject>

@required
-(void)editRatioListView:(EditRatioListView *)rationListView didSelectedItemView:(EditRatioListItemView *)itemView;

@end

NS_ASSUME_NONNULL_END
