//
//  TextDirectionMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextMenuView.h"
#import "AttributedLabel.h"

/**
 文字排列方式
 */
typedef NS_ENUM(NSInteger, TextDirectionType) {
    // 从左到右排列
    TextDirectionTypeRight = 2,
    // 从右到左排列
    TextDirectionTypeLeft = 3
};

@class TextDirectionMenuView;

@protocol TextDirectionMenuViewDelegate <NSObject>
@optional

/**
 样式变更回调

 @param menu 菜单视图
 @param directionType 排列方式
 */
- (void)menu:(TextDirectionMenuView *)menu didChangeDirectionType:(TextDirectionType)directionType;

@end

/**
 文字样式视图
 */
@interface TextDirectionMenuView : TextMenuView

@property (nonatomic, weak) id<TextDirectionMenuViewDelegate> delegate;

/**
 文字方向
 */
@property (nonatomic) TextDirectionType directionType;

- (void)updateByAttributeLabel:(AttributedLabel *)label;
@end
