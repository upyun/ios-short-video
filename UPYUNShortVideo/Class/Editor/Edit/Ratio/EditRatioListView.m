//
//  EditRationListView.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/1.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "EditRatioListView.h"
#import "EditRatioListItemView.h"

@interface EditRatioListView()
{
    NSMutableArray<EditRationModel *> *_rationModelArray;
}
@end

@implementation EditRatioListView

+ (Class)listItemViewClass {
    return [EditRatioListItemView class];
}

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    
    
    _rationModelArray = [NSMutableArray array];
    
    NSArray<NSString *> *iconNames = @[@"crop_no",@"crop_16-9",@"crop_3-2",@"crop_4-3",@"crop_1-1",@"crop_3-4",@"crop_2-3",@"crop_9-16"];
    NSArray<NSString *> *titles = @[@"无",@"16:9",@"3:2",@"4:3",@"1:1",@"3:4",@"2:3",@"9:16"];
    NSArray<NSNumber *> *ratios = @[@(0),@(9.f/16.f),@(3.f/2.f),@(4.f/3.f),@(1.f),@(3.f/4.f),@(2.f/3.f),@(16.f/9.f)];


    // 配置 UI
    typeof(self)weakSelf = self;
    [self addItemViewsFromXIBWithCount:iconNames.count config:^(HorizontalListView *listView, NSUInteger index, UIView *itemView) {
     
        NSString *iconName = iconNames[index];
        NSString *title = titles[index];
    
        EditRatioListItemView *ratioItemView = (EditRatioListItemView *)itemView;
        
        EditRationModel *ratioModel = [[EditRationModel alloc]init];
        ratioModel.title = title;
        ratioModel.iconName = [NSString stringWithFormat:@"%@_nor",iconName];
        ratioModel.selectedIconName = [NSString stringWithFormat:@"%@_sel",iconName];

        ratioModel.ratio = [ratios[index] floatValue];
        ratioItemView.model = ratioModel;
        
        [weakSelf->_rationModelArray addObject:ratioModel];
       
    }];
    
    [self setSelectedIndex:0];
}

- (void)itemViewDidTap:(EditRatioListItemView *)itemView; {
    [super itemViewDidTap:itemView];
    [self.delegate editRatioListView:self didSelectedItemView:itemView];
}

@end
