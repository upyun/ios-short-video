//
//  TuAlbumModel.m
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import "TuAlbumModel.h"

@implementation TuAlbumModel

- (NSUInteger)photosNum
{
    if (_photosNum == 0) {
        _photosNum = [_group numberOfAssets];
    }
    return _photosNum;
}

- (NSString *)albumName
{
    if (!_albumName) {
        _albumName = [_group valueForProperty:ALAssetsGroupPropertyName];
        _albumName = NSLocalizedString(@"lsq_albumComponent_allOfVideo", @"所有视频");
    }
    return _albumName;
}

@end

