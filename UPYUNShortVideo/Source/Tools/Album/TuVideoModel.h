//
//  TuVideoModel.h
//  VideoAlbumDemo
//
//  Created by wen on 23/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

/**
 视频信息类
 */
@interface TuVideoModel : NSObject

// 展示图
@property (strong, nonatomic) UIImage *image;
// asset对象
@property (strong, nonatomic) ALAsset *asset;
// 视频的时长
@property (copy, nonatomic) NSString *videoTime;
// 原数据
@property (strong, nonatomic) NSDictionary *imageDic;
// 图片的URL
@property (strong, nonatomic) NSURL *url;
// 图片的唯一标示符
@property (copy, nonatomic) NSString *uti;

@end

/**
 视频选择代理
 */
@protocol TuVideoSelectedDelegate <NSObject>

- (void)selectedModel:(TuVideoModel *)model;

@end

