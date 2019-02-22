//
//  BaseEditComponentViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/27.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseEditComponentViewController.h"

@interface BaseEditComponentViewController ()

@property (nonatomic, strong) BottomNavigationBar *bottomNavigationBar;

@end

@implementation BaseEditComponentViewController

+ (CGFloat)bottomContentOffset {
    return 40;
}

+ (CGFloat)bottomPreviewOffset {
    return 196;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    _bottomNavigationBar = [[BottomNavigationBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_bottomNavigationBar];
    _bottomNavigationBar.backgroundColor = [UIColor blackColor];
    [_bottomNavigationBar.leftButton setImage:[UIImage imageNamed:@"edit_ic_close"] forState:UIControlStateNormal];
    [_bottomNavigationBar.rightButton setImage:[UIImage imageNamed:@"edit_ic_sure"] forState:UIControlStateNormal];
    [_bottomNavigationBar.leftButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomNavigationBar.rightButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    _bottomNavigationBar.title = title;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize size = self.view.bounds.size;
    CGFloat bottomBarHeight = [self.class bottomContentOffset];
    if (@available(iOS 11.0, *)) {
        bottomBarHeight += self.view.safeAreaInsets.bottom;
    }
    _bottomNavigationBar.frame = CGRectMake(0, size.height - bottomBarHeight, size.width, bottomBarHeight);
}

#pragma mark - action

- (void)cancelButtonAction:(UIButton *)sender {
    [self.componentNavigator popEditComponentViewController];
}

- (void)doneButtonAction:(UIButton *)sender {
    [self.componentNavigator popEditComponentViewController];
}

@end
