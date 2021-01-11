//
//  TextDirectionMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextDirectionMenuView.h"
#import "TuSDKFramework.h"
#import "AttributedLabel.h"

// 排列方式
static NSString * const kItemDirectionKey = @"direction";
// 缩略图键
static NSString * const kItemIconKey = @"icon";
// 标题键
static NSString * const kItemTitleKey = @"title";

@interface TextDirectionMenuView ()

/**
 菜单项信息
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *menuItemInfos;

@end

@implementation TextDirectionMenuView

- (void)commonInit {
    [super commonInit];
    
    _menuItemInfos =
    @[
      @{kItemDirectionKey:@(TextDirectionTypeRight),kItemIconKey: @"edit_text_ic_smooth", kItemTitleKey: NSLocalizedStringFromTable(@"tu_从左到右", @"VideoDemo", @"从左到右")},
      @{kItemDirectionKey:@(TextDirectionTypeLeft),kItemIconKey: @"edit_text_ic_inverse", kItemTitleKey: NSLocalizedStringFromTable(@"tu_从右到左", @"VideoDemo", @"从右到左")},
      ];
    self.itemSize = CGSizeMake(((self.frame.size.width - 76) / _menuItemInfos.count), 44);
    self.itemSpacing = 0;
    
    // 配置菜单项
    NSMutableArray *menuItemViews = [NSMutableArray array];
    for (NSDictionary *info in _menuItemInfos) {
        MenuItemControl *itemView = [[MenuItemControl alloc] initWithFrame:CGRectZero];
        itemView.tag = [info[kItemDirectionKey] floatValue];
        [self.scrollView addSubview:itemView];
        [menuItemViews addObject:itemView];
        itemView.textLabel.text = info[kItemTitleKey];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:info[kItemIconKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        itemView.iconView = imageView;
        [itemView addTarget:self action:@selector(menuItemTapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.menuItemViews = menuItemViews.copy;
}

- (void)setDirectionType:(TextDirectionType)directionType;{
    _directionType = directionType;
    
    [self.menuItemViews enumerateObjectsUsingBlock:^(UIView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        MenuItemControl *itemControl = (MenuItemControl *)itemView;
        BOOL selected = itemControl.tag == directionType;
        
        UIColor *selectedColor = [UIColor lsqClorWithHex:@"#ffc502"];
        itemControl.textLabel.textColor = selected ? selectedColor : [UIColor whiteColor];
        
        UIImageView *iconView = (UIImageView *)itemControl.iconView;
        iconView.tintColor = selected ? selectedColor : [UIColor whiteColor];
        
    }];
}

/**
 设置
 @param label 设置属性
 */
- (void)updateByAttributeLabel:(AttributedLabel *)label;{
    [self setDirectionType:[label.writingDirection.firstObject floatValue]];
}

/**
 菜单项点击事件

 @param sender 点击的按钮
 */
- (void)menuItemTapAction:(UIView *)sender {
     self.directionType = sender.tag;
     self.selectedIndex = [self.menuItemViews indexOfObject:sender];
    if ([self.delegate respondsToSelector:@selector(menu:didChangeDirectionType:)]) {
        [self.delegate menu:self didChangeDirectionType:self.directionType];
    }
}

@end
