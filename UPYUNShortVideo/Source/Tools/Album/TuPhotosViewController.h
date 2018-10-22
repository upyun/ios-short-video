//
//  TuPhotosViewController.h
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuVideoModel.h"

/**
 相册内容预览页面
 */
@interface TuPhotosViewController : UIViewController

// 视频选择代理
@property (nonatomic, weak) id<TuVideoSelectedDelegate> selectedDelegate;
// 相册内容数组
@property (strong, nonatomic) NSMutableArray *allPhotosArray;
// 选中后是否进行预览
@property (assign, nonatomic) BOOL isPreviewVideo;

@end

