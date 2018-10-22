//
//  TuSDKMovieEditorBase.h
//  TuSDKVideo
//
//  Created by Yanlin Qiu on 19/12/2016.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import "TuSDKVideoImport.h"
#import "TuSDKVideoResult.h"
#import "TuSDKMovieEditorOptions.h"
#import "TuSDKMediaEffectData.h"
#import "TuSDKMovieEditorMode.h"
#import "TuSDKMovieEditorMediaEffectsSync.h"
#import "TuSDKMediaTimelineAssetMoviePlayer.h"
#import "TuSDKMediaMovieEditorExportSession.h"
#import "TuSDKMediaTimeEffect.h"
#import "TuSDKMediaSpeedTimeEffect.h"
#import "TuSDKMediaRepeatTimeEffect.h"
#import "TuSDKMediaReverseTimeEffect.h"


@protocol TuSDKMovieEditorLoadDelegate;
@protocol TuSDKMovieEditorSaveDelegate;
@protocol TuSDKMovieEditorPlayerDelegate;

/**
 *  视频编辑基类
 */
@interface TuSDKMovieEditorBase : NSObject
                                        <
                                            TuSDKMediaTimelineAssetMoviePlayerDelegate,
                                            TuSDKMovieEditorExportSessionDelegate,
                                            TuSDKMediaVideoRender
                                        >


/**
 *  初始化
 *
 *  @param holderView 预览容器
 *  @return 对象实例
 */
- (instancetype _Nonnull )initWithPreview:(UIView *_Nonnull)holderView options:(TuSDKMovieEditorOptions *_Nonnull)options;

/**
 *  输入视频源 URL > Asset
 */
@property (nonatomic,readonly) NSURL * _Nullable inputURL;

/**
 *  输入视频源 URL > Asset
 */
@property (nonatomic,readonly) AVAsset * _Nullable inputAsset;

/**
 获取视频信息，视频加载完成后可用
 @since      v3.0
 */
@property (nonatomic,readonly)TuSDKMediaAssetInfo * _Nullable inputAssetInfo;

/**
 应用特效后的输出总时长 单位：秒
 @since v3.0
 */
@property(nonatomic,readonly) float duration DEPRECATED_MSG_ATTRIBUTE("Please use timelineOutputDuraiton");

/**
 视频原始时长 (不包含时间特效） 单位：秒
 */
@property(nonatomic,readonly) float actualDuration DEPRECATED_MSG_ATTRIBUTE("Please use inputDuration");

/**
 媒体的真实时长
 @since      v3.0
 */
@property (nonatomic,readonly) CMTime inputDuration;

/**
 *  TuSDKMovieEditor 状态
 */
@property (assign,readonly) lsqMovieEditorStatus status;

/**
 *  是否正在切换滤镜
 */
@property (nonatomic, readonly) BOOL isFilterChanging;

/**
 *  裁剪范围 （开始时间~持续时间）
 */
@property (nonatomic,strong) TuSDKTimeRange * _Nullable cutTimeRange;

/**
 *  最小裁剪持续时间
 */
@property (nonatomic, assign) NSUInteger minCutDuration DEPRECATED_MSG_ATTRIBUTE("Please use options");

/**
 *  最大裁剪持续时间
 */
@property (nonatomic, assign) NSUInteger maxCutDuration DEPRECATED_MSG_ATTRIBUTE("Please use options");

/**
 *  保存到系统相册 (默认保存, 当设置为NO时, 保存到临时目录)
 */
@property (nonatomic) BOOL saveToAlbum DEPRECATED_MSG_ATTRIBUTE("Please use options");

/**
 *  保存到系统相册的相册名称
 */
@property (nonatomic, copy) NSString * _Nullable saveToAlbumName DEPRECATED_MSG_ATTRIBUTE("Please use options");

/**
 *  视频覆盖区域颜色 (默认：[UIColor blackColor])
 */
@property (nonatomic, retain) UIColor * _Nullable regionViewColor DEPRECATED_MSG_ATTRIBUTE("Please use options");

/**
 *  导出视频的文件格式（默认:lsqFileTypeMPEG4）
 */
@property (nonatomic, assign) lsqFileType fileType DEPRECATED_MSG_ATTRIBUTE("Please use options");

/**
 *  预览时视频原音音量， 默认 1.0  注：仅在 option 中的 enableSound 为 YES 时有效
 */
@property (nonatomic, assign) CGFloat videoSoundVolume ;

#pragma mark - waterMark

/**
 *  设置水印图片，最大边长不宜超过 500
 */
@property (nonatomic) UIImage * _Nullable waterMarkImage;

/**
 *  水印位置，默认 lsqWaterMarkBottomRight
 */
@property (nonatomic) lsqWaterMarkPosition waterMarkPosition;

#pragma mark - Load/Save

/**
 视频加载事件委托
 
 @since v3.0
 */
@property (nonatomic, weak) id <TuSDKMovieEditorLoadDelegate> _Nullable loadDelegate;

/**
 视频播放器事件委托
 
 @since v3.0
 */
@property (nonatomic, weak) id <TuSDKMovieEditorPlayerDelegate> _Nullable playerDelegate;

/**
 视频保存事件委托
 
 @since v3.0
 */
@property (nonatomic, weak) id <TuSDKMovieEditorSaveDelegate> _Nullable saveDelegate;

/**
 *  加载视频，显示第一帧
 */
- (void)loadVideo;

/**
 *  通知视频编辑器状态
 *
 *  @param status 状态信息
 */
- (void) notifyMovieEditorStatus:(lsqMovieEditorStatus) status;

/**
 更新预览View

 @param frame 设定的frame
 @since 2.2.0
 */
- (void) updatePreViewFrame:(CGRect)frame;

#pragma mark - destroy

/**
 *  销毁
 */
- (void)destroy;

@end


/** 播放控制 */
#pragma mark - MediaPlayControl
/**
 播放预览控制
 @since 3.0
 */
@interface TuSDKMovieEditorBase  (MediaPlayControl)

/**
 启动预览
 @since 1.0
 */
- (void)startPreview;

/**
 停止预览
 @since 1.0
 */
- (void)stopPreview;

/**
  停止并重新开始预览
  如果你需要 stopPreView 紧接着使用 startPreView 再次启动预览，你首选的方案应为 rePreview，rePreview会根据内部状态在合适的时间启动预览
  @since 1.0
 */
- (void)rePreview;

/**
  暂停预览
  @since 1.0
 */
- (void)pausePreView;

/**
  是否正在预览视频
  @return true/false
  @since 1.0
 */
- (BOOL)isPreviewing;

/**
 跳转至某一时间节点
 
 @param time 当前视频的时间节点(若以设置过裁剪时间段，该时间表示裁剪后时间表示)
 */
- (void)seekToPreviewWithTime:(CMTime)time DEPRECATED_MSG_ATTRIBUTE("Please call seekToTime:");

/**
 在指定的时间范围内设置当前回放时间。
 
 @param outputTime 输出时间
 @since v3.0
 */
- (void)seekToTime:(CMTime)outputTime;

@end


/**
 时间轴
 */
#pragma mark - Timeline

@interface TuSDKMovieEditorBase (Timeline)

/**
 应用特效后的输出总时长
 
 @since v3.0
 */
- (CMTime)timelineOutputDuraiton;

/**
 获取当前视频帧时间
 
 @return CMTime
 */
- (CMTime)getCurrentSampleTime DEPRECATED_MSG_ATTRIBUTE("Please call outputTimeAtTimeline:");

/**
 当前已经播放时长

 @return CMTime
 @since v3.0
 */
- (CMTime)outputTimeAtTimeline;

/**
 当前正在播放的切片时间
 
 @return CMTime
 @since v3.0
 */
- (CMTime)outputTimeAtSlice;


@end


/** 播放控制 */
#pragma mark - Recording
/**
 播放预览控制
 @since 3.0
 */
@interface TuSDKMovieEditorBase  (Recording)

/**
 *  开始录制视频 将被存储至文件
 */
- (void)startRecording;

/**
 *  取消录制
 */
- (void)cancelRecording;

/**
 *  是否正在录制视频
 *
 *  @return true/false
 */
- (Boolean)isRecording;

@end



#pragma mark -  MediaEffectManager

/**
 * 特效管理
 */
@interface TuSDKMovieEditorBase  (MediaEffectManager) <TuSDKMediaVideoEffectsSyncDelegate>

/**
 *  切换滤镜
 *
 *  @param code 滤镜代号
 *
 *  @return BOOL 是否成功切换滤镜
 */
- (BOOL)switchFilterWithCode:(NSString *_Nonnull)code DEPRECATED_MSG_ATTRIBUTE("Please call addMediaEffect:");

/**
 添加一个多媒体特效。该方法不会自动设置触发时间.
 
 @since      v2.0
 @param mediaEffect
 @discussion 如果已有特效和该特效不能同时共存，已有旧特效将被移除.
 */
- (BOOL)addMediaEffect:(TuSDKMediaEffectData *_Nonnull)mediaEffect;

/**
 移除特效数据
 
 @since      v2.1
 
 @param mediaEffect TuSDKMediaEffectData
 */
- (void)removeMediaEffect:(TuSDKMediaEffectData *_Nonnull)mediaEffect;

/**
 移除指定类型的特效信息
 
 @since      v2.1
 @param effectType 特效类型
 */
- (void)removeMediaEffectsWithType:(TuSDKMediaEffectDataType)effectType;

/**
 @since      v2.0
 @discussion 移除所有特效
 */
- (void)removeAllMediaEffect;

/**
 开始编辑并预览特效.
 
 @since      v2.1
 @param mediaEffect TuSDKMediaEffectData
 @discussion  当调用该方法时SDK内部将会设置特效开始时间为当前视频时间。
 */
- (void)applyMediaEffect:(TuSDKMediaEffectData *_Nonnull)mediaEffect;

/**
 停止编辑特效.
 
 @since      v2.1
 @param mediaEffect TuSDKMediaEffectData
 @discussion 当调用该方法时SDK内部将会设置特效结束时间为当前视频时间。
 */
- (void)unApplyMediaEffect:(TuSDKMediaEffectData *_Nonnull)mediaEffect;

/**
 获取指定类型的特效信息
 
 @since      v2.1
 @param effectType 特效数据类型
 @return 特效列表
 */
- (NSArray<TuSDKMediaEffectData *> *_Nonnull)mediaEffectsWithType:(TuSDKMediaEffectDataType)effectType;

@end

#pragma mark - 时间特效 > 反复/快慢速/倒序

@interface TuSDKMovieEditorBase (TimeEffect)

/**
 添加时间特效.
 目前所有时间特效均互斥同时只能添加一个

 @param timeEffect 时间特效
        TuSDKMediaSpeedTimeEffect / TuSDKMediaRepeatTimeEffect / TuSDKMediaReverseTimeEffect
 
 @since v3.0
 */
- (void)addMediaTimeEffect:(TuSDKMediaTimeEffect *)timeEffect;

/**
 清除所有时间特效
 
 @since v3.0
 */
- (void)removeAllMediaTimeEffect;

@end

#pragma mark - Particle Effect

@interface TuSDKMovieEditorBase (ParticleEffect)

/**
 更新粒子特效的发射器位置
 
 @param point 粒子发射器位置  左上角为(0,0)  右下角为(1,1)
 @since      v2.0
 */
- (void)updateParticleEmitPosition:(CGPoint)point;

/**
 更新 下一次添加的 粒子特效材质大小  0~1  注：对当前正在添加或已添加的粒子不生效
 
 @param size 粒子特效材质大小
 @since      v2.0
 */
- (void)updateParticleEmitSize:(CGFloat)size;

/**
 更新 下一次添加的 粒子特效颜色  注：对当前正在添加或已添加的粒子不生效
 
 @param color 粒子特效颜色
 @since      v2.0
 */
- (void)updateParticleEmitColor:(UIColor *_Nonnull)color;

@end



#pragma mark - TuSDKMovieEditorLoadDelegate 

/**
 视频加载加载时间回调
 @since v3.0
 */
@protocol TuSDKMovieEditorLoadDelegate <NSObject>
@required

/**
 加载进度改变事件
 
 @param editor TuSDKMovieEditor
 @param percentage 进度百分比 (0 - 1)
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor loadProgressChanged:(CGFloat)percentage;

/**
 加载状态回调
 
 @param editor TuSDKMovieEditor
 @param status 当前加载状态
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor loadStatusChanged:(lsqMovieEditorStatus)status;

/**
 视频加载完成
 
 @param editor TuSDKMovieEditor
 @param movieInfo 视频信息
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor assetInfoReady:(TuSDKMediaAssetInfo * _Nullable)assetInfo error:(NSError *_Nullable)error;

@end


#pragma mark - TuSDKMovieEditorPlayDelegate 视频播放进度回调

/**
 视频加载加载时间回调
 @since v3.0
 */
@protocol TuSDKMovieEditorPlayerDelegate <NSObject>
@required

/**
 播放进度改变事件
 
 @param editor MovieEditor
 @param percent (0 - 1)
 @param outputTime 导出文件后所在输出时间
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor progressChanged:(CGFloat)percent outputTime:(CMTime)outputTime;

/**
 播放进度改变事件
 
 @param editor MovieEditor
 @param status 当前播放状态
 
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor playerStatusChanged:(lsqMovieEditorStatus)status;

@end


#pragma mark - TuSDKMovieEditorSaveDelegate 视频保存进度回调

/**
 视频加载加载时间回调
 @since v3.0
 */
@protocol TuSDKMovieEditorSaveDelegate <NSObject>

@required

/**
 保存进度改变事件
 
 @param editor TuSDKMovieEditor
 @param percentage 进度百分比 (0 - 1)
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor saveProgressChanged:(CGFloat)percentage;

/**
 视频保存完成
 
 @param editor TuSDKMovieEditor
 @param result 保存结果
 @param error 错误信息
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor saveResult:(TuSDKVideoResult *_Nullable)result error:(NSError *_Nullable)error;

/**
 保存状态改变事件
 
 @param editor MovieEditor
 @param status 当前保存状态
 
 @since      v3.0
 */
- (void)mediaMovieEditor:(TuSDKMovieEditorBase *_Nonnull)editor saveStatusChanged:(lsqMovieEditorStatus)status;

@end
