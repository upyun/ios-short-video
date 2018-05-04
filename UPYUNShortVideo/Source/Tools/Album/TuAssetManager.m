//
//  TuAssetManager.m
//  VideoAlbumDemo
//
//  Created by wen on 23/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import "TuAssetManager.h"
#import "TuAlbumModel.h"

@interface TuAssetManager ()
// library 对象
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
// 所有相册封面信息
@property (strong, nonatomic) NSMutableArray *allAlbumAy;
// 所有相册里的所有图片信息
@property (strong, nonatomic) NSMutableArray *allGroup;

@end

static TuAssetManager *sharedManager = nil;
static BOOL ifOne = YES;

@implementation TuAssetManager

#pragma mark - setter getter

// 是否重新加载图片
- (void)setIfRefresh:(BOOL)ifRefresh
{
    _ifRefresh = ifRefresh;
    
    ifOne = ifRefresh;
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

// 所有相册封面信息
- (NSMutableArray *)allAlbumAy
{
    if (!_allAlbumAy) {
        _allAlbumAy = [NSMutableArray array];
    }
    return _allAlbumAy;
}

// 所有相册里的所有图片信息
- (NSMutableArray *)allGroup
{
    if (!_allGroup) {
        _allGroup = [NSMutableArray array];
    }
    return _allGroup;
}

#pragma mark - init method

+ (instancetype)sharedManager
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

// 获取所有相册信息
- (void)getAllAlbumWithStart:(void (^)(void))start WithEnd:(void (^)(NSArray *, NSArray *))album WithFailure:(void (^)(NSError *))failure
{
    if (start) {
        start();
    }
    
    if (ifOne) {
        [self.allAlbumAy removeAllObjects];
        [self.allGroup removeAllObjects];
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                
                if ([group numberOfAssets] != 0) {
                    TuAlbumModel *album = [[TuAlbumModel alloc] init];
                    
                    album.coverImage = [UIImage imageWithCGImage:[group posterImage]];
                    
                    album.group = group;
                    [self.allAlbumAy addObject:album];
                    
                    NSMutableArray *ay = [NSMutableArray array];
                    
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        
                        if (result) {
                            TuVideoModel *model = [[TuVideoModel alloc] init];
                            NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                            model.videoTime = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                            
                            model.asset = result;
                            
                            [ay addObject:model];
                        }
                    }];
                    [self.allGroup addObject:ay];
                }
                
            }else {
                if (self.allAlbumAy.count > 0) {
                    if (album) {
                        album(self.allAlbumAy,self.allGroup);
                        ifOne = NO;
                    }
                }
            }
        } failureBlock:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }else {
        if (album) {
            album(self.allAlbumAy,self.allGroup);
        }
    }
}

// 获取视频的大小
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"00:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"00:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

@end
