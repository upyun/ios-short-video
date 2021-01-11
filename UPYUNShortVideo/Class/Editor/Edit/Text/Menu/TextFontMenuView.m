//
//  TextFontMenuView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextFontMenuView.h"
#import "TuSDKFramework.h"
#import "AttributedLabel.h"

// 字体对象键
static NSString * const kItemFontKey = @"font";
// 字体标题键
static NSString * const kItemTitleKey = @"title";


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
    self.itemSize = CGSizeMake((self.frame.size.width - 76)/2.f,self.frame.size.height/2);
    self.itemSpacing = 0;
    
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
 设置
 @param label 设置属性
 */
- (void)updateByAttributeLabel:(AttributedLabel *)label;{
    [self setFont:label.font];
}

- (void)setFont:(UIFont *)font;{
   
    [self.menuItemViews enumerateObjectsUsingBlock:^(UIView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        MenuItemControl *itemControl = (MenuItemControl *)itemView;
        
        UIFont *itemFont = self -> _fontInfos[idx][kItemFontKey];
        BOOL selected = [itemFont.familyName isEqualToString:font.familyName];
        
        UIColor *selectedColor = [UIColor lsqClorWithHex:@"#ffc502"];
        itemControl.textLabel.textColor = selected ? selectedColor : [UIColor whiteColor];
        
        UILabel *label = (UILabel *)itemControl.iconView;
        label.textColor = selected ? selectedColor : [UIColor whiteColor];
        
    }];
    
}

/**
 菜单项点击事件

 @param sender 点击的菜单项
 */
- (void)menuItemTapAction:(UIView *)sender {
    NSInteger index = [self.menuItemViews indexOfObject:sender];
    self.selectedIndex = index;
    UIFont *font = _fontInfos[index][kItemFontKey];
    [self setFont:font];
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
