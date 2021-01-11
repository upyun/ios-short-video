//
//  TextAlphaMenuView.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/6.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TextAlphaMenuView;

@protocol TextAlphaMenuViewDelegate <NSObject>

@optional

/**
 变更回调
 
 @param menu 菜单视图
 @param value 间距
 */
- (void)menu:(TextAlphaMenuView *)menu didChangeAlphavalue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TextAlphaMenuView : UIView

@property (nonatomic, weak) id<TextAlphaMenuViewDelegate> delegate;

@property (nonatomic)CGFloat alphaValue;

@end

NS_ASSUME_NONNULL_END
