//
//  CameraBeautySkinListView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/9/17.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "CameraBeautySkinListView.h"
#import "Constants.h"
#import "CameraBeautyFaceListItemView.h"

@interface CameraBeautySkinListView ()

@end

@implementation CameraBeautySkinListView

+ (Class)listItemViewClass {
    return [CameraBeautyFaceListItemView class];
}

- (void)commonInit {
    [super commonInit];
    
    NSArray *faceFeatures = @[kBeautySkinKeys];
    _useSkinNatural = YES;
    // 配置 UI
    self.autoItemSize = YES;
    [self addItemViewsWithCount:faceFeatures.count config:^(HorizontalListView *listView, NSUInteger index, HorizontalListItemView *_itemView) {
        NSString *faceFeature = faceFeatures[index];
        // 标题
        NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", faceFeature];
        _itemView.titleLabel.text = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
        // 缩略图
        NSString *imageName = [NSString stringWithFormat:@"face_ic_%@", faceFeature];
        UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _itemView.thumbnailView.image = image;
    }];
    
    // 重置按钮
    HorizontalListItemView *resetItemView = [CameraBeautyFaceListItemView itemViewWithImage:[UIImage imageNamed:@"ic_nix"] title:nil];
    resetItemView.disableSelect = YES;
    resetItemView.titleLabel.text = @"  ";
    [self insertItemView:resetItemView atIndex:0];
    
    // 白点分割按钮
    CameraBeautyFaceListItemView *dotItemView = [CameraBeautyFaceListItemView new];
    dotItemView.itemWidth = 4;
    dotItemView.thumbnailView.backgroundColor = [UIColor grayColor];
    dotItemView.disableSelect = YES;
    dotItemView.titleLabel.text = @"  ";
    [self insertItemView:dotItemView atIndex:2];
    
    [self setUseSkinNatural:_useSkinNatural];
}

/**
 设置是否使用自然美颜

 @param useSkinNatural true/false
 */
- (void)setUseSkinNatural:(BOOL)useSkinNatural;
{
    HorizontalListItemView *itemView = [self itemViewAtIndex:1];
    itemView.selected = NO;
    NSString *code = useSkinNatural ? @"skin_precision" : @"skin_extreme";
    // 标题
    NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
    itemView.titleLabel.text = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
    // 缩略图
    NSString *imageName = [NSString stringWithFormat:@"face_ic_%@", code];
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    itemView.thumbnailView.image = image;
    
    _useSkinNatural = useSkinNatural;
}

- (NSString *)selectedSkinKey;
{
    if (self.selectedIndex > 2 && self.selectedIndex - 2 < @[kBeautySkinKeys].count)
        return @[kBeautySkinKeys][self.selectedIndex - 2];
    return nil;
}

#pragma mark HorizontalListItemViewDelegate

/**
 列表项点击回调
 */
- (void)itemViewDidTap:(HorizontalListItemView *)tapedItemView {
    [super itemViewDidTap:tapedItemView];
  
    switch (self.selectedIndex) {
        case 0:
            break;
        case 1:// 切换美颜模类型
            [self setUseSkinNatural:!_useSkinNatural];
            break;
        default:
    
            break;
    }
    
    if (self.itemViewTapActionHandler) self.itemViewTapActionHandler(self, tapedItemView);
}

@end
