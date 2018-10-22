//
//  TuSDKPFEditTextController.m
//  TuSDKGeeV1
//
//  Created by wen on 20/07/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import "TuSDKPFEditTextController.h"

@implementation TuSDKPFEditTextController

#pragma mark - setter getter
/**
 *  视图类
 *
 *  @return 视图类 (默认:TuSDKPFEditStickerView, 需要继承 TuSDKPFEditStickerView)
 */
- (Class)viewClazz;
{
    if (!_viewClazz || ![_viewClazz lsq_isKindOfClass:[TuSDKPFEditTextView class]]) {
        _viewClazz = [TuSDKPFEditTextView class];
    }
    return _viewClazz;
}
/**
 *  裁剪区域视图
 */
- (TuSDKICMaskRegionView *)cutRegionView;
{
    return _defaultStyleView.cutRegionView;
}

/**
 *  文字视图
 */
- (TuSDKPFTextView *) textView;
{
    return _defaultStyleView.textView;
}

#pragma mark - init method 

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.title = LSQString(@"lsq_edit_entry_text", @"文字");
}

/**
 *  创建默认样式视图 (如需创建自定义视图，请覆盖该方法，并创建自己的视图类)
 */
- (void)buildDefaultStyleView;
{
    if (_defaultStyleView) return;
    
    CGFloat height =  [[UIApplication sharedApplication]isStatusBarHidden] ? lsqScreenHeight : lsqExcludeStatusBarHeight;
    CGFloat topY = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) { // iPhone X
        height = lsqScreenHeight - 78;
        topY = 44;
    }

    _defaultStyleView = [self.viewClazz initWithFrame:CGRectMake(0, topY, self.view.lsqGetSizeWidth, height)];
    [self configDefaultStyleView:_defaultStyleView];
    
    // 异步加载输入图片
    [self asyncLoadInputImageWithBlock:^id{
        return self.inputImage;
    }];
}

- (TuSDKPFEditTextViewOptions *)textOptions;
{
    if (!_textOptions)
        _textOptions = [TuSDKPFEditTextViewOptions defaultOptions];
    
    return _textOptions;
}

/**
 *  配置默认样式视图
 *
 *  @param view 默认样式视图 (如需创建自定义视图，请覆盖该方法，并配置自己的视图类)
 */
- (void)configDefaultStyleView:(TuSDKPFEditTextView *)view;
{
    if (!view) return;
    NSArray *btnStrs = @[@"text_addText", @"text_color", @"text_style"];
    
    // 设置初始化创建样式 在 lsqInitView前调用
    view.textOptions = self.textOptions;
    // 初始化视图
    [view lsqInitView];
    // 事件处理
    [view.bottomBar.cancelButton addTouchUpInsideTarget:self action:@selector(backActionHadAnimated)];
    [view.bottomBar.completeButton addTouchUpInsideTarget:self action:@selector(onImageCompleteAtion)];
    
    [view.optionBackButton addTouchUpInsideTarget:self action:@selector(onOptionBackAction)];
    [view.optionBar bindModules:btnStrs target:self action:@selector(onOptionSelectedAction:)];

    [self.view addSubview:view];
}

// 异步处理图片
- (void)asyncEditWithResult:(TuSDKResult *)result;
{
   
}

#pragma mark - image

/**
 *  异步加载输入图片完成
 *
 *  @param image 输入图片
 */
- (void)loadedInputImage:(UIImage *)image;
{
    if (_defaultStyleView) {
        [_defaultStyleView setImage:image];
    }
}

#pragma mark - click method

- (void)onOptionBackAction;
{
    [self setOptionViewHiddenState:YES];
}

- (void)onOptionSelectedAction:(UIView *)btn;
{
    [self.defaultStyleView selectedIndexWith:btn.tag];
}

/**
 *  设置选项操作视图隐藏状态
 *
 *  @param isHidden 是否隐藏
 */
- (void)setOptionViewHiddenState:(BOOL)isHidden;
{
    [self.defaultStyleView setOptionViewHiddenState:isHidden];
}

#pragma mark - result method

/**
 *  异步通知处理结果
 *
 *  @param result SDK处理结果
 *
 *  @return 是否截断默认处理逻辑 (默认: false, 设置为True时使用自定义处理逻辑)
 */
- (BOOL)asyncNotifyProcessingWithResult:(TuSDKResult *)result;
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(onAsyncTuSDKEditText:result:)]) return false;
    return [self.delegate onAsyncTuSDKEditText:self result:result];
}

/**
 *  通知处理结果
 *
 *  @param result SDK处理结果
 */
- (void)notifyProcessingWithResult:(TuSDKResult *)result;
{
    if ([self showResultPreview: result]) return;
    
    [self showHubSuccessWithStatus:LSQString(@"lsq_edit_processed", @"处理完成")];
    if (![self.delegate respondsToSelector:@selector(onTuSDKEditText:result:)] ) return;
    [self.delegate onTuSDKEditText:self result:result];
}

@end
