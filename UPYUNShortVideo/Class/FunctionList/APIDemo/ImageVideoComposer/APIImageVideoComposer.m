//
//  APIImageVideoComposer.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/5/29.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "APIImageVideoComposer.h"
#import "TuSDKFramework.h"

#define kTransitionDuration .5

@interface APIImageVideoComposer()<TuSDKMediaMovieCompositionComposerDelegate>
{
    
    TuSDKMediaMutableVideoComposition *_mutableVideoComposition;
    TuSDKMediaMutableAudioComposition *_mutableAudioComposition;
    
    NSMutableArray<TuSDKMediaTransitionEffect *> *_effects;
}

@property (nonatomic, strong) TuSDKMediaMovieCompositionComposer *composer;

@end


@implementation APIImageVideoComposer

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _mutableVideoComposition = [[TuSDKMediaMutableVideoComposition alloc] init];
    _mutableAudioComposition = [[TuSDKMediaMutableAudioComposition alloc] init];
    _singleImageDuration = 2.0;
    _effects = [NSMutableArray array];
    
    TuSDKMediaCompositionVideoComposerSettings *settings = [[TuSDKMediaCompositionVideoComposerSettings alloc] init];
    settings.saveToAlbum = NO;
    // 设置水印，默认为空
//    settings.waterMarkImage = [UIImage imageNamed:@"sample_watermark.png"];
    // 设置水印图片的位置
//    settings.waterMarkPosition = lsqWaterMarkTopRight;
    // 输出格式大小
//    settings.outputSize = CGSizeMake(540, 960);
    // 适应画布大小
    //        settings.aspectOutputRatioInSideCanvas = NO;
    // 设置输出旋转
    // settings.outputTransform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
    
    _composer = [[TuSDKMediaMovieCompositionComposer alloc] initWithVideoComposition:self->_mutableVideoComposition audioComposition:self->_mutableAudioComposition composorSettings:settings];
    _composer.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundFromBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)enterBackgroundFromBack {
    [self cancelCompose];
}

- (void)setInputPHAssets:(NSArray<PHAsset *> *)inputPHAssets {
    _inputPHAssets = inputPHAssets;
}

- (void)startCompose {
    
    [self loadPhAssetsWithCompletion:^(BOOL result) {
        [self->_composer startExport];
    }];
    
}

- (void)cancelCompose {
    [_composer cancelExport];
}


/**
 加载 PHAssets
 */
- (void)loadPhAssetsWithCompletion:(void (^)(BOOL result))completion;{
    
    __block CMTime outputTime = kCMTimeZero;
    typeof(self)weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self requestAssetForIndex:0 completion:^(PHAsset *inputPhAsset, NSObject *returnValue) {
            
            if (inputPhAsset && returnValue) {
                
                switch (inputPhAsset.mediaType) {
                    case PHAssetMediaTypeVideo:
                    {
                        AVAsset *videoAsset = (AVAsset *)returnValue;
                        
                        TuSDKMediaVideoTrackComposition *videoComposition = [[TuSDKMediaVideoTrackComposition alloc] initWithVideoAsset:videoAsset];
                        [weakSelf->_mutableVideoComposition appendComposition:videoComposition];
                        
                        TuSDKMediaAudioTrackComposition *audioComposition = [[TuSDKMediaAudioTrackComposition alloc] initWithAudioAsset:videoAsset];
                        [weakSelf->_mutableAudioComposition appendComposition:audioComposition];
                        
                        outputTime = CMTimeAdd(outputTime, videoComposition.outputDuraiton);
                        
                    }
                        break;
                    case PHAssetMediaTypeImage:{
                        
                        TuSDKMediaImageComposition *imageComposition = [[TuSDKMediaImageComposition alloc] initWithImage:(UIImage *)returnValue];
                        imageComposition.maxOutputDuration = CMTimeMakeWithSeconds(weakSelf.singleImageDuration, NSEC_PER_SEC);
                        [weakSelf->_mutableVideoComposition appendComposition:imageComposition];
                        
                        // 第一张图片不加转场特效
                        if (weakSelf->_mutableVideoComposition.compositions.count > 1) {
                            
                            // 通过开始时间，拿到上一个图片的最后一帧数据给到转场特效中
                            TuSDKTimeRange *timeRange = [TuSDKTimeRange makeTimeRangeWithStartSeconds:((weakSelf->_mutableVideoComposition.compositions.count - 1) * weakSelf.singleImageDuration) - 1.0/30.0 endSeconds:(weakSelf->_mutableVideoComposition.compositions.count - 1) * weakSelf.singleImageDuration + kTransitionDuration - 1.0/30.0 ];
                            
                            TuSDKMediaTransitionEffect *effect = [[TuSDKMediaTransitionEffect alloc] initWithTransitionType:TuSDKMediaTransitionTypePullInRight atTimeRange:timeRange];
                            effect.interFrameAnim = YES;
                            effect.animationDuration = kTransitionDuration * 1000;
                            [weakSelf->_composer addMediaEffect:effect];
                        }
                        
                        
                        TuSDKMediaAudioMuteComposition *audioComposition = [[TuSDKMediaAudioMuteComposition alloc] init];
                        audioComposition.maxOutputDuration = imageComposition.maxOutputDuration;
                        [weakSelf->_mutableAudioComposition appendComposition:audioComposition];
                        
                        outputTime = CMTimeAdd(outputTime, imageComposition.outputDuraiton);
                    }
                        
                    default:
                        break;
                }
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(YES);
                    }
                });
                
            }
        }];
        
    });
}


/**
 请求指导所有的 PHAsset
 
 @param index 索引
 @param completion 完成后处理函数
 @return 请求结果
 */
- (BOOL)requestAssetForIndex:(NSUInteger)index completion:(void (^)(PHAsset *inputPhAsset, NSObject *returnValue))completion;{
    if (index > _inputPHAssets.count - 1) {
        completion(nil,nil);
        return NO;
    }
    
    PHAsset *phAsset = _inputPHAssets[index];
    
    [self requestAVAsset:phAsset completion:^(PHAsset *inputPhAsset, NSObject *returnValue) {
        
        completion(inputPhAsset,returnValue);
        
        [self requestAssetForIndex:index+1 completion:completion];
        
    }];
    
    return YES;
}

/**
 请求 PHAsset
 
 @param phAsset PHAsset 文件对象
 @param completion 完成后的操作
 */
- (void)requestAVAsset:(PHAsset *)phAsset completion:(void (^)(PHAsset *inputPhAsset, NSObject *returnValue))completion {
    
    if (phAsset.mediaType == PHAssetMediaTypeImage) {
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.synchronous = YES;
        // 配置请求
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            if (progress == 1.0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TuSDK shared].messageHub dismiss];
                });
            } else {
                [[TuSDK shared].messageHub showProgress:progress status:@"iCloud 同步中"];
            }
            
        };
        
        CGSize outputSize = [TuSDKMediaFormatAssistant safeVideoSize:CGSizeMake(phAsset.pixelWidth, phAsset.pixelWidth)];
        
        [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:outputSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (completion) completion(phAsset, result);
        }];
        
    }else{
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        // 配置请求
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            if (progress == 1.0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TuSDK shared].messageHub dismiss];
                });
            } else {
                [[TuSDK shared].messageHub showProgress:progress status:@"iCloud 同步中"];
            }
            
        };
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            
            if (completion) completion(phAsset, asset);
        }];
        
        
    }
}


#pragma mark - ComposerDelegate
/**
 合成器进度改变事件
 
 @param compositionComposer 合成器
 @param percent (0 - 1)
 @param outputTime 当前帧所在持续时间
 @since v3.4.1
 */
- (void)mediaMovieCompositionComposer:(TuSDKMediaMovieCompositionComposer *_Nonnull)compositionComposer progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime; {
    [[TuSDK shared].messageHub showProgress:percent status:@"正在生成视频..."];
    //    NSLog(@"progressChanged : %f",percent);
}

/**
 合成器状态改变事件
 
 @param compositionComposer  合成器
 @param status 当前播放器状态
 @since v3.4.1
 */
- (void)mediaMovieCompositionComposer:(TuSDKMediaMovieCompositionComposer *_Nonnull)compositionComposer statusChanged:(TuSDKMediaExportSessionStatus)status; {
    NSLog(@"statusChanged : %ld",status);
    switch (status) {
        case TuSDKMediaExportSessionStatusCancelled:
        case TuSDKMediaExportSessionStatusFailed:
            [[TuSDK shared].messageHub showError:@"生成失败"];
            break;
        case TuSDKMediaExportSessionStatusCompleted:
            [[TuSDK shared].messageHub dismiss];
            break;
            
        default:
            break;
    }
}

/**
 合成器合成完成事件
 
 @param compositionComposer  合成器
 @param result TuSDKVideoResult
 @param error 错误信息
 @since v3.4.1
 */
- (void)mediaMovieCompositionComposer:(TuSDKMediaMovieCompositionComposer *_Nonnull)compositionComposer result:(TuSDKVideoResult *_Nonnull)result error:(NSError *_Nonnull)error; {
    NSLog(@"result : %@ error : %@",result,error);
    [[TuSDK shared].messageHub dismiss];
    if (error) {
        [[TuSDK shared].messageHub showError:@"生成失败"];
    } else {
        if (result.videoAsset == nil) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:result.videoPath]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.composerCompleted) {
                    self.composerCompleted(asset);
                }
            });
            return;
        }
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        // 配置请求
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            if (progress == 1.0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TuSDK shared].messageHub dismiss];
                });
            } else {
                [[TuSDK shared].messageHub showProgress:progress status:@"iCloud 同步中"];
            }
        };
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:result.videoAsset.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.composerCompleted) {
                    self.composerCompleted((AVURLAsset *)asset);
                }
            });
        }];
        
    }
}

@end
