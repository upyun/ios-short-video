//
//  StickerTextEditContainersView.h
//  TuSDK
//
//  Created by wen on 24/07/2017.
//  Copyright © 2017 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

@class StickerTextItemView;
@protocol StickerTextEditorPanelDelegate;
@protocol StickerTextItemViewDelegate;

#pragma mark - StickerTextEditorPanel

@interface StickerTextEditorPanel : UIView<StickerTextItemViewDelegate>

/**
 当前选中的item
 @since   v2.2.0
 */
@property (nonatomic, strong) StickerTextItemView  *currentSelectedItem ;

/**
 文字item列表
 @since   v2.2.0
 */
@property (nonatomic) NSMutableArray<StickerTextItemView *> *allTextItemViewArray;

/**
 StickerTextEditorPanel 委托对象
 @since   v2.2.0
 */
@property (nonatomic, weak) id<StickerTextEditorPanelDelegate> delegate;

/**
 初始化提示信息
 @since   v2.2.0
 */
@property (nonatomic) NSString *textString;

/**
 初始化文字样式信息设置
 @since   v2.2.0
 */
@property (nonatomic) NSMutableParagraphStyle *textParaStyle;

/**
 当前已使用贴纸总数
 @since   v2.2.0
 */
@property (nonatomic, readonly) NSUInteger textCount;

/**
 *  边框宽度
 */
@property (nonatomic, assign) CGFloat textBorderWidth;

/**
 边框颜色
 @since   v2.2.0
 */
@property (nonatomic, retain) UIColor *textBorderColor;

/**
 文字边距 默认 （0，0，0，0）
 @since   v2.2.0
 */
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;

/**
 文字最大放大倍数 (相对于父视图) 默认 1.0
 @since   v2.2.0
 */
@property (nonatomic, assign) CGFloat textMaxScale;

/**
 初始化方法
 @param frame View的frame
 @param textFont 字体
 @param textColor 字体颜色
 @return textView对象
 @since   v2.2.0
 */
- (instancetype)initWithFrame:(CGRect)frame textFont:(UIFont *)textFont textColor:(UIColor *)textColor;

/**
 添加一个文字
 @param sticker 文字元素
 @since   v2.2.0
 */
- (void)appendText;

/**
 改变文字内容
 @param text 文字内容
 @since   v2.2.0
 */
- (void)changeText:(NSString *)text;

/**
 改变文字颜色
 @param textColor 文字颜色
 @since   v2.2.0
 */
- (void)changeTextColor:(UIColor *)textColor;

/**
 改变线条颜色
 @param strokeColor 线条颜色
 @since   v2.2.0
 */
- (void)changeStrokeColor:(UIColor *)strokeColor;

/**
 改变字体背景颜色
 @param textBackgroudColor 字体背景颜色
 @since   v2.2.0
 */
- (void)changeTextBackgroudColor:(UIColor *)textBackgroudColor;

/**
 改变书写方向 参考 NSWritingDirectionAttributeName
 @param writingDirection 书写方向
 @since   v2.2.0
 */
- (void)changeWritingDirection:(NSArray<NSNumber *> *)writingDirection;

/**
 改变文字对齐方式
 @param textAlignment 对齐方式
 @since   v2.2.0
 */
- (void)changeTextAlignment:(NSTextAlignment)textAlignment;

/**
 获取文字处理结果
 @param regionRect 图片选区范围
 @return 贴纸处理结果
 @since   v2.2.0
 */
- (NSArray *)resultsWithRegionRect:(CGRect)regionRect;

/**
 是否已经选中某一个文字
 @return YES：已经选中
 @since   v2.2.0
 */
- (BOOL)hasSelectedItem;

/**
 修改下划线状态
 @since   v2.2.0
 */
- (void)toggleUnderline;

/**
 删除添加的所有文字贴图
 @since   v2.2.0
 */
- (void)deletaAllTextItemViews;

/**
 取消选定状态
 @since   v2.2.0
 */
- (void)cancelAllSelected;

/**
 显示文字贴纸
 @param time 显示时间
 @since   v2.2.0
 */
- (void)disPlayTextItemViewAtTime:(CGFloat)time;

@end


#pragma mark - StickerTextItemViewDelegate

/**
 贴纸元件视图委托
 @since   v2.2.0
 */
@protocol StickerTextItemViewDelegate <NSObject>

/**
 贴纸元件关闭
 @param view 贴纸元件视图
 @since   v2.2.0
 */
- (void)onClosedTextItemView:(StickerTextItemView *)view;

/**
 选中贴纸元件
 @param view 贴纸元件视图
 @since   v2.2.0
 */
- (void)onSelectedTextItemView:(StickerTextItemView *)view;

@end




#pragma mark - StickerTextItemView

/**
 *  贴纸元件视图
 */
@interface StickerTextItemView : UIView
{
    
@protected
    // 图片视图
    TuSDKPFTextLabel *_textView;
    // 取消按钮
    UIButton *_cancelButton;
    // 旋转缩放按钮
    UIButton *_turnButton;
    // 宽度拉伸按钮
    UIButton *_stretchButton;
}


/**
 时间范围
 @since   v2.2.0
 */
@property (nonatomic) TuSDKTimeRange *timeRange;

/**
 图片视图
 @since   v2.2.0
 */
@property (nonatomic, readonly) UILabel *textView;

/**
 取消按钮
 @since   v2.2.0
 */
@property (nonatomic, readonly) UIButton *cancelButton;

/**
 旋转缩放按钮
 @since   v2.2.0
 */
@property (nonatomic, readonly) UIButton *turnButton;

/**
 宽度拉伸按钮
 @since   v2.2.0
 */
@property (nonatomic, readonly) UIButton *stretchButton;

/**
 贴纸元件视图委托
 @since   v2.2.0
 */
@property (nonatomic, weak) id<StickerTextItemViewDelegate> delegate;

/**
 最小缩小比例(默认: 0.5f <= mMinScale <= 1)
 @since   v2.2.0
 */
@property (nonatomic, assign) CGFloat minScale;

/**
 边框宽度
 @since   v2.2.0
 */
@property (nonatomic, assign) CGFloat textBorderWidth;

/**
 边框颜色
 @since   v2.2.0
 */
@property (nonatomic, retain) UIColor *textBorderColor;

/**
 文字颜色
 @since   v2.2.0
 */
@property (nonatomic, retain) UIColor *textColor;

/**
 选中状态
 @since   v2.2.0
 */
@property (nonatomic, assign) BOOL selected;

/**
 文字内容
 @since   v2.2.0
 */
@property (nonatomic, strong) NSString *textString;

/**
 贴纸数据对象
 @since   v2.2.0
 */
@property (nonatomic, retain) TuSDKPFSticker *textSticker;

/**
 文字样式信息设置
 @since   v2.2.0
 */
@property (nonatomic, strong) NSMutableParagraphStyle *textParaStyle;

/**
 是否显示下划线
 @since   v2.2.0
 */
@property (nonatomic, assign) BOOL enableUnderline;

/**
 书写方向 参考 NSWritingDirectionAttributeName
 @since   v2.2.0
 */
@property (nonatomic, strong) NSArray<NSNumber *> *writingDirection;

/**
 文字对齐方式
 @since   v2.2.0
 */
@property (nonatomic, assign) NSTextAlignment textAlignment;

/**
 文字背景色
 @since   v2.2.0
 */
@property (nonatomic, strong) UIColor *textBackgroudColor;

/**
 线条颜色
 @since   v2.2.0
 */
@property (nonatomic, strong) UIColor *textStrokeColor;

/**
 文字边距 默认 （0，0，0，0）
 @since   v2.2.0
 */
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;

/**
 文字最大放大倍数 (相对于父视图) 默认 1.0
 @since   v2.2.0
 */
@property (nonatomic, assign) CGFloat textMaxScale;

/**
 初始化字体信息
 @param textFont 字体
 @since   v2.2.0
 */
- (void)initWithTextFont:(UIFont *)textFont;

/**
 重置文字视图边缘距离
 @since   v2.2.0
 */
- (void)resetTextEdge;

/**
 获取贴纸处理结果
 @param regionRect 图片选区范围
 @return 贴纸处理结果
 @since   v2.2.0
 */
- (TuSDKPFStickerResult *)resultWithRegionRect:(CGRect)regionRect;

@end

#pragma mark - StickerTextEditorPanelDelegate

@protocol StickerTextEditorPanelDelegate <NSObject>

@optional

/**
 选中一个文字贴纸
 @param ediotrPanel 编辑器面板
 @param itemView StickerTextItemView
 @since   v2.2.0
 */
- (void)stickerTextEditorPanel:(StickerTextEditorPanel *)editorPanel didSelectedItemView:(StickerTextItemView *)itemView;

/**
 选中一个文字贴纸 触发编辑操作
 @param ediotrPanel 编辑器面板
 @param itemView StickerTextItemView
 @since   v2.2.0
 */
- (void)stickerTextEditorPanel:(StickerTextEditorPanel *)editorPanel editingItemView:(StickerTextItemView *)itemView;

/**
 是否取消全部选中
 @return YES 允许取消
 @since   v2.2.0
 */
- (BOOL)canCancelAllSelected;

/**
 删除选中的item
 @since   v2.2.0
 */
- (void)deleteSelectedItem;

@end
