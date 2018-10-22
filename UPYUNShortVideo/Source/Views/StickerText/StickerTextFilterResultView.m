//
//  StickerTextFilterResultView.m
//  TuSDKVideoDemo
//
//  Created by songyf on 2018/7/3.
//  Copyright (c) 2018年 tusdk.com. All rights reserved.
//

#import "StickerTextFilterResultView.h"
#import "StickerTextParameterConfigView.h"

#pragma mark - TuSDKPFEditFilterBottomBar

/**
 文字贴纸底部动作栏
 @since 2.2.0
 */
@implementation StickerTextFilterBottomBar

#pragma mark - init

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
    self.backgroundColor = [UIColor lsqClorWithHex:@"#403e43"];
    
    // 取消按钮
    _cancelButton = [UIButton buttonWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth / 4, self.lsqGetSizeHeight)
                          imageLSQBundleNamed:@"style_default_edit_button_cancel"];
    [self addSubview:_cancelButton];
    
    // 完成按钮
    _completeButton = [UIButton buttonWithFrame:CGRectMake(_cancelButton.lsqGetSizeWidth * 3, 0, _cancelButton.lsqGetSizeWidth, self.lsqGetSizeHeight)
                            imageLSQBundleNamed:@"style_default_edit_button_completed"];
    [self addSubview:_completeButton];
}
@end

#pragma mark - TuSDKCPFilterResultView

/**
 *  滤镜处理结果控制器视图
 *  @since     v2.2.0
 */
@implementation StickerTextFilterResultView

/**
 *  初始化视图
 *  @since     v2.2.0
 */
- (void)lsqInitView;
{
    self.backgroundColor = [UIColor lsqClorWithHex:@"#2e2c30"];
    
    // 底部动作栏
    _bottomBar = [StickerTextFilterBottomBar initWithFrame:CGRectMake(0, [self lsqGetSizeHeight] - 49, self.lsqGetSizeWidth, 49)];
    // _bottomBar.titleView.text = LSQString(@"lsq_edit_skin_title", @"美颜");
    [self addSubview:_bottomBar];
    
    // 参数配置视图
    _configView = [StickerTextParameterConfigView initWithFrame:CGRectMake(0, _bottomBar.lsqGetOriginY - 80, self.lsqGetSizeWidth, 80)];
    [self addSubview:_configView];
    
    // 图片视图
    _imageView = [TuSDKICFilterImageViewWrap initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, _configView.lsqGetOriginY)];
    [_imageView setBackgroundColor:[UIColor lsqClorWithHex:@"#2e2c30"]];
    [self addSubview:_imageView];
}
@end
