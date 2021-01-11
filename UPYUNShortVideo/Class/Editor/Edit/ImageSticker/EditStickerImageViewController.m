//
//  EditTileStickerViewController.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/5.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "EditStickerImageViewController.h"
#import "ScrollVideoTrimmerView.h"
#import "StickerImageListView.h"
#import "EditStickerView.h"
#import "StickerEditor.h"

#import "TextStickerEditorItem.h"
#import "ImageStickerEditorItem.h"

// 贴纸最小时长
static const NSTimeInterval kStickerImageEffectMinDuration = 1.0;


#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wprotocol"
@interface EditStickerImageViewController ()
<
TileStickerListViewDelegate ,
EditStickerViewDelegate,
ScrollVideoTrimmerViewDelegate,
StickerEditorDelegate
>

/**
 时间修整控件
 */
@property (weak, nonatomic) IBOutlet ScrollVideoTrimmerView *trimmerView;

/**
 播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playButton;

/**
 贴纸 列表
 */
@property (weak, nonatomic) IBOutlet StickerImageListView *stickerLitView;

/**
 贴纸编辑视图
 */
@property (nonatomic)  StickerEditor *stickerEditor;

/**
 MV 时间范围，设置时也设置了 `currentMvEffect` 的时间范围
 */
@property (nonatomic, strong) TuSDKTimeRange *effectTimeRange;

/**
 当前操作的 MV 效果
 */
@property (nonatomic, strong) TuSDKMediaStickerImageEffect *currentMvEffect;

@property (nonatomic)BOOL viewDidLayout;

@end

@implementation EditStickerImageViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复到首帧
    [self.movieEditor seekToTime:kCMTimeZero];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.playbackProgress = CMTimeGetSeconds(self.movieEditor.outputTimeAtSlice) / CMTimeGetSeconds(self.movieEditor.inputDuration);
}

-(void)viewDidLayoutSubviews;{
    [super viewDidLayoutSubviews];
    if (!_viewDidLayout){
        [self setupUI];
        _viewDidLayout = YES;
    }
    
    // 获取视频在屏幕中的大小，应用到贴纸编辑区域的布局
    CGRect bounds = self.movieEditor.holderView.bounds;
    TuSDKVideoTrackInfo *trackInfo = self.movieEditor.inputAssetInfo.videoInfo.videoTrackInfoArray.firstObject;
    CGSize videoSize = trackInfo.presentSize;
    bounds.origin = CGPointMake(0, self.movieEditor.holderView.superview.frame.origin.y);
    /** 计算视频绘制区域 */
    if (self.movieEditor.options.outputSizeOptions.aspectOutputRatioInSideCanvas) {
        // 根据用户设置的比例计算
        CGRect outputRect = AVMakeRectWithAspectRatioInsideRect(self.movieEditor.options.outputSizeOptions.outputSize, bounds);
        _stickerEditor.contentView.frame = outputRect;
    }else {
        _stickerEditor.contentView.frame = AVMakeRectWithAspectRatioInsideRect(videoSize, bounds);
    }
}

- (void)setupUI {
    self.title = NSLocalizedStringFromTable(@"tu_贴纸", @"VideoDemo", @"贴纸");
    
    _trimmerView.trimmerMaskView.hidden = YES;
    // 配置最小选取时长
    _trimmerView.minIntervalProgress = kStickerImageEffectMinDuration / CMTimeGetSeconds(self.movieEditor.inputDuration);
    // 时间轴展示缩略图
    _trimmerView.thumbnailsView.thumbnails = self.thumbnails;
    _playButton.selected = self.movieEditor.isPreviewing;
    
    
    /** 初始化 StickerEditor 用于编辑图片贴纸 */
    _stickerEditor = [[StickerEditor alloc] initWithHolderView:self.view];
    _stickerEditor.delegate = self;
    
    /**
     由于 StickerEditor 和  MovieEditor 的特效不能同时显示，也为了保证图片贴纸和文字贴纸的编辑顺序，并在 UI 上有层级关系，这里统一将 TuSDKMediaEffectDataTypeStickerText 与 TuSDKMediaEffectDataTypeStickerImage 添加至 StickerEditor，点击保存时通过 StickerEditor 获取编辑后的特效并添加至 MovieEditor。
     */
    NSMutableArray<id<TuSDKMediaEffect>> *initialEffects = [NSMutableArray array];
    self.initialEffects = initialEffects;
    __weak typeof(self)weakSelf = self;
    [[self.movieEditor allMediaEffects] enumerateObjectsUsingBlock:^(id<TuSDKMediaEffect> _Nonnull effect, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (effect.effectType) {
            case TuSDKMediaEffectDataTypeStickerText:{
                TextStickerEditorItem *item = [[TextStickerEditorItem alloc] initWithEditor:weakSelf.stickerEditor];
                item.editable = NO;
                item.tag  = -1;
                item.effect = effect;
                [weakSelf.stickerEditor addItem:item];
                [initialEffects addObject:effect];
                break;
            }
            case TuSDKMediaEffectDataTypeStickerImage: {
                /** appendStickerImageEffect 显示时 需要依赖 _stickerViewEditor 的 frame  */
                ImageStickerEditorItem *item = [[ImageStickerEditorItem alloc] initWithEditor:weakSelf.stickerEditor];
                item.tag  = idx;
                item.effect = effect;
                [weakSelf.stickerEditor addItem:item];
                [initialEffects addObject:effect];
                break;
            }
            default:
                break;
        }
    }];
    
    // 显示指定时间内的贴纸
    [_stickerEditor showItemByTime:kCMTimeZero];
    
    /** 移除 MovieEditor 中的特效，因为已添加至 _stickerEditor */
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerImage];
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerText];

    [self.movieEditor pausePreView];
    [self.movieEditor seekToTime:kCMTimeZero];

}

/**
 更新当前播放进度

 @param playbackProgress 当前播放进度
 */
- (void)setPlaybackProgress:(double)playbackProgress {
    [super setPlaybackProgress:playbackProgress];
    
    _trimmerView.currentProgress = playbackProgress;
    // 跳过时间轴最后一次跳转
    if (!_trimmerView.dragging && self.movieEditor.isPreviewing)
        [_stickerEditor showItemByTime:self.movieEditor.outputTimeAtSlice];
}

/**
 取消按钮事件
 
 @param sender 取消按钮
 */
- (void)cancelButtonAction:(UIButton *)sender {
    [super cancelButtonAction:sender];
    // 恢复先前记录的状态
    [self.movieEditor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeStickerImage];
    for (id<TuSDKMediaEffect> initialEffect in self.initialEffects) {
        [self.movieEditor addMediaEffect:initialEffect];
    }
  
}

/**
 完成按钮事件
 
 @param sender 完成按钮
 */
- (void)doneButtonAction:(UIButton *)sender {
    [super doneButtonAction:sender];

    NSArray<id<TuSDKMediaEffect>> *effects = [_stickerEditor resultsWithRegionRect:_stickerEditor.contentView.bounds];
    
    /** 将所有贴纸特效添加至 MovieEditor */
    [effects enumerateObjectsUsingBlock:^(id<TuSDKMediaEffect> _Nonnull effect, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.movieEditor addMediaEffect:effect];
    }];
}

/**
 播放按钮事件
 
 @param sender 播放按钮
 */
- (IBAction)playButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (self.trimmerView.currentProgress >= 1.0) {
            [self.movieEditor seekToTime:kCMTimeZero];
        }
        [self.movieEditor startPreview];
    } else {
        [self.movieEditor pausePreView];
    }
}

- (void)setPlaying:(BOOL)playing {
    [super setPlaying:playing];
    self.playButton.selected = playing;
    
    [_stickerEditor cancelSelectedAllItems];
   [_trimmerView setSelectedTimeRange:kCMTimeRangeZero atDuration:kCMTimeZero];
}

/**
 时间轴进度更新回调
 
 @param trimmer 时间轴
 @param progress 时间进度
 @param location 时间轴标记
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer updateProgress:(double)progress atLocation:(TrimmerTimeLocation)location {
    NSTimeInterval duration = CMTimeGetSeconds(self.movieEditor.inputDuration);
    NSTimeInterval targetTime = duration * progress;
    [self.movieEditor seekToInputTime:CMTimeMakeWithSeconds(targetTime, self.movieEditor.inputDuration.timescale)];
  
    switch (location) {
            // 左滑块修整时间
        case TrimmerTimeLocationLeft:
            // 右滑块修整时间
        case TrimmerTimeLocationRight:{
            CMTimeRange range =   [_trimmerView selectedTimeRangeAtDuration:self.movieEditor.inputDuration];
            _currentMvEffect.atTimeRange =  [TuSDKTimeRange makeTimeRangeWithStart:range.start duration:range.duration];
            
        } break;
            // 当前游标修整时间
        case TrimmerTimeLocationCurrent:{
            [_stickerEditor showItemByTime:self.movieEditor.outputTimeAtSlice];
        } break;
        default:{} break;
    }
}

/**
 标记选中回调
 
 @param trimmer 时间轴
 @param markIndex 选中遮罩的索引
 */
- (void)trimmer:(ScrollVideoTrimmerView *)trimmer didSelectMarkWithIndex:(NSUInteger)markIndex;
{
    [_stickerEditor selectWithIndex:markIndex];
}

/**
 时间轴到达临界值回调
 
 @param trimmer 时间轴
 @param reachMaxIntervalProgress 时间轴最大进度
 @param reachMinIntervalProgress 时间轴最小进度
 */
- (void)trimmer:(id<VideoTrimmerViewProtocol>)trimmer reachMaxIntervalProgress:(BOOL)reachMaxIntervalProgress reachMinIntervalProgress:(BOOL)reachMinIntervalProgress {
    if (reachMinIntervalProgress) {
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"tu_特效时长最少%@秒", @"VideoDemo", @"特效时长最少%@秒"), @(kStickerImageEffectMinDuration)];
        [[TuSDK shared].messageHub showToast:message];
    }
}

@end

#pragma Mark - TileStickerListViewDelegate

@implementation EditStickerImageViewController ( TileStickerListViewDelegate )

- (void)tileStickerListView:(StickerImageListView *)stickerListView didSelectedItemView:(StickerImageItemView *)itemView {

    CMTime duration = self.movieEditor.inputDuration;
    // 设置默认的时间范围
    CMTime startTime = self.movieEditor.outputTimeAtSlice;
    NSTimeInterval durationInterval = CMTimeGetSeconds(duration);
    if (durationInterval - CMTimeGetSeconds(startTime) < kStickerImageEffectMinDuration) {
        startTime = CMTimeMakeWithSeconds(durationInterval - kStickerImageEffectMinDuration, duration.timescale);
    }
    
    if (CMTimeGetSeconds(startTime) < 0) {
        startTime = kCMTimeZero;
    }
    
    /** 为 itemView.stickerimage 生成一个贴纸特效 */
    TuSDKMediaStickerImageEffect *stickerImageEffect = [[TuSDKMediaStickerImageEffect alloc] initWithStickerImage:[[TuSDK2DImageSticker alloc] initWithStickerImage:itemView.stickerimage] atTimeRange:[TuSDKTimeRange makeTimeRangeWithStart:startTime duration:CMTimeMakeWithSeconds(kStickerImageEffectMinDuration, duration.timescale)]];

    
    /** 将贴纸特效在 stickerView 中显示 */
    ImageStickerEditorItem *item = [[ImageStickerEditorItem alloc] initWithEditor:_stickerEditor];
    item.effect = stickerImageEffect;
    [_stickerEditor addItem:item];
    [_stickerEditor cancelSelectedAllItems];
    item.selected = YES;
}


@end

#pragma mark - StickerEditorDelegate

@implementation EditStickerImageViewController (StickerEditorDelegate)


-(void)resetItemsTag;{
    __block NSUInteger count = 0;
    [[_stickerEditor items] enumerateObjectsUsingBlock:^(UIView<StickerEditorItem> * _Nonnull eachItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([eachItem isKindOfClass:[ImageStickerEditorItem class]]) {
            eachItem.tag = count;
            count ++;
        }
    }];
}

/**
 一个贴纸项被添加
 
 @param editor 视频编辑器
 @param item 贴纸项
 */
- (void)imageStickerEditor:(StickerEditor *)editor didAddItem:(UIView<StickerEditorItem> *)item;{
    if (!item.editable) return;
    
    // 添加颜色条
    [_trimmerView addMarkWithColor:[UIColor colorWithRed:255/255.0 green:204/255.0 blue:0/255.0 alpha:0.5] timeRange:item.effect.atTimeRange.CMTimeRange atDuration:self.movieEditor.inputDuration];
    _trimmerView.selectedMarkIndex = -1;


    [self resetItemsTag];
    
}
/**
 移除一个图片贴纸项

 @param editor 编辑器
 @param item 贴纸项
 */
-(void)imageStickerEditor:(StickerEditor *)editor didRemoveItem:(UIView<StickerEditorItem> *)item;{
    if (!item.editable) return;

    _currentMvEffect = nil;
    // 移除颜色条
    [_trimmerView removeMarkAtIndex:item.tag];
    _trimmerView.trimmerMaskView.hidden = YES;
    
    [self resetItemsTag];
}

/**
 选中一个图片贴纸

 @param editor 编辑器
 @param item 贴纸项
 */
-(void)imageStickerEditor:(StickerEditor *)editor didSelectedItem:(UIView<StickerEditorItem> *)item;{
    TuSDKMediaStickerImageEffect *effect = item.effect;
    _currentMvEffect = item.effect;
    [_trimmerView setSelectedTimeRange:effect.atTimeRange.CMTimeRange atDuration:self.movieEditor.inputDuration];
    _trimmerView.selectedMarkIndex = item.tag;
}

/**
 图片贴纸视图被取消选中

 @param editor 编辑器
 @param item 贴纸项
 */
-(void)imageStickerEditor:(StickerEditor *)editor didCancelSelectedItem:(UIView<StickerEditorItem> *)item;{
    [_trimmerView setSelectedTimeRange:kCMTimeRangeZero atDuration:kCMTimeZero];
}

@end
