//
//  StickerTextParameterConfigView.m
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright (c) 2018年 tusdk.com. All rights reserved.
//

#import "StickerTextParameterConfigView.h"

/**
 *  参数配置视图
 *  @since     v2.2.0
 */
@interface StickerTextParameterConfigView(){
    // 参数视图列表
    NSMutableArray *_mParamViews;
    // 当前选中的索引
    NSUInteger _mCurrentIndex;
    // 滑动条包装视图
    UIView *_seekWrapView;
}
@end

@implementation StickerTextParameterConfigView


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
- (void)lsqInitView;
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor lsqClorWithHex:@"#1e1c1f"];
    
    // 参数选项视图
    _paramsView = [UIView initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, 30)];
    [self addSubview:_paramsView];

    // 滑动条包装视图
    _seekWrapView = [UIView initWithFrame:CGRectMake(0, _paramsView.lsqGetBottomY, self.lsqGetSizeWidth, self.lsqGetSizeHeight - _paramsView.lsqGetBottomY)];
    [self addSubview:_seekWrapView];
    
    // 重置按钮
    _restButton = [UIButton buttonWithFrame:CGRectMake(8, [_seekWrapView lsqGetCenterY:28], 54, 28)
                                     title:LSQString(@"lsq_reset", @"重置")
                                      font:lsqFontSize(12) color:[UIColor whiteColor]];
    _restButton.layer.cornerRadius = [_restButton lsqGetSizeHeight]/2;
    _restButton.backgroundColor = lsqRGB(70, 175, 119);
    [_restButton addTouchUpInsideTarget:self action:@selector(handleRestAction)];
    [_seekWrapView addSubview:_restButton];

    // 数字显示视图
    _numberView = [UILabel initWithFrame:CGRectMake(_seekWrapView.lsqGetSizeWidth - 50, [_seekWrapView lsqGetCenterY:30], 50, 30)
                                fontSize:16 color:lsqRGB(255, 255, 255) aligment:NSTextAlignmentCenter];
    [_seekWrapView addSubview:_numberView];

    // 百分比控制条
    _seekBar = [TuSDKICSeekBar initWithFrame:CGRectMake(_restButton.lsqGetRightX + 24, 0, _numberView.lsqGetOriginX - _restButton.lsqGetRightX - 24 - 16, _seekWrapView.lsqGetSizeHeight)];
    _seekBar.delegate = self;
    [_seekWrapView addSubview:_seekBar];
}

/**
 *  设置进度
 *  @param progress 百分比
 *  @since     v2.2.0
 */
- (void)setTitleWithProgress:(CGFloat)progress;
{
    if (!self.numberView) return;
    
    self.numberView.text = [NSString stringWithFormat:@"+%01ld", (unsigned long)(progress * 100)];
}

/**
 *  跳到指定百分比
 *  @param progress 百分比进度
 *  @since          2.2.0
 */
- (void)seekWithProgress:(CGFloat)progress;
{
    if (self.seekBar) {
        self.seekBar.progress = progress;
    }
    [self setTitleWithProgress:progress];
    [self onTuSDKICSeekBar:_seekBar changedProgress:progress];
}

/**
 * 重置参数
 * @since    2.2.0
 */
- (void)handleRestAction;
{
    if (self.delegate) {
        [self.delegate onTuSDKCPParameterConfig:self resetWithIndex:_mCurrentIndex];
    }
}

#pragma mark - TuSDKICSeekBarDelegate

/**
 *  进度改变
 *  @param seekbar  百分比控制条
 *  @param progress 进度百分比
 *  @since          2.2.0
 */
- (void)onTuSDKICSeekBar:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress;
{
    [self setTitleWithProgress:progress];
    if (self.delegate) {
        [self.delegate onTuSDKCPParameterConfig:self changeWithIndex:_mCurrentIndex progress:progress];
    }
}

/**
 *  设置参数列表
 *  @param params 参数列表
 *  @param index  选中索引
 *  @since        2.2.0
 */
- (void)setParams:(NSArray *)params selectedIndex:(NSUInteger)index;
{
    if (!params || index >= params.count || params.count == 0 || !self.paramsView) return;
    
    [self.paramsView removeAllSubviews];
    _mParamViews = [NSMutableArray arrayWithCapacity:params.count];
    
    CGFloat width = floorf(self.lsqGetSizeWidth / params.count);
    CGFloat left = 0;
    for (NSString *key in params) {
        UIButton *button = [self createParamViewWithKey:key
                                                  frame:CGRectMake(left, 0, width, self.paramsView.lsqGetSizeHeight)];
        [self.paramsView addSubview:button];
        [_mParamViews addObject:button];
        left = button.lsqGetRightX;
    }
    _mCurrentIndex = NSNotFound;
    [self selectWithIndex:index];
}

/**
 *  创建参数视图
 *  @param key NSString
 *  @param frame CGRect
 *  @return UIButton
 *  @since        2.2.0
 */
- (UIButton *)createParamViewWithKey:(NSString *)key frame:(CGRect)frame;
{
    NSString *titleKey = [NSString stringWithFormat:@"lsq_filter_set_%@", key];
    UIButton *btn = [UIButton buttonWithFrame:frame
                                        title:LSQString(titleKey, @"")
                                         font:lsqFontSize(12) color:[UIColor whiteColor]];
    [btn setTitleColor:lsqRGB(255, 102, 51) forState:UIControlStateSelected];
    [btn setTitleColor:lsqRGB(255, 102, 51) forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [btn addTouchUpInsideTarget:self action:@selector(onParamSelected:)];
    return btn;
}

/**
 *  选中一个参数
 *  @param btn UIButton
 *  @since        2.2.0
 */
- (void)onParamSelected:(UIButton *)btn;
{
    if (!_mParamViews) return;
    NSUInteger index = [_mParamViews indexOfObject:btn];
    [self selectWithIndex:index];
}

/**
 *  选中索引
 *  @param index 索引
 *  @since        2.2.0
 */
- (void)selectWithIndex:(NSUInteger)index;
{
    if (_mCurrentIndex == index || !_mParamViews || index == NSNotFound) return;
    
    _mCurrentIndex = index;
    for (NSUInteger i = 0, j = _mParamViews.count; i < j; i++) {
        UIButton *btn = [_mParamViews objectAtIndex:i];
        btn.selected = (i == index) && _mParamViews.count > 1;
    }
    
    if (self.delegate) {
        [self seekWithProgress:[self.delegate onTuSDKCPParameterConfig:self valueWithIndex:_mCurrentIndex]];
    }
}
@end
