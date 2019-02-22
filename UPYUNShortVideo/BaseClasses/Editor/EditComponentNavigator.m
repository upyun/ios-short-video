//
//  EditComponentNavigator.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditComponentNavigator.h"

@interface EditComponentNavigator ()

/**
 视图控制器栈
 */
@property (nonatomic, strong) NSMutableArray<UIViewController<EditComponentNavigationProtocol> *> *viewControllers;

/**
 根视图控制器
 */
@property (nonatomic, weak) UIViewController<EditComponentNavigationProtocol> *rootViewController;

@end

@implementation EditComponentNavigator

- (instancetype)initWithRootViewController:(UIViewController<EditComponentNavigationProtocol> *)rootViewController {
    if (self = [super init]) {
        _rootViewController = rootViewController;
        _viewControllers = [NSMutableArray array];
    }
    return self;
}

- (void)pushEditComponentViewController:(UIViewController<EditComponentNavigationProtocol> *)viewController {
    // 若在跳转过渡中，则跳过
    if (_transiting) return;
    // 标记为跳转中
    _transiting = YES;
    
    // 当前的顶层控制器调用 `-actionBeforePushToViewController:`
    if ([[self lastViewController] respondsToSelector:@selector(actionBeforePushToViewController:)]) {
        [[self lastViewController] actionBeforePushToViewController:viewController];
    }
    
    // 添加子控制器
    [self.viewControllers addObject:viewController];
    [self.rootViewController addChildViewController:viewController];
    viewController.componentNavigator = self;
    
    // 更新布局
    CGRect viewControllerFrame = self.rootViewController.view.frame;
    viewControllerFrame.origin.y = viewControllerFrame.size.height;
    viewController.view.frame = viewControllerFrame;
    [self.rootViewController.view addSubview:viewController.view];
    
    // 回调 `-navigator:didChangeTopViewController:`
    if ([self.delegate respondsToSelector:@selector(navigator:didChangeTopViewController:)]) {
        [self.delegate navigator:self didChangeTopViewController:viewController];
    }
    
    // 动画过渡
    [UIView animateWithDuration:kNavigationAnimationDuration animations:^{
        viewController.view.frame = self.rootViewController.view.frame;
    } completion:^(BOOL finished) {
        [viewController didMoveToParentViewController:self.rootViewController];
        // 标记结束跳转过渡
        self->_transiting = NO;
    }];
}

- (void)popEditComponentViewController {
    // 若在跳转过渡中，则跳过
    if (_transiting) return;
    // 标记跳转中
    _transiting = YES;
    
    // 移除控制器页面
    UIViewController<EditComponentNavigationProtocol> *viewController = [self lastViewController];
    [self.viewControllers removeLastObject];
    [viewController willMoveToParentViewController:nil];
    
    // 更新布局
    CGRect viewControllerFrame = viewController.view.frame;
    viewControllerFrame.origin.y = viewControllerFrame.size.height;
    [UIView animateWithDuration:kNavigationAnimationDuration animations:^{
        viewController.view.frame = viewControllerFrame;
    } completion:^(BOOL finished) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        // 标记结束跳转过渡
        self->_transiting = NO;
        
        // 回调 `-navigator:didChangeTopViewController:`
        if ([self.delegate respondsToSelector:@selector(navigator:didChangeTopViewController:)]) {
            [self.delegate navigator:self didChangeTopViewController:[self lastViewController]];
        }
    }];
    
    // 弹栈后的顶层视图控制器调用 `-actionAfterPopFromViewController:`
    if ([[self lastViewController] respondsToSelector:@selector(actionAfterPopFromViewController:)]) {
        [[self lastViewController] actionAfterPopFromViewController:viewController];
    }
}

#pragma mark - private

/**
 获取视图控制器栈中最后一个控制器
 */
- (UIViewController<EditComponentNavigationProtocol> *)lastViewController {
    if (_viewControllers.count) {
        return _viewControllers.lastObject;
    } else {
        return _rootViewController;
    }
}

@end
