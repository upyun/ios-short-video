//
//  TextItemTransformControl.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/6.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributedLabel.h"
#import "StickerEditor.h"

@protocol TextStickerEditorItemDelegate;

/**
 文字项变形控件
 */
@interface TextStickerEditorItem : UIControl <StickerEditorItem>

/**
 显示的文字标签
 */
@property (nonatomic, strong) AttributedLabel *textLabel;


/**
 最大缩放值， 默认是根据机型分辨率计算所支持的适合的缩放比
 过大会导致模糊，锯齿等
 */
@property (nonatomic, assign) CGFloat maxScale;

@property (nonatomic)id<TextStickerEditorItemDelegate> delegate;

/**
 通过内容大小更新布局

 @param contentSize 布局尺寸
 */
- (void)updateLayoutWithContentSize:(CGSize)contentSize;

@end

/**
 触发编辑
 */
@protocol TextStickerEditorItemDelegate <NSObject>

/**
 item 进入编辑状态

 @param item 问题贴纸 item
 */
-(void)shouldEditItem:(TextStickerEditorItem *)item;

@end
