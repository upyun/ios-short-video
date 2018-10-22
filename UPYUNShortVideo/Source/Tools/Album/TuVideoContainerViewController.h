//
//  TuVideoContainerViewController.h
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuVideoModel.h"

/**
 视频预览页面
 */
@interface TuVideoContainerViewController : UIViewController
// 视频选择回调
@property (copy, nonatomic) void(^didSelectedBlock)(TuVideoModel *selectedModel);
// 视频model对象
@property (strong, nonatomic) TuVideoModel *model;

@end

