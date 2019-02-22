//
//  TextStyleMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextStyleMenuView.h"

// 缩略图键
static NSString * const kItemIconKey = @"icon";
// 标题键
static NSString * const kItemTitleKey = @"title";

@interface TextStyleMenuView ()

/**
 菜单项信息
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *menuItemInfos;

@end

@implementation TextStyleMenuView

- (void)commonInit {
    [super commonInit];
    
    _menuItemInfos =
    @[
      @{kItemIconKey: @"edit_text_ic_left", kItemTitleKey: NSLocalizedStringFromTable(@"tu_左对齐", @"VideoDemo", @"左对齐")},
      @{kItemIconKey: @"edit_text_ic_center", kItemTitleKey: NSLocalizedStringFromTable(@"tu_居中", @"VideoDemo", @"居中")},
      @{kItemIconKey: @"edit_text_ic_right", kItemTitleKey: NSLocalizedStringFromTable(@"tu_右对齐", @"VideoDemo", @"右对齐")},
      @{kItemIconKey: @"edit_text_ic_underline", kItemTitleKey: NSLocalizedStringFromTable(@"tu_下划线", @"VideoDemo", @"下划线")},
      @{kItemIconKey: @"edit_text_ic_smooth", kItemTitleKey: NSLocalizedStringFromTable(@"tu_从左到右", @"VideoDemo", @"从左到右")},
      @{kItemIconKey: @"edit_text_ic_inverse", kItemTitleKey: NSLocalizedStringFromTable(@"tu_从右到左", @"VideoDemo", @"从右到左")},
      ];
    self.itemSize = CGSizeMake(48, 44);
    self.itemSpacing = 40;
    
    // 配置菜单项
    NSMutableArray *menuItemViews = [NSMutableArray array];
    for (NSDictionary *info in _menuItemInfos) {
        MenuItemControl *itemView = [[MenuItemControl alloc] initWithFrame:CGRectZero];
        [self.scrollView addSubview:itemView];
        [menuItemViews addObject:itemView];
        itemView.textLabel.text = info[kItemTitleKey];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:info[kItemIconKey]]];
        itemView.iconView = imageView;
        [itemView addTarget:self action:@selector(menuItemTapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.menuItemViews = menuItemViews.copy;
}

/**
 菜单项点击事件

 @param sender 点击的按钮
 */
- (void)menuItemTapAction:(UIView *)sender {
    NSInteger index = [self.menuItemViews indexOfObject:sender];
    self.selectedIndex = index;
    if ([self.delegate respondsToSelector:@selector(menu:didChangeStyle:)]) {
        [self.delegate menu:self didChangeStyle:index];
    }
}

@end
