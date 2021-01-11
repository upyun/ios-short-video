//
//  TextStyleMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextStyleMenuView.h"
#import "TuSDKFramework.h"
#import "AttributedLabel.h"

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
      @{kItemIconKey: @"t_ic_nor_nor", kItemTitleKey: NSLocalizedStringFromTable(@"tu_正常", @"VideoDemo", @"正常")},
      @{kItemIconKey: @"t_ic_blod_nor", kItemTitleKey: NSLocalizedStringFromTable(@"tu_加粗", @"VideoDemo", @"加粗")},
      @{kItemIconKey: @"t_ic_underline_nor", kItemTitleKey: NSLocalizedStringFromTable(@"tu_下划线", @"VideoDemo", @"下划线")},
      @{kItemIconKey: @"t_ic_ltalic_nor", kItemTitleKey: NSLocalizedStringFromTable(@"tu_斜体", @"VideoDemo", @"斜体")},

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
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:info[kItemIconKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        itemView.iconView = imageView;
        [itemView addTarget:self action:@selector(menuItemTapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.menuItemViews = menuItemViews.copy;
}

/**
 设置
 @param label 设置属性
 */
- (void)updateByAttributeLabel:(AttributedLabel *)label;{

    BOOL bold = label.bold;
    BOOL underline = label.underline;
    BOOL obliqueness = label.obliqueness;
    
    
    [self.menuItemViews enumerateObjectsUsingBlock:^(UIView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        MenuItemControl *itemControl = (MenuItemControl *)itemView;
        
        BOOL selected = YES;
        
        switch (idx) {
            case 1:
                selected = bold;
                break;
            case 2:
                selected = underline;
                break;
            case 3:
                selected = obliqueness;
                break;
            case 0:
                selected = !bold && !underline && !obliqueness;
                break;
            default:
                break;
        }
        
        UIColor *selectedColor = [UIColor lsqClorWithHex:@"#ffc502"];
        itemControl.textLabel.textColor = selected ? selectedColor : [UIColor whiteColor];
        
        UIImageView *iconView = (UIImageView *)itemControl.iconView;
        iconView.tintColor = selected ? selectedColor : [UIColor whiteColor];
        
    }];
    
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
