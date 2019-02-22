//
//  BaseNavigationViewController.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseNavigationViewController.h"

// 顶部导航条默认高度
static const CGFloat kDefaultTopNavigationBarHeight = 64.0;

@interface BaseNavigationViewController ()

@property (nonatomic, strong) TopNavigationBar *topNavigationBar;

@end

@implementation BaseNavigationViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _topContentOffset = kDefaultTopNavigationBarHeight;
    _topNavigationBar = [[TopNavigationBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_topNavigationBar];
    
    [_topNavigationBar.backButton addTarget:self action:@selector(base_backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topNavigationBar.rightButton addTarget:self action:@selector(base_rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize size = self.view.bounds.size;
    if (@available(iOS 11.0, *)) {
        _topContentOffset = self.view.safeAreaInsets.top + kDefaultTopNavigationBarHeight;
    }
    _topNavigationBar.frame = CGRectMake(0, 0, size.width, _topContentOffset);
}

- (void)base_backButtonAction:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)base_rightButtonAction:(UIButton *)sender {
    if (self.rightButtonActionHandler) self.rightButtonActionHandler(self, sender);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
