//
//  EditComponentNavigator.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

// 导航动画时长
static const NSTimeInterval kNavigationAnimationDuration = 0.25;

@protocol EditComponentNavigationProtocol, EditComponentNavigatorDelegate;

/**
 编辑页面中切换子页面的导航管理器
 内部管理的控制器都需遵循 EditComponentNavigationProtocol 协议
 */
@interface EditComponentNavigator : NSObject

/// 过渡中
@property (nonatomic, assign, readonly) BOOL transiting;

/// 根控制器
@property (nonatomic, weak, readonly) UIViewController<EditComponentNavigationProtocol> *rootViewController;

@property (nonatomic, weak) id<EditComponentNavigatorDelegate> delegate;

/// 通过根控制器初始化
- (instancetype)initWithRootViewController:(UIViewController<EditComponentNavigationProtocol> *)rootViewController;

/**
 压入子视图控制器为顶层视图控制器
 调用后，当前视图控制器会调用 `-actionBeforePushToViewController:` 方法

 @param viewController 即将作为顶层视图的控制器
 */
- (void)pushEditComponentViewController:(UIViewController<EditComponentNavigationProtocol> *)viewController;

/**
 弹出顶部视图控制器
 调用后，其弹栈后的顶层控制器会调用 `-actionAfterPopFromViewController:` 方法
 */
- (void)popEditComponentViewController;

@end


/**
 编辑模块导航器代理
 */
@protocol EditComponentNavigatorDelegate <NSObject>
@optional

/**
 顶部视图控制器更新回调

 @param navigator 页面导航管理器
 @param topViewController 顶层视图控制器
 */
- (void)navigator:(EditComponentNavigator *)navigator didChangeTopViewController:(UIViewController<EditComponentNavigationProtocol> *)topViewController;

@end


/**
 编辑模块页面协议
 */
@protocol EditComponentNavigationProtocol <NSObject>

/**
 页面导航管理器
 */
@property (nonatomic, strong) EditComponentNavigator *componentNavigator;

@optional

/**
 是否应显示播放按钮
 */
@property (nonatomic, assign, readonly) BOOL shouldShowPlayButton;

/**
 控制器调用 `-pushEditComponentViewController:` 后，跳转页面前的回调
 可在这里进行 UI 的更新

 @param controllerWillPushTo 即将跳转的控制器
 */
- (void)actionBeforePushToViewController:(UIViewController<EditComponentNavigationProtocol> *)controllerWillPushTo;

/**
 其他视图控制器 `-pushEditComponentViewController:`  弹栈后回到当前视图控制器时，调用当前控制器的该方法

 @param controllerDidPop 弹栈的视图控制
 */
- (void)actionAfterPopFromViewController:(UIViewController<EditComponentNavigationProtocol> *)controllerDidPop;

@end
