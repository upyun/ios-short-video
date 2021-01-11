//
//  MovieEditViewController.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/23.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "EditComponentNavigator.h"

/**
 视频编辑根控制器
 */
@interface MovieEditViewController : BaseNavigationViewController<EditComponentNavigationProtocol>

/**
 视频编辑子控制器导航管理
 */
@property (nonatomic, strong) EditComponentNavigator *componentNavigator;

/**
 输入视频文件的 URL
 */
@property (nonatomic, copy) NSURL *inputURL;

@end
