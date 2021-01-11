//
//  ImageStickerEditorItem.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/4/22.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerEditor.h"

NS_ASSUME_NONNULL_BEGIN

/**
 图片贴纸Item，每个Item代表一个图片贴纸编辑项
 */
@interface ImageStickerEditorItem : UIView <StickerEditorItem>
{
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
 *  贴纸数据对象
 */
@property (nonatomic, retain) UIImage *sticker;

/**
 *  重置图片视图边缘距离
 */
- (void)resetImageEdge;

@end

NS_ASSUME_NONNULL_END
