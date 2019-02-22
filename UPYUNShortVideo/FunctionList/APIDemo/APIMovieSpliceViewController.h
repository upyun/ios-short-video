//
//  APIMovieSpliceViewController.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/15.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseViewController.h"

/**
 多视频拼接
 */
@interface APIMovieSpliceViewController : BaseViewController

@property (nonatomic, strong) NSURL *firstInputURL;

@property (nonatomic, strong) NSURL *secondInputURL;

@end
