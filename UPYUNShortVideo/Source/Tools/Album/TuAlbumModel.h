//
//  TuAlbumModel.h
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TuAlbumModel : NSObject

// 封面图
@property (strong, nonatomic) UIImage *coverImage;
// 相册名称
@property (copy, nonatomic) NSString *albumName;
// 相册内容数量
@property (assign, nonatomic) NSUInteger photosNum;
// group对象
@property (strong, nonatomic) ALAssetsGroup *group;

@end

