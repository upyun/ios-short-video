//
//  EditStickerView.h
//  TuSDK
//
//

#import "TuSDKFramework.h"

@class EditStickerViewItemView;
@class EditStickerView;

/**
 *  贴纸元件视图委托
 */
@protocol EditStickerItemViewDelegate <NSObject>
/**
 *  贴纸元件关闭
 *
 *  @param view 贴纸元件视图
 */
- (void)onClosedStickerItemView:(EditStickerViewItemView *)view;

/**
 *  选中贴纸元件
 *
 *  @param view 贴纸元件视图
 */
- (void)onSelectedStickerItemView:(EditStickerViewItemView *)view;

/**
 *  选中贴纸元件被取消选择
 *
 *  @param view 贴纸元件视图
 */
- (void)onDidCancelSelecteStickerItemView:(EditStickerViewItemView *)view;
@end

#pragma mark - TuSDKPFStickerItemView
/**
 *  贴纸元件视图
 */
@interface EditStickerViewItemView : UIView {
    @protected
    // 图片视图
    UIImageView *_imageView;
    // 取消按钮
    UIButton *_cancelButton;
    // 旋转缩放按钮
    UIButton *_turnButton;
}
/**
 *  图片视图
 */
@property (nonatomic, readonly) UIImageView *imageView;
/**
 *  取消按钮
 */
@property (nonatomic, readonly) UIButton *cancelButton;
/**
 *  旋转缩放按钮
 */
@property (nonatomic, readonly) UIButton *turnButton;

/**
 *  贴纸元件视图委托
 */
@property (nonatomic, weak) id<EditStickerItemViewDelegate> delegate;

@property (nonatomic,readonly) TuSDKMediaStickerImageEffect *stickerImageEffect;


/**
 *  最小缩小比例(默认: 0.5f <= mMinScale <= 1)
 */
@property (nonatomic) CGFloat minScale;

/**
 *  边框宽度
 */
@property (nonatomic) CGFloat strokeWidth;

/**
 *  边框颜色
 */
@property (nonatomic, retain) UIColor *strokeColor;

/**
 *  选中状态
 */
@property (nonatomic) BOOL selected;

@property (nonatomic) NSUInteger index;

/**
 *  贴纸数据对象
 */
@property (nonatomic, retain) UIImage *sticker;

/**
 *  重置图片视图边缘距离
 */
- (void)resetImageEdge;

/**
 *  获取贴纸处理结果
 *
 *  @param regionRect 图片选区范围
 *
 *  @return 贴纸处理结果
 */
- (TuSDKMediaStickerImageEffect *)resultWithRegionRect:(CGRect)regionRect;
@end

#pragma mark - TuSDKPFStickerView

/**
 *  贴纸视图委托
 */
@protocol EditStickerViewDelegate <EditStickerItemViewDelegate>

@end

/**
 *  贴纸视图
 */
@interface EditStickerView : UIView<EditStickerItemViewDelegate>
/**
 *  贴纸视图委托
 */
@property (nonatomic, weak) id<EditStickerViewDelegate> delegate;

/**
 *  当前已使用贴纸总数
 */
@property (nonatomic, readonly) NSUInteger stickerCount;

- (void)selectStickerWithIndex:(NSUInteger)index;

// 取消所有贴纸选中状态
- (void)cancelAllSelected;

/**
 添加贴纸特效
 @param stickerImageEffect 贴纸特效
 */
- (void)appendStickerImageEffect:(TuSDKMediaStickerImageEffect *)stickerImageEffect autoSelect:(BOOL)select;

/**
 *  获取贴纸处理结果
 *
 *  @param regionRect 图片选区范围
 *
 *  @return 贴纸处理结果
 */
- (NSArray<TuSDKMediaStickerImageEffect *> *)resultsWithRegionRect:(CGRect)regionRect;


- (void)showStickerItemAtTime:(CMTime)time animated:(BOOL)animated;

@end
