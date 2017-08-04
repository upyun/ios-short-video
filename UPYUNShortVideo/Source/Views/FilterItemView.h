//
//  FilterItemView.h
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/11.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 点击事件的代理
 
 @param viewDescription 点击的basicView所对应的code(对于滤镜栏中即为filterCode)
 */

@protocol FilterItemViewClickDelegate <NSObject>

/**
 滤镜视图

 @param viewDescription 滤镜描述
 @param tag 滤镜的 tag 值
 */

- (void)clickBasicViewWith:(NSString *)viewDescription withBasicTag:(NSInteger)tag;

@end

/**
 滤镜的itemView，包括滤镜效果展示图以及滤镜名
 */
@interface FilterItemView : UIView

// 该对象所对应的code
@property (nonatomic,copy) NSString * viewDescription;
// 点击事件的代理
@property (nonatomic,assign) id<FilterItemViewClickDelegate> clickDelegate;

/**
 根据参数内容初始化控件
 
 @param imageName 图片名
 @param title title名
 @param fontSize 字号
 */
- (void)setViewInfoWith:(NSString *)imageName title:(NSString *)title  titleFontSize:(CGFloat)fontSize;

/**
 改变显示颜色 同时修改边框以及 字体栏

 @param color 展示颜色
 */
- (void)refreshClickColor:(UIColor*)color;


/**
 改变选中边框颜色
 
 @param color 展示颜色
 */
- (void)refreshSelectedBoundsColor:(UIColor *)color;

@end
