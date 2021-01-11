//
//  TextAlignmentMenuView.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/9.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "TextMenuView.h"

@class TextAlignmentMenuView;

@protocol TextAlignmentMenuViewDelegate <NSObject>
@optional

/**
 文字样式变更回调

 @param menu 文字菜单视图
 @param alignment 文字样式
 */
- (void)menu:(TextAlignmentMenuView *)menu didChangeAlignment:(NSTextAlignment)alignment;

@end

/**
 文字样式视图
 */
@interface TextAlignmentMenuView : TextMenuView

@property (nonatomic, weak) id<TextAlignmentMenuViewDelegate> delegate;

@property (nonatomic) NSTextAlignment alignment;

@end
