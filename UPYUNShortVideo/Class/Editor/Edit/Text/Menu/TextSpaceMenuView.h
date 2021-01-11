//
//  TextSpaceMenuView.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/6.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TextSpaceMenuView;

/**
 文字颜色位置
 */
typedef NS_ENUM(NSInteger, TextSpaceType) {
    // 字间距
    TextSpaceTypeWord = 0,
    // 行间距
    TextSpaceTypeLine,
};

@protocol TextSpaceMenuViewDelegate <NSObject>

@optional


/**
 间距变更回调
 
 @param menu 菜单视图
 @param space 间距
 @param type 设置的间距类型
 */
- (void)menu:(TextSpaceMenuView *_Nullable)menu didChangeSpace:(CGFloat)space forType:(TextSpaceType)type;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TextSpaceMenuView : UIView

@property (nonatomic, weak) id<TextSpaceMenuViewDelegate> delegate;

/**
 设置值

 @param value 当前值
 @param spaceType 类型
 */
- (void)setValue:(CGFloat)value spaceType:(TextSpaceType)spaceType;

@end

NS_ASSUME_NONNULL_END
