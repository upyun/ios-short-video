//
//  TuVideoModel.m
//  VideoAlbumDemo
//
//  Created by wen on 23/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import "TuVideoModel.h"

@implementation TuVideoModel

- (NSDictionary *)imageDic
{
    if (!_imageDic) {
        _imageDic = [[_asset defaultRepresentation] metadata];
    }
    return _imageDic;
}

- (NSString *)uti
{
    if (!_uti) {
        _uti = [[_asset defaultRepresentation] UTI];
    }
    return _uti;
}

- (NSURL *)url
{
    if (!_url) {
        _url = [[_asset defaultRepresentation] url];
    }
    return _url;
}

- (void)setAsset:(ALAsset *)asset
{
    _asset = asset;
    _url = [[_asset defaultRepresentation] url];
}

@end

