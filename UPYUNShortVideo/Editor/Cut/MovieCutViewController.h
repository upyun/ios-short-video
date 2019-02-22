//
//  MovieCutViewController.h
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/20.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import <Photos/Photos.h>

/**
 视频时间裁剪
 */
@interface MovieCutViewController : BaseNavigationViewController

/**
选取的视频
 */
@property (nonatomic, strong) NSArray<AVURLAsset *> *inputAssets;

/**
 裁剪后的视频
 */
@property (nonatomic, strong) NSURL *outputURL;

@end
