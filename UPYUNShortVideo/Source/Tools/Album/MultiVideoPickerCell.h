//
//  MultiVideoPickerCell.h
//  MultiVideoPicker
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TuVideoModel;

@interface MultiVideoPickerCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIButton *selectButton;

@property (nonatomic, copy) void (^selectButtonActionHandler)(MultiVideoPickerCell *cell, BOOL selected);

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) TuVideoModel *model;

@end
