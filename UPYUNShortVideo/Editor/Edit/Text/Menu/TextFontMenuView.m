//
//  TextFontMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextFontMenuView.h"

// 字体对象键
static NSString * const kItemFontKey = @"font";
// 字体标题键
static NSString * const kItemTitleKey = @"title";
// 默认字体大小键
static const CGFloat kDefalutFontSize = 15.0;

@interface TextFontMenuView ()

/**
 字体信息，详见 `-commonInit` 中的定义
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *fontInfos;

@end

@implementation TextFontMenuView

#pragma mark - init

- (void)commonInit {
    [super commonInit];
    
    // 菜单项布局
    self.itemSize = CGSizeMake(40, 44);
    self.itemSpacing = 28;
    
    // 配置字体信息，可参考以下代码
    _fontSize = kDefalutFontSize;
    _fontInfos =
    @[
      @{kItemFontKey: [UIFont fontWithName:@"Heiti TC" size:_fontSize], kItemTitleKey: NSLocalizedStringFromTable(@"tu_黑体", @"VideoDemo", @"黑体")},
      @{kItemFontKey: [UIFont fontWithName:@"HiraKakuProN-W3" size:_fontSize], kItemTitleKey: NSLocalizedStringFromTable(@"tu_明黑", @"VideoDemo", @"明黑")},
      ];
    
    // 按字体信息创建菜单项
    NSMutableArray *menuItemViews = [NSMutableArray array];
    for (NSDictionary *info in _fontInfos) {
        MenuItemControl *itemView = [[MenuItemControl alloc] initWithFrame:CGRectZero];
        [self.scrollView addSubview:itemView];
        [menuItemViews addObject:itemView];
        itemView.textLabel.text = info[kItemTitleKey];
        UILabel *label = [self.class labelForFont:info[kItemFontKey]];
        itemView.iconView = label;
        [itemView addTarget:self action:@selector(menuItemTapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.menuItemViews = menuItemViews.copy;
}

/**
 菜单项点击事件

 @param sender 点击的菜单项
 */
- (void)menuItemTapAction:(UIView *)sender {
    NSInteger index = [self.menuItemViews indexOfObject:sender];
    self.selectedIndex = index;
    UIFont *font = _fontInfos[index][kItemFontKey];
    if ([self.delegate respondsToSelector:@selector(menu:didChangeFont:)]) {
        [self.delegate menu:self didChangeFont:font];
    }
}

/**
 创建字体显示标签工具方法
 可按需更改字体显示标签的样式

 @param font 字体对象
 @return 标签对象
 */
+ (UILabel *)labelForFont:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedStringFromTable(@"tu_涂图", @"VideoDemo", @"涂图");
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:font.fontName size:18];
    return label;
}

@end
