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
    _faceType = TuSkinFaceTypeBeauty;
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
    resetItemView.titleLabel.text = NSLocalizedStringFromTable(@"tu_无", @"VideoDemo", @"无");
    [self insertItemView:resetItemView atIndex:0];
    
    // 白点分割按钮
    CameraBeautyFaceListItemView *dotItemView = [CameraBeautyFaceListItemView new];
    dotItemView.itemWidth = 6;
    dotItemView.thumbnailView.backgroundColor = [UIColor grayColor];
    dotItemView.disableSelect = YES;
    dotItemView.titleLabel.text = @"  ";
    [self insertItemView:dotItemView atIndex:2];
    
    [self setFaceType:_faceType];
}

- (void)setFaceType:(TuSkinFaceType)faceType
{
    _faceType = faceType;
    
    HorizontalListItemView *itemView = [self itemViewAtIndex:1];
    itemView.selected = NO;
    NSString *code = nil;
    NSString *ruddyCode = nil;
    if (_faceType == TuSkinFaceTypeNatural)
    {
        code = @"skin_precision";
        ruddyCode = @"ruddy";
    }
    else if (_faceType == TuSkinFaceTypeMoist)
    {
        code = @"skin_extreme";
        ruddyCode = @"sharpen";
    }
    else
    {
        code = @"skin_beauty";
        ruddyCode = @"sharpen";
    }
    // 标题
    NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
    itemView.titleLabel.text = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
    // 缩略图
    NSString *imageName = [NSString stringWithFormat:@"face_ic_%@", code];
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    itemView.thumbnailView.image = image;
    
    HorizontalListItemView *ruddyItemView = [self itemViewAtIndex:5];
    // 标题
    NSString *ruddytitle = [NSString stringWithFormat:@"lsq_filter_set_%@", ruddyCode];
    ruddyItemView.titleLabel.text = NSLocalizedStringFromTable(ruddytitle, @"TuSDKConstants", @"无需国际化");
    // 缩略图
    NSString *ruddyImageName = [NSString stringWithFormat:@"face_ic_%@", ruddyCode];
    UIImage *ruddyImage = [[UIImage imageNamed:ruddyImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    ruddyItemView.thumbnailView.image = ruddyImage;
}

- (NSString *)selectedSkinKey;
{
    if (_faceType == TuSkinFaceTypeNatural)
    {
        if (self.selectedIndex > 2 && self.selectedIndex - 2 < @[kNaturalBeautySkinKeys].count)
            return @[kNaturalBeautySkinKeys][self.selectedIndex - 2];
    }
    else
    {
        if (self.selectedIndex > 2 && self.selectedIndex - 2 < @[kBeautySkinKeys].count)
            return @[kBeautySkinKeys][self.selectedIndex - 2];
    }
    
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
        {
            if (_faceType == TuSkinFaceTypeBeauty)
            {
                _faceType = TuSkinFaceTypeMoist;
            }
            else if (_faceType == TuSkinFaceTypeMoist)
            {
                _faceType = TuSkinFaceTypeNatural;
            }
            else
            {
                _faceType = TuSkinFaceTypeBeauty;
            }
            [self setFaceType:_faceType];
        }
            break;
        default:
    
            break;
    }
    
    if (self.itemViewTapActionHandler) self.itemViewTapActionHandler(self, tapedItemView);
}

@end
