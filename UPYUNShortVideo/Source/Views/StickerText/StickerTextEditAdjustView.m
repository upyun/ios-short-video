//
//  StickerTextEditAdjustView.m
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright (c) 2015年 tusdk.com. All rights reserved.
//

#import "StickerTextEditAdjustView.h"

#pragma mark - StickerTextEditAdjustOptionBar

/**
 *  选项栏目
 *  @since         v2.2.0
 */
@implementation StickerTextEditAdjustOptionBar

#pragma mark init

/**
 *  初始化
 *  @param frame 外部设定frame
 *  @return UIView
 *  @since     v2.2.0
 */
- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

/**
 *  生成界面
 *  @since     v2.2.0
 */
-(void)lsqInitView;
{
    self.backgroundColor = [UIColor lsqClorWithHex:@"#000000"];
    // 横向滚动视图
    _wrapView = [UIScrollView initWithFrame:self.bounds];
    _wrapView.alwaysBounceHorizontal = NO;
    _wrapView.directionalLockEnabled = YES;
    [self addSubview:_wrapView];
    
    // 模块按钮列表
    _buttons = [NSMutableArray array];
}

#pragma mark modules

/**
 *  绑定功能模块
 *  @param modules 功能模块列表
 *  @param target  绑定事件对象
 *  @param action  绑定事件
 *  @since         v2.2.0
 */
- (void)bindModules:(NSArray *)modules target:(id)target action:(SEL)action;
{
    if (!modules) return;
    // 删除已有按钮
    if (_buttons) {
        [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    _buttons = [NSMutableArray array];
    
    NSUInteger count = modules.count;
    
    for (NSString *type in modules) {
        UIButton *btn = [self buildButtonWithActionType:type moduleCount:count];
        if (!btn) continue;
        btn.tag = _buttons.count;
        [_wrapView addSubview:btn];
        [_buttons addObject:btn];
        [btn addTouchUpInsideTarget:target action:action];
    }
    [self needUpdateLayout];
}

/**
 *  创建动作按钮
 *  @param module 图片编辑动作类型
 *  @param count  按钮总数
 *  @return       动作按钮
 *  @since        v2.2.0
 */
- (UIButton *)buildButtonWithActionType:(NSString *)module moduleCount:(NSUInteger)count;
{
//    NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", module];
    NSString *icon = [NSString stringWithFormat:@"style_default_edit_icon_%@", module];
    
    CGFloat buttonWidth = self.lsqGetSizeWidth/4.5;
    if (count <=4)
    {
        buttonWidth = self.lsqGetSizeWidth/count;
    }
    
    UIButton *btn = [UIButton buttonWithFrame:CGRectMake(0, 0, buttonWidth, self.lsqGetSizeHeight)
                                        title:@""
                                         font:lsqFontSize(10)
                                        color:[UIColor whiteColor]];
    [btn setStateNormalImage:[UIImage imageNamed:icon]];
    return btn;
}

/**
 *  更新按钮布局
 *  @since         v2.2.0
 */
- (void)needUpdateLayout;
{
    _wrapView.frame = self.bounds;
    if (!_buttons) return;
    
    CGFloat left = 0;
    for (UIButton *btn in _buttons) {
        btn.frame = CGRectMake(left, 0, btn.lsqGetSizeWidth, self.lsqGetSizeHeight);
        left += btn.lsqGetSizeWidth;
    }
    _wrapView.contentSize = CGSizeMake(left, self.lsqGetSizeHeight);
}
@end

#pragma mark - TuSDKPFEditAdjustView

/**
 *  颜色调整控制器视图
 *  @since         v2.2.0
 */
@implementation StickerTextEditAdjustView

/**
 *  初始化视图
 *  @since         v2.2.0
 */
- (void)lsqInitView;
{
    [super lsqInitView];
    
    self.backgroundColor = [UIColor lsqClorWithHex:@"#000000"];
    
    // 底部动作栏
    _bottomBar.titleView.text = LSQString(@"lsq_filter_set_adjustment", @"调整");
    
    // 选项栏目
    _optionBar = [StickerTextEditAdjustOptionBar initWithFrame:_configView.frame];
    [self addSubview:_optionBar];
    
    _configActionContainer = [UIView initWithFrame:_bottomBar.frame];
    _configActionContainer.backgroundColor = [UIColor lsqClorWithHex:@"#403e43"];
    
    // 参数配置视图取消按钮
    _configCancalButton = [UIButton buttonWithFrame:CGRectMake(0, 0, _configActionContainer.lsqGetSizeWidth / 4, _configActionContainer.lsqGetSizeHeight)
                          imageLSQBundleNamed:@"style_default_edit_button_cancel"];
    [_configActionContainer addSubview:_configCancalButton];
    
    // 参数配置视图完成按钮
    _configCompleteButton = [UIButton buttonWithFrame:CGRectMake(_configCancalButton.lsqGetSizeWidth * 3, 0, _configCancalButton.lsqGetSizeWidth, _configActionContainer.lsqGetSizeHeight)
                            imageLSQBundleNamed:@"style_default_edit_button_completed"];
    [_configActionContainer addSubview:_configCompleteButton];
    
    _configActionContainer.hidden = YES;
    
    [self addSubview:_configActionContainer];
}

/**
 *  显示配置选项
 *  @param key 配置选项键
 *  @since         v2.2.0
 */
- (void)showConfigWithKey:(NSString *)key;
{
    if (!key) return;
    [self.configView setParams:@[key] selectedIndex:0];
    [self setConfigViewHiddenState:NO];
}

/**
 *  设置配置视图隐藏状态
 *  @param isHidden 是否隐藏
 *  @since         v2.2.0
 */
- (void)setConfigViewHiddenState:(BOOL)isHidden;
{
    _optionBar.hidden = NO;
    _configActionContainer.hidden = NO;
    
    CGFloat alpha = isHidden ? 1 : 0;
    CGFloat top = isHidden ? _bottomBar.lsqGetBottomY : _bottomBar.lsqGetOriginY;
    
    [UIView animateWithDuration:0.26 animations:^{
        _optionBar.alpha = alpha;
        [_configActionContainer lsqSetOriginY:top];
    } completion:^(BOOL finished) {
        if (!finished) return;
        _configActionContainer.hidden = isHidden;
        _optionBar.hidden = !isHidden;
    }];
}
@end
