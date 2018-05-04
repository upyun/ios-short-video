//
//  TuAlbumViewController.h
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuAlbumModel.h"
#import "TuVideoModel.h"

#pragma mark - TuAlbumViewController

/**
 相册浏览页面
 */
@interface TuAlbumViewController : UIViewController
// 视频选择代理
@property (nonatomic, weak) id<TuVideoSelectedDelegate> selectedDelegate;
// 选中后是否进行预览
@property (assign, nonatomic) BOOL isPreviewVideo;

@end

#pragma mark - TuTableViewCell

/**
 相册浏览tableViewCell
 */
@interface TuTableViewCell : UITableViewCell
// 视频总数
@property (assign, nonatomic) NSInteger count;
// 封面图
@property (strong, nonatomic) UIImage *photoImg;
// 名称
@property (copy, nonatomic) NSString *photoName;
// 相册内容总数
@property (assign, nonatomic) NSInteger photoNum;
// model对象
@property (strong, nonatomic) TuAlbumModel *model;

@end

