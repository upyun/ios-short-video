//
//  TextAlignmentMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextAlignmentMenuView.h"
#import "TuSDKFramework.h"
#import "AttributedLabel.h"

// 对齐方式
static NSString * const kItemAlignmentKey = @"alignmnet";
// 缩略图键
static NSString * const kItemIconKey = @"icon";
// 标题键
static NSString * const kItemTitleKey = @"title";

@interface TextAlignmentMenuView ()
/**
 菜单项信息
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *menuItemInfos;

@end

@implementation TextAlignmentMenuView

- (void)commonInit {
    [super commonInit];
    
    _menuItemInfos =
    @[
      @{kItemAlignmentKey:@(NSTextAlignmentLeft), kItemIconKey: @"edit_text_ic_left", kItemTitleKey: NSLocalizedStringFromTable(@"tu_左对齐", @"VideoDemo", @"左对齐")},
      @{kItemAlignmentKey:@(NSTextAlignmentCenter),kItemIconKey: @"edit_text_ic_center", kItemTitleKey: NSLocalizedStringFromTable(@"tu_居中", @"VideoDemo", @"居中")},
      @{kItemAlignmentKey:@(NSTextAlignmentRight),kItemIconKey: @"edit_text_ic_right", kItemTitleKey: NSLocalizedStringFromTable(@"tu_右对齐", @"VideoDemo", @"右对齐")}
      ];
    
    self.itemSize = CGSizeMake(((self.frame.size.width - 76) / _menuItemInfos.count), 44);
    self.itemSpacing = 0;
    
    
    // 配置菜单项
    NSMutableArray *menuItemViews = [NSMutableArray array];
    
    for (NSDictionary *info in _menuItemInfos) {
        MenuItemControl *itemView = [[MenuItemControl alloc] initWithFrame:CGRectZero];
        itemView.tag = [info[kItemAlignmentKey] floatValue];
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
    [self setAlignment:label.textAlignment];
}

/**
 设置 NSTextAlignment

 @param alignment NSTextAlignment
 */
- (void)setAlignment:(NSTextAlignment)alignment
{
    _alignment = alignment;
    
    [self.menuItemViews enumerateObjectsUsingBlock:^(UIView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        MenuItemControl *itemControl = (MenuItemControl *)itemView;
        BOOL selected = itemControl.tag == alignment;

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
    self.alignment =  sender.tag;
    self.selectedIndex = [self.menuItemViews indexOfObject:sender];;
    if ([self.delegate respondsToSelector:@selector(menu:didChangeAlignment:)])
        [self.delegate menu:self didChangeAlignment:self.alignment];
}

@end
