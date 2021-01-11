//
//  EditEffectViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/29.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "EditEffectViewController.h"
#import "PageTabbar.h"

#import "SceneEffectViewController.h"
#import "TimeEffectViewController.h"
#import "ParticleEffectViewController.h"

@interface EditEffectViewController ()<PageTabbarDelegate>

/**
 选中项索引
 */
@property (nonatomic, assign, readonly) NSInteger selectedIndex;

/**
 当前选中的子页面
 */
@property (nonatomic, weak) BaseEditComponentViewController *currentChildViewController;

/**
 子页面缓存
 */
@property (nonatomic, strong) NSMutableDictionary *childViewControllerCache;

/**
 承载子页面的视图
 */
@property (nonatomic, strong) UIView *childControllerView;

/**
 切换过渡中
 */
@property (nonatomic, assign) BOOL transiting;

@end

@implementation EditEffectViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复到首帧
    [self.movieEditor seekToTime:kCMTimeZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    // 配置承载子页面视图
    _childControllerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:_childControllerView atIndex:0];
    _childControllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
    
    // 配置底部标签栏
    PageTabbar *tabbar = [[PageTabbar alloc] initWithFrame:CGRectZero];
    tabbar.itemTitles = @[NSLocalizedStringFromTable(@"tu_场景", @"VideoDemo", @"场景"), NSLocalizedStringFromTable(@"tu_时间", @"VideoDemo", @"时间"), NSLocalizedStringFromTable(@"tu_魔法", @"VideoDemo", @"魔法")];
    tabbar.trackerSize = CGSizeMake(48, 2);
    tabbar.itemsSpacing = 52;
    tabbar.itemSelectedColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    tabbar.itemNormalColor = [UIColor whiteColor];
    tabbar.selectedIndex = 0;
    self.bottomNavigationBar.titleView = tabbar;
    [tabbar addTarget:self action:@selector(tabbarSelectedIndexChangeAction:) forControlEvents:UIControlEventValueChanged];
    tabbar.delegate = self;
    
    // 配置初始选的子页面
    BaseEditComponentViewController *viewController = [self subViewControllerWithIndex:tabbar.selectedIndex];
    [self setupEditComponentViewController:viewController];
    [self showSubViewController:viewController];
    self.currentChildViewController = viewController;
}

/**
 同步自身信息到子页面控制器
 
 @param editComponentViewController 子页面控制器
 */
- (void)setupEditComponentViewController:(BaseEditComponentViewController *)editComponentViewController {
    
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
    
    editComponentViewController.movieEditor = self.movieEditor;
    editComponentViewController.thumbnails = self.thumbnails;
    editComponentViewController.playbackProgress = self.playbackProgress;
    editComponentViewController.playing = self.playing;
}

#pragma mark - property

- (NSInteger)selectedIndex {
    PageTabbar *tabbar = (PageTabbar *)self.bottomNavigationBar.titleView;
    return tabbar.selectedIndex;
}

- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];
    _currentChildViewController.playbackProgress = playbackProgress;
}

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    _currentChildViewController.playing = playing;
}

- (void)setThumbnails:(NSArray<UIImage *> *)thumbnails {
    [super setThumbnails:thumbnails];
    _currentChildViewController.thumbnails = thumbnails;
}

#pragma mark - action

/**
 标签栏选中索引变更回调

 @param sender 标签栏对象
 */
- (void)tabbarSelectedIndexChangeAction:(PageTabbar *)sender {}

/**
 完成按钮事件

 @param sender 点击的按钮
 */
- (void)doneButtonAction:(UIButton *)sender {
    [super doneButtonAction:sender];
    for (BaseEditComponentViewController *childController in _childViewControllerCache.allValues) {
        [childController doneButtonAction:sender];
    }
}

/**
 取消按钮事件

 @param sender 点击的按钮
 */
- (void)cancelButtonAction:(UIButton *)sender {
    [super cancelButtonAction:sender];
    for (BaseEditComponentViewController *childController in _childViewControllerCache.allValues) {
        [childController cancelButtonAction:sender];
    }
}

#pragma mark - PageTabbarDelegate

/**
 标签栏选中回调
 
 @param tabbar 标签栏对象
 @param fromIndex 起始索引
 @param toIndex 目标索引
 */
- (void)tabbar:(PageTabbar *)tabbar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self switchFromIndex:fromIndex toIndex:toIndex animated:YES];
}

/**
 起始的标签项是否可切换到目标标签项
 
 @param tabbar 标签栏对象
 @param fromIndex 起始索引
 @param toIndex 目标索引
 @return 是否可切换
 */
- (BOOL)tabbar:(PageTabbar *)tabbar canSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    return !_transiting;
}

#pragma mark - data source

/**
 获取给定索引的子页面

 @param index 页面索引
 @return 子页面
 */
- (BaseEditComponentViewController *)subViewControllerWithIndex:(NSInteger)index {
    if (!_childViewControllerCache) _childViewControllerCache = [NSMutableDictionary dictionary];
    switch (index) {
        case 0:{
            // 场景特效页面
            SceneEffectViewController *viewController = _childViewControllerCache[@0];
            if (!viewController) {
                viewController = [[SceneEffectViewController alloc] initWithNibName:nil bundle:nil];
                _childViewControllerCache[@0] = viewController;
            }
            return viewController;
        } break;
        case 1:{
            // 时间特效页面
            TimeEffectViewController *viewController = _childViewControllerCache[@1];
            if (!viewController) {
                viewController = [[TimeEffectViewController alloc] initWithNibName:nil bundle:nil];
                _childViewControllerCache[@1] = viewController;
            }
            return viewController;
        } break;
        case 2:{
            // 模仿特效页面
            ParticleEffectViewController *viewController = _childViewControllerCache[@2];
            if (!viewController) {
                viewController = [[ParticleEffectViewController alloc] initWithNibName:nil bundle:nil];
                _childViewControllerCache[@2] = viewController;
            }
            return viewController;
        } break;
        default:{} break;
    }
    return nil;
}

#pragma mark - container view controller

/**
 切换当前选中的子页面

 @param fromIndex 起始索引
 @param toIndex 目标索引
 @param animated 是否动画切换
 */
- (void)switchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    if (fromIndex == toIndex) return;
    
    BaseEditComponentViewController *toViewController = [self subViewControllerWithIndex:toIndex];
    [self setupEditComponentViewController:toViewController];
    
    // 非动画切换
    if (!animated) {
        [self hideSubViewController:_currentChildViewController];
        [self showSubViewController:toViewController];
        self.currentChildViewController = (BaseEditComponentViewController *)toViewController;
        return;
    }
    
    // 标记起始子控制器即将移除
    [_currentChildViewController willMoveToParentViewController:nil];
    // 添加目标子控制器
    [self addChildViewController:toViewController];

    // 计算起始布局页面的布局以及目标页面的布局
    CGRect currentFrame = _childControllerView.bounds;
    CGRect leftFrame = currentFrame;
    leftFrame.origin.x -= leftFrame.size.width;
    CGRect rightFrame = currentFrame;
    rightFrame.origin.x += rightFrame.size.width;
    
    CGRect startSwitchingFrame;
    CGRect endSwitchingFrame;
    if (toIndex > fromIndex) {
        startSwitchingFrame = rightFrame;
        endSwitchingFrame = leftFrame;
    } else {
        startSwitchingFrame = leftFrame;
        endSwitchingFrame = rightFrame;
    }

    toViewController.view.frame = startSwitchingFrame;
    
    // 动画切换
    self.transiting = YES;
    [self transitionFromViewController:_currentChildViewController toViewController:toViewController duration:kPageSwitchAnimationDuration options:0 animations:^{
        toViewController.view.frame = currentFrame;
        self.currentChildViewController.view.frame = endSwitchingFrame;
    } completion:^(BOOL finished) {
        // 标记目标控制器已经添加到父视图
        [toViewController didMoveToParentViewController:self];
        // 移除初始控制器视图
        [self.currentChildViewController.view removeFromSuperview];
        // 移除初始控制器父子关系
        [self.currentChildViewController removeFromParentViewController];
        // 更新状态
        self.currentChildViewController = (BaseEditComponentViewController *)toViewController;
        self.transiting = NO;
        [self setupEditComponentViewController:toViewController];
    }];
}

/**
 添加子页面

 @param viewController 子页面控制器
 */
- (void)showSubViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    viewController.view.frame = _childControllerView.bounds;
    [_childControllerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

/**
 移除子页面

 @param viewController 子页面控制器
 */
- (void)hideSubViewController:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

@end
